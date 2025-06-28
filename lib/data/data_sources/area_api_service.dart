// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/areas_model.dart';
import 'package:http/http.dart' as http;

class AreaApiService {
  final String _baseUrl = '${Constants.baseUrl}/Area';

  Future<AreaResponse?> getAreas() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return AreaResponse.fromJson(jsonData);
      } else {
        print('Failed to load areas: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching areas: $e');
      return null;
    }
  }
  Future<AreaResponse?> getAreasInTrash() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl?isactive=false"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return AreaResponse.fromJson(jsonData);
      } else {
        print('Failed to load areas: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching areas: $e');
      return null;
    }
  }
}
