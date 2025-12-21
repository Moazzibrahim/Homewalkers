import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/team_leader/dashboard_count.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeamleaderDashboardApiService {
  static const String _baseUrl =
      '${Constants.baseUrl}/users/teamleader/dashboard-cached2';

  /// Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get email from SharedPreferences
  Future<String?> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  /// Fetch Teamleader Dashboard Data
  Future<TeamleaderDashboardResponse> fetchDashboard() async {
    try {
      final token = await _getToken();
      final email = await _getEmail();

      if (token == null || email == null) {
        throw Exception('Token or Email is missing');
      }

      final url = Uri.parse('$_baseUrl/$email');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TeamleaderDashboardResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load dashboard | StatusCode: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
