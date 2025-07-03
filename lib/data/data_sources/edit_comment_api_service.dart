// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class EditCommentApiService {
  final String baseUrl = '${Constants.baseUrl}/Action/comment';

  Future<bool> editComment({
    required String commentId,
    required String firstText,
    required String secondText,
  }) async {
    final url = Uri.parse('$baseUrl/$commentId');

    final body = jsonEncode({
      "firstText": firstText,
      "secondText": secondText,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('تم التحديث بنجاح');
        return true;
      } else {
        print('فشل التحديث: ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      print('حدث خطأ: $e');
      return false;
    }
  }
}
