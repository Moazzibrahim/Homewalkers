// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetLeadsService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<LeadResponse> getAssignedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? token = await _getToken();

      if (savedEmail == null || token == null) {
        throw Exception("Missing email or token.");
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/filter-by-email?email=$savedEmail&leadisactive=true',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);

        // ✅ ترتيب البيانات حسب التاريخ (من الأحدث إلى الأقدم)
        leadsResponse.data?.sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA); // الأحدث أولاً
        });

        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print('${lead.name} - date: ${lead.date}');
        });

        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print(
            '${lead.name} - date: ${lead.date} | last_stage_date_updated: ${lead.stagedateupdated}',
          );
        });

        log("✅ Get leads successfully");
        await prefs.setInt('lastLeadCount', leadsResponse.count ?? 0);
        await prefs.setString(
          'userlog',
          leadsResponse.data!.first.sales!.userlog!.id.toString(),
        );
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
      String? token = await _getToken();

      if (savedEmail == null || token == null) {
        throw Exception("Missing email or token.");
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/teamleader-leads?email=$savedEmail&leadisactive=true',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);

        leadsResponse.data?.sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA); // الأحدث أولاً
        });

        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print('${lead.name} - date: ${lead.date}');
        });
        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print(
            '${lead.name} - date: ${lead.date} | last_stage_date_updated: ${lead.lastStageDateUpdated}',
          );
        });

        // 🧠 حفظ بيانات إضافية
        if (leadsResponse.data != null && leadsResponse.data!.isNotEmpty) {
          await prefs.setString(
            'userlog',
            leadsResponse.data!.first.sales?.userlog?.id ?? '',
          );
          await prefs.setString(
            'teamLeaderIddspecific',
            leadsResponse.data!.first.sales?.teamleader?.id ?? '',
          );
        }

        return leadsResponse;
      } else {
        throw Exception(
          '❌ Failed to load assigned data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getLeadsDataByTeamLeader: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getLeadCountPerStage() async {
    try {
      LeadResponse leadResponse = await getLeadsDataByTeamLeader();
      final Map<String, int> stageCounts = {};

      for (var lead in leadResponse.data!) {
        String stageName = lead.stage?.name ?? "Unknown";
        stageCounts[stageName] = (stageCounts[stageName] ?? 0) + 1;
      }

      log("📊 Lead count per stage: $stageCounts");
      return stageCounts;
    } catch (e) {
      log("❌ Error while counting leads per stage: $e");
      return {};
    }
  }

  Future<Map<String, int>> getLeadCountPerStageInSales() async {
    try {
      LeadResponse leadResponse = await getAssignedData();
      final Map<String, int> stageCounts = {};

      for (var lead in leadResponse.data!) {
        String stageName = lead.stage?.name ?? "Unknown";
        stageCounts[stageName] = (stageCounts[stageName] ?? 0) + 1;
      }

      log("📊 Lead count per stage (Sales): $stageCounts");
      return stageCounts;
    } catch (e) {
      log("❌ Error while counting leads per stage: $e");
      return {};
    }
  }

  Future<LeadResponse> getLeadsDataByManager() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? token = await _getToken();

      if (savedEmail == null || token == null) {
        throw Exception("Missing email or token.");
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/managers-leads?email=$savedEmail&leadisactive=true',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);

        // ✅ ترتيب البيانات حسب التاريخ (من الأحدث إلى الأقدم)
        leadsResponse.data?.sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA); // الأحدث أولاً
        });

        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print('${lead.name} - date: ${lead.date}');
        });
        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print(
            '${lead.name} - date: ${lead.date} | last_stage_date_updated: ${lead.lastStageDateUpdated}',
          );
        });

        // 🧠 حفظ بيانات إضافية
        await prefs.setString(
          'userlog',
          leadsResponse.data!.first.sales!.userlog!.id.toString(),
        );
        await prefs.setString(
          'managerIdspecific',
          leadsResponse.data?.first.sales?.manager?.id ?? '',
        );
        await prefs.setString(
          'managerName',
          leadsResponse.data?.first.sales?.manager?.name ?? '',
        );

        return leadsResponse;
      } else {
        throw Exception(
          '❌ Failed to load manager data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getLeadsDataByManager: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getLeadCountPerStageInManager() async {
    try {
      LeadResponse leadResponse = await getLeadsDataByManager();
      final Map<String, int> stageCounts = {};

      for (var lead in leadResponse.data!) {
        String stageName = lead.stage?.name ?? "Unknown";
        stageCounts[stageName] = (stageCounts[stageName] ?? 0) + 1;
      }

      log("📊 Lead count per stage (Manager): $stageCounts");
      return stageCounts;
    } catch (e) {
      log("❌ Error while counting leads per stage (Manager): $e");
      return {};
    }
  }

  Future<LeadResponse> getLeadsDataByMarketer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? token = await _getToken();

      if (savedEmail == null || token == null) {
        throw Exception("Missing email or token.");
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/GetAllLeadsAddedByUser?email=$savedEmail&leadisactive=true',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);

        // ✅ ترتيب البيانات حسب التاريخ (من الأحدث إلى الأقدم)
        leadsResponse.data?.sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA); // الأحدث أولاً
        });

        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print('${lead.name} - date: ${lead.date}');
        });
        // 🖨️ طباعة أول 5 عناصر للتأكد من الترتيب
        leadsResponse.data?.take(5).forEach((lead) {
          print(
            '${lead.name} - date: ${lead.date} | last_stage_date_updated: ${lead.lastStageDateUpdated}',
          );
        });

        // 🧠 حفظ بيانات إضافية
        await prefs.setString(
          'userlog',
          leadsResponse.data!.first.sales!.userlog!.id.toString(),
        );
        await prefs.setString(
          'markteridSpecific',
          leadsResponse.data?.first.sales?.manager?.id ?? '',
        );
        await prefs.setString(
          'markterName',
          leadsResponse.data?.first.sales?.manager?.name ?? '',
        );

        return leadsResponse;
      } else {
        throw Exception(
          '❌ Failed to load marketer data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getLeadsDataByMarketer: $e');
      rethrow;
    }
  }

  Future<LeadResponse> getLeadsDataByMarketerInTrash() async {
    try {
      final String? token = await _getToken();

      if (token == null) {
        throw Exception("Missing token.");
      }

      final url = Uri.parse('${Constants.baseUrl}/users?leadisactive=false');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);
        log("✅ Get leads successfully by marketer (Trash)");
        return leadsResponse;
      } else {
        throw Exception(
          '❌ Failed to load leads in trash: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('❌ Error in getLeadsDataByMarketerInTrash: $e');
      rethrow;
    }
  }
}
