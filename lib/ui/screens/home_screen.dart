import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';
import 'package:rawang_melodies/ui/components/album_card.dart';
import 'package:rawang_melodies/ui/components/track_list_item.dart';

class HomeScreen extends StatelessWidget {
  final List<AlbumEntity> albums;
  final List<TrackEntity> tracks;
  final List<TrackEntity> popularTracks;
  final List<OwnerEntity> owners;
  final String? currentPlayingTrackId;
  final void Function(AlbumEntity) onSelectAlbum;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(TrackEntity) onAddToPlaylist;
  final void Function(TrackEntity) onShare;
  final VoidCallback onOpenAddSongDialog;
  final void Function(String) onFilterByOwner;
  final VoidCallback onSeeAllOwners;

  const HomeScreen({
    super.key,
    required this.albums,
    required this.tracks,
    required this.popularTracks,
    required this.owners,
    this.currentPlayingTrackId,
    required this.onSelectAlbum,
    required this.onPlayTrack,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onShare,
    required this.onOpenAddSongDialog,
    required this.onFilterByOwner,
    required this.onSeeAllOwners,
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
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        ColorizeAnimatedText(
                          "Preserving Our Ancestral Echoes",
                          speed: const Duration(milliseconds: 500),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [
                            theme.colorScheme.onSurface, // White
                            // theme.colorScheme.primary, // Green
                            const Color.fromARGB(204, 51, 170, 3),
                            Colors.tealAccent,
                            // theme.colorScheme.onSurface,
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 36, // Reserve space for 2 lines to prevent vertical jumping
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TyperAnimatedText(
                          "Stream, download offline, and discover traditional songs.",
                          speed: const Duration(milliseconds: 90),
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        TyperAnimatedText(
                          "Shvngbe sv̀ng Pàmvrà",
                          speed: const Duration(milliseconds: 90),
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        TyperAnimatedText(
                          "Mvkúnrì ayv́ng hapshì lúnshìe",
                          speed: const Duration(milliseconds: 90),
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 15,),

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
                  onTap: onSeeAllOwners,
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
          const SizedBox(height: 7      ),

          SizedBox(
            height: 120,
            child: owners.isEmpty
                ? const Center(child: Text('Loading owners...', style: TextStyle(fontSize: 12)))
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical:8
                    ),
                    clipBehavior: Clip.none,
                    children: _buildOwnerAvatars(context),
                  ),
          ),

          const SizedBox(height: 10),


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
            height: 250,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: albums.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final album = albums[index];
                final count = tracks.where((t) => t.albumId == album.id).length;
                return AlbumCard(
                  width: 160,
                  album: album,
                  trackCount: count,
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
              "Popular Songs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          popularTracks.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: popularTracks.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final track = popularTracks[index];
                    return TrackListItem(
                      track: track,
                      isPlayingCurrentTrack: track.id == currentPlayingTrackId,
                      onTrackClick: () => onPlayTrack(track, popularTracks),
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

  List<Widget> _buildOwnerAvatars(BuildContext context) {
    final theme = Theme.of(context);
    return owners.map((owner) {
      final avatarUrl = ApiService.resolveMediaUrl(owner.avatarUrl);
      final isSinger = owner.ownerType == OwnerType.singer.name;
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () => onFilterByOwner(owner.name),
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl.isEmpty
                        ? _buildInitials(theme, owner.name, isSinger)
                        : CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            memCacheWidth: 120,
                            placeholder: (context, url) => _buildLoadingCircle(theme),
                            errorWidget: (context, url, error) =>
                                _buildInitials(theme, owner.name, isSinger),
                            fadeInDuration: const Duration(milliseconds: 200),
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

  Widget _buildInitials(ThemeData theme, String name, bool isSinger) {
    final initials = name
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
          colors: isSinger
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
  }

  Widget _buildLoadingCircle(ThemeData theme) {
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
  }
}
