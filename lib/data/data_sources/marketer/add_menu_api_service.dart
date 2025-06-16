// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class AddMenuApiService {
  /// دالة عامة تقدر تبعتها لأي endpoint وتحدد الـ body
  Future<http.Response> postData({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Success: ${response.body}');
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (e) {
      print('🔥 Exception: $e');
      rethrow;
    }
  }

  /// مثال مخصص للإضافة في communication way
  Future<void> addCommunicationWay(String name) async {
    const String url = '${Constants.baseUrl}/communicationway';
    final body = {"name": name};
    await postData(url: url, body: body);
  }

  Future<void> addDeveloper(String name) async {
    const String url = '${Constants.baseUrl}/Developers';
    final body = {"name": name};
    await postData(url: url, body: body);
  }

  Future<void> addDProject(
    String name,
    String developerId,
    String cityId,
    String area,
  ) async {
    const String url = '${Constants.baseUrl}/Projectss';
    final body = {
      "name": name,
      "developer": developerId,
      "city": cityId,
      "area": area,
    };
    await postData(url: url, body: body);
  }

  Future<void> addChannel(String name, String code) async {
    const String url = '${Constants.baseUrl}/channal';
    final body = {"name": name, "code": code};
    await postData(url: url, body: body);
  }

  Future<void> addCancelReasons(String cancelreason) async {
    const String url = '${Constants.baseUrl}/cancelreason';
    final body = {"cancelreason": cancelreason};
    await postData(url: url, body: body);
  }

  Future<void> postCampaign(
    String campaignName,
    String date,
    String cost,
    String isActivate,
    String addBy,
    String updatedBy,
  ) async {
    const String url = '${Constants.baseUrl}/Campain';
    final body = {
      "CampainName": campaignName,
      "Date": date,
      "Cost": cost,
      "isactivate": isActivate,
      "addby": addBy,
      "updatedby": updatedBy,
    };
    await postData(url: url, body: body);
  }

  Future<void> addRegion(String region) async {
    const String url = '${Constants.baseUrl}/regions';
    final body = {"name": region};
    await postData(url: url, body: body);
  }

  Future<void> addArea(String area, String region) async {
    const String url = '${Constants.baseUrl}/regions';
    final body = {"Areaname": area, "Region": region};
    await postData(url: url, body: body);
  }
}
