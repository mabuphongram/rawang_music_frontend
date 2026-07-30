import 'package:flutter/material.dart';
import 'package:rawang_melodies/player/audio_player_engine.dart';

class MiniPlayerBar extends StatelessWidget {
  final PlayerStateData playerState;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onNext;
  final VoidCallback onExpandPlayer;

  const MiniPlayerBar({
    super.key,
    required this.playerState,
    required this.onTogglePlayPause,
    required this.onNext,
    required this.onExpandPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final track = playerState.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final progress = playerState.durationSec > 0
        ? (playerState.currentPositionSec / playerState.durationSec).clamp(0.0, 1.0)
        : 0.0;
    
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onExpandPlayer,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/${track.albumId == "alb_1" || track.albumId == "alb_2" || track.albumId == "alb_3" || track.albumId == "alb_4" || track.albumId == "alb_5" || track.albumId == "alb_6" ? "img_rawang_hero_1785383680261" : "img_rawang_hero_1785383680261"}.jpg',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 44,
                            height: 44,
                            color: Colors.grey,
                            child: const Icon(Icons.album),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  track.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (playerState.isKaraokeMode) ...[
                                const SizedBox(width: 4),
                                const Text("🎤", style: TextStyle(fontSize: 12)),
                              ],
                            ],
                          ),
                          Text(
                            "${track.artistName} • ${track.albumName}",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      onPressed: onTogglePlayPause,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      onPressed: onNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
