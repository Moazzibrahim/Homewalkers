// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/meetingComments_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MeetingCommentsApiService {
  final String baseUrl = "${Constants.baseUrl}/Meetingcomments";

  Future<MeetingcommentsModel> fetchMeetingComments({
    num? page,
    num? limit,
    String? userId,

    String? stageIds,
    String? salesDeveloperIds,
    String? leadNames,
    String? phones,
    String? sales,

    String? stageDateFrom,
    String? stageDateTo,
    String? commentCreatedFrom,
    String? commentCreatedTo,
  }) async {
    try {
      Map<String, String> queryParams = {};

      /// ✅ مهم: اعمل نسخة محلية من الرابط
      String url = baseUrl;

      /// ✅ متستخدمش += على baseUrl نفسه
      if (userId != null && userId.isNotEmpty) {
        url = "$baseUrl/user/$userId";
      }

      // Pagination
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      if (stageIds != null && stageIds.isNotEmpty) {
        queryParams['stage'] = stageIds;
      }

      if (leadNames != null && leadNames.isNotEmpty) {
        queryParams['name'] = leadNames;
      }

      if (phones != null && phones.isNotEmpty) {
        queryParams['phone'] = phones;
      }

      if (stageDateFrom != null && stageDateFrom.isNotEmpty) {
        queryParams['stageDateFrom'] = stageDateFrom;
      }

      if (stageDateTo != null && stageDateTo.isNotEmpty) {
        queryParams['stageDateTo'] = stageDateTo;
      }

      if (commentCreatedFrom != null && commentCreatedFrom.isNotEmpty) {
        queryParams['createdFrom'] = commentCreatedFrom;
      }

      if (commentCreatedTo != null && commentCreatedTo.isNotEmpty) {
        queryParams['createdTo'] = commentCreatedTo;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse(url).replace(queryParameters: queryParams);

      print("🔗 Request URL: $uri");
      print("📋 Query Params: $queryParams");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📊 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("✅ Total Results: ${decoded['results']}");
        print("✅ Data Items: ${decoded['data']?.length}");
        return MeetingcommentsModel.fromJson(decoded);
      } else {
        print("❌ Error Body: ${response.body}");
        throw Exception("Failed to load Meeting Comments");
      }
    } catch (e) {
      print("🚨 API ERROR: $e");
      rethrow;
    }
  }
}
