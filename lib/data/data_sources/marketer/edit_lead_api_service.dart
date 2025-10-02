// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditLeadApiService {
  final String baseUrl = '${Constants.baseUrl}/users';

  Future<void> editLead({
    required String userId,
    String? phone,
    String? name,
    String? email,
    String? project,
    String? notes,
    String? stage,
    String? chanel,
    String? communicationway,
    String? leedtype,
    String? dayonly,
    String? campaign,
    String? lastStageDateUpdated,
  }) async {
    final url = Uri.parse('$baseUrl/$userId');
    final prefs = await SharedPreferences.getInstance();
    final salesId = prefs.getString('salesId');
    final now = DateTime.now().toUtc();
    final String currentDateTime = now.toIso8601String();

    // بناء البودي فقط من القيم غير null وغير الفارغة
    Map<String, dynamic> body = {};

    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (project != null && project.isNotEmpty) body['project'] = project;
    if (salesId != null && salesId.isNotEmpty) body['sales'] = salesId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (stage != null && stage.isNotEmpty) body['stage'] = stage;
    if (chanel != null && chanel.isNotEmpty) body['chanel'] = chanel;
    if (communicationway != null && communicationway.isNotEmpty) {
      body['communicationway'] = communicationway;
    }
    if (leedtype != null && leedtype.isNotEmpty) body['leedtype'] = leedtype;
    if (dayonly != null && dayonly.isNotEmpty) body['dayonly'] = dayonly;
    if (campaign != null && campaign.isNotEmpty) body['campaign'] = campaign;
    if (lastStageDateUpdated != null && lastStageDateUpdated.isNotEmpty) {
      body['last_stage_date_updated'] = lastStageDateUpdated;
    }

    body['review'] = false;
    body['lastcommentdate'] = currentDateTime;
    body['lastdateassign'] = currentDateTime;
    body['stagedateupdated'] = currentDateTime;
    body['addby'] = salesId;
    body['updatedby'] = salesId;

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${prefs.getString('token')}",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Lead updated successfully');
      } else {
        print('❌ Failed to update lead: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> editLeadAssignValue({
    required String userId,
    bool? assign,
  }) async {
    final url = Uri.parse('$baseUrl/$userId');
    // بناء البودي فقط من القيم غير null وغير الفارغة
    Map<String, dynamic> body = {};
    final prefs = await SharedPreferences.getInstance();

    if (assign != null ) body['assign'] = assign;

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${prefs.getString('token')}",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('✅ Lead updated successfully');
      } else {
        print('❌ Failed to update lead: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
