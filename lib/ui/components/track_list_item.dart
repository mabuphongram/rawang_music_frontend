import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class TrackListItem extends StatelessWidget {
  final TrackEntity track;
  final bool isPlayingCurrentTrack;
  final VoidCallback onTrackClick;
  final VoidCallback onToggleDownload;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onShare;
  final String? albumCoverImage;
  /// When false, the cover circle shows no play icon / playing indicator.
  final bool showPlayOverlay;

  const TrackListItem({
    super.key,
    required this.track,
    required this.isPlayingCurrentTrack,
    required this.onTrackClick,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onShare,
    this.albumCoverImage,
    this.showPlayOverlay = true,
  });

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = albumCoverImage != null && albumCoverImage!.isNotEmpty
        ? ApiService.resolveMediaUrl(albumCoverImage!)
        : '';
    
    return GestureDetector(
      onTap: onTrackClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPlayingCurrentTrack 
              ? theme.colorScheme.primaryContainer.withOpacity(0.4)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceVariant,
                    image: coverUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(coverUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                if (showPlayOverlay) ...[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(
                          isPlayingCurrentTrack ? 0.55 : 0.35),
                    ),
                  ),
                  if (isPlayingCurrentTrack)
                    const _PlayingBars(color: Colors.white)
                  else
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                ] else if (isPlayingCurrentTrack)
                  const _PlayingBars(color: Colors.white),
              ],
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${track.artistName} • ${_formatDuration(track.durationSeconds)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (track.lyrics.trim().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lyrics_outlined,
                                size: 9,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "Lyrics",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (track.hasKaraoke)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
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
                    ],
                  ),
                ],
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

/// Animated equalizer bars shown in the cover circle of the track
/// that is currently playing.
class _PlayingBars extends StatefulWidget {
  final Color color;
  const _PlayingBars({required this.color});

  @override
  State<_PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<_PlayingBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(_controller.value),
            const SizedBox(width: 2.5),
            _bar(1.0 - _controller.value),
            const SizedBox(width: 2.5),
            _bar((_controller.value + 0.5) % 1.0),
          ],
        );
      },
    );
  }

  Widget _bar(double t) {
    return Container(
      width: 3,
      height: 5 + t * 11,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
