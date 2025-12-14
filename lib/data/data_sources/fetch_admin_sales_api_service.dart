import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/admin_sales_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FetchAdminSalesApiService {
  static const String _baseUrl =
      '${Constants.baseUrl}/users/admin/sales-Leads-count';

  Future<AdminSalesModel> getSalesLeadsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return AdminSalesModel.fromJson(decoded);
      } else {
        throw Exception(
          'Failed to fetch sales leads count | '
          'Status: ${response.statusCode} | '
          'Body: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
