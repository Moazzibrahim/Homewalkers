import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:http/http.dart' as http;

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
}
