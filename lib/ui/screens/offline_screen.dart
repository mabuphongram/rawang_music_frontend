import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/ui/components/track_list_item.dart';

class OfflineScreen extends StatelessWidget {
  final List<TrackEntity> downloadedTracks;
  final List<TrackEntity> favoriteTracks;
  final String? currentPlayingTrackId;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(TrackEntity) onShare;

  const OfflineScreen({
    super.key,
    required this.downloadedTracks,
    required this.favoriteTracks,
    this.currentPlayingTrackId,
    required this.onPlayTrack,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
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
                    child: Icon(Icons.offline_pin, color: theme.colorScheme.onPrimary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Offline & Favorites", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                        Text("Favorites & downloads - ready without coverage.", style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8))),
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
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(14)),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: [
                  Tab(text: 'Favorites  ${favoriteTracks.length}'),
                  Tab(text: 'Downloaded  ${downloadedTracks.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _TrackTab(
                  tracks: favoriteTracks,
                  emptyIcon: Icons.favorite_border,
                  emptyTitle: 'No favorites yet.',
                  emptySubtitle: 'Tap heart icon on any song to add.',
                  currentPlayingTrackId: currentPlayingTrackId,
                  onPlayTrack: onPlayTrack,
                  onToggleDownload: onToggleDownload,
                  onToggleFavorite: onToggleFavorite,
                  onShare: onShare,
                  isFavoriteTab: true,
                ),
                _TrackTab(
                  tracks: downloadedTracks,
                  emptyIcon: Icons.download_done,
                  emptyTitle: 'No downloaded tracks yet.',
                  emptySubtitle: 'Tap download icon on any Rawang song to store offline.',
                  currentPlayingTrackId: currentPlayingTrackId,
                  onPlayTrack: onPlayTrack,
                  onToggleDownload: onToggleDownload,
                  onToggleFavorite: onToggleFavorite,
                  onShare: onShare,
                  isFavoriteTab: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackTab extends StatelessWidget {
  final List<TrackEntity> tracks;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final String? currentPlayingTrackId;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(TrackEntity) onShare;
  final bool isFavoriteTab;

  const _TrackTab({
    required this.tracks,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.currentPlayingTrackId,
    required this.onPlayTrack,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onShare,
    required this.isFavoriteTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Icon(emptyIcon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(emptyTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            Text(emptySubtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (tracks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isFavoriteTab ? 'Favorited (${tracks.length})' : 'Downloaded (${tracks.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
                ElevatedButton.icon(
                  onPressed: () => onPlayTrack(tracks.first, tracks),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: Text(isFavoriteTab ? 'Play Favorites' : 'Play Offline', style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 90),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TrackListItem(
                  track: track,
                  isPlayingCurrentTrack: track.id == currentPlayingTrackId,
                  onTrackClick: () => onPlayTrack(track, tracks),
                  onToggleDownload: () => onToggleDownload(track),
                  onToggleFavorite: () => onToggleFavorite(track),
                  onAddToPlaylist: () {}, // playlists discarded
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
