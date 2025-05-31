// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';

class LoginApiService {
  // Variables to hold token and role
  String? token;
  String? role;
  String? name;
  String? phone;
  String? salesId;

  final String baseUrl = Constants.baseUrl;

  Future<LoginResponse> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Signup/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);

        // Extract values safely
        token = loginResponse.token;
        role = loginResponse.user.role;
        name = loginResponse.user.name;
        phone = loginResponse.user.phone;
        salesId = loginResponse.user.id;
        String createdAt = loginResponse.user.createdAt;
        String updatedAt = loginResponse.user.updatedAt;
        bool active = loginResponse.user.active;

        // Debug logs to verify values
        log('✅ Login successful');
        log('🔐 Token: $token');
        log('👤 Role: $role');
        log('📛 Name: $name');
        log('📱 Phone: $phone');
        log('🗓️ Created At: $createdAt');
        log('🕒 Updated At: $updatedAt');
        log('✔️ Active: $active');
        final fcmtoken = await FirebaseMessaging.instance.getToken();
        print("🧪 Main.dart direct FCM Token: $fcmtoken");

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token ?? '');
        await prefs.setString('role', role!);
        await prefs.setString('email', email);
        await prefs.setString('name', name!);
        await prefs.setString('phone', phone!);
        await prefs.setString('salesId', salesId!);
        await prefs.setString('createdAt', createdAt);
        await prefs.setString('updatedAt', updatedAt);
        await prefs.setBool('active', active);
        if (role == "Sales") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalesTabsScreen()),
          );
        } else if (role == "Team Leader") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TeamLeaderTabsScreen()),
          );
        } else if (role == "Admin") {
          Navigator.pushNamed(context, '/adminHome');
        } else if (role == "Manager") {
          Navigator.pushNamed(context, '/managerHome');
        } else {
          log('❌ Unknown role: $role');
        }

        return loginResponse;
      } else {
        log('❌ Login failed: ${response.statusCode}');
        log('❌ Response body: ${response.body}');
        throw Exception('Login failed');
      }
    } catch (e) {
      log('❌ Exception during login: $e');
      rethrow;
    }
  }
}
