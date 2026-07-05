// ignore_for_file: avoid_print, unused_local_variable

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditLeadApiService {
  String get baseUrl => '${Constants.baseUrl}/users';

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
    bool? ignoreDuplicate,
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
    if (ignoreDuplicate != null) {
      body['ignoredublicate'] = ignoreDuplicate;
    }

    body['review'] = false;
    // body['lastcommentdate'] = currentDateTime;
    // body['lastdateassign'] = currentDateTime;
    //  body['stagedateupdated'] = currentDateTime;
    if (islLeadactivte != null) {
      body['leadisactive'] = islLeadactivte;
    }
    print("url: $url");
    // ✅ الطباعة الواضحة لكل القيم اللي هتتبعت
    print('----------------------------------------');
    print('🟩 Editing Lead ID: $userId');
    print('🧩 Role: $role');
    print('🧑‍💼 salesId: $salesId');
    print('🧾 sales_userlog_id: $salesUserLogId');
    print("ignore duplicate: ${body['ignoreduplicate']}");
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
        print('Response body: ${response.body}');
      } else {
        print('❌ Failed to update lead: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> editMultipleLeads({
    required List<String> userIds,
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
    bool? ignoreDuplicate,
  }) async {
    print('🔁 Starting bulk edit for ${userIds.length} leads...');

    for (final userId in userIds) {
      await editLead(
        userId: userId,
        phone: phone,
        phone2: phone2,
        whatsappNumber: whatsappNumber,
        name: name,
        salesIdd: salesIdd,
        email: email,
        project: project,
        notes: notes,
        stage: stage,
        chanel: chanel,
        communicationway: communicationway,
        leedtype: leedtype,
        dayonly: dayonly,
        campaign: campaign,
        lastStageDateUpdated: lastStageDateUpdated,
        islLeadactivte: islLeadactivte,
        ignoreDuplicate: ignoreDuplicate,
      );
    }

    print('✅ Bulk edit done for ${userIds.length} leads.');
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

  Future<void> transferLeadFromDataToOriginal({required String userId}) async {
    final url = Uri.parse('$baseUrl/$userId');
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> body = {'data': false, 'transferefromdata': true};

    print('----------------------------------------');
    print('🟩 Transferring Lead from Data - ID: $userId');
    print('📤 Final Request Body: ${jsonEncode(body)}');
    print('----------------------------------------');

    try {
      final response = await http.put(
        // ← نفس راوت editLead (PUT)
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${prefs.getString('token')}",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Lead transferred from data successfully');
      } else {
        print('❌ Failed to transfer lead: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  // ── Bulk Update Field (راوت عام بيعدل field واحد لأكتر من lead) ──
  // ── Bulk Update Field (راوت عام بيعدل field واحد لأكتر من lead) ──
  Future<void> bulkUpdateField({
    required List<String> ids,
    required String key,
    required dynamic value,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/users/leads/bulk-update-field');
    print('🔗 Bulk Update URL: $url');

    final prefs = await SharedPreferences.getInstance();

    final body = {'ids': ids, 'key': key, 'value': value};

    print('----------------------------------------');
    print('🟦 Bulk Update Field');
    print('🔑 Key: $key | Value: $value');
    print('🆔 IDs: $ids');
    print('----------------------------------------');

    // ── من غير try/catch هنا، عشان لو حصل فشل، الاستثناء يطلع لفوق للـ Cubit يمسكه
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${prefs.getString('token')}",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('✅ Bulk update done successfully');
    } else {
      print('❌ Failed bulk update: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception("Failed to update leads (${response.statusCode})");
    }
  }

  // ── Shortcuts لكل حالة استخدام ──

  // نقل الـ leads من Data Center للـ Original
  Future<void> bulkTransferFromDataToOriginal({
    required List<String> ids,
  }) async {
    await bulkUpdateField(ids: ids, key: 'transferefromdata', value: true);
  }

  // Ignore Duplicate لأكتر من lead
  Future<void> bulkIgnoreDuplicate({required List<String> ids}) async {
    await bulkUpdateField(ids: ids, key: 'ignoredublicate', value: false);
  }

  // Delete (soft delete) لأكتر من lead
  Future<void> bulkDeleteLeads({required List<String> ids}) async {
    await bulkUpdateField(ids: ids, key: 'leadisactive', value: "false");
  }
}
