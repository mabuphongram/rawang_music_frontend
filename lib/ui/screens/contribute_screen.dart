import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';
import 'package:rawang_melodies/viewmodels/auth_view_model.dart';

/// Community song submission. Uploads MP3 audio (max 15 MB) + optional
/// karaoke MP3 to the pending-review queue. Login is required — the
/// contributor name comes from the logged-in account, never typed input.
class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _composerCtrl = TextEditingController();

  int _hours = 0;
  int _minutes = 3;
  int _seconds = 0;

  PlatformFile? _audio;
  PlatformFile? _karaoke;
  String? _fileError;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _composerCtrl.dispose();
    super.dispose();
  }

  int get _durationSeconds => _hours * 3600 + _minutes * 60 + _seconds;

  String _formatBytes(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  String _describeFile(PlatformFile file) {
    final size = file.lengthSync();
    return size == null ? file.name : '${file.name} (${_formatBytes(size)})';
  }

  Future<void> _pickFile({required bool karaoke}) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    if ((file.extension ?? '').toLowerCase() != 'mp3') {
      setState(() => _fileError = 'Only MP3 files are accepted.');
      return;
    }
    final size = file.lengthSync() ?? await file.length();
    if (size > ApiService.maxContributionFileBytes) {
      setState(() => _fileError =
          'File too large (${_formatBytes(size)}). Max is 15 MB.');
      return;
    }
    if (file.path == null) {
      setState(() => _fileError = 'Could not read the selected file.');
      return;
    }
    setState(() {
      _fileError = null;
      if (karaoke) {
        _karaoke = file;
      } else {
        _audio = file;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audio?.path == null) {
      setState(() => _fileError = 'Please attach your song MP3 file.');
      return;
    }
    if (_durationSeconds <= 0) {
      setState(() => _fileError = 'Please set the song duration.');
      return;
    }
    setState(() {
      _submitting = true;
      _fileError = null;
    });
    try {
      await ApiService.submitContribution(
        title: _titleCtrl.text.trim(),
        artistName: _artistCtrl.text.trim(),
        composerName: _composerCtrl.text.trim(),
        durationSeconds: _durationSeconds,
        audioPath: _audio!.path!,
        karaokePath: _karaoke?.path,
      );
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Contribute Song')),
      body: user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Please log in first.\nContributions are attributed to your account.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            )
          : _submitted
              ? _buildSuccess(theme, user.name)
              : _buildForm(theme, user.name),
    );
  }

  Widget _buildSuccess(ThemeData theme, String contributorName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            const Text(
              'Sent for review!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Thanks $contributorName. An admin will preview your song and add it to the catalogue if approved.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, String contributorName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Song Title *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _artistCtrl,
              decoration: const InputDecoration(labelText: 'Singer / Artist Name *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _composerCtrl,
              decoration: const InputDecoration(labelText: 'Composer Name (optional)'),
            ),
            const SizedBox(height: 16),
            const Text('Duration (HH : MM : SS) *', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _durationDropdown('HH', _hours, 0, 5, (v) => setState(() => _hours = v))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: _durationDropdown('MM', _minutes, 0, 59, (v) => setState(() => _minutes = v))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: _durationDropdown('SS', _seconds, 0, 59, (v) => setState(() => _seconds = v))),
              ],
            ),
            const SizedBox(height: 16),
            _fileTile(
              label: 'Song MP3 * (max 15 MB)',
              file: _audio,
              onPick: () => _pickFile(karaoke: false),
              onClear: () => setState(() => _audio = null),
            ),
            const SizedBox(height: 8),
            _fileTile(
              label: 'Karaoke MP3 (optional, max 15 MB)',
              file: _karaoke,
              onPick: () => _pickFile(karaoke: true),
              onClear: () => setState(() => _karaoke = null),
            ),
            if (_fileError != null) ...[
              const SizedBox(height: 8),
              Text(_fileError!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 6),
                Text('Uploading as $contributorName',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload),
                label: Text(_submitting ? 'Uploading...' : 'Submit for Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationDropdown(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [for (var i = min; i <= max; i++) DropdownMenuItem(value: i, child: Text(i.toString().padLeft(2, '0')))],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _fileTile({
    required String label,
    required PlatformFile? file,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 13)),
        subtitle: file == null
            ? const Text('No file chosen')
            : Text(_describeFile(file)),
        trailing: file == null
            ? IconButton(icon: const Icon(Icons.attach_file), onPressed: onPick)
            : IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
        onTap: onPick,
      ),
    );
  }
}
