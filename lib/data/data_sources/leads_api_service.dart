// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:developer';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetLeadsService {
  Future<LeadResponse> getAssignedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');

      if (savedEmail == null) {
        throw Exception("No saved email found.");
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/filter-by-email?email=$savedEmail',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);
        log("✅ Get leads successfully");
        bool result = await prefs.setInt(
          'lastLeadCount',
          leadsResponse.count ?? 0,
        );
        bool userlogResult = await prefs.setString(
          'userlog',
          leadsResponse.data!.first.sales!.userlog!.id.toString(),
        );

        log("✅ Last count stored: ${leadsResponse.count}, success: $result");
        return leadsResponse;
      } else {
        throw Exception(
          '❌ Failed to load assigned data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getAssignedData: $e');
      rethrow;
    }
  }

  Future<LeadResponse> getLeadsDataByTeamLeader() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');

      if (savedEmail == null) {
        throw Exception("No saved email found.");
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/teamleader-leads?email=$savedEmail',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);
        final teamLeaderIddSpecific =
            leadsResponse.data?.first.sales?.teamleader?.id;
        bool result = await prefs.setString(
          'teamLeaderIddspecific',
          teamLeaderIddSpecific ?? '',
        );
        log("✅ Get leads successfully by team leader");
        return leadsResponse;
      } else {
        throw Exception(
          '❌ Failed to load assigned data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getAssignedData: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getLeadCountPerSales() async {
    try {
      LeadResponse leadResponse =
          await getLeadsDataByTeamLeader(); // أو getAssignedData لو بتشتغل على الداتا دي

      List<LeadData> leads = leadResponse.data ?? [];

      Map<String, int> salesLeadCount = {};

      for (var lead in leads) {
        String? salesName = lead.sales?.name ?? 'Unknown';

        if (salesLeadCount.containsKey(salesName)) {
          salesLeadCount[salesName] = salesLeadCount[salesName]! + 1;
        } else {
          salesLeadCount[salesName] = 1;
        }
      }

      return salesLeadCount;
    } catch (e) {
      log('❌ Error in getLeadCountPerSales: $e');
      return {};
    }
  }
}
