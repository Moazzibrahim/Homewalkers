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
    String? phone2,
    String? whatsappNumber,
    String? name,
    String? salesIdd,
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
    bool? islLeadactivte,
  }) async {
    final url = Uri.parse('$baseUrl/$userId');
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final salesId = prefs.getString('salesId');
    final salesUserLogId = prefs.getString('sales_userlog_id');
    final now = DateTime.now().toUtc();
    final String currentDateTime = now.toIso8601String();

    Map<String, dynamic> body = {};

    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (phone2 != null && phone2.isNotEmpty) body['phonenumber2'] = phone2;
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      body['whatsappnumber'] = whatsappNumber;
    }
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (project != null && project.isNotEmpty) body['project'] = project;

    // ✅ تحديد الـ Sales ID اللي هيتبعت بناءً على الدور
    // if (role == 'Admin') {
    //   body['sales'] = salesId;
    // } else {
    //   // لو sales_userlog_id فاضي أو null، استخدم salesId بدلها
    //   body['sales'] =
    //       (salesIdd != null && salesIdd.isNotEmpty) ? salesIdd : salesId;
    // }

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
    if (islLeadactivte != null) {
      body['leadisactive'] = islLeadactivte;
    }

    // ✅ الطباعة الواضحة لكل القيم اللي هتتبعت
    print('----------------------------------------');
    print('🟩 Editing Lead ID: $userId');
    print('🧩 Role: $role');
    print('🧑‍💼 salesId: $salesId');
    print('🧾 sales_userlog_id: $salesUserLogId');
    print('📦 Sales ID Sent in Body: ${body['sales']}');
    print('📤 Final Request Body: ${jsonEncode(body)}');
    print('----------------------------------------');

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

    if (assign != null) body['assign'] = assign;

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

  Future<void> changeLeadToData({List<String>? leadIds}) async {
    final url = Uri.parse('${Constants.baseUrl}/users/transfer-to-data-center');
    Map<String, dynamic> body = {};
    final prefs = await SharedPreferences.getInstance();

    if (leadIds != null && leadIds.isNotEmpty) body['leadIds'] = leadIds;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${prefs.getString('token')}",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('✅ Leads changed to data successfully');
      } else {
        print('❌ Failed to change leads to data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
