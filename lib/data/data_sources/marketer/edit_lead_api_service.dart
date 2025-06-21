// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class EditLeadApiService {
  final String baseUrl = '${Constants.baseUrl}/users';

  Future<void> editLead({
    required String userId,
    String? phone,
    String? name,
    String? email,
  }) async {
    final url = Uri.parse('$baseUrl/$userId');

    // بناء البودي فقط من القيم اللي مش null
    Map<String, dynamic> body = {};
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
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
}
