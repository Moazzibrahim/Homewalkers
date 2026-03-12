// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'package:homewalkers_app/core/constants/apiExceptions.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateLeadApiService {
  Future<void> createLead({
    required String name,
    required String email,
    required String phone,
    required String project,
    required String sales,
    required String notes,
    required String chanel,
    required String communicationway,
    required String leedtype,
    required String dayonly,
    required String lastStageDateUpdated,
    required String campaign,
    required String budget,
    // 🔹 الجديد: اختياري
    String campaignRedirectLink = '',
    String question1_text = '',
    String question1_answer = '',
    String question2_text = '',
    String question2_answer = '',
    String question3_text = '',
    String question3_answer = '',
    String question4_text = '',
    String question4_answer = '',
    String question5_text = '',
    String question5_answer = '',
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/users');
    final now = DateTime.now().toUtc();
    final String currentDateTime = now.toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw ApiException('No token found in SharedPreferences');
    }
    final salesid = prefs.getString('salesId');
    final pendingStageId = prefs.getString('pending_stage_id');

    final body = {
      "name": name,
      "email": email,
      "phone": "+$phone",
      "project": project,
      "sales": sales,
      "notes": notes,
      "stage": pendingStageId,
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
      "budget": budget,
      // 🔹 هنا ضفت الحقول الجديدة
      "campaignRedirectLink": campaignRedirectLink,
      "question1_text": question1_text,
      "question1_answer": question1_answer,
      "question2_text": question2_text,
      "question2_answer": question2_answer,
      "question3_text": question3_text,
      "question3_answer": question3_answer,
      "question4_text": question4_text,
      "question4_answer": question4_answer,
      "question5_text": question5_text,
      "question5_answer": question5_answer,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    print("body sent: ${jsonEncode(body)}");
    print("url: $url");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Lead created successfully');
    } else {
      final res = jsonDecode(response.body);
      if ((res['message'] ?? '').contains(
        "phone number is already registered",
      )) {
        print("⚠️ Warning: phone already exists");
      }
      print(
        '❌ Failed to create lead: ${response.statusCode} ${res['message']}',
      );
      throw ApiException(res['message'] ?? 'Unknown error');
    }
  }
}
