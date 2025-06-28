// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

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
  Future<void> addStage(String name,String stageType,String comment) async {
    const String url = '${Constants.baseUrl}/stage';
    final body = {"name": name,"stagetype": stageType,"Comment": comment};
    await postData(url: url, body: body);
  }
  Future<void> addStageType(String name,String comment) async {
    const String url = '${Constants.baseUrl}/stagetype';
    final body = {"name": name,"Comment": comment};
    await postData(url: url, body: body);
  }
  Future<void> addUsers(String name,String email,String phone,String password,String confirmpassword,String role) async {
    const String url = '${Constants.baseUrl}/Signup';
    final body = {"name": name,"email": email,"phone": phone,"password": password,"passwordConfirm": confirmpassword,"role": role,};
    await postData(url: url, body: body);
  }
    Future<void> addSales(String name,List<String> city,String teamleaderId,String managerId,bool isactive,String notes) async {
    const String url = '${Constants.baseUrl}/Sales';
    final prefs = await SharedPreferences.getInstance();
    final userlogid = prefs.getString('salesId');
    final body = {"name": name,"city": city,"userlog": userlogid,"teamleader": teamleaderId,"Manager": managerId,"salesisactivate": isactive,"notes": notes};
    await postData(url: url, body: body);
  }

  Future<void> addDeveloper(String name, ) async {
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
    bool isActivate,
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
    const String url = '${Constants.baseUrl}/Area';
    final body = {"Areaname": area, "Region": region};
    await postData(url: url, body: body);
  }
}
