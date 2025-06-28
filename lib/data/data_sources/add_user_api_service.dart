// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class SignupService {
  final String _baseUrl = '${Constants.baseUrl}/Signup';

  Future<void> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'role': role,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Signup successful: ${response.body}');
      } else {
        print('Signup failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error during signup: $e');
    }
  }
}
