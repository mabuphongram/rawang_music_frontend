import 'dart:ui';
import 'package:flutter/material.dart';

/// Reuses the dedicated auth heritage background image
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Opacity(
            opacity: 0.9,
            child: Image.asset(
              'assets/images/auth-background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(color: Theme.of(context).colorScheme.primary),
            ),
          ),
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
