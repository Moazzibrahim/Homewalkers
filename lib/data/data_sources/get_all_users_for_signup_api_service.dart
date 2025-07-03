// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/all_users_model_for_add_users.dart';
import 'package:http/http.dart' as http;

class GetAllUsersForSignupApiService {
  static const String _baseUrl = '${Constants.baseUrl}/Signup?active=true';
  static const String _baseUrlInTrash = '${Constants.baseUrl}/Signup?active=false';
  Future<AllUsersModelForAddUsers?> getUsers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final allUsersModel = AllUsersModelForAddUsers.fromJson(jsonResponse);
        return allUsersModel;
      } else {
        print('❌ Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
    }
    return null;
  }
  Future<AllUsersModelForAddUsers?> getUsersInTrash() async {
    try {
      final response = await http.get(Uri.parse(_baseUrlInTrash));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final allUsersModel = AllUsersModelForAddUsers.fromJson(jsonResponse);
        return allUsersModel;
      } else {
        print('❌ Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
    }
    return null;
  }
}
