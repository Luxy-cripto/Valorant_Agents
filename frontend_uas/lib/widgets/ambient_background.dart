import 'dart:ui';
import 'package:flutter/material.dart';

class AmbientBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const AmbientBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base Dark Slate / Dark Purple (Valorant Night Theme)
        Container(color: const Color(0xFF0A071B)),

        // Top Right Purple Neon Blob
        Positioned(
          top: -size.width * 0.25,
          right: -size.width * 0.25,
          child: Container(
            width: size.width * 0.85,
            height: size.width * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withAlpha((0.22 * 255).round()),
            ),
          ),
        ),

        // Bottom Left Magenta Neon Blob
        Positioned(
          bottom: -size.width * 0.25,
          left: -size.width * 0.25,
          child: Container(
            width: size.width * 0.75,
            height: size.width * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD946EF).withAlpha((0.18 * 255).round()),
            ),
          ),
        ),

        // Efek Soft Blur untuk menyatukan Blob Neon ke Background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Content Layer (Bisa opsional SafeArea)
        useSafeArea ? SafeArea(child: child) : child,
      ],
    );
  }
}