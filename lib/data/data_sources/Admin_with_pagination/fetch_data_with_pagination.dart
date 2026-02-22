// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/data/models/leadsAdminModelWithPagination.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class LeadsApiServiceWithQuery {
  final String baseUrl =
      "${Constants.baseUrl}/users/admin/allleadspagination";

  /// fetch leads with query params (search + filters + pagination)
  Future<Leadsadminmodelwithpagination?> fetchLeads({
    int page = 1,
    int limit = 10,
    String? search,

    /// ✅ بدل String بقوا List<String>
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        print("Token not found!");
        return null;
      }

      Map<String, String> queryParams = {
        "page": page.toString(),
        "leadisactive": "true",
      };

      /// ✅ نحدد هل فيه فلترة ولا لا
      bool hasFilter =
          search != null ||
          (salesIds != null && salesIds.isNotEmpty) ||
          (developerIds != null && developerIds.isNotEmpty) ||
          (projectIds != null && projectIds.isNotEmpty) ||
          (channelIds != null && channelIds.isNotEmpty) ||
          (campaignIds != null && campaignIds.isNotEmpty) ||
          (communicationWayIds != null &&
              communicationWayIds.isNotEmpty) ||
          (stageIds != null && stageIds.isNotEmpty) ||
          (addedByIds != null && addedByIds.isNotEmpty) ||
          (assignedFromIds != null &&
              assignedFromIds.isNotEmpty) ||
          (assignedToIds != null && assignedToIds.isNotEmpty) ||
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

      /// ✅ أهم جزء: join(",") علشان ميبقاش فيه أقواس
      if (salesIds != null && salesIds.isNotEmpty) {
        queryParams["sales"] = salesIds.join(",");
      }

      if (developerIds != null && developerIds.isNotEmpty) {
        queryParams["developer"] = developerIds.join(",");
      }

      if (projectIds != null && projectIds.isNotEmpty) {
        queryParams["project"] = projectIds.join(",");
      }

      if (channelIds != null && channelIds.isNotEmpty) {
        queryParams["chanel"] = channelIds.join(",");
      }

      if (campaignIds != null && campaignIds.isNotEmpty) {
        queryParams["campaign"] = campaignIds.join(",");
      }

      if (communicationWayIds != null &&
          communicationWayIds.isNotEmpty) {
        queryParams["communicationway"] =
            communicationWayIds.join(",");
      }

      if (stageIds != null && stageIds.isNotEmpty) {
        queryParams["stage"] = stageIds.join(",");
      }

      if (addedByIds != null && addedByIds.isNotEmpty) {
        queryParams["addedBy"] = addedByIds.join(",");
      }

      if (assignedFromIds != null &&
          assignedFromIds.isNotEmpty) {
        queryParams["assignedFrom"] =
            assignedFromIds.join(",");
      }

      if (assignedToIds != null &&
          assignedToIds.isNotEmpty) {
        queryParams["assignedTo"] =
            assignedToIds.join(",");
      }

      if (ignoreDuplicate != null) {
        queryParams["ignoreduplicate"] =
            ignoreDuplicate.toString();
        queryParams["duplicates"] =
            ignoreDuplicate.toString();
      }

      if (data != null) {
        queryParams["data"] = data.toString();
      }

      if (transferefromdata != null) {
        queryParams["transferefromdata"] =
            transferefromdata.toString();
      }

      /// 🔥 تواريخ
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

      final uri =
          Uri.parse(baseUrl).replace(queryParameters: queryParams);

      print("Final URL: ${uri.toString()}");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body);
        return Leadsadminmodelwithpagination.fromJson(
            jsonData);
      } else {
        print("Failed: ${response.statusCode}");
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
