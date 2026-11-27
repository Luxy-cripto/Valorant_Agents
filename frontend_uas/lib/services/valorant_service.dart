import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent_model.dart';

class ValorantService {
  static const String _apiUrl = 'https://valorant-api.com/v1/agents?isPlayableCharacter=true';
  static const String _cacheKey = 'cached_valorant_agents';

  // Fetch agents dengan mekanisme Offline Caching
  Future<List<AgentModel>> fetchAgents() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        // Simpan JSON string terbaru ke local storage HP
        await prefs.setString(_cacheKey, response.body);
        
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> agentsJson = data['data'];
        return agentsJson.map((json) => AgentModel.fromJson(json)).toList();
      } else {
        throw Exception('Server mengembalikan kode status ${response.statusCode}');
      }
    } on SocketException {
      // Jika internet mati / offline, ambil dari Cache Local
      return _loadFromCache(prefs, 'Tidak ada koneksi internet. Menampilkan data offline.');
    } catch (e) {
      // Jika terjadi error lain / timeout, coba load dari cache
      return _loadFromCache(prefs, 'Gagal terhubung ke server. Menampilkan data offline.');
    }
  }

  // Helper untuk membaca dari SharedPreferences
  List<AgentModel> _loadFromCache(SharedPreferences prefs, String errorMessage) {
    final String? cachedData = prefs.getString(_cacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      final Map<String, dynamic> data = json.decode(cachedData);
      final List<dynamic> agentsJson = data['data'];
      return agentsJson.map((json) => AgentModel.fromJson(json)).toList();
    } else {
      throw Exception('$errorMessage (Belum ada data tersimpan)');
    }
  }
}