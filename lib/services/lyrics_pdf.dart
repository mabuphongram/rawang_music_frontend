import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';

/// Exports a track's lyrics as a printable PDF lyric sheet and opens the
/// system share sheet (save / print / send).
///
/// Rawang has no precomposed codepoints for v̀ v́ ø̀ (confirmed with the
/// Keyman Rawang keyboard authors) — they are base letter + combining mark
/// (U+0300/U+0301). The bundled Padauk font lacks those mark glyphs, so text
/// is segmented per run: Padauk for everything it covers (Latin, Myanmar),
/// DejaVu Sans for the gaps (combining marks, ǿ Ǿ ċ ē ō). A base letter
/// followed by a combining mark is kept in the same DejaVu run so the accent
/// stacks correctly over it.
class LyricsPdf {
  static pw.Font? _padaukReg;
  static pw.Font? _padaukBold;
  static pw.Font? _dejavuReg;
  static pw.Font? _dejavuBold;

  /// Pre-loads the fonts (call when the player opens so the first
  /// export tap doesn't pay the loading cost).
  static Future<void> warmup() => _loadFonts();

  static Future<void> _loadFonts() async {
    if (_padaukReg != null) return;
    Future<pw.Font> load(String asset) async {
      final b = await rootBundle.load(asset);
      return pw.Font.ttf(b);
    }

    _padaukReg = await load('assets/fonts/Padauk-Regular.ttf');
    _padaukBold = await load('assets/fonts/Padauk-Bold.ttf');
    _dejavuReg = await load('assets/fonts/DejaVuSans.ttf');
    _dejavuBold = await load('assets/fonts/DejaVuSans-Bold.ttf');
  }

  /// Codepoints Padauk lacks (verified against its cmap). Everything else
  /// in our corpus renders through Padauk.
  static const _dejavuCodepoints = {
    0x0300, // combining grave  (v̀ ø̀)
    0x0301, // combining acute  (v́)
    0x010B, // ċ
    0x0113, // ē
    0x014D, // ō
    0x01FE, // Ǿ (in case data ever stores it precomposed)
    0x01FF, // ǿ (in case data ever stores it precomposed)
  };

  /// DejaVu's x-height is ~25% taller than Padauk's at the same point
  /// size (measured 0.547 vs 0.435 em). Scale DejaVu down so mixed lines
  /// look uniform (verified with side-by-side render tests).
  static const _dejavuSizeFactor = 0.8;

  static const _combiningMarks = {0x0300, 0x0301};

  /// A text block uses ONE font only: DejaVu if it holds any gap char,
  /// else Padauk. (The pdf package corrupts glyphs when a marked run is
  /// split across two fonts in one RichText — verified with render tests.)
  /// The whole catalog separates cleanly this way (no line mixes Myanmar
  /// script with gap chars); mixed lines fall back to _spans below.
  static bool _needsDejavu(String text) {
    for (final r in text.runes) {
      if (_dejavuCodepoints.contains(r)) return true;
    }
    return false;
  }

  static bool _hasMyanmar(String text) {
    for (final r in text.runes) {
      if (r >= 0x1000 && r <= 0x109F) return true;
    }
    return false;
  }

  /// Splits [text] into font runs. A base letter immediately followed by a
  /// combining mark stays in the same (DejaVu) run so the accent stacks.
  static List<pw.TextSpan> _spans(String text, double size,
      {bool bold = false, PdfColor? color, double? lineSpacing}) {
    final padauk = bold ? _padaukBold! : _padaukReg!;
    final dejavu = bold ? _dejavuBold! : _dejavuReg!;
    final runes = text.runes.toList();
    final useDejavu = List<bool>.filled(runes.length, false);
    for (var i = 0; i < runes.length; i++) {
      if (_dejavuCodepoints.contains(runes[i])) {
        useDejavu[i] = true;
        // Pull a preceding base letter into the same run for stacking.
        if (i > 0 && _combiningMarks.contains(runes[i]) && !useDejavu[i - 1]) {
          useDejavu[i - 1] = true;
        }
      }
    }
    final out = <pw.TextSpan>[];
    final buf = StringBuffer();
    bool? cur;
    void flush() {
      if (buf.isEmpty) return;
      out.add(pw.TextSpan(
        text: buf.toString(),
        style: pw.TextStyle(
          font: cur! ? dejavu : padauk,
          fontSize: cur! ? size * _dejavuSizeFactor : size,
          color: color,
          lineSpacing: lineSpacing,
        ),
      ));
      buf.clear();
    }

    for (var i = 0; i < runes.length; i++) {
      cur ??= useDejavu[i];
      if (useDejavu[i] != cur) {
        flush();
        cur = useDejavu[i];
      }
      buf.writeCharCode(runes[i]);
    }
    flush();
    return out;
  }

  static pw.Widget _rich(String text, double size,
      {bool bold = false, PdfColor? color, double? lineSpacing}) {
    final dejavu = _needsDejavu(text);
    if (dejavu && _hasMyanmar(text)) {
      // Hypothetical mixed line — best-effort segmented run.
      return pw.RichText(
        text: pw.TextSpan(
          children: _spans(text, size,
              bold: bold, color: color, lineSpacing: lineSpacing),
        ),
      );
    }
    final font = bold
        ? (dejavu ? _dejavuBold! : _padaukBold!)
        : (dejavu ? _dejavuReg! : _padaukReg!);
    final effectiveSize = dejavu ? size * _dejavuSizeFactor : size;
    return pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontSize: effectiveSize,
        color: color,
        lineSpacing: lineSpacing,
      ),
    );
  }

  /// Strips LRC timestamps ("[01:23.45] line") and blank lines.
  static List<String> cleanLines(String lyrics) {
    final out = <String>[];
    for (var line in lyrics.split('\n')) {
      line = line.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('[')) {
        final end = line.indexOf(']');
        if (end != -1) line = line.substring(end + 1).trim();
      }
      if (line.isNotEmpty) out.add(line);
    }
    return out;
  }

  static Future<void> exportTrack(TrackEntity track) async {
    final lines = cleanLines(track.lyrics);
    if (lines.isEmpty) throw Exception('No lyrics to export');
    await _loadFonts();

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        header: (ctx) => ctx.pageNumber == 1
            ? pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _rich(track.title, 22, bold: true),
                  pw.SizedBox(height: 4),
                  _rich('${track.artistName} • ${track.albumName}', 12,
                      color: PdfColors.grey700),
                  if (track.rawangTitle.isNotEmpty)
                    _rich(track.rawangTitle, 12, color: PdfColors.grey700),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 12),
                ],
              )
            : pw.SizedBox(),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Rawang Melodies • heritage preservation',
              style: pw.TextStyle(font: _padaukReg, fontSize: 9, color: PdfColors.grey600),
            ),
            pw.Text(
              '${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(font: _padaukReg, fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
        build: (ctx) => lines
            .map((l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: _rich(l, 12, lineSpacing: 4),
                ))
            .toList(),
      ),
    );

    final safeTitle = track.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: '$safeTitle - lyrics.pdf',
    );
  }
}
