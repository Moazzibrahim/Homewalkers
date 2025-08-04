// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/new_admin_users_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetAllUsersApiService {
  static const String _baseUrl = '${Constants.baseUrl}/users/leads-with-stages';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty || token == "null") {
      print('❌ Token is missing or invalid');
      return null;
    }
    return token;
  }

  Future<AllUsersModel?> getUsers() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final allUsersModel = AllUsersModel.fromJson(jsonResponse);
        return allUsersModel;
      } else {
        print('❌ Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
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
        throw Exception(
          '❌ Failed to load leads data: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error in getLeadsDataInTrash: $e');
      rethrow;
    }
  }
}