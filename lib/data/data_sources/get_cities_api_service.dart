// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/cities_model.dart';
import 'package:homewalkers_app/data/models/regions_model.dart';
import 'package:http/http.dart' as http;
// تأكد من تعديل المسار حسب مكان ملف الموديل

class GetCitiesApiService {
  Future<CityResponse?> getCities() async {
    final String baseUrl = '${Constants.baseUrl}/Cities';
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return CityResponse.fromJson(decodedJson);
      } else {
        print('❌ Failed to fetch cities: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 Exception occurred while fetching cities: $e');
      return null;
    }
  }

  Future<RegionsModel?> getRegions() async {
    final String baseUrl = '${Constants.baseUrl}/regions';
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return RegionsModel.fromJson(decodedJson);
      } else {
        print('❌ Failed to fetch regions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 Exception occurred while fetching regions: $e');
      return null;
    }
  }
}
