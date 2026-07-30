import 'package:flutter/material.dart';
import 'package:rawang_melodies/player/audio_player_engine.dart';
import 'package:rawang_melodies/ui/components/album_card.dart'; // For OwnerChip

class FullScreenPlayerModal extends StatefulWidget {
  final PlayerStateData playerState;
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

class _FullScreenPlayerModalState extends State<FullScreenPlayerModal> {
  int _selectedPlayerTab = 0; // 0: Cover/Art, 1: Lyrics

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.playerState.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
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
                    "RAWANG HERITAGE MUSIC",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    track.genre,
                    style: TextStyle(
                      fontSize: 12,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _selectedPlayerTab = 0),
                        style: TextButton.styleFrom(
                          foregroundColor: _selectedPlayerTab == 0 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                        child: const Text("Album Art"),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedPlayerTab = 1),
                        style: TextButton.styleFrom(
                          foregroundColor: _selectedPlayerTab == 1 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                        child: Text(widget.playerState.isKaraokeMode ? "🎤 Karaoke Lyrics" : "Rawang Lyrics"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPlayerTab == 0)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth * 0.85,
                          height: constraints.maxWidth * 0.85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: theme.colorScheme.surfaceVariant,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/img_rawang_hero_1785383680261.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: widget.playerState.isKaraokeMode 
                              ? Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: const EdgeInsets.all(12),
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
                                )
                              : null,
                        );
                      }
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.playerState.isKaraokeMode 
                            ? theme.colorScheme.tertiaryContainer.withOpacity(0.3)
                            : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.playerState.isKaraokeMode ? "🎤 SING-ALONG KARAOKE LYRICS" : "POETRY & LYRICS",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: widget.playerState.isKaraokeMode ? theme.colorScheme.tertiary : theme.colorScheme.primary,
                                  ),
                                ),
                                if (widget.playerState.isKaraokeMode)
                                  Text(
                                    "Vocals Muted",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.tertiary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              track.lyrics,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: widget.playerState.isKaraokeMode ? FontWeight.w600 : FontWeight.normal,
                                color: theme.colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 16),
                  OwnerChip(ownerTypeString: track.ownerType),
                  const SizedBox(height: 8),
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
                    "${track.artistName} • ${track.albumName}",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
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
