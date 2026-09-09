import 'dart:math' as math;
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
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                child: _showOfflineNoCache
                    ? _buildOfflineNoCacheCard()
                    : AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOfflineWithCache)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFFD36E).withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.wifi_off, size: 13, color: Color(0xFFFFD36E)),
                                      SizedBox(width: 5),
                                      Text(
                                        'Offline • cached library',
                                        style: TextStyle(
                                          color: Color(0xFFFFD36E),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              _buildGoldenCircularLoader(_progressController.value),
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

  Widget _buildGoldenCircularLoader(double progress) {
    const gold = Color(0xFFEACD8A);
    return SizedBox(
      width: 200,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left decorative waves
          Positioned(
            left: 0,
            child: CustomPaint(
              size: const Size(52, 40),
              painter: _GoldWavesPainter(mirror: false),
            ),
          ),
          // Right decorative waves
          Positioned(
            right: 0,
            child: CustomPaint(
              size: const Size(52, 40),
              painter: _GoldWavesPainter(mirror: true),
            ),
          ),
          // Golden ring with progress + glow dot
          SizedBox(
            width: 84,
            height: 84,
            child: CustomPaint(
              painter: _GoldenRingPainter(progress: progress.clamp(0.0, 1.0), gold: gold),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    _WaveBar(height: 8),
                    SizedBox(width: 3),
                    _WaveBar(height: 14),
                    SizedBox(width: 3),
                    _WaveBar(height: 22),
                    SizedBox(width: 3),
                    _WaveBar(height: 14),
                    SizedBox(width: 3),
                    _WaveBar(height: 8),
                  ],
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

class _WaveBar extends StatelessWidget {
  final double height;
  const _WaveBar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEACD8A),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEACD8A).withValues(alpha: 0.7),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _GoldenRingPainter extends CustomPainter {
  final double progress;
  final Color gold;

  _GoldenRingPainter({required this.progress, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Base faint ring
    final basePaint = Paint()
      ..color = gold.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, basePaint);

    // Progress arc starting at top
    final sweep = progress * 3.141592653589793 * 2;
    if (sweep > 0.001) {
      final progressPaint = Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      // Soft glow under the arc
      final glowPaint = Paint()
        ..color = gold.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2,
        sweep,
        false,
        glowPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2,
        sweep,
        false,
        progressPaint,
      );

      // Glowing dot at the tip
      final angle = -3.141592653589793 / 2 + sweep;
      final dotPos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final dotGlow = Paint()
        ..color = gold.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(dotPos, 7, dotGlow);
      final dotCore = Paint()..color = const Color(0xFFFFF6E0);
      canvas.drawCircle(dotPos, 3.2, dotCore);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldenRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GoldWavesPainter extends CustomPainter {
  final bool mirror;
  _GoldWavesPainter({required this.mirror});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEACD8A).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final faint = Paint()
      ..color = const Color(0xFFEACD8A).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final y = 8.0 + i * 10.0;
      final path = Path();
      if (!mirror) {
        path.moveTo(0, y + 6);
        path.quadraticBezierTo(size.width * 0.35, y - 6, size.width * 0.6, y + 2);
        path.quadraticBezierTo(size.width * 0.8, y + 8, size.width, y - 2);
      } else {
        path.moveTo(size.width, y + 6);
        path.quadraticBezierTo(size.width * 0.65, y - 6, size.width * 0.4, y + 2);
        path.quadraticBezierTo(size.width * 0.2, y + 8, 0, y - 2);
      }
      canvas.drawPath(path, i == 1 ? paint : faint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldWavesPainter oldDelegate) => false;
}
