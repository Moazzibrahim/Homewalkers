import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/add_comment_model.dart';
import 'package:http/http.dart' as http;

class AddCommentApiService {
  static Future<CommentResponse?> addComment({
    required String sales,
    required String text1,
    required String text2,
    required String date,
    required String leed,
    required String userlog,
    required String usernamelog,
  }) async {
    final Map<String, dynamic> body = {
      "sales": sales,
      "text1": text1,
      "text2": text2,
      "date": date,
      "leed": leed,
      "userlog": userlog,
      "usernamelog": usernamelog,
    };

    try {
      final response = await http.post(
        Uri.parse("${Constants.baseUrl}/Action"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Comment added successfully: ${jsonResponse['message']}');
        return CommentResponse.fromJson(jsonResponse);
      } else {
        print('❌ Failed: ${response.statusCode} => ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error adding comment: $e');
      return null;
    }
  }
}
