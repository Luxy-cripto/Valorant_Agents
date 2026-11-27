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

  double _rotateX = 0.0;
  double _rotateY = 0.0;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
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
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotateY += details.delta.dx * 0.008;
          _rotateX -= details.delta.dy * 0.008;

          // Batasi sudut Tilt 3D Card agar karakter tidak pernah memutar ke samping (mencegah gepeng)
          _rotateX = _rotateX.clamp(-0.4, 0.4);
          _rotateY = _rotateY.clamp(-0.4, 0.4);
        });
      },
      onPanEnd: (_) {
        setState(() {
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
              end: Offset(_rotateX, _rotateY),
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            builder: (context, animOffset, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015) // Depth 3D Perspektif
                  ..rotateX(animOffset.dx)
                  ..rotateY(animOffset.dy),
                child: Container(
                  width: 260,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1F2326).withOpacity(0.8),
                        const Color(0xFF0F172A).withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFFFF4655).withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4655).withOpacity(0.25),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: Offset(-animOffset.dy * 15, animOffset.dx * 15),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 1. LAYER LAPISAN 1: Neon Aura Background Glow
                      Positioned(
                        top: 40,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF4655).withOpacity(_pulseGlowAnimation.value),
                                blurRadius: 40,
                                spreadRadius: 6,
                              ),
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(_pulseGlowAnimation.value * 0.5),
                                blurRadius: 60,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. LAYER LAPISAN 2: Shadow Bayangan Karakter (Parallax Back)
                      Transform.translate(
                        offset: Offset(animOffset.dy * 20, _floatingAnimation.value + (animOffset.dx * 10)),
                        child: Opacity(
                          opacity: 0.35,
                          child: SizedBox(
                            height: 250,
                            child: _buildAgentImage(colorTint: Colors.black),
                          ),
                        ),
                      ),

                      // 3. LAYER LAPISAN 3: Agent Character POP-OUT (Pop Terangkat ke Depan 3D)
                      Transform.translate(
                        offset: Offset(animOffset.dy * -12, _floatingAnimation.value - 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 255,
                            child: _buildAgentImage(),
                          ),
                        ),
                      ),

                      // 4. LAYER LAPISAN 4: Holographic Light Glare (Kilapan Kaca 3D saat Di-tilt)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.05),
                                ],
                                begin: Alignment(animOffset.dy * 2, -1.0),
                                end: Alignment(-animOffset.dy * 2, 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 5. Bayangan 3D Ellipse Kaki
                      Positioned(
                        bottom: 12,
                        child: Transform.scale(
                          scale: 1.0 - (_floatingAnimation.value / 40.0),
                          child: Container(
                            width: 100,
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.elliptical(100, 12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
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
        errorBuilder: (_, __, ___) {
          if (widget.fallbackIconUrl != null && widget.fallbackIconUrl!.isNotEmpty) {
            return Image.network(
              widget.fallbackIconUrl!,
              fit: BoxFit.contain,
              color: colorTint,
              colorBlendMode: colorTint != null ? BlendMode.srcIn : null,
              errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 100, color: Colors.white),
            );
          }
          return const Icon(Icons.person_rounded, size: 100, color: Colors.white);
        },
      );
    } else if (widget.fallbackIconUrl != null && widget.fallbackIconUrl!.isNotEmpty) {
      return Image.network(
        widget.fallbackIconUrl!,
        fit: BoxFit.contain,
        color: colorTint,
        colorBlendMode: colorTint != null ? BlendMode.srcIn : null,
        errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 100, color: Colors.white),
      );
    } else {
      return const Icon(Icons.person_rounded, size: 100, color: Colors.white);
    }
  }
}