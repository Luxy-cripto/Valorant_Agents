import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _rankData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await ApiService.getUser();
      
      // Ambil Riot Name & Tag dari database (atau fallback default Luxy#1701)
      final String riotName = user?['riot_name'] ?? 'Luxy';
      final String riotTag = user?['riot_tag'] ?? '1701';

      // Fetch MMR & Badge Rank dari API
      final rankStats = await ApiService.getPlayerRankStats(riotName, riotTag);

      if (mounted) {
        setState(() {
          _userData = user;
          _rankData = rankStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('PLAYER PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1E2E), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4655)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar Banner Valorant Style
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFF4655), width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF4655).withOpacity(0.4),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const CircleAvatar(
                              radius: 48,
                              backgroundColor: Color(0xFF1E1E2E),
                              child: Icon(
                                Icons.person_rounded,
                                size: 56,
                                color: Color(0xFFFF4655),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        _userData?['name']?.toString().toUpperCase() ?? 'AGENT PLAYER',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rank Badge Dinamis (Ikon + Nama Rank)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4655).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF4655), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_rankData?['rank_icon'] != null)
                              Image.network(
                                _rankData!['rank_icon'],
                                width: 20,
                                height: 20,
                                errorBuilder: (ctx, _, __) =>
                                    const Icon(Icons.military_tech, color: Color(0xFFFF4655), size: 18),
                              )
                            else
                              const Icon(Icons.military_tech, color: Color(0xFFFF4655), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              (_rankData?['rank_name'] ?? 'RADIANT RANK').toString().toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFFF4655),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // User Info GlassCard
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACCOUNT DETAILS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            _buildInfoTile(Icons.email_outlined, 'Email Address', _userData?['email'] ?? '-'),
                            const SizedBox(height: 16),
                            _buildInfoTile(Icons.tag_rounded, 'User ID', '#${_userData?['id'] ?? '-'}'),
                            const SizedBox(height: 16),
                            _buildInfoTile(
                              Icons.equalizer_rounded,
                              'Current Rating / ELO',
                              '${_rankData?['elo'] ?? 0} RR',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoTile(Icons.verified_user_outlined, 'Account Status', 'Active / Authenticated'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Logout Button
                      ElevatedButton(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent, width: 1.2),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: const BoxConstraints(minHeight: 50),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'LOGOUT ACCOUNT',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF4655), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}