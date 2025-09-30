import 'dart:convert';
import 'package:homewalkers_app/core/constants/apiExceptions.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leadStagesModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangeStageApiService {
  static Future<Map<String, dynamic>> changeStage({
    required String leadId,
    required LeadStageRequest request,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/users/$leadId');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw ApiException('No token found in SharedPreferences');
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw ApiException(data['message'] ?? 'Failed to update stage',
            statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Failed to change stage: $e');
    }
  }

  static Future<Map<String, dynamic>> postLeadStage({
    required String leadId,
    required String date,
    required String stage,
    required String sales,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/LeadStages');
    final body = {
      "LeadId": leadId,
      "date": date,
      "stage": stage,
      "sales": sales,
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw ApiException(data['message'] ?? 'Failed to post lead stage',
            statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Failed to post lead stage: $e');
    }
  }
}
