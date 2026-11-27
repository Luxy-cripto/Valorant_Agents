import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? glowColor;
  final Color? borderGlowColor;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 22.0,
    this.padding = const EdgeInsets.all(20.0),
    this.onTap,
    this.glowColor,
    this.borderGlowColor,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Mengubah default glow menjadi Warna Merah khas Valorant (#FF4655)
    final activeGlow = widget.glowColor ?? const Color(0xFFFF4655);
    final activeBorderGlow = widget.borderGlowColor ?? const Color(0xFFBD1E2C);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            // Soft Outer Ambient Glow (Warna Merah Valorant)
            BoxShadow(
              color: activeGlow.withOpacity(_isPressed ? 0.35 : 0.15),
              blurRadius: _isPressed ? 24 : 16,
              spreadRadius: _isPressed ? 2 : -2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: activeBorderGlow.withOpacity(0.10),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: activeGlow.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.08),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    // Palette Warna Senada: Dark Slate + Valorant Crimson Glow
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E1E2E).withOpacity(0.60), // Top Slate Glass
                        const Color(0xFF151928).withOpacity(0.50), // Mid Glass
                        const Color(0xFF0F172A).withOpacity(0.70), // Bottom Dark Slate
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // Border Dual-tone Merah Valorant & Subtle White
                    border: Border.all(
                      width: 1.5,
                      color: _isPressed
                          ? activeGlow.withOpacity(0.8)
                          : Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Specular Highlight (Pantulan Kaca Soft White)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.30),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      widget.child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}