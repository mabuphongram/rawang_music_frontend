import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted-glass card for the transparent auth screens.
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Translucent text-field decoration that stays readable over the background.
InputDecoration glassInput({
  required String label,
  required IconData prefix,
  String? hint,
  Widget? suffix,
}) {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Colors.white24),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white38),
    prefixIcon: Icon(prefix, color: Colors.white70),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.08),
    enabledBorder: border,
    focusedBorder: border.copyWith(borderSide: const BorderSide(color: Colors.white70)),
    errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.redAccent)),
  );
}

const glassTextStyle = TextStyle(color: Colors.white);
