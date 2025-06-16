// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/campaign_models.dart';
import 'package:http/http.dart' as http;

class CampaignApiService {
  final String _baseUrl = '${Constants.baseUrl}/Campain';

  Future<CampaignResponse?> getCampaigns() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CampaignResponse.fromJson(jsonData);
      } else {
        print('Failed to load campaigns: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching campaigns: $e');
      return null;
    }
  }
}
