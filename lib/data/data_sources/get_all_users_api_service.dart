// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/lead_stats_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/new_admin_users_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetAllUsersApiService {
  static const String _baseUrl =
      '${Constants.baseUrl}/users/leads-with-stages?leadisactive=true';

  static const String _stagesStatsUrl =
      '${Constants.baseUrl}/users/mobile/stages-stats';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty || token == "null") {
      print('❌ Token is missing or invalid');
      return null;
    }
    return token;
  }

  Future<AllUsersModel?> getUsers({
    int page = 1,
    int limit = 5,
    String? stageName,
    bool? duplicates,
    bool? ignoreDuplicates,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final uri = Uri.parse(
      '${Constants.baseUrl}/users/admin/allleadspagination',
    ).replace(
      queryParameters: {
        'leadisactive': 'true',
        'sort':'-date',
        'page': page.toString(),
        'limit': limit.toString(),
        if (stageName != null && stageName.isNotEmpty) 'stage': stageName,
        if (duplicates != null && duplicates == true) 'duplicates': 'true',
        if (ignoreDuplicates != null && ignoreDuplicates == true)
          'ignoreduplicate': 'true',
      },
    );
    print(
      '📌 Fetching users with parameters: page=$page, limit=$limit, stageName=$stageName, duplicates=$duplicates, ignoreDuplicates=$ignoreDuplicates',
    );
    print('URL of getUsers: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("response.body: ${response.body}");
        return await compute(parseUsers, response.body);
      } else {
        print('❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }

    return null;
  }

  // function منفصلة لل compute
  AllUsersModel parseUsers(String responseBody) {
    final jsonResponse = json.decode(responseBody);
    return AllUsersModel.fromJson(jsonResponse);
  }

  Future<AllUsersModel?> getAllUsers() async {
    final token = await _getToken();
    if (token == null) return null;

    String url = _baseUrl;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AllUsersModel.fromJson(jsonResponse);
      } else {
        print('❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }

    return null;
  }

  Future<LeadResponse?> getLeadsDataInTrash() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final url = Uri.parse('${Constants.baseUrl}/users?leadisactive=false');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);
        print("✅ Get leads successfully by admin in trash");
        return leadsResponse;
      } else {
        throw Exception('❌ Failed to load leads data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getLeadsDataInTrash: $e');
      rethrow;
    }
  }

  // ✅ NEW ✅
  Future<LeadsStatsModel?> getStageStats() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(_stagesStatsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📌 Status: ${response.statusCode}');
      print('📌 Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        return LeadsStatsModel.fromJson(jsonBody);
      } else {
        print('❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }

    return null;
  }
}
