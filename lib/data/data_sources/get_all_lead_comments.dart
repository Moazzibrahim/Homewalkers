// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_assigned_model.dart';
import 'package:homewalkers_app/data/models/newCommentsModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetAllLeadCommentsApiService {
  Future<LeadCommentsModel> fetchActionData({required String leedId}) async {
    final Uri url = Uri.parse('${Constants.baseUrl}/Action?leed=$leedId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(
          'Lead Comments JSON Data: ${response.body}',
        ); // طباعة البيانات المستلمة
        return LeadCommentsModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load data, status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // دالة جديدة لجلب بيانات LeadAssigned
  Future<LeadAssignedModel> fetchLeadAssigned(String id) async {
    final Uri url = Uri.parse('${Constants.baseUrl}/LeadAssigned?LeadId=$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return LeadAssignedModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load LeadAssigned data');
    }
  }

  // ✅ New function to post a reply to a comment
  Future<void> postReply({
    required String commentId,
    required String replyText,
  }) async {
    final Uri url = Uri.parse('${Constants.baseUrl}/Action/reply');

    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final prefs = await SharedPreferences.getInstance();
    final salesId = prefs.getString('salesId');

    final Map<String, dynamic> body = {
      'commentId': commentId,
      'replyText': replyText,
      'userId': salesId,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to post reply. Status code: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to send reply: $e');
    }
  }

  Future<NewCommentsModel> fetchNewComments({
    required String leadId,
    int? page,
    int? limit,
  }) async {
    try {
      // بناء URL مع معاملات التصفية الاختيارية
      final queryParameters = <String, String>{};
      if (page != null) queryParameters['page'] = page.toString();
      if (limit != null) queryParameters['limit'] = limit.toString();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('salesId');

      final uri = Uri.parse(
        '${Constants.baseUrl}/Action/actions/$leadId/user/$userId/comments',
      ).replace(queryParameters: queryParameters);

      // إرسال الطلب
      final response = await http.get(uri, headers: _getHeaders());

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return NewCommentsModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch comments. Status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON response: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // يمكن إضافة رأسيات إضافية مثل التوثيق
      // 'Authorization': 'Bearer $token',
    };
  }
}
