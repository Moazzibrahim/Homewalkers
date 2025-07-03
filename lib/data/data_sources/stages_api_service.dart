// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/stages_models.dart';
import 'package:http/http.dart' as http;

class StagesApiService {
  Future<StageResponse?> fetchStages() async {
    final url = Uri.parse('${Constants.baseUrl}/stage?stageisactivate=true');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return StageResponse.fromJson(jsonBody);
      } else {
        print('Failed to load stages. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching stages: $e');
      return null;
    }
  }
  Future<StageResponse?> fetchStagesInTrash() async {
    final url = Uri.parse('${Constants.baseUrl}/stage?stageisactivate=false');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return StageResponse.fromJson(jsonBody);
      } else {
        print('Failed to load stages. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching stages: $e');
      return null;
    }
  }
}
