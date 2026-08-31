import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/viewmodels/music_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextScreen});

  final Widget nextScreen;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _minSplash = Duration(milliseconds: 1500);
  static const _maxWait = Duration(seconds: 8);
  late final AnimationController _progressController;
  bool _showOfflineNoCache = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _minSplash,
    )..forward();
    // Defer to next frame so Provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final vm = context.read<MusicViewModel>();
    // Wait for min splash + data (with timeout). Errors are swallowed - handled via syncError/hasCache
    try {
      await Future.wait([
        Future.delayed(_minSplash),
        vm.initializationDone.timeout(_maxWait).catchError((_) {}),
      ]);
    } catch (_) {}

    if (!mounted) return;

    // Ensure progress bar filled
    if (_progressController.status != AnimationStatus.completed) {
      await _progressController.animateTo(1.0, duration: const Duration(milliseconds: 200));
    }

    final hasCache = vm.albums.isNotEmpty || vm.tracks.isNotEmpty || vm.owners.isNotEmpty;
    final isOffline = vm.syncError != null;

    if (isOffline && !hasCache) {
      // First launch offline - no data to show
      setState(() => _showOfflineNoCache = true);
      return;
    }
    _navigateToNext();
  }

  Future<void> _retry() async {
    setState(() {
      _showOfflineNoCache = false;
      _isRetrying = true;
    });
    _progressController.reset();
    _progressController.forward();
    final vm = context.read<MusicViewModel>();
    try {
      await Future.wait([
        Future.delayed(_minSplash),
        vm.retryInitialization().timeout(_maxWait).catchError((_) {}),
      ]);
    } catch (_) {}
    if (!mounted) return;
    if (_progressController.status != AnimationStatus.completed) {
      await _progressController.animateTo(1.0, duration: const Duration(milliseconds: 200));
    }
    final hasCache = vm.albums.isNotEmpty || vm.tracks.isNotEmpty || vm.owners.isNotEmpty;
    if (vm.syncError != null && !hasCache) {
      setState(() {
        _showOfflineNoCache = true;
        _isRetrying = false;
      });
      return;
    }
    _navigateToNext();
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => widget.nextScreen),
    );
  }

  void _continueOffline() {
    // Allow user to proceed to app even without cache - will show empty offline/library screens
    _navigateToNext();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Watch for syncError to show offline banner while still loading with cache
    final vm = context.watch<MusicViewModel>();
    final hasCache = vm.albums.isNotEmpty || vm.tracks.isNotEmpty || vm.owners.isNotEmpty;
    final isOfflineWithCache = vm.syncError != null && hasCache && !_showOfflineNoCache;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash screen.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => ColoredBox(color: colorScheme.primary),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xB3000000)],
                stops: [0.55, 1],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 52),
                child: _showOfflineNoCache
                    ? _buildOfflineNoCacheCard()
                    : AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          final secondsLeft =
                              (_minSplash.inMilliseconds / 1000 * (1 - _progressController.value))
                                  .ceil()
                                  .clamp(0, 2);
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Rawang Melodies',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  if (isOfflineWithCache)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.wifi_off, size: 14, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            'Offline',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Text(
                                      _isRetrying ? 'retrying...' : '$secondsLeft s',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                              if (isOfflineWithCache)
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    'No internet - showing cached library',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: _showOfflineNoCache
                                      ? null
                                      : _progressController.value == 1.0 && isOfflineWithCache
                                          ? null // indeterminate while waiting with cache? keep determinate full
                                          : _progressController.value,
                                  minHeight: 4,
                                  backgroundColor: Colors.white30,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFFD36E),
                                  ),
                                ),
                              ),
                              if (isOfflineWithCache)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Sync failed: ${vm.syncError}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineNoCacheCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 42, color: Color(0xFF6B7280)),
          const SizedBox(height: 10),
          const Text(
            "You're offline",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 6),
          Text(
            'No cached songs yet. Connect to the internet to load Rawang heritage music.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _continueOffline,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue offline'),
            ),
          ),
        ],
      ),
    );
  }
}
