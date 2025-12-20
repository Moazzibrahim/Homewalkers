// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/newCommentsModel.dart';
import 'package:http/http.dart' as http;

class Newcommentsapiservice {
  Future<NewCommentsModel> fetchLeadComments({
    required String leadId,
    required String userId,
    int page = 1,
    int limit = 5,
  }) async {
    final Uri url = Uri.parse(
      '${Constants.baseUrl}/Action/actions/$leadId/user/$userId/comments',
    );
    print("Fetching comments from URL: $url");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        print("body: ${response.body}");
        return NewCommentsModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load lead comments (status: ${response.statusCode} ${response.body})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch lead comments: $e');
    }
  }
}
