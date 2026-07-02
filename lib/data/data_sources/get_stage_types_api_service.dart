// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/stage_type_model.dart';
import 'package:http/http.dart'
    as http; // Replace with the actual file name that contains your StageTypeResponse model

class StageTypeApiService {
  Future<StageTypeResponse?> fetchStageTypes() async {
    final url = Uri.parse(
      '${Constants.baseUrl}/stagetype?isstagetypeactivate=true',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StageTypeResponse.fromJson(jsonData);
      } else {
        print(
          'Failed to load stage types. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching stage types: $e');
      return null;
    }
  }

  Future<StageTypeResponse?> fetchStageTypesInTrash() async {
    final url = Uri.parse(
      '${Constants.baseUrl}/stagetype?isstagetypeactivate=false',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StageTypeResponse.fromJson(jsonData);
      } else {
        print(
          'Failed to load stage types. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching stage types: $e');
      return null;
    }
  }
}
