import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homewalkers_app/data/models/regions_model.dart';

class RegionApiService {
  final String baseUrl = 'https://apirender8.onrender.com/api/v1/regions?active=true';

  Future<RegionsModel> fetchRegions() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return RegionsModel.fromJson(jsonData);
      } else {
        throw Exception('error: ${response.statusCode}');
      }
    } catch (e) {
      // مفيد في حالة لا يوجد اتصال أو أي استثناء آخر
      throw Exception('حدث خطأ أثناء الاتصال بالخادم: $e');
    }
  }

  Future<RegionsModel> fetchRegionsInTrash() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl?active=false"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return RegionsModel.fromJson(jsonData);
      } else {
        throw Exception('error: ${response.statusCode}');
      }
    } catch (e) {
      // مفيد في حالة لا يوجد اتصال أو أي استثناء آخر
      throw Exception('حدث خطأ أثناء الاتصال بالخادم: $e');
    }
  }
}
