import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Menggunakan 'localhost' saat di Chrome Web, dan IP LAN '192.168.1.106' saat di HP/Device
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://10.10.8.153:8000/api';
    }
    return 'http://10.10.8.153:8000/api';
  }

  // --- TOKEN MANAGEMENT ---
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // --- AUTHENTICATION ---

  // REGISTER USER BARU
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Gagal terhubung ke server $baseUrl.',
      };
    }
  }

  // LOGIN USER
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;

      final token = data['access_token'] ?? data['token'];
      if ((response.statusCode == 200 || response.statusCode == 201) && token != null) {
        await saveToken(token);
      }

      return data;
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Gagal koneksi ke server.',
      };
    }
  }

  // GET USER PROFILE (UNTUK PROFILE SCREEN)
  static Future<Map<String, dynamic>?> getUser() async {
    final token = await getToken();

    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error getUser Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception getUser: $e');
    }
    return null;
  }

  // LOGOUT USER
  static Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {}
      await removeToken();
    }
  }

  // --- VALORANT STATS INTEGRATION (HENRIKDEV API & VALORANT-API) ---
  static Future<Map<String, dynamic>> getPlayerRankStats(String name, String tag) async {
    try {
      // 1. Fetch MMR / Rank Data dari HenrikDev API (Region Asia Pacific 'ap')
      final mmrResponse = await http.get(
        Uri.parse('https://api.henrikdev.xyz/valorant/v1/mmr/ap/$name/$tag'),
      );

      if (mmrResponse.statusCode == 200) {
        final mmrData = jsonDecode(mmrResponse.body)['data'];
        final String rankName = mmrData['currenttierpatched'] ?? 'Unranked';
        final int currentTier = mmrData['currenttier'] ?? 0;
        final int elo = mmrData['elo'] ?? 0;

        // 2. Fetch Badge Ikon Tier dari Valorant-API Competitivetiers
        String? rankIconUrl;
        final tierResponse = await http.get(
          Uri.parse('https://valorant-api.com/v1/competitivetiers'),
        );

        if (tierResponse.statusCode == 200) {
          final tierData = jsonDecode(tierResponse.body)['data'];
          if (tierData.isNotEmpty) {
            final tiersList = tierData.last['tiers'] as List;
            final matchedTier = tiersList.firstWhere(
              (t) => t['tier'] == currentTier,
              orElse: () => null,
            );
            if (matchedTier != null) {
              rankIconUrl = matchedTier['largeIcon'];
            }
          }
        }

        return {
          'rank_name': rankName,
          'elo': elo,
          'rank_icon': rankIconUrl,
        };
      }
    } catch (e) {
      debugPrint('Error fetch player rank: $e');
    }

    return {
      'rank_name': 'UNRANKED',
      'elo': 0,
      'rank_icon': null,
    };
  }

  // --- FETCH ROLES (TABEL 1 INDUK) ---
  static Future<List<dynamic>> getRoles() async {
    final token = await getToken();

    if (token == null) {
      debugPrint('Token belum ada, silakan login terlebih dahulu.');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? body;
      } else {
        debugPrint('Error Roles Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception getRoles: $e');
    }
    return [];
  }

  // --- FETCH AGENT POOLS (TABEL 2 ANAK - READ) ---
  static Future<List<dynamic>> getAgentPools() async {
    final token = await getToken();

    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agent-pools'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? body;
      } else {
        debugPrint('Error AgentPools Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception getAgentPools: $e');
    }
    return [];
  }

  // --- CREATE AGENT POOL (TABEL 2 ANAK - INSERT) ---
  static Future<Map<String, dynamic>> createAgentPool(
    Map<String, dynamic> poolData,
  ) async {
    final token = await getToken();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agent-pools'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(poolData),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {'statusCode': 500, 'message': 'Gagal mengirim data pool ke server.'};
    }
  }
}