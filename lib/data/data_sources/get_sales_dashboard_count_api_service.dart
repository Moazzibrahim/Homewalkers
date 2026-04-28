import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/Data/sales_data_dashboard_count_model.dart';
import 'package:homewalkers_app/data/models/sales_dashboard_model.dart';
import 'package:homewalkers_app/presentation/widgets/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesDashboardApiService {
  static final String _baseUrl =
      '${Constants.baseUrl}/users/sales/dashboard/fast';

  /// Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get email from SharedPreferences
  Future<String?> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  /// Fetch sales dashboard data
  Future<SalesStagesResponse> fetchSalesDashboard() async {
    try {
      final token = await _getToken();
      final email = await _getEmail();

      if (token == null || email == null) {
        throw Exception('Missing token or email');
      }

      final url = Uri.parse('$_baseUrl/$email');

      final response = await HttpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SalesStagesResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch sales dashboard: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Sales Dashboard API Error: $e');
    }
  }

  /// Fetch sales dashboard count data
  Future<SalesDataDashboardCountModel> fetchSalesDataDashboardCount() async {
    try {
      final token = await _getToken();
      final email = await _getEmail();

      if (token == null || email == null) {
        throw Exception('Missing token or email');
      }

      final url = Uri.parse('$_baseUrl/CRMDATA/$email');

      final response = await HttpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;

        return SalesDataDashboardCountModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch sales dashboard: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Sales Dashboard API Error: $e');
    }
  }
}
