// lib/data/data_sources/request_leads_api_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/get_all_lead_requests_model.dart';
import 'package:homewalkers_app/data/models/request_leads_model.dart';
import 'package:homewalkers_app/presentation/widgets/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestLeadsFromDataApiService {
  final String? baseUrl = Constants.baseUrl;

  /// Request leads from data centre
  /// [requestedLimit] - Number of leads to request
  Future<RequestLeadsResponse> requestLeads({
    required int requestedLimit,
  }) async {
    if (baseUrl == null) {
      throw Exception("Base URL not set. Please set company domain first.");
    }

    try {
      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('salesId');

      if (userId == null || userId.isEmpty) {
        throw Exception("User ID not found. Please login again.");
      }

      final url = Uri.parse("$baseUrl/users/sales/request-leads-from-data");

      final Map<String, dynamic> requestBody = {
        "userId": userId,
        "requestedLimit": requestedLimit,
      };

      log("📤 Requesting leads from data centre");
      log("📍 URL: $url");
      log("📦 Body: ${jsonEncode(requestBody)}");

      final response = await HttpClient.post(
        url,
        body: jsonEncode(requestBody),
      );

      log("📥 Response Status: ${response.statusCode}");
      log("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return RequestLeadsResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              errorData['error'] ??
              "Failed to request leads. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      log("❌ Error requesting leads: $e");
      rethrow;
    }
  }

  /// Get all requests history with pagination and filters
  /// No need to send userId because it's extracted from the token
  Future<GetAllRequestsResponse> getAllRequests({
    int page = 1,
    int limit = 20,
    String? fromDate,
    String? toDate,
    String? status,
    String? userId,
  }) async {
    if (baseUrl == null) {
      throw Exception("Base URL not set. Please set company domain first.");
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = userId ?? prefs.getString('salesId');
      if (effectiveUserId == null || effectiveUserId.isEmpty) {
        throw Exception("User ID not found. Please login again.");
      }
      // Build query parameters (no userId needed, token handles authentication)
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add date filters if provided
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['fromDate'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['toDate'] = toDate;
      }
      if (userId != null && userId.isNotEmpty) {
        queryParams['userId'] = userId;
      }

      // Build URL with query parameters
      final uri = Uri.parse(
        "$baseUrl/users/sales/request-leads-from-data",
      ).replace(queryParameters: queryParams);

      log("📤 Getting all requests history");
      log("📍 URL: $uri");
      log("📊 Page: $page, Limit: $limit");
      if (fromDate != null) log("📅 From Date: $fromDate");
      if (toDate != null) log("📅 To Date: $toDate");
      if (status != null) log("🏷️ Status filter: $status");
      if (userId != null) log("🔍 Filtering by specific userId: $userId");

      final response = await HttpClient.get(uri);

      log("📥 Response Status: ${response.statusCode}");
      log("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        GetAllRequestsResponse allRequests = GetAllRequestsResponse.fromJson(
          responseData,
        );

        // Apply status filter if provided (client-side filtering)
        if (status != null && status.isNotEmpty) {
          final filteredData =
              allRequests.data
                  .where((request) => request.status == status)
                  .toList();
          allRequests = GetAllRequestsResponse(
            status: allRequests.status,
            results: filteredData.length,
            data: filteredData,
            pagination: allRequests.pagination,
          );
          log(
            "📊 Filtered by status '$status': ${filteredData.length} results",
          );
        }

        return allRequests;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              errorData['error'] ??
              "Failed to get requests history. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      log("❌ Error getting requests history: $e");
      rethrow;
    }
  }
}
