import 'package:flutter/material.dart';

/// Reuses splash screen's heritage background image
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/splash screen.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(color: Theme.of(context).colorScheme.primary),
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
        // subtle scrim for readability
        Container(color: Colors.black.withValues(alpha: 0.15)),
        SafeArea(child: child),
      ],
    );
  }
}
