import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';
import 'package:rawang_melodies/ui/components/album_card.dart';
import 'package:rawang_melodies/ui/components/track_list_item.dart';

class HomeScreen extends StatefulWidget {
  final List<AlbumEntity> albums;
  final List<TrackEntity> tracks;
  final List<TrackEntity> popularTracks;
  final List<OwnerEntity> owners;
  final List<HeroSlideEntity> heroSlides;
  final String? currentPlayingTrackId;
  final void Function(AlbumEntity) onSelectAlbum;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(TrackEntity) onAddToPlaylist;
  final void Function(TrackEntity) onShare;
  final int onlineCount;
  final VoidCallback onOpenAddSongDialog;
  final void Function(String) onFilterByOwner;
  final VoidCallback onSeeAllOwners;

  const HomeScreen({
    super.key,
    required this.albums,
    required this.tracks,
    required this.popularTracks,
    required this.owners,
    required this.heroSlides,
    this.currentPlayingTrackId,
    required this.onSelectAlbum,
    required this.onPlayTrack,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onShare,
    required this.onlineCount,
    required this.onOpenAddSongDialog,
    required this.onFilterByOwner,
    required this.onSeeAllOwners,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // ── Hero carousel ──────────────────────────────────────────────────
  late final PageController _pageController;
  Timer? _autoplayTimer;
  int _currentSlide = 0;

  /// Slides to show: admin content when synced, bundled fallback otherwise.
  List<HeroSlideEntity> get _effectiveSlides => widget.heroSlides.isNotEmpty
      ? widget.heroSlides
      : [
          HeroSlideEntity(
            id: 'fallback',
            eyebrow: 'RAWANG HERITAGE MUSIC',
            title: 'Preserving Our Ancestral Echoes',
            subtitle: 'Stream, download offline, and discover traditional songs.',
            durationSeconds: 7,
          ),
        ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pageController = PageController();
    _scheduleAutoplay();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heroSlides != oldWidget.heroSlides) {
      _currentSlide = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _scheduleAutoplay();
    }
  }

  void _scheduleAutoplay() {
    _autoplayTimer?.cancel();
    final slides = _effectiveSlides;
    if (slides.length < 2) return;
    final seconds = slides[_currentSlide.clamp(0, slides.length - 1)].durationSeconds.clamp(3, 60);
    _autoplayTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentSlide + 1) % slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Carousel (16:9, admin-driven with bundled fallback)
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _effectiveSlides.length,
                      onPageChanged: (index) {
                        setState(() => _currentSlide = index);
                        _scheduleAutoplay();
                      },
                      itemBuilder: (context, index) {
                        final slide = _effectiveSlides[index];
                        final imageUrl = ApiService.resolveMediaUrl(slide.imageUrl);
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl.isEmpty
                                ? Image.asset(
                                    'assets/images/img_rawang_hero_1785383680261.jpg',
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: theme.colorScheme.surface,
                                    ),
                                    errorWidget: (context, url, error) => Image.asset(
                                      'assets/images/img_rawang_hero_1785383680261.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            Container(
                              decoration: BoxDecoration(
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
                                  if (slide.eyebrow.isNotEmpty)
                                    Text(
                                      slide.eyebrow,
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
                                      key: ValueKey('title_${slide.id}'),
                                      repeatForever: false,
                                      animatedTexts: [
                                        ColorizeAnimatedText(
                                          slide.title,
                                          speed: const Duration(milliseconds: 500),
                                          textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          colors: [
                                            theme.colorScheme.onSurface,
                                            const Color.fromARGB(204, 51, 170, 3),
                                            Colors.tealAccent,
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (slide.subtitle.isNotEmpty)
                                    SizedBox(
                                      width: double.infinity,
                                      child: AnimatedTextKit(
                                        key: ValueKey('subtitle_${slide.id}'),
                                        repeatForever: false,
                                        animatedTexts: [
                                          TyperAnimatedText(
                                            slide.subtitle,
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
                          ],
                        );
                      },
                    ),
                    if (_effectiveSlides.length > 1)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_effectiveSlides.length, (index) {
                            final isActive = index == _currentSlide;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 450),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isActive ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
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
                  onTap: widget.onSeeAllOwners,
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
            child: widget.owners.isEmpty
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
                  onPressed: widget.onOpenAddSongDialog,
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
              itemCount: widget.albums.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final album = widget.albums[index];
                final count = widget.tracks.where((t) => t.albumIds.contains(album.id)).length;
                return AlbumCard(
                  width: 160,
                  album: album,
                  trackCount: count,
                  onClick: () => widget.onSelectAlbum(album),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),

          // Featured Rawang Traditional Songs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular Songs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
                        ),
                      ),
                      const SizedBox(width: 7),

                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${widget.onlineCount}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          widget.popularTracks.isEmpty
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
                  itemCount: widget.popularTracks.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final track = widget.popularTracks[index];
                    return TrackListItem(
                      track: track,
                      isPlayingCurrentTrack: track.id == widget.currentPlayingTrackId,
                      onTrackClick: () => widget.onPlayTrack(track, widget.popularTracks),
                      onToggleDownload: () => widget.onToggleDownload(track),
                      onToggleFavorite: () => widget.onToggleFavorite(track),
                      onAddToPlaylist: () => widget.onAddToPlaylist(track),
                      onShare: () => widget.onShare(track),
                    );
                  },
                ),
        ],
      ),
    );
  }

  List<Widget> _buildOwnerAvatars(BuildContext context) {
    final theme = Theme.of(context);
    return widget.owners.map((owner) {
      final avatarUrl = ApiService.resolveMediaUrl(owner.avatarUrl);
      final isSinger = owner.ownerType == OwnerType.singer.name;
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () => widget.onFilterByOwner(owner.name),
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
