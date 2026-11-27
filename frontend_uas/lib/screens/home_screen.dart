import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'agent_list_screen.dart';
import 'agent_pool_form_screen.dart';
import 'profile_screen.dart';
import '../routes/routes.dart';
import '../services/api_service.dart'; // Import ApiService untuk hapus token

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _appVersion = 'Loading...';
  
  final PageStorageBucket _bucket = PageStorageBucket();

  late final AnimationController _badgeAnimController;
  late final Animation<double> _badgeScale;

  final List<Widget> _pages = [
    const AgentListScreen(key: PageStorageKey('AgentListScreen')),
    const AgentPoolFormScreen(key: PageStorageKey('AgentPoolFormScreen')),
    const ProfileScreen(key: PageStorageKey('ProfileScreen')),
  ];

  @override
  void initState() {
    super.initState();
    _loadAppVersion();

    _badgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _badgeScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _badgeAnimController,
        curve: Curves.easeInOut,
      ),
    );

    _badgeAnimController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _badgeAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${info.version}+${info.buildNumber}';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _appVersion = 'v1.0.0+3';
        });
      }
    }
  }

  // DI-PERBAIKI: Hapus token lokal saat Logout ditekan
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFF4655), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFFFF4655), size: 20),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah kamu yakin ingin keluar dari aplikasi?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'VALORANT LOADOUT $_appVersion',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4655),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              
              // 1. Hapus token session autentikasi
              await ApiService.removeToken();

              // 2. Bersihkan stack navigasi & pindah ke Login
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          reverseDuration: const Duration(milliseconds: 250),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.04),
              end: Offset.zero,
            ).animate(animation);

            final scaleAnimation = Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 3) {
                  _handleLogout();
                } else {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFFFF4655),
              unselectedItemColor: Colors.grey[500],
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.grid_view_rounded),
                      if (_currentIndex == 0)
                        Positioned(
                          top: -6,
                          right: -10,
                          child: ScaleTransition(
                            scale: _badgeScale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4655),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF4655).withOpacity(0.8),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Agents',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add_moderator),
                  label: 'Agent Pool',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.logout_rounded),
                  label: 'Logout',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'BUILD VERSION $_appVersion',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}