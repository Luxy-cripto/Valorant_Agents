import 'dart:math' as math;
import 'package:flutter/material.dart';

class Interactive3DAgentViewer extends StatefulWidget {
  final String? portraitUrl;
  final String? fallbackIconUrl;
  final String agentName;

  const Interactive3DAgentViewer({
    Key? key,
    required this.portraitUrl,
    required this.fallbackIconUrl,
    required this.agentName,
  }) : super(key: key);

  @override
  State<Interactive3DAgentViewer> createState() => _Interactive3DAgentViewerState();
}

class _Interactive3DAgentViewerState extends State<Interactive3DAgentViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseGlowAnimation;

  // Sudut rotasi saat ini
  double _rotateX = 0.0;
  double _rotateY = 0.0;

  // Sudut target untuk animasi reset mulus saat dilepas
  double _targetRotateX = 0.0;
  double _targetRotateY = 0.0;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseGlowAnimation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Faktor perspektif ketebalan horizontal anti-gepeng
    final double perspectiveFactor = (math.cos(_rotateY).abs() * 0.35) + 0.65;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotateY += details.delta.dx * 0.01;
          _rotateX -= details.delta.dy * 0.008;

          // Batasi sudut rotasi horizontal dan vertikal agar interaksi tetap intuitif
          _rotateX = _rotateX.clamp(-0.35, 0.35);
          _rotateY = _rotateY.clamp(-0.55, 0.55);

          _targetRotateX = _rotateX;
          _targetRotateY = _rotateY;
        });
      },
      onPanEnd: (_) {
        setState(() {
          // Reset rotasi kembali ke 0 secara mulus
          _targetRotateX = 0.0;
          _targetRotateY = 0.0;
          _rotateX = 0.0;
          _rotateY = 0.0;
        });
      },
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(_targetRotateX, _targetRotateY),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, animOffset, child) {
              final transformMatrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0012) // Depth 3D Perspective
                ..rotateX(animOffset.dx)
                ..rotateY(animOffset.dy);

              return Transform(
                alignment: Alignment.center,
                transform: transformMatrix,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Neon Aura Background Glow
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4655).withOpacity(_pulseGlowAnimation.value),
                            blurRadius: 45,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(_pulseGlowAnimation.value * 0.5),
                            blurRadius: 65,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // 2. Extruded Depth Shadow (Lapisan Ketebalan Belakang)
                    Transform.translate(
                      offset: Offset(animOffset.dy * 15, _floatingAnimation.value),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(perspectiveFactor, 1.0, 1.0),
                        child: Opacity(
                          opacity: 0.3,
                          child: SizedBox(
                            height: 240,
                            child: _buildAgentImage(colorTint: Colors.black),
                          ),
                        ),
                      ),
                    ),

                    // 3. Karakter Agent Utama (Front Layer Interactive)
                    Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(perspectiveFactor, 1.0, 1.0),
                        child: SizedBox(
                          height: 240,
                          child: _buildAgentImage(),
                        ),
                      ),
                    ),

                    // 4. Bayangan 3D Ellipse di Bawah Kaki Karakter
                    Positioned(
                      bottom: -10,
                      child: Transform.scale(
                        scale: 1.0 - (_floatingAnimation.value / 40.0),
                        child: Container(
                          width: 110,
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.elliptical(110, 14)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.65),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAgentImage({Color? colorTint}) {
    if (widget.portraitUrl != null && widget.portraitUrl!.isNotEmpty) {
      return Image.network(
        widget.portraitUrl!,
        fit: BoxFit.contain,
        color: colorTint,
        colorBlendMode: colorTint != null ? BlendMode.srcIn : null,
        errorBuilder: (_, __, ___) => widget.fallbackIconUrl != null
            ? Image.network(widget.fallbackIconUrl!, height: 130)
            : const Icon(Icons.person, size: 90, color: Colors.white),
      );
    } else if (widget.fallbackIconUrl != null && widget.fallbackIconUrl!.isNotEmpty) {
      return Image.network(
        widget.fallbackIconUrl!,
        height: 130,
        color: colorTint,
        colorBlendMode: colorTint != null ? BlendMode.srcIn : null,
      );
    } else {
      return const Icon(Icons.person, size: 90, color: Colors.white);
    }
  }
}