import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnersScreen extends StatefulWidget {
  final List<OwnerEntity> owners;

  const OwnersScreen({super.key, required this.owners});

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final singers = widget.owners
        .where((o) => o.ownerType == OwnerType.singer.name)
        .toList();
    final organizations = widget.owners
        .where((o) => o.ownerType == OwnerType.organization.name)
        .toList();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse by Owner',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${widget.owners.length} contributors',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab Bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: [
                    Tab(text: 'Singers  ${singers.length}'),
                    Tab(text: 'Organizations  ${organizations.length}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Grid ──────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OwnerGrid(owners: singers, isSinger: true),
                  _OwnerGrid(owners: organizations, isSinger: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _OwnerGrid extends StatelessWidget {
  final List<OwnerEntity> owners;
  final bool isSinger;

  const _OwnerGrid({required this.owners, required this.isSinger});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (owners.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSinger ? Icons.mic_off_rounded : Icons.corporate_fare_rounded,
              size: 52,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isSinger ? 'No singers yet' : 'No organizations yet',
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: owners.length,
      itemBuilder: (context, index) =>
          _OwnerCard(owner: owners[index], isSinger: isSinger),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _OwnerCard extends StatelessWidget {
  final OwnerEntity owner;
  final bool isSinger;

  const _OwnerCard({required this.owner, required this.isSinger});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _socialText(String url, String prefix) {
    if (url.isEmpty) return prefix;
    // strip https://www. for display
    return url
        .replaceFirst(RegExp(r'https?://(www\.)?'), '')
        .replaceAll(RegExp(r'/$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiService.resolveMediaUrl(owner.avatarUrl);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ─────────────────────────────────────────────────
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipOval(
              child: avatarUrl.isEmpty
                  ? _buildInitials(context)
                  : CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      memCacheWidth: 152,
                      placeholder: (_, __) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: primary),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _buildInitials(context),
                      fadeInDuration: const Duration(milliseconds: 200),
                    ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Name ───────────────────────────────────────────────────
          Text(
            owner.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          // ── Stats ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note_rounded, size: 12, color: primary),
              const SizedBox(width: 3),
              Text(
                '${owner.albumCount} Albums',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '  |  ',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              Icon(Icons.music_note_rounded, size: 12, color: primary),
              const SizedBox(width: 3),
              Text(
                '${owner.trackCount} Tracks',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 10),

          // ── Social Links ───────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SocialRow(
                icon: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 12, color: Colors.white),
                ),
                text: _socialText(
                    owner.socialLinks.youtube, 'youtube.com/channel'),
                available: owner.socialLinks.youtube.isNotEmpty,
                onTap: () => _launchUrl(owner.socialLinks.youtube),
              ),
              const SizedBox(height: 5),
              _SocialRow(
                icon: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1877F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'f',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                text: _socialText(
                    owner.socialLinks.facebook, 'facebook.com/page'),
                available: owner.socialLinks.facebook.isNotEmpty,
                onTap: () => _launchUrl(owner.socialLinks.facebook),
              ),
              const SizedBox(height: 5),
              _SocialRow(
                icon: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.tiktok, size: 11, color: Colors.white),
                ),
                text: _socialText(
                    owner.socialLinks.tiktok, 'tiktok.com/@user'),
                available: owner.socialLinks.tiktok.isNotEmpty,
                onTap: () => _launchUrl(owner.socialLinks.tiktok),
              ),
              const SizedBox(height: 5),
              _SocialRow(
                icon: Icon(Icons.phone_outlined,
                    size: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                text: owner.phone.isNotEmpty
                    ? owner.phone
                    : '+95 9 --- --- ---',
                available: owner.phone.isNotEmpty,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final theme = Theme.of(context);
    final initials = owner.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      decoration: BoxDecoration(
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
          initials.isEmpty ? '?' : initials,
          style: TextStyle(
              color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SocialRow extends StatelessWidget {
  final Widget icon;
  final String text;
  final bool available;
  final VoidCallback onTap;

  const _SocialRow({
    required this.icon,
    required this.text,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Opacity(
        opacity: available ? 1.0 : 0.3,
        child: Row(
          children: [
            icon,
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: available
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
