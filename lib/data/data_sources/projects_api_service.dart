import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/projects_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // استبدل your_project بمسار مشروعك

class ProjectsApiService {
  final String baseUrl =
      '${Constants.baseUrl}/Projectss?isprojectactivate=true';

  Future<ProjectsModel> fetchProjects() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProjectsModel.fromJson(jsonData);
    } else {
      throw Exception('error: ${response.statusCode}');
    }
  }

  Future<ProjectsModel> fetchProjectsInTrash() async {
    final response = await http.get(
      Uri.parse("$baseUrl?isprojectactivate=false"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProjectsModel.fromJson(jsonData);
    } else {
      throw Exception('error: ${response.statusCode}');
    }
  }
}
