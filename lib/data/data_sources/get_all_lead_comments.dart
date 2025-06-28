import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_assigned_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetAllLeadCommentsApiService {
  Future<LeadCommentsModel> fetchActionData({required String leedId}) async {
    final Uri url = Uri.parse('${Constants.baseUrl}/Action?leed=$leedId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
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

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final leadAssigned = LeadAssignedModel.fromJson(jsonData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          'clearHistory',
          leadAssigned.data!.first.clearHistory!,
        );
        return leadAssigned; // لو الموديل يبدأ من key "data"
      } else {
        throw Exception(
          'Failed to load LeadAssigned data, status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch LeadAssigned data: $e');
    }
  }
   // ✅ New function to post a reply to a comment
  Future<void> postReply({
    required String commentId,
    required String replyText,
  }) async {
    final Uri url = Uri.parse('${Constants.baseUrl}/Action/reply');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

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
}
