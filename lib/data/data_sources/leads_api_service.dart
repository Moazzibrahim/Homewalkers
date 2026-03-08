// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/manager_new/manager_dashboard_pagination_model.dart';
import 'package:homewalkers_app/data/models/manager_new/manager_leads_pagiantion_model.dart';
import 'package:homewalkers_app/data/models/marketer_dashboard_model.dart';
import 'package:homewalkers_app/data/models/new_marketer_pagination_model.dart';
import 'package:homewalkers_app/data/models/salesLeadsModelWithPagination.dart';
import 'package:homewalkers_app/data/models/teamleader_pagination_leads_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetLeadsService {
  final String baseUrl = "${Constants.baseUrl}/users/filter-by-email-advanced";
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<LeadResponse> getAssignedData({
    int page = 1,
    int limit = 500,
    bool forDashboard = false,
    bool? data,
    bool? transferfromdata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? token = await _getToken();

      if (savedEmail == null || token == null) {
        throw Exception("Missing email or token.");
      }

      /// ✅ نبني الـ query parameters بدون تغيير الأسماء
      final queryParams = <String, String>{
        'email': savedEmail,
        'leadisactive': 'true',
      };

      if (data != null) {
        queryParams['data'] = data.toString();
      }

      if (transferfromdata != null) {
        queryParams['transferefromdata'] = transferfromdata.toString();
        // 👆 نفس الاسم بالظبط زي ما عندك
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/filter-by-email',
      ).replace(queryParameters: queryParams);
      print(" Constructed URL: $url");
      // ⏱️ Start measuring request time
      final stopwatch = Stopwatch()..start();
      print("Request URL: $url");

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      stopwatch.stop();
      final seconds = stopwatch.elapsedMilliseconds / 1000;
      print("Request loading time: ${seconds.toStringAsFixed(2)} seconds");

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print("API Response: ${jsonBody['data']?.length ?? 0} items");

        var leadsResponse = LeadResponse.fromJson(jsonBody);

        // ترتيب حسب التاريخ
        leadsResponse.data?.sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

        final allData = leadsResponse.data ?? [];

        if (forDashboard) {
          print("Dashboard mode: Returning ${allData.length} items");
          return LeadResponse(count: allData.length, data: allData);
        } else {
          final start = (page - 1) * limit;

          if (start >= allData.length) {
            return LeadResponse(count: allData.length, data: []);
          }

          final end = start + limit;
          final safeEnd = end > allData.length ? allData.length : end;
          final paginatedData = allData.sublist(start, safeEnd);

          print(
            "Pagination mode: page $page, showing ${paginatedData.length} items",
          );

          return LeadResponse(count: allData.length, data: paginatedData);
        }
      } else {
        throw Exception('❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error in getAssignedData: $e');
      rethrow;
    }
  }

  Future<Salesleadsmodelwithpagination?> fetchSalesLeadsWithPagination({
    int page = 1,
    int limit = 10,
    String? search, // الاسم، الايميل، واتساب، تليفون
    String? salesId,
    String? developerId,
    String? projectId,
    String? channelId,
    String? stageId,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    bool? data,
    bool? transferefromdata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final savedEmail = prefs.getString('email') ?? '';

      if (token.isEmpty) {
        print("Token not found!");
        return null;
      }

      // تجهيز query parameters
      // تجهيز query parameters
      Map<String, String> queryParams = {
        "page": page.toString(),
        "leadisactive": "true",
        "email": savedEmail,
        "limit": limit.toString(), // ✅ دائماً أضف الـ limit
      };

      // لو مفيش فلترة خالص، خلي limit موجود عشان pagination
      bool hasFilter =
          search != null ||
          salesId != null ||
          developerId != null ||
          projectId != null ||
          channelId != null ||
          stageId != null ||
          creationDateFrom != null ||
          creationDateTo != null ||
          stageDateFrom != null ||
          stageDateTo != null;

      if (search != null && search.isNotEmpty) {
        queryParams["keyword"] = search;
      }

      if (salesId != null) queryParams["sales"] = salesId;
      if (developerId != null) queryParams["developer"] = developerId;
      if (projectId != null) queryParams["project"] = projectId;
      if (channelId != null) queryParams["channel"] = channelId;
      if (stageId != null) queryParams["stage"] = stageId;
      if (data != null) {
        queryParams["data"] = data.toString();
      }
      if (transferefromdata != null) {
        queryParams["transferefromdata"] = transferefromdata.toString();
      }

      // تحويل التواريخ لبداية اليوم ونهاية اليوم
      DateTime startOfDay(DateTime date) =>
          DateTime.utc(date.year, date.month, date.day, 0, 0, 0);

      DateTime endOfDay(DateTime date) =>
          DateTime.utc(date.year, date.month, date.day, 23, 59, 59);

      if (creationDateFrom != null) {
        queryParams["createdFrom"] =
            startOfDay(creationDateFrom).toIso8601String();
      }
      if (creationDateTo != null) {
        queryParams["createdTo"] = endOfDay(creationDateTo).toIso8601String();
      }
      if (stageDateFrom != null) {
        queryParams["stageDateFrom"] =
            startOfDay(stageDateFrom).toIso8601String();
      }
      if (stageDateTo != null) {
        queryParams["stageDateTo"] = endOfDay(stageDateTo).toIso8601String();
      }

      // بناء URL مع query parameters
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      print("Request URL: $uri");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final result = Salesleadsmodelwithpagination.fromJson(jsonData);

        // لو فيه stageId ابعت اتعمل sort حسب stage date
        if (stageId != null && result.data != null) {
          result.data!.sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a.lastStageDateUpdated ?? '') ??
                DateTime(1970);
            DateTime dateB =
                DateTime.tryParse(b.lastStageDateUpdated ?? '') ??
                DateTime(1970);

            return dateA.compareTo(dateB); // من القديم للجديد
          });
        }

        return result;
      } else {
        print("Failed to load leads: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Error fetching leads: $e");
      return null;
    }
  }

  Future<TeamleaderPaginationLeadsModel?> fetchTeamLeaderLeadsWithPagination({
    int page = 1,
    int limit = 10,
    String? search, // الاسم، الايميل، واتساب، تليفون
    String? salesId,
    String? developerId,
    String? projectId,
    String? channelId,
    String? stageId,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    bool? data,
    bool? transferefromdata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final savedEmail = prefs.getString('email') ?? '';

      if (token.isEmpty) {
        print("Token not found!");
        return null;
      }

      // تجهيز query parameters
      // تجهيز query parameters
      Map<String, String> queryParams = {
        "page": page.toString(),
        "leadisactive": "true",
        "email": savedEmail,
        "limit": limit.toString(), // ✅ دائماً أضف الـ limit
      };

      // لو مفيش فلترة خالص، خلي limit موجود عشان pagination
      bool hasFilter =
          search != null ||
          salesId != null ||
          developerId != null ||
          projectId != null ||
          channelId != null ||
          stageId != null ||
          creationDateFrom != null ||
          creationDateTo != null ||
          stageDateFrom != null ||
          stageDateTo != null;

      if (search != null && search.isNotEmpty) {
        queryParams["keyword"] = search;
      }

      if (salesId != null) queryParams["sales"] = salesId;
      if (developerId != null) queryParams["developer"] = developerId;
      if (projectId != null) queryParams["project"] = projectId;
      if (channelId != null) queryParams["channel"] = channelId;
      if (stageId != null) queryParams["stage"] = stageId;
      if (data != null) {
        queryParams["data"] = data.toString();
      }
      if (transferefromdata != null) {
        queryParams["transferefromdata"] = transferefromdata.toString();
      }

      // تحويل التواريخ لبداية اليوم ونهاية اليوم
      DateTime startOfDay(DateTime date) =>
          DateTime.utc(date.year, date.month, date.day, 0, 0, 0);

      DateTime endOfDay(DateTime date) =>
          DateTime.utc(date.year, date.month, date.day, 23, 59, 59);

      if (creationDateFrom != null) {
        queryParams["createdFrom"] =
            startOfDay(creationDateFrom).toIso8601String();
      }
      if (creationDateTo != null) {
        queryParams["createdTo"] = endOfDay(creationDateTo).toIso8601String();
      }
      if (stageDateFrom != null) {
        queryParams["stageDateFrom"] =
            startOfDay(stageDateFrom).toIso8601String();
      }
      if (stageDateTo != null) {
        queryParams["stageDateTo"] = endOfDay(stageDateTo).toIso8601String();
      }

      // بناء URL مع query parameters
      final uri = Uri.parse(
        "${Constants.baseUrl}/users/teamleader-leads-withpagination",
      ).replace(queryParameters: queryParams);
      print("Request URL: $uri");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final result = TeamleaderPaginationLeadsModel.fromJson(jsonData);

        // لو فيه stageId ابعت اتعمل sort حسب stage date
        if (stageId != null && result.data != null) {
          result.data!.sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a.lastStageDateUpdated ?? '') ??
                DateTime(1970);
            DateTime dateB =
                DateTime.tryParse(b.lastStageDateUpdated ?? '') ??
                DateTime(1970);

            return dateA.compareTo(dateB); // من القديم للجديد
          });
        }

        return result;
      } else {
        print("Failed to load leads: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Error fetching leads: $e");
      return null;
    }
  }

  Future<bool> postMeetingCommentWithStage({
    required String leadId,
    required String stageId,
    required String comment,
    required String salesdeveloperName,
    required DateTime stageDate, // ✅ جديد
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("Token not found");
      }

      final url = Uri.parse(
        "${Constants.baseUrl}/Meetingcomments/$leadId/stage/$stageId",
      );

      print("POST URL: $url");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "comment": comment,
          "stageDate": stageDate.toUtc().toIso8601String(),
          "commentBy": prefs.getString('salesId'),
          "salesdeveloperName": salesdeveloperName,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          "Failed to post meeting comment: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error posting meeting comment: $e");
      rethrow;
    }
  }

  Future<LeadResponse> getLeadsDataByTeamLeader({
    bool? data,
    bool? transferfromdata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? token = await _getToken();

      if (savedEmail == null || token == null) {
        throw Exception("Missing email or token.");
      }

      final queryParams = {'email': savedEmail, 'leadisactive': 'true'};

      if (data != null) {
        queryParams['data'] = data.toString();
      }

      if (transferfromdata != null) {
        queryParams['transferefromdata'] = transferfromdata.toString();
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/teamleader-leads',
      ).replace(queryParameters: queryParams);

      print("Request URL: $url");

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);

        // ترتيب حسب التاريخ (الأحدث أولاً)
        leadsResponse.data?.sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

        if (leadsResponse.data != null && leadsResponse.data!.isNotEmpty) {
          Set<String> salesIds = {};
          Set<String> userLogs = {};

          for (var lead in leadsResponse.data!) {
            if (lead.sales?.id != null && lead.sales!.id!.isNotEmpty) {
              salesIds.add(lead.sales!.id!);
            }

            if (lead.sales?.userlog?.id != null &&
                lead.sales!.userlog!.id!.isNotEmpty) {
              userLogs.add(lead.sales!.userlog!.id!);
            }
          }

          await prefs.setStringList('teamLeaderSalesIds', salesIds.toList());

          await prefs.setStringList('teamLeaderUserLogs', userLogs.toList());
        }

        return leadsResponse;
      } else {
        throw Exception('Failed to load assigned data: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in getLeadsDataByTeamLeader: $e');
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

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<ManagerDashboardPaginationModel?> fetchManagerDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final email = prefs.getString('email');

      if (token == null || token.isEmpty) {
        log("❌ Token not found");
        return null;
      }

      final url = "${Constants.baseUrl}/users/stage-Dashboard-Manager/$email";

      log("📤 GET URL: $url");

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      log("✅ STATUS CODE: ${response.statusCode}");
      log("📦 RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        return ManagerDashboardPaginationModel.fromJson(response.data);
      } else {
        log("❌ Unexpected status code: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      log("❌ DIO ERROR");
      log("🔴 STATUS CODE: ${e.response?.statusCode}");
      log("🔴 RESPONSE: ${e.response?.data}");
      return null;
    } catch (e) {
      log("❌ GENERAL ERROR: $e");
      return null;
    }
  }

  Future<ManagerDashboardPaginationModel?> fetchManagerDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final email = prefs.getString('email');

      if (token == null || token.isEmpty) {
        log("❌ Token not found");
        return null;
      }

      final url =
          "${Constants.baseUrl}/users/stage-Dashboard-Manager-crmdata/$email";

      log("📤 GET URL: $url");

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      log("✅ STATUS CODE: ${response.statusCode}");
      log("📦 RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        return ManagerDashboardPaginationModel.fromJson(response.data);
      } else {
        log("❌ Unexpected status code: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      log("❌ DIO ERROR");
      log("🔴 STATUS CODE: ${e.response?.statusCode}");
      log("🔴 RESPONSE: ${e.response?.data}");
      return null;
    } catch (e) {
      log("❌ GENERAL ERROR: $e");
      return null;
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

      final urlmarketerDashboard = Uri.parse(
        '${Constants.baseUrl}/users/marketer-leads?email=$savedEmail&leadisactive=true',
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

  /// ✅ دالة مساعدة لبداية اليوم بالتوقيت المحلي ثم تحويلها لـ UTC
  /// دالة مساعدة لبداية اليوم كـ String بالتوقيت المحلي
  String startOfDayLocalString(DateTime date) {
    // إرجاع التاريخ بصيغة YYYY-MM-DD 00:00:00
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')} "
        "00:00:00";
  }

  /// دالة مساعدة لنهاية اليوم كـ String بالتوقيت المحلي
  String endOfDayLocalString(DateTime date) {
    // إرجاع التاريخ بصيغة YYYY-MM-DD 23:59:59
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')} "
        "23:59:59";
  }

  Future<CrmLeadsResponse> fetchManagerLeads({
    bool? data,
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? salesIds,
    List<String>? developerIds,
    List<String>? projectIds,
    List<String>? channelIds,
    List<String>? campaignIds,
    List<String>? communicationWayIds,
    List<String>? stageIds,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,
    bool? ignoreDuplicate,
    bool? transferefromdata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');
      final String? token = prefs.getString('token');

      if (email == null || email.isEmpty) {
        throw Exception('Email not found');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }

      /// 🔹 تحديد الـ endpoint
      final String endpoint =
          (data ?? false)
              ? "users/managers-leads"
              : "users/managers-leads-crm-data";

      /// 🔹 Query Parameters الأساسية
      Map<String, String> queryParameters = {
        "email": email,
        "page": page.toString(),
        "limit": limit.toString(),
      };

      /// 🔹 Search
      if (search != null && search.isNotEmpty) {
        queryParameters["keyword"] = search;
      }

      /// 🔹 Join arrays
      if (salesIds != null && salesIds.isNotEmpty) {
        queryParameters["sales"] = salesIds.join(",");
      }

      if (developerIds != null && developerIds.isNotEmpty) {
        queryParameters["developerParam"] = developerIds.join(",");
      }

      if (projectIds != null && projectIds.isNotEmpty) {
        queryParameters["projectParam"] = projectIds.join(",");
      }

      if (channelIds != null && channelIds.isNotEmpty) {
        queryParameters["channel"] = channelIds.join(",");
      }

      if (campaignIds != null && campaignIds.isNotEmpty) {
        queryParameters["campaign"] = campaignIds.join(",");
      }

      if (communicationWayIds != null && communicationWayIds.isNotEmpty) {
        queryParameters["communicationway"] = communicationWayIds.join(",");
      }

      if (stageIds != null && stageIds.isNotEmpty) {
        queryParameters["stage"] = stageIds.join(",");
      }

      if (ignoreDuplicate != null) {
        queryParameters["ignoredublicate"] = ignoreDuplicate.toString();
      }

      if (transferefromdata != null) {
        queryParameters["transferefromdata"] = transferefromdata.toString();
      }

      if (creationDateFrom != null) {
        queryParameters["createdFrom"] = startOfDayLocalString(
          creationDateFrom,
        );
      }

      if (creationDateTo != null) {
        queryParameters["createdTo"] = endOfDayLocalString(creationDateTo);
      }

      if (lastStageUpdateFrom != null) {
        queryParameters["stageDateFrom"] = startOfDayLocalString(
          lastStageUpdateFrom,
        );
      }

      if (lastStageUpdateTo != null) {
        queryParameters["stageDateTo"] = endOfDayLocalString(lastStageUpdateTo);
      }

      if (stageDateFrom != null) {
        queryParameters["stageDateFrom"] = startOfDayLocalString(stageDateFrom);
      }

      if (stageDateTo != null) {
        queryParameters["stageDateTo"] = endOfDayLocalString(stageDateTo);
      }

      /// 🔹 Build URL
      final Uri url = Uri.parse(
        "${Constants.baseUrl}/$endpoint",
      ).replace(queryParameters: queryParameters);

      print("📡 Fetching Manager Leads: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return CrmLeadsResponse.fromJson(decoded);
      } else {
        throw Exception(
          "Failed: ${response.statusCode} - ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      print("❌ Error fetching manager leads: $e");
      throw Exception("Error fetching manager leads: $e");
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

  static const String _baseUrl =
      "${Constants.baseUrl}/users/stages-with-duplicate-by-addedby/";

  static const String _leadsBaseUrl =
      "${Constants.baseUrl}/users/stages-crm-data-with-duplicate-by-addedby/";

  Future<MarketerDashboardModel> fetchMarketerDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? userId = prefs.getString("salesId");
      final String? token = prefs.getString("token");

      if (userId == null || token == null) {
        throw Exception("User ID or Token not found in SharedPreferences");
      }

      final url = Uri.parse("$_baseUrl$userId");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return MarketerDashboardModel.fromJson(decoded);
      } else {
        throw Exception(
          "Failed to load dashboard data: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching dashboard data: $e");
    }
  }

  Future<MarketerDashboardModel> fetchMarketerDataDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? userId = prefs.getString("salesId");
      final String? token = prefs.getString("token");

      if (userId == null || token == null) {
        throw Exception("User ID or Token not found in SharedPreferences");
      }

      final url = Uri.parse("$_leadsBaseUrl$userId");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return MarketerDashboardModel.fromJson(decoded);
      } else {
        throw Exception(
          "Failed to load dashboard data: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching dashboard data: $e");
    }
  }

  Future<NewMarketerPaginationModel> fetchleadsMarketerWithPagination({
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? salesIds,
    List<String>? developerIds,
    List<String>? projectIds,
    List<String>? channelIds,
    List<String>? campaignIds,
    List<String>? communicationWayIds,
    List<String>? stageIds,
    List<String>? addedByIds,
    List<String>? assignedFromIds,
    List<String>? assignedToIds,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,
    bool? duplicates,
    bool? ignoreDuplicate,
    bool? data,
    bool? transferefromdata,
  }) async {
    try {
      // Get email and token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');
      final String? token = prefs.getString('token');
      final String urll;

      // Check if email and token exist
      if (email == null || email.isEmpty) {
        throw Exception('Email not found in SharedPreferences');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      // Build query parameters
      Map<String, String> queryParameters = {
        'email': email,
        'leadisactive': 'true',
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Check if there are any filters
      bool hasFilter =
          search != null ||
          (salesIds != null && salesIds.isNotEmpty) ||
          (developerIds != null && developerIds.isNotEmpty) ||
          (projectIds != null && projectIds.isNotEmpty) ||
          (channelIds != null && channelIds.isNotEmpty) ||
          (campaignIds != null && campaignIds.isNotEmpty) ||
          (communicationWayIds != null && communicationWayIds.isNotEmpty) ||
          (stageIds != null && stageIds.isNotEmpty) ||
          (addedByIds != null && addedByIds.isNotEmpty) ||
          (assignedFromIds != null && assignedFromIds.isNotEmpty) ||
          (assignedToIds != null && assignedToIds.isNotEmpty) ||
          creationDateFrom != null ||
          creationDateTo != null ||
          lastStageUpdateFrom != null ||
          lastStageUpdateTo != null ||
          lastCommentDateFrom != null ||
          lastCommentDateTo != null ||
          stageDateFrom != null ||
          stageDateTo != null;

      // Add search parameter
      if (search != null && search.isNotEmpty) {
        queryParameters["keyword"] = search;
      }

      /// ✅ Join arrays with comma
      if (salesIds != null && salesIds.isNotEmpty) {
        queryParameters["sales"] = salesIds.join(",");
      }

      if (developerIds != null && developerIds.isNotEmpty) {
        queryParameters["developer"] = developerIds.join(",");
      }

      if (projectIds != null && projectIds.isNotEmpty) {
        queryParameters["project"] = projectIds.join(",");
      }

      if (channelIds != null && channelIds.isNotEmpty) {
        queryParameters["chanel"] = channelIds.join(",");
      }

      if (campaignIds != null && campaignIds.isNotEmpty) {
        queryParameters["campaign"] = campaignIds.join(",");
      }

      if (communicationWayIds != null && communicationWayIds.isNotEmpty) {
        queryParameters["communicationway"] = communicationWayIds.join(",");
      }

      if (stageIds != null && stageIds.isNotEmpty) {
        queryParameters["stage"] = stageIds.join(",");
      }

      if (ignoreDuplicate != null) {
        queryParameters["ignoredublicate"] = ignoreDuplicate.toString();
      }

      // Add date filters
      if (creationDateFrom != null) {
        queryParameters["createdFrom"] = startOfDayLocalString(
          creationDateFrom,
        );
      }

      if (creationDateTo != null) {
        queryParameters["createdTo"] = endOfDayLocalString(creationDateTo);
      }

      if (lastStageUpdateFrom != null) {
        queryParameters["stageDateFrom"] = startOfDayLocalString(
          lastStageUpdateFrom,
        );
      }

      if (lastStageUpdateTo != null) {
        queryParameters["stageDateTo"] = endOfDayLocalString(lastStageUpdateTo);
      }

      if (stageDateFrom != null) {
        queryParameters["stageDateFrom"] = startOfDayLocalString(stageDateFrom);
      }

      if (stageDateTo != null) {
        queryParameters["stageDateTo"] = endOfDayLocalString(stageDateTo);
      }
      if (transferefromdata == true) {
        urll = "users/GetAllLeadsAddedByUser-advanced";
      } else {
        urll = "users/GetAllLeadsAddedByUser-crmdata-advanced";
      }
      // Build the URL with all query parameters
      final Uri url = Uri.parse(
        '${Constants.baseUrl}/$urll',
      ).replace(queryParameters: queryParameters);

      // For debugging - print the URL
      print('Fetching leads from: $url');

      // Make the API request with authorization header
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse the response body to JSON
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Convert JSON to model
        return NewMarketerPaginationModel.fromJson(jsonResponse);
      } else {
        // Handle error response
        throw Exception(
          'Failed to load leads: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Handle any errors
      print('Error fetching leads: $e');
      throw Exception('Error fetching leads: $e');
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

        // لو مفيش داتا خالص
        if (leadsResponse.data == null || leadsResponse.data!.isEmpty) {
          throw Exception("No leads returned from API.");
        }

        // ترتيب حسب التاريخ
        leadsResponse.data?.sort((a, b) {
          final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

        // قراءة أول Lead بطريقة آمنة
        final firstLead = leadsResponse.data!.first;

        final userLogId = firstLead.sales?.userlog?.id;
        final managerId = firstLead.sales?.manager?.id;
        final managerName = firstLead.sales?.manager?.name;

        // حفظ بطريقة آمنة بدون Crash
        if (userLogId != null) {
          await prefs.setString('userlog', userLogId);
        }

        await prefs.setString('markteridSpecific', managerId ?? '');
        await prefs.setString('markterName', managerName ?? '');

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
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');

      if (token == null) {
        throw Exception("Missing token.");
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/users/GetAllLeadsAddedByUser-advanced?leadisactive=false&email=$email',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final leadsResponse = LeadResponse.fromJson(jsonBody);
        log("✅ Get leads successfully by marketer (Trash)}");
        print("url: $url");
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
