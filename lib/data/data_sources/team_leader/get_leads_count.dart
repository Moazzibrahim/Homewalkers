// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/team_leader/get_leads_count_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // This should be your model file

class GetLeadsCountApiService {
  static const String baseUrl =
      '${Constants.baseUrl}/users/Get_Sales_Data_And_Thier_Leads_Data';
  Future<TeamLeaderResponse?> fetchSalesData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');

    if (savedEmail == null) {
      throw Exception("No saved email found.");
    }

    final Uri url = Uri.parse('$baseUrl?email=$savedEmail');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TeamLeaderResponse.fromJson(jsonData);
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching sales data: $e');
      return null;
    }
  }
}
