import 'dart:async';
import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _leftBladeSlide;
  late Animation<double> _leftBladeOpacity;
  late Animation<Offset> _rightBladeSlide;
  late Animation<double> _rightBladeOpacity;
  late Animation<double> _textScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _leftBladeSlide = Tween<Offset>(
      begin: const Offset(-1.2, -0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _leftBladeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _rightBladeSlide = Tween<Offset>(
      begin: const Offset(1.2, -0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _rightBladeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.60, curve: Curves.easeIn),
      ),
    );

    _textScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOutBack),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.95, curve: Curves.easeIn),
      ),
    );

    // Jalankan animasi, begitu selesai langsung cek status login
    _controller.forward().then((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Jeda sebentar agar tampilan logo terasa pas
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Cek apakah token autentikasi tersimpan di SharedPreferences
    final token = await ApiService.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Jika SUDAH LOGIN -> Langsung ke Home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // Jika BELUM LOGIN -> Ke Login Screen
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4655),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF4655), Color(0xFFBD1E2C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 140,
                  height: 120,
                  child: Stack(
                    children: [
                      SlideTransition(
                        position: _leftBladeSlide,
                        child: FadeTransition(
                          opacity: _leftBladeOpacity,
                          child: CustomPaint(
                            size: const Size(140, 120),
                            painter: ValorantLeftBladePainter(),
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: _rightBladeSlide,
                        child: FadeTransition(
                          opacity: _rightBladeOpacity,
                          child: CustomPaint(
                            size: const Size(140, 120),
                            painter: ValorantRightBladePainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _textOpacity,
                  child: ScaleTransition(
                    scale: _textScale,
                    child: Column(
                      children: [
                        const Text(
                          'VALORANT',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AGENT MANAGER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.8),
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.black.withOpacity(0.8),
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ValorantLeftBladePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.05, size.height * 0.15);
    path.lineTo(size.width * 0.38, size.height * 0.15);
    path.lineTo(size.width * 0.58, size.height * 0.85);
    path.lineTo(size.width * 0.42, size.height * 0.85);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ValorantRightBladePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.62, size.height * 0.15);
    path.lineTo(size.width * 0.95, size.height * 0.15);
    path.lineTo(size.width * 0.77, size.height * 0.50);
    path.lineTo(size.width * 0.45, size.height * 0.50);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}