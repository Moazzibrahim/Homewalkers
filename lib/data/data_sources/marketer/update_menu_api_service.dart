// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<void> updateCommunicationWayStatus(String communicationWayId, bool active) async {
  final String url = '${Constants.baseUrl}/communicationway/$communicationWayId';
  final body = {"iscommunicationwayactivate": active};
  await updateData(url: url, body: body);
}
  Future<void> updateSales(String name,String salesIdi) async {
    final String url = '${Constants.baseUrl}/Sales/$salesIdi';
    final prefs = await SharedPreferences.getInstance();
    final userlogid = prefs.getString('salesId');
    final body = {"name": name,"userlog": userlogid};
    await updateData(url: url, body: body);
  }
  Future<void> updateSalesStatus(bool isactive,String salesIdi) async {
    final String url = '${Constants.baseUrl}/Sales/$salesIdi';
    final body = {"salesisactivate":isactive};
    await updateData(url: url, body: body);
  }
  Future<void> updateUser(String name,String Idi,String email,String phone,String role,bool opencomments, bool CloseDoneDealcomments) async {
    final String url = '${Constants.baseUrl}/Signup/$Idi';
    final body = {"name": name, "email": email, "phone": phone, "role": role,"opencomments": opencomments,"CloseDoneDealcomments": CloseDoneDealcomments};
    await updateData(url: url, body: body);
  }
  Future<void> updateUserstatus( bool isactive,String Idi) async {
    final String url = '${Constants.baseUrl}/Signup/$Idi';
    final body = {"active":isactive};
    await updateData(url: url, body: body);
  }
  Future<void> updateUserPassword(String idi,String currentPassword,String password, String confirmpassword,) async {
    final String url = '${Constants.baseUrl}/Signup/changeMyPassword/$idi';
    final body = {"currentPassword": currentPassword, "password": password, "passwordConfirm": confirmpassword};
    await updateData(url: url, body: body);
  }
  Future<void> updateStage(String name,String stageId,String stageType,String comment) async {
    final String url = '${Constants.baseUrl}/stage/$stageId';
    final body = {"name": name,"stagetype": stageType,"Comment": comment};
    await updateData(url: url, body: body);
  }
  Future<void> updateStageStatus(String stageId, bool active) async {
  final String url = '${Constants.baseUrl}/stage/$stageId';
  final body = {"stageisactivate": active};
  await updateData(url: url, body: body);
}

  Future<void> updateStageType(String name,String stageId,String comment) async {
    final String url = '${Constants.baseUrl}/stagetype/$stageId';
    final body = {"name": name,"Comment": comment};
    await updateData(url: url, body: body);
  }
  Future<void> updateStageTypeStatus(String stageTypeId, bool active) async {
  final String url = '${Constants.baseUrl}/stagetype/$stageTypeId';
  final body = {"isstagetypeactivate": active};
  await updateData(url: url, body: body);
}
  Future<void> updateDeveloper(String name,String developerId) async {
    final String url = '${Constants.baseUrl}/Developers/$developerId';
    final body = {"name": name};
    await updateData(url: url, body: body);
  }
  Future<void> updateDeveloperStatus(String developerId, bool active) async {
  final String url = '${Constants.baseUrl}/Developers/$developerId';
  final body = {"isdeveloperactivate": active};
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
  Future<void> updateDProjectStatus(String projectId, bool active) async {
  final String url = '${Constants.baseUrl}/Projectss/$projectId';
  final body = {"isprojectactivate": active};
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
  Future<void> updateCancelReasonsStatus(String cancelreasonId, bool active) async {
  final String url = '${Constants.baseUrl}/cancelreason/$cancelreasonId';
  final body = {"iscancelreasonactivate": active};
  await updateData(url: url, body: body);
}
  Future<void> updateChannelStatus(String channelId, bool active) async {
  final String url = '${Constants.baseUrl}/channal/$channelId';
  final body = {"active": active};
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
  Future<void> updateCampaignStatus(String campaignId, bool active) async {
  final String url = '${Constants.baseUrl}/Campain/$campaignId';
  final body = {"isactivate": active}; // تم توحيد المفتاح إلى "active"
  await updateData(url: url, body: body);
}
  Future<void> updateRegion(String region,String regionId) async {
    final String url = '${Constants.baseUrl}/regions/$regionId';
    final body = {"name": region};
    await updateData(url: url, body: body);
  }
  Future<void> updateRegionStatus(String regionId, bool active,String region) async {
  final String url = '${Constants.baseUrl}/regions/$regionId';
  final body = {"active": active,"name": region};
  await updateData(url: url, body: body);
}
    Future<void> updateArea(String area, String region,String areaId) async {
    final String url = '${Constants.baseUrl}/Area/$areaId';
    final body = {"Areaname": area, "Region": region};
    await updateData(url: url, body: body);
  }
  Future<void> updateAreaStatus(String areaId, bool active) async {
  final String url = '${Constants.baseUrl}/Area/$areaId';
  final body = {"active": active};
  await updateData(url: url, body: body);
}
Future<void> updateCity(String city,String cityId) async {
    final String url = '${Constants.baseUrl}/Cities/$cityId';
    final body = {"name":city};
    await updateData(url: url, body: body);
  }
  Future<void> updateCityStatus(String cityId,bool active) async {
    final String url = '${Constants.baseUrl}/Cities/$cityId';
    final body = {"active":active};
    await updateData(url: url, body: body);
  }
}
