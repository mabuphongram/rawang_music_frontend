import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/ui/components/track_list_item.dart';

class OfflineScreen extends StatelessWidget {
  final List<TrackEntity> downloadedTracks;
  final String? currentPlayingTrackId;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(TrackEntity) onAddToPlaylist;
  final void Function(TrackEntity) onShare;

  const OfflineScreen({
    super.key,
    required this.downloadedTracks,
    this.currentPlayingTrackId,
    required this.onPlayTrack,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.offline_pin,
                    color: theme.colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Offline Mode Active",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        "Ready for listening in remote valleys without cell coverage.",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Downloaded Music (${downloadedTracks.length})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              if (downloadedTracks.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => onPlayTrack(downloadedTracks.first, downloadedTracks),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text("Play Offline", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: downloadedTracks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.download_done,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No downloaded tracks yet.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        "Tap the download icon on any Rawang song to store it offline.",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 90),
                  itemCount: downloadedTracks.length,
                  itemBuilder: (context, index) {
                    final track = downloadedTracks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TrackListItem(
                        track: track,
                        isPlayingCurrentTrack: track.id == currentPlayingTrackId,
                        onTrackClick: () => onPlayTrack(track, downloadedTracks),
                        onToggleDownload: () => onToggleDownload(track),
                        onToggleFavorite: () => onToggleFavorite(track),
                        onAddToPlaylist: () => onAddToPlaylist(track),
                        onShare: () => onShare(track),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
