// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/data/models/leadsAdminModelWithPagination.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class LeadsApiServiceWithQuery {
  final String baseUrl = "${Constants.baseUrl}/users/admin/allleadspagination";

  /// fetch leads with query params (search + filters + pagination)
  Future<Leadsadminmodelwithpagination?> fetchLeads({
    int page = 1,
    int limit = 10,
    String? search, // الاسم، الايميل، واتساب، تليفون
    String? salesId,
    String? developerId,
    String? projectId,
    String? channelId,
    String? campaignId,
    String? communicationWayId,
    String? stageId,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    String? addedById,
    String? assignedFromId,
    String? assignedToId,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,
    bool? duplicates,
    bool? ignoreDuplicate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        print("Token not found!");
        return null;
      }

      // تجهيز query parameters
      // تجهيز query parameters
      Map<String, String> queryParams = {
        "page": page.toString(),
        "leadisactive": "true",
      };

      // لو مفيش فلترة خالص، خلي limit موجود عشان pagination
      bool hasFilter =
          search != null ||
          salesId != null ||
          developerId != null ||
          projectId != null ||
          channelId != null ||
          campaignId != null ||
          communicationWayId != null ||
          stageId != null ||
          addedById != null ||
          assignedFromId != null ||
          assignedToId != null ||
          creationDateFrom != null ||
          creationDateTo != null ||
          lastStageUpdateFrom != null ||
          lastStageUpdateTo != null ||
          lastCommentDateFrom != null ||
          lastCommentDateTo != null ||
          stageDateFrom != null ||
          stageDateTo != null;

      if (!hasFilter) {
        queryParams["limit"] = limit.toString();
      }

      if (search != null && search.isNotEmpty) {
        queryParams["keyword"] = search;
      }

      if (salesId != null) queryParams["sales"] = salesId;
      if (developerId != null) queryParams["developer"] = developerId;
      if (projectId != null) queryParams["project"] = projectId;
      if (channelId != null) queryParams["chanel"] = channelId;
      if (campaignId != null) queryParams["campaign"] = campaignId;
      if (communicationWayId != null) {
        queryParams["communicationway"] = communicationWayId;
      }
      if (stageId != null) queryParams["stage"] = stageId;
      if (addedById != null) queryParams["addedBy"] = addedById;
      if (assignedFromId != null) queryParams["assignedFrom"] = assignedFromId;
      if (assignedToId != null) queryParams["assignedTo"] = assignedToId;
      if (ignoreDuplicate != null) {
        queryParams["ignoreduplicate"] = ignoreDuplicate.toString();
        queryParams["duplicates"] = ignoreDuplicate.toString();
      }

      // تحويل التواريخ لبداية اليوم ونهاية اليوم
      DateTime startOfDay(DateTime date) =>
          DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay(DateTime date) =>
          DateTime(date.year, date.month, date.day, 23, 59, 59);

      if (creationDateFrom != null) {
        queryParams["createdAt[gte]"] =
            startOfDay(creationDateFrom).toIso8601String();
      }
      if (creationDateTo != null) {
        queryParams["createdAt[lte]"] =
            endOfDay(creationDateTo).toIso8601String();
      }

      if (lastStageUpdateFrom != null) {
        queryParams["last_stage_date_updated[gte]"] =
            startOfDay(lastStageUpdateFrom).toIso8601String();
      }
      if (lastStageUpdateTo != null) {
        queryParams["last_stage_date_updated[lte]"] =
            endOfDay(lastStageUpdateTo).toIso8601String();
      }

      if (lastCommentDateFrom != null) {
        queryParams["lastcommentdate[gte]"] =
            startOfDay(lastCommentDateFrom).toIso8601String();
      }
      if (lastCommentDateTo != null) {
        queryParams["lastcommentdate[lte]"] =
            endOfDay(lastCommentDateTo).toIso8601String();
      }

      if (stageDateFrom != null) {
        queryParams["stagedateupdated[gte]"] =
            startOfDay(stageDateFrom).toIso8601String();
      }
      if (stageDateTo != null) {
        queryParams["stagedateupdated[lte]"] =
            endOfDay(stageDateTo).toIso8601String();
      }

      // بناء URL مع query parameters
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Leadsadminmodelwithpagination.fromJson(jsonData);
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

  Future<Leadsadminmodelwithpagination?> fetchLeadsInTrash({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        print("Token not found!");
        return null;
      }

      // 🗑️ route بتاع الـ trash
      final uri = Uri.parse(
        "${Constants.baseUrl}/users/admin/allleadspagination",
      ).replace(
        queryParameters: {
          "page": page.toString(),
          "limit": limit.toString(),
          "leadisactive": "false",
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Leadsadminmodelwithpagination.fromJson(jsonData);
      } else {
        print("Failed to load trash leads: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Error fetching trash leads: $e");
      return null;
    }
  }
}
