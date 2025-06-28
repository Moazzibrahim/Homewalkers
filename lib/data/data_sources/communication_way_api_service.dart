// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/communication_ways_model.dart';
import 'package:http/http.dart' as http;

class CommunicationWayApiService {
  Future<CommunicationWayResponse?> fetchCommunicationWays() async {
  final String url = '${Constants.baseUrl}/communicationway';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return CommunicationWayResponse.fromJson(jsonData);
    } else {
      print('Failed to load data: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching data: $e');
    return null;
  }
}

Future<CommunicationWayResponse?> fetchCommunicationWaysInTrash() async {
  final String url = '${Constants.baseUrl}/communicationway?isactive=false';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return CommunicationWayResponse.fromJson(jsonData);
    } else {
      print('Failed to load data: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching data: $e');
    return null;
  }
}

}