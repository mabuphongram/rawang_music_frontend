import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/ui/components/album_card.dart';
import 'package:rawang_melodies/ui/components/track_list_item.dart';

class HomeScreen extends StatelessWidget {
  final List<AlbumEntity> albums;
  final List<TrackEntity> tracks;
  final String? currentPlayingTrackId;
  final void Function(AlbumEntity) onSelectAlbum;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(TrackEntity) onAddToPlaylist;
  final void Function(TrackEntity) onShare;
  final VoidCallback onOpenAddSongDialog;
  final void Function(String) onFilterByOwner;

  const HomeScreen({
    super.key,
    required this.albums,
    required this.tracks,
    this.currentPlayingTrackId,
    required this.onSelectAlbum,
    required this.onPlayTrack,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onShare,
    required this.onOpenAddSongDialog,
    required this.onFilterByOwner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Cultural Banner
          Container(
            margin: const EdgeInsets.all(16),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/img_rawang_hero_1785383680261.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.background.withOpacity(0.9),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    "Preserving Our Ancestral Echoes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    "Stream, download offline, and discover traditional songs.",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Owner Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explore Collections",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onOpenAddSongDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Contribute Song", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(context, "All Albums", "ALL", true, null),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Singers", OwnerType.singer.name, false, Icons.mic),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Organizations", OwnerType.organization.name, false, Icons.corporate_fare),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Title Collections", OwnerType.anonymous.name, false, Icons.music_note),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Featured Albums Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Featured Albums",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 230,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: albums.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final album = albums[index];
                return AlbumCard(
                  width: 160,
                  album: album,
                  onClick: () => onSelectAlbum(album),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),

          // Featured Rawang Traditional Songs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Popular Traditional Songs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: tracks.take(6).length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return TrackListItem(
                track: track,
                isPlayingCurrentTrack: track.id == currentPlayingTrackId,
                onTrackClick: () => onPlayTrack(track, tracks),
                onToggleDownload: () => onToggleDownload(track),
                onToggleFavorite: () => onToggleFavorite(track),
                onAddToPlaylist: () => onAddToPlaylist(track),
                onShare: () => onShare(track),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String filter, bool selected, IconData? icon) {
    return ChoiceChip(
      label: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) {
        onFilterByOwner(filter);
      },
    );
  }
}
