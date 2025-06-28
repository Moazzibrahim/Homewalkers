// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/cancel_reason_model.dart';
import 'package:http/http.dart' as http;

class CancelReasonApiService {
  final String _baseUrl = '${Constants.baseUrl}/cancelreason';

  Future<CancelReasonResponse?> getCancelReasons() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CancelReasonResponse.fromJson(jsonData);
      } else {
        print('Failed to load cancel reasons: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching cancel reasons: $e');
      return null;
    }
  }
  Future<CancelReasonResponse?> getCancelReasonsInTrash() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl?isactive=false"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CancelReasonResponse.fromJson(jsonData);
      } else {
        print('Failed to load cancel reasons: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching cancel reasons: $e');
      return null;
    }
  }
}
