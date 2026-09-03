import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';

class TrackListItem extends StatelessWidget {
  final TrackEntity track;
  final bool isPlayingCurrentTrack;
  final VoidCallback onTrackClick;
  final VoidCallback onToggleDownload;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onShare;

  const TrackListItem({
    super.key,
    required this.track,
    required this.isPlayingCurrentTrack,
    required this.onTrackClick,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onShare,
  });

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTrackClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isPlayingCurrentTrack 
              ? theme.colorScheme.primaryContainer.withOpacity(0.4)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlayingCurrentTrack 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.surfaceVariant,
              ),
              child: Icon(
                Icons.play_arrow,
                color: isPlayingCurrentTrack 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isPlayingCurrentTrack 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (track.rawangTitle.isNotEmpty)
                    Text(
                      track.rawangTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    "${track.artistName} • ${_formatDuration(track.durationSeconds)}",
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
            if (track.hasKaraoke)
              Container(
                margin: const EdgeInsets.only(left: 8, right: 2),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  "🎤 Karaoke",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                track.isDownloaded ? Icons.download_done : Icons.download,
                color: track.isDownloaded 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 20,
              ),
              onPressed: onToggleDownload,
            ),
            IconButton(
              icon: Icon(
                track.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: track.isFavorite 
                    ? theme.colorScheme.tertiary 
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 20,
              ),
              onPressed: onToggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}
