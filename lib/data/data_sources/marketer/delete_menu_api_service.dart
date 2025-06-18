// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:homewalkers_app/core/constants/constants.dart';

class DeleteMenuApiService {
  Future<void> deleteRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Deleted successfully');
      } else {
        print('❌ Failed to delete: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> deleteCommunicationWay(String communicationWayId) async {
    final String url =
        '${Constants.baseUrl}/communicationway/$communicationWayId';
    await deleteRequest(url: url);
  }

  Future<void> deleteDeveloper(String developerId) async {
    final String url = '${Constants.baseUrl}/Developers/$developerId';
    await deleteRequest(url: url);
  }

  Future<void> deleteProject(String projectId) async {
    final String url = '${Constants.baseUrl}/Projectss/$projectId';
    await deleteRequest(url: url);
  }

  Future<void> deleteChannel(String channelId) async {
    final String url = '${Constants.baseUrl}/channal/$channelId';
    await deleteRequest(url: url);
  }

  Future<void> deleteCancelReason(String cancelreasonId) async {
    final String url = '${Constants.baseUrl}/cancelreason/$cancelreasonId';
    await deleteRequest(url: url);
  }

  Future<void> deleteCampaign(String campaignId) async {
    final String url = '${Constants.baseUrl}/Campain/$campaignId';
    await deleteRequest(url: url);
  }

  Future<void> deleteRegion(String regionId) async {
    final String url = '${Constants.baseUrl}/regions/$regionId';
    await deleteRequest(url: url);
  }
  Future<void> deleteArea(String areaId) async {
    final String url = '${Constants.baseUrl}/Area/$areaId';
    await deleteRequest(url: url);
  }
}
