// ignore_for_file: avoid_print, use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/login_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginApiService {
  String? token;
  String? role;
  String? name;
  String? phone;
  String? salesId;
  String? newFcmToken;
  String? deviceId;

  final String baseUrl = Constants.baseUrl;

  Future<Map<String, dynamic>> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final response = await http.post(
        Uri.parse("$baseUrl/Signup/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
        }),
      );

      log('📦 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final userData = responseData['data'];
        token = responseData['token'];
        deviceId = responseData['deviceId'] ?? '';

        if (userData == null || token == null || deviceId == null) {
          log('❌ Missing token or or deviceId or user in response ');
          throw Exception('Login failed: Missing required data');
        }
        // استخراج القيم من userData
        name = userData['name'];
        role = userData['role'];
        phone = userData['phone'];
        salesId = userData['_id'];
        newFcmToken = userData['fcmToken'];
        String? createdAt = userData['createdAt'];
        String? updatedAt = userData['updatedAt'];
        bool active = userData['active'] ?? false;

        // Debug logs
        log('✅ Login successful');
        log('🔐 Token: $token');
        log('👤 Role: $role');
        log('📛 Name: $name');
        log('📱 Phone: $phone');
        log('🗓️ Created At: $createdAt');
        log('🕒 Updated At: $updatedAt');
        log('✔️ Active: $active');
        log('📲 New FCM Token: $newFcmToken');
        log('� deviceId: $deviceId');

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token ?? '');
        await prefs.setString('deviceId', deviceId ?? '');
        await prefs.setString('role', role ?? '');
        await prefs.setString('email', email);
        await prefs.setString('name', name ?? '');
        await prefs.setString('phone', phone ?? '');
        await prefs.setString('salesId', salesId ?? '');
        await prefs.setString('createdAt', createdAt ?? '');
        await prefs.setString('updatedAt', updatedAt ?? '');
        await prefs.setBool('active', active);
        await prefs.setString('NewfcmToken', newFcmToken ?? '');
        context.read<NotificationCubit>().initNotifications();
        // Navigate based on role
        if (role == "Sales") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SalesTabsScreen()),
          );
        } else if (role == "Team Leader") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeamLeaderTabsScreen()),
          );
        } else if (role == "Manager") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TabsScreenManager()),
          );
        } else if (role == "Marketer") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MarketierTabsScreen()),
          );
        } else if (role == "Admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminTabsScreen()),
          );
        } else {
          log('❌ Unknown role: $role');
          throw Exception('Unknown role: $role');
        }
        return {
          'token': token,
          'role': role,
          'name': name,
          'phone': phone,
          'salesId': salesId,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
          'active': active,
          'newFcmToken': newFcmToken,
          'deviceId': deviceId,
        };
      } else {
        log('❌ Login failed: ${response.statusCode}');
        log('❌ Response body: ${response.body}');
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      log('❌ Exception during login: $e');
      rethrow;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSalesId = prefs.getString('salesId') ?? '';
      final savedDeviceId = prefs.getString('deviceId') ?? '';
      final savedToken = prefs.getString('token') ?? '';

      if (savedSalesId.isEmpty || savedDeviceId.isEmpty) {
        log('❌ لا يوجد SalesId أو DeviceId في التخزين');
        throw Exception("SalesId or DeviceId not found in storage");
      }

      // ✅ حذف FCM Token من Firebase
      await FirebaseMessaging.instance.deleteToken();
      log("🧹 FCM Token Deleted ✅");

      final url = Uri.parse(
        "${Constants.baseUrl}/userdevices/$savedSalesId/devices/$savedDeviceId/logout",
      );

      log("📤 Sending logout request to: $url");

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $savedToken', // لو محتاج توكن في الهيدر
        },
      );

      if (response.statusCode == 200) {
        log("✅ Logout successful: ${response.body}");

        // 🗑️ امسح كل البيانات من SharedPreferences
        await prefs.remove('token');
        await prefs.remove('deviceId');
        await prefs.remove('role');
        await prefs.remove('salesId');

          context.read<NotificationCubit>().disposeNotifications();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false, // 🔄 Remove all previous routes
        );
      } else {
        log("❌ Logout failed: ${response.statusCode}");
        log("❌ Response body: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("logout failed try again")));
      }
    } catch (e) {
      log("❌ Exception during logout: $e");
      rethrow;
    }
  }
}
