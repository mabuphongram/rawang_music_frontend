import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

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
    final theme = Theme.of(context);
    final singers =
        widget.owners.where((o) => o.ownerType == OwnerType.singer.name).toList();
    final organizations = widget.owners
        .where((o) => o.ownerType == OwnerType.organization.name)
        .toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
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

            // ── Tab Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.45),
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle:
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: [
                    Tab(text: 'Singers  ${singers.length}'),
                    Tab(text: 'Organizations  ${organizations.length}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Grid ─────────────────────────────────────────────────────
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
// Grid
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
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              isSinger ? 'No singers yet' : 'No organizations yet',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: owners.length,
      itemBuilder: (context, index) =>
          _OwnerCard(owner: owners[index], isSinger: isSinger),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card — circle avatar style
// ─────────────────────────────────────────────────────────────────────────────
class _OwnerCard extends StatelessWidget {
  final OwnerEntity owner;
  final bool isSinger;

  const _OwnerCard({required this.owner, required this.isSinger});

  List<Color> _gradientColors(ColorScheme cs) => isSinger
      ? [cs.primary, cs.tertiary]
      : [cs.secondary, cs.primary];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final avatarUrl = ApiService.resolveMediaUrl(owner.avatarUrl);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: cs.primary.withValues(alpha: 0.08),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cs.surfaceVariant.withValues(alpha: 0.4),
            border: Border.all(color: cs.outline.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Circle avatar ──────────────────────────────────
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSinger ? cs.primary : cs.secondary)
                            .withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl.isEmpty
                        ? _buildInitials(cs)
                        : Image.network(
                            avatarUrl,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return _buildLoading(cs);
                            },
                            errorBuilder: (_, __, ___) => _buildInitials(cs),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Name ──────────────────────────────────────────
                Text(
                  owner.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.3,
                    letterSpacing: -0.1,
                  ),
                ),

                const SizedBox(height: 6),

                // ── Type label ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSinger ? Icons.mic_rounded : Icons.corporate_fare_rounded,
                      size: 11,
                      color: isSinger ? cs.primary : cs.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSinger ? 'Singer' : 'Organization',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(ColorScheme cs) {
    final initials = owner.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors(cs),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme cs) {
    return Container(
      width: 84,
      height: 84,
      color: cs.surfaceVariant,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
