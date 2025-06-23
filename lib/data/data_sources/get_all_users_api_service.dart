// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/all_users_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:http/http.dart' as http;

class GetAllUsersApiService {
  static const String _baseUrl = '${Constants.baseUrl}/users?leadisactive=true';

  Future<AllUsersModel?> getUsers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return AllUsersModel.fromJson(jsonResponse);
      } else {
        print('❌ Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
    }
    return null;
  }
  Future<LeadResponse> getLeadsDataInTrash() async {
    try {
      final url = Uri.parse(
        '${Constants.baseUrl}/users?leadisactive=false',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);
        print("✅ Get leads successfully by admin in trash");
        return leadsResponse;
      } else {
        throw Exception(
          '❌ Failed to load assigned data: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error in getLeadsDataByAdmin in trash: $e');
      rethrow;
    }
  }
}
