import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rawang_melodies/player/audio_player_engine.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class _LyricLine {
  final Duration time;
  final String text;
  _LyricLine(this.time, this.text);
}

class FullScreenPlayerModal extends StatefulWidget {
  final PlayerStateData playerState;
  final String? albumCoverImage;
  final VoidCallback onDismiss;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final void Function(int) onSeekTo;
  final void Function(int) onSeekRelative;
  final VoidCallback onToggleLoop;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleDownload;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleKaraokeMode;
  final VoidCallback onShare;

  const FullScreenPlayerModal({
    super.key,
    required this.playerState,
    this.albumCoverImage,
    required this.onDismiss,
    required this.onTogglePlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onSeekTo,
    required this.onSeekRelative,
    required this.onToggleLoop,
    required this.onToggleShuffle,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onToggleKaraokeMode,
    required this.onShare,
  });

  @override
  State<FullScreenPlayerModal> createState() => _FullScreenPlayerModalState();
}

class _FullScreenPlayerModalState extends State<FullScreenPlayerModal> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    if (widget.playerState.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(FullScreenPlayerModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playerState.isPlaying && !oldWidget.playerState.isPlaying) {
      _rotationController.repeat();
    } else if (!widget.playerState.isPlaying && oldWidget.playerState.isPlaying) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  List<_LyricLine> _parseLyrics(String lyrics) {
    final lines = lyrics.split('\n');
    final result = <_LyricLine>[];
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('[')) {
        final endBracket = line.indexOf(']');
        if (endBracket != -1) {
          final timeStr = line.substring(1, endBracket);
          final text = line.substring(endBracket + 1).trim();
          
          final timeParts = timeStr.split(':');
          Duration time = Duration.zero;
          if (timeParts.length == 3) {
            time = Duration(
              hours: int.tryParse(timeParts[0]) ?? 0,
              minutes: int.tryParse(timeParts[1]) ?? 0,
              seconds: int.tryParse(timeParts[2]) ?? 0,
            );
          } else if (timeParts.length == 2) {
             final secParts = timeParts[1].split('.');
             if (secParts.length == 2) {
               time = Duration(
                 minutes: int.tryParse(timeParts[0]) ?? 0,
                 seconds: int.tryParse(secParts[0]) ?? 0,
                 milliseconds: (int.tryParse(secParts[1]) ?? 0) * 10,
               );
             } else {
               time = Duration(
                 minutes: int.tryParse(timeParts[0]) ?? 0,
                 seconds: int.tryParse(timeParts[1]) ?? 0,
               );
             }
          }
          if (text.isNotEmpty) {
            result.add(_LyricLine(time, text));
          }
        }
      }
    }
    return result;
  }

  Widget _buildLyricsQueue(ThemeData theme, List<_LyricLine> parsedLines, int currentPosMs) {
    if (parsedLines.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: Text(
          "Lyrics are not available for this song.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Find current line based on milliseconds
    int currentIndex = -1;
    for (int i = parsedLines.length - 1; i >= 0; i--) {
      if (currentPosMs >= parsedLines[i].time.inMilliseconds) {
        currentIndex = i;
        break;
      }
    }

    // Smooth continuous fraction progress between current line and next line
    double fractionalProgress = 0.0;
    if (currentIndex >= 0 && currentIndex < parsedLines.length - 1) {
      final currentLineTime = parsedLines[currentIndex].time.inMilliseconds;
      final nextLineTime = parsedLines[currentIndex + 1].time.inMilliseconds;
      final interval = nextLineTime - currentLineTime;
      if (interval > 0) {
        final elapsed = currentPosMs - currentLineTime;
        fractionalProgress = (elapsed / interval).clamp(0.0, 1.0);
      }
    } else if (currentIndex == -1 && parsedLines.isNotEmpty) {
      final firstLineTime = parsedLines[0].time.inMilliseconds;
      if (firstLineTime > 0) {
        fractionalProgress = (currentPosMs / firstLineTime).clamp(0.0, 1.0);
      }
    }

    // Continuous floating index
    final double continuousIndex = (currentIndex < 0 ? -1.0 : currentIndex.toDouble()) + fractionalProgress;
    const double lineHeight = 26.0;

    return Container(
      height: 78,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Render window of lines around the current position
          for (int i = 0; i < parsedLines.length; i++)
            _buildGradualLyricLine(
              theme: theme,
              lineIndex: i,
              text: parsedLines[i].text,
              continuousIndex: continuousIndex,
              lineHeight: lineHeight,
            ),
        ],
      ),
    );
  }

  Widget _buildGradualLyricLine({
    required ThemeData theme,
    required int lineIndex,
    required String text,
    required double continuousIndex,
    required double lineHeight,
  }) {
    // Relative distance: 0.0 means perfectly in center, -1.0 is one line above, +1.0 is one line below
    final double distance = lineIndex - continuousIndex;

    // Only render lines in view (-1.8 to 1.8)
    if (distance < -1.8 || distance > 1.8) {
      return const SizedBox.shrink();
    }

    // Vertical Y offset moving gradually upwards
    final double yOffset = distance * lineHeight;

    // Gradual smooth opacity: 1.0 at center, fades smoothly to ~0.35 as it moves away
    final double normalizedDist = distance.abs();
    final double opacity = (1.0 - (normalizedDist * 0.45)).clamp(0.25, 1.0);

    // Uniform font size and normal weight for all lines
    const double fontSize = 14.0;
    const FontWeight fontWeight = FontWeight.normal;

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: theme.colorScheme.primary, // Yellow / Theme Primary color for all lines
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.playerState.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final parsedLyrics = _parseLyrics(track.lyrics);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: widget.onDismiss,
              ),
              Column(
                children: [
                  Text(
                    "PLAYING NOW",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    track.albumName,
                    style: TextStyle(
                      fontSize: 10.7,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: widget.onShare,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.playerState.isKaraokeMode)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: theme.colorScheme.onTertiaryContainer, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "KARAOKE MODE: Instrumental Backing Active",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final imageUrl = widget.albumCoverImage != null && widget.albumCoverImage!.isNotEmpty
                          ? ApiService.resolveMediaUrl(widget.albumCoverImage!)
                          : '';
                          
                      ImageProvider decorationImageProvider;
                      if (imageUrl.isNotEmpty) {
                        decorationImageProvider = CachedNetworkImageProvider(imageUrl);
                      } else {
                        decorationImageProvider = const AssetImage('assets/images/img_rawang_hero_1785383680261.jpg');
                      }
                      
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: _rotationController,
                            child: Container(
                              width: constraints.maxWidth * 0.70,
                              height: constraints.maxWidth * 0.70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.grey[850]!,
                                    Colors.black,
                                    Colors.black,
                                  ],
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Vinyl Grooves
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                                    ),
                                    margin: const EdgeInsets.all(12),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                                    ),
                                    margin: const EdgeInsets.all(28),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                                    ),
                                    margin: const EdgeInsets.all(44),
                                  ),
                                  // Center Album Art Label - cached via CachedNetworkImageProvider
                                  Container(
                                    width: constraints.maxWidth * 0.28,
                                    height: constraints.maxWidth * 0.28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: decorationImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(color: Colors.black, width: 4),
                                    ),
                                  ),
                                  // Vinyl Center Hole
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.surface,
                                      border: Border.all(color: Colors.grey[800]!, width: 1),
                                    ),
                                  ),
                                  // Glossy overlay for realism
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(0.15),
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(0.15),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.playerState.isKaraokeMode)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "🎤 SING-ALONG",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onTertiary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  ),
                    
                  const SizedBox(height: 24),
                  
                  // Title and Artist
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (track.rawangTitle.isNotEmpty)
                    Text(
                      track.rawangTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  Text(
                    "Yo - ${track.artistName}",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lyrics Queue
                  _buildLyricsQueue(theme, parsedLyrics, widget.playerState.currentPositionMs),
                  
                  const SizedBox(height: 16),
                  
                  // Karaoke Button
                  ElevatedButton.icon(
                    onPressed: widget.onToggleKaraokeMode,
                    icon: Icon(widget.playerState.isKaraokeMode ? Icons.mic : Icons.mic_off, size: 18),
                    label: Text(
                      widget.playerState.isKaraokeMode 
                          ? "Karaoke Mode: ON (Instrumental)" 
                          : (track.hasKaraoke ? "Switch to Karaoke Version 🎤" : "Toggle Vocal Remover / Karaoke"),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.playerState.isKaraokeMode ? theme.colorScheme.tertiary : theme.colorScheme.surfaceVariant,
                      foregroundColor: widget.playerState.isKaraokeMode ? theme.colorScheme.onTertiary : theme.colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: theme.colorScheme.primary,
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: theme.colorScheme.surfaceVariant,
                    ),
                    child: Slider(
                      value: widget.playerState.currentPositionSec.toDouble(),
                      min: 0,
                      max: widget.playerState.durationSec > 0 ? widget.playerState.durationSec.toDouble() : 1,
                      onChanged: (val) => widget.onSeekTo(val.toInt()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(widget.playerState.currentPositionSec),
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        _formatDuration(widget.playerState.durationSec),
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shuffle),
                        color: widget.playerState.isShuffle ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        onPressed: widget.onToggleShuffle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 32),
                        color: theme.colorScheme.onSurface,
                        onPressed: widget.onPrevious,
                      ),
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        color: theme.colorScheme.onSurfaceVariant,
                        onPressed: () => widget.onSeekRelative(-10),
                      ),
                      GestureDetector(
                        onTap: widget.onTogglePlayPause,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: Icon(
                            widget.playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 36,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        color: theme.colorScheme.onSurfaceVariant,
                        onPressed: () => widget.onSeekRelative(10),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 32),
                        color: theme.colorScheme.onSurface,
                        onPressed: widget.onNext,
                      ),
                      IconButton(
                        icon: Icon(widget.playerState.isLooping ? Icons.repeat_one : Icons.repeat),
                        color: widget.playerState.isLooping ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        onPressed: widget.onToggleLoop,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.onToggleFavorite,
                        icon: Icon(
                          track.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: track.isFavorite ? theme.colorScheme.tertiary : theme.colorScheme.onPrimary,
                        ),
                        label: Text(track.isFavorite ? "Favorited" : "Favorite"),
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.onToggleDownload,
                        icon: Icon(track.isDownloaded ? Icons.download_done : Icons.download),
                        label: Text(track.isDownloaded ? "Downloaded Offline" : "Download Offline"),
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
