// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/team_leader/get_sales_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetSalesTeamLeaderApiService {
  Future<SalesTeamModel?> getSalesTeamLeader() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');

      if (savedEmail == null) {
        throw Exception("No saved email found.");
      }
      final String url =
          '${Constants.baseUrl}/Sales/salesbyemail?email=$savedEmail';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Get sales successfully");
        return SalesTeamModel.fromJson(data);
      } else {
        print(
          'Failed to fetch sales team leader data. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching sales team leader: $e');
      return null;
    }
  }
}
