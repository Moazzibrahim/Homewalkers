// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateLeadApiService {
  Future<void> createLead ({
    required String name,
    required String email,
    required String phone,
    required String project,
    required String sales,
    required String notes,
    // required bool assign,
    required String stage,
    required String chanel,
    required String communicationway,
    required String leedtype,
    required String dayonly, // لازم يكون بصيغة yyyy-MM-dd
    required String lastStageDateUpdated,
    required String campaign,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/users');
    final now = DateTime.now().toUtc(); // بتوقيت UTC زي المطلوب
    final String currentDateTime = now.toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    final salesid = prefs.getString('salesId');
    final body = {
      "name": name,
      "email": email,
      "phone": phone,
      "project": project,
      "sales": sales,
      "notes": notes,
      // "assign": assign,
      "stage": stage,
      "chanel": chanel,
      "communicationway": communicationway,
      "leedtype": leedtype,
      "review": false,
      "dayonly": dayonly,
      "last_stage_date_updated": lastStageDateUpdated,
      "addby": salesid,
      "updatedby": salesid,
      "campaign": campaign,
      "lastcommentdate": "_",
      "lastdateassign": currentDateTime,
      "stagedateupdated": currentDateTime,
    };
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN', // شيل التعليق لو فيه توكن
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Lead created successfully: ${response.body}');
    } else {
      print('❌ Failed to create lead. Status: ${response.statusCode}');
      print(response.body);
    }
  }
}
