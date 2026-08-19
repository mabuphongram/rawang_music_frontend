import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';
import 'package:rawang_melodies/ui/components/album_card.dart';
import 'package:rawang_melodies/ui/components/track_list_item.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumEntity album;
  final List<TrackEntity> tracks;
  final String? currentPlayingTrackId;
  final VoidCallback onBack;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final VoidCallback onPlayAll;
  final VoidCallback onDownloadAlbum;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(TrackEntity) onAddToPlaylist;
  final void Function(TrackEntity) onShare;

  const AlbumDetailScreen({
    super.key,
    required this.album,
    required this.tracks,
    this.currentPlayingTrackId,
    required this.onBack,
    required this.onPlayTrack,
    required this.onPlayAll,
    required this.onDownloadAlbum,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
              // Text(
              //   "Rvwàng Zaywàrì V1.0.0",
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: theme.colorScheme.onBackground,
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(builder: (context) {
                    final imageUrl = ApiService.resolveMediaUrl(album.coverImage);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl.isEmpty
                          ? Container(
                              width: 110,
                              height: 110,
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: Icon(Icons.album, size: 40, color: Colors.white54),
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey.shade800,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey.shade800,
                                  child: const Center(
                                    child: Icon(Icons.album, size: 40, color: Colors.white54),
                                  ),
                                );
                              },
                            ),
                    );
                  }),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        Text(
                          album.ownerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          "${tracks.length} tracks",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                album.description,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPlayAll,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Play All"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDownloadAlbum,
                      icon: const Icon(Icons.download),
                      label: const Text("Download All"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Tracks in Album",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              ...tracks.map((track) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TrackListItem(
                      track: track,
                      isPlayingCurrentTrack: track.id == currentPlayingTrackId,
                      onTrackClick: () => onPlayTrack(track, tracks),
                      onToggleDownload: () => onToggleDownload(track),
                      onToggleFavorite: () => onToggleFavorite(track),
                      onAddToPlaylist: () => onAddToPlaylist(track),
                      onShare: () => onShare(track),
                    ),
                  )),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ],
    );
  }
}
