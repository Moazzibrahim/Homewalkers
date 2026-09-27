import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/projects_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // استبدل your_project بمسار مشروعك

class ProjectsApiService {
  String get baseUrl => '${Constants.baseUrl}/Projectss?isprojectactivate=true';

  Future<ProjectsModel> fetchProjects() async {
    // ✅ هات أول صفحة الأول عشان تعرف عدد الصفحات الكلي
    final firstPageResponse = await http.get(Uri.parse('$baseUrl&page=1'));

    if (firstPageResponse.statusCode != 200) {
      throw Exception('error: ${firstPageResponse.statusCode}');
    }

    final firstJson = json.decode(firstPageResponse.body);
    ProjectsModel firstModel = ProjectsModel.fromJson(firstJson);

    final totalPages = firstModel.pagination?.numberOfPages?.toInt() ?? 1;
    List<ProjectData> allData = List.from(firstModel.data ?? []);

    // ✅ لو فيه أكتر من صفحة، هات الباقي بالتوازي
    if (totalPages > 1) {
      final futures = <Future<http.Response>>[];
      for (int page = 2; page <= totalPages; page++) {
        futures.add(http.get(Uri.parse('$baseUrl&page=$page')));
      }

      final responses = await Future.wait(futures);

      for (final res in responses) {
        if (res.statusCode == 200) {
          final pageJson = json.decode(res.body);
          final pageModel = ProjectsModel.fromJson(pageJson);
          allData.addAll(pageModel.data ?? []);
        }
      }
    }

    // ✅ رجّع موديل واحد فيه كل المشاريع (111 مشروع)
    return ProjectsModel(
      results: firstModel.results,
      pagination: firstModel.pagination,
      data: allData,
    );
  }

  Future<ProjectsModel> fetchProjectsInTrash() async {
    final firstPageResponse = await http.get(
      Uri.parse("$baseUrl?isprojectactivate=false&page=1"),
    );

    if (firstPageResponse.statusCode != 200) {
      throw Exception('error: ${firstPageResponse.statusCode}');
    }

    final firstJson = json.decode(firstPageResponse.body);
    ProjectsModel firstModel = ProjectsModel.fromJson(firstJson);

    final totalPages = firstModel.pagination?.numberOfPages?.toInt() ?? 1;
    List<ProjectData> allData = List.from(firstModel.data ?? []);

    if (totalPages > 1) {
      final futures = <Future<http.Response>>[];
      for (int page = 2; page <= totalPages; page++) {
        futures.add(
          http.get(Uri.parse("$baseUrl?isprojectactivate=false&page=$page")),
        );
      }

      final responses = await Future.wait(futures);

      for (final res in responses) {
        if (res.statusCode == 200) {
          final pageJson = json.decode(res.body);
          final pageModel = ProjectsModel.fromJson(pageJson);
          allData.addAll(pageModel.data ?? []);
        }
      }
    }

    return ProjectsModel(
      results: firstModel.results,
      pagination: firstModel.pagination,
      data: allData,
    );
  }
}
