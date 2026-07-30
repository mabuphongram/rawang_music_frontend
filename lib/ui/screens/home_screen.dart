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
                  color: Colors.black.withValues(alpha: 0.2),
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
                    theme.colorScheme.surface.withValues(alpha: 0.9),
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
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "Stream, download offline, and discover traditional songs.",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),


          // Browse by Owner – avatar row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Browse by Owner",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => onFilterByOwner(OwnerType.singer.name),
                  child: Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _buildOwnerAvatars(context, albums),
            ),
          ),

          const SizedBox(height: 20),


          // Featured Albums Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured Albums",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
          SizedBox(
            height: 230,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: albums.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
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
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: tracks.take(6).length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
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

  List<Widget> _buildOwnerAvatars(BuildContext context, List<AlbumEntity> albums) {
    final theme = Theme.of(context);

    // Hardcoded dummy avatars (7 singers, 3 organizations)
    final owners = <_OwnerInfo>[
      _OwnerInfo(name: "Ah Dang Rawang", type: OwnerType.singer.name, filterKey: OwnerType.singer.name, imageUrl: "https://randomuser.me/api/portraits/men/32.jpg"),
      _OwnerInfo(name: "Seng Rawang", type: OwnerType.singer.name, filterKey: OwnerType.singer.name, imageUrl: "https://randomuser.me/api/portraits/women/44.jpg"),
      _OwnerInfo(name: "John Singer", type: OwnerType.singer.name, filterKey: OwnerType.singer.name, imageUrl: "https://randomuser.me/api/portraits/men/68.jpg"),
      _OwnerInfo(name: "Maria Artist", type: OwnerType.singer.name, filterKey: OwnerType.singer.name, imageUrl: "https://randomuser.me/api/portraits/women/65.jpg"),
      _OwnerInfo(name: "David Vocals", type: OwnerType.singer.name, filterKey: OwnerType.singer.name, imageUrl: "https://randomuser.me/api/portraits/men/22.jpg"),
      _OwnerInfo(name: "Sarah Melody", type: OwnerType.singer.name, filterKey: OwnerType.singer.name, imageUrl: "https://randomuser.me/api/portraits/women/11.jpg"),
      _OwnerInfo(name: "Peter Tune", type: OwnerType.singer.name, filterKey: OwnerType.singer.name, imageUrl: "https://randomuser.me/api/portraits/men/90.jpg"),
      
      _OwnerInfo(name: "Rawang Literature & Culture", type: OwnerType.organization.name, filterKey: OwnerType.organization.name, imageUrl: "https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=150&h=150&fit=crop"),
      _OwnerInfo(name: "Rawang Youth Heritage", type: OwnerType.organization.name, filterKey: OwnerType.organization.name, imageUrl: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=150&h=150&fit=crop"),
      _OwnerInfo(name: "Traditional Arts Org", type: OwnerType.organization.name, filterKey: OwnerType.organization.name, imageUrl: "https://images.unsplash.com/photo-1497366216548-37526070297c?w=150&h=150&fit=crop"),
    ];

    return owners.map((owner) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () => onFilterByOwner(owner.filterKey),
          child: SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      owner.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.3),
                                theme.colorScheme.secondary.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) {
                        final initials = owner.name
                            .trim()
                            .split(' ')
                            .take(2)
                            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                            .join();
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: owner.type == OwnerType.singer.name
                                  ? [theme.colorScheme.primary, theme.colorScheme.tertiary]
                                  : [theme.colorScheme.secondary, theme.colorScheme.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  owner.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _OwnerInfo {
  final String name;
  final String type;
  final String filterKey;
  final String imageUrl;
  const _OwnerInfo({required this.name, required this.type, required this.filterKey, required this.imageUrl});
}
