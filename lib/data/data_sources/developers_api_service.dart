import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/developers_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // استبدل your_project بمسار مشروعك

class DeveloperApiService {
  final String baseUrl = '${Constants.baseUrl}/Developers?isdeveloperactivate=true';
  

  Future<DevelopersModel> fetchDevelopers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return DevelopersModel.fromJson(jsonData);
    } else {
      throw Exception('فشل في جلب البيانات: ${response.statusCode}');
    }
  }
  Future<DevelopersModel> fetchDevelopersInTrash() async {
    final response = await http.get(Uri.parse("$baseUrl?isdeveloperactivate=false"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return DevelopersModel.fromJson(jsonData);
    } else {
      throw Exception('فشل في جلب البيانات: ${response.statusCode}');
    }
  }
}
