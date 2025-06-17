// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class UpdateMenuApiService {
  Future<http.Response> updateData({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.put(
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

  Future<void> updateCommunicationWay(String name,String communicationWayId) async {
    final String url = '${Constants.baseUrl}/communicationway/$communicationWayId';
    final body = {"name": name};
    await updateData(url: url, body: body);
  }
  Future<void> updateDeveloper(String name,String developerId) async {
    final String url = '${Constants.baseUrl}/Developers/$developerId';
    final body = {"name": name};
    await updateData(url: url, body: body);
  }
  
  Future<void> updateDProject(
    String name,
    String developerId,
    String cityId,
    String area,
    String projectId
  ) async {
    final String url = '${Constants.baseUrl}/Projectss/$projectId';
    final body = {
      "name": name,
      "developer": developerId,
      "city": cityId,
      "area": area,
    };
    await updateData(url: url, body: body);
  }
  Future<void> updateChannel(String name, String code,String channelId) async {
    final String url = '${Constants.baseUrl}/channal/$channelId';
    final body = {"name": name, "code": code};
    await updateData(url: url, body: body);
  }
  Future<void> updateCancelReasons(String cancelreason,String cancelreasonId) async {
    final String url = '${Constants.baseUrl}/cancelreason/$cancelreasonId';
    final body = {"cancelreason": cancelreason};
    await updateData(url: url, body: body);
  }
  Future<void> updateCampaign(
    String campaignName,
    String date,
    String cost,
    bool isActivate,
    String addBy,
    String updatedBy,
    String campaignId
  ) async {
    final String url = '${Constants.baseUrl}/Campain/$campaignId';
    final body = {
      "CampainName": campaignName,
      "Date": date,
      "Cost": cost,
      "isactivate": isActivate,
      "addby": addBy,
      "updatedby": updatedBy,
    };
    await updateData(url: url, body: body);
  }
  Future<void> updateRegion(String region,String regionId) async {
    final String url = '${Constants.baseUrl}/regions/$regionId';
    final body = {"name": region};
    await updateData(url: url, body: body);
  }
    Future<void> updateArea(String area, String region,String areaId) async {
    final String url = '${Constants.baseUrl}/Area/$areaId';
    final body = {"Areaname": area, "Region": region};
    await updateData(url: url, body: body);
  }
}
