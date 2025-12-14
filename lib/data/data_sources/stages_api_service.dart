// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/stages_models.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StagesApiService {
  Future<StageResponse?> fetchStages() async {
    final url = Uri.parse('${Constants.baseUrl}/stage?stageisactivate=true');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final stageResponse = StageResponse.fromJson(jsonBody);
        final stages = stageResponse.data;
        if (stages != null && stages.isNotEmpty) {
          String? freshId;
          String? pendingId;
          String? transferId;
          String? truePendingId;

          // ✅ ندوّر على الـ stages بالاسم
          for (var stage in stages) {
            if (stage.name?.toLowerCase() == 'fresh') {
              freshId = stage.id;
            } else if (stage.name?.toLowerCase() == 'no stage') {
              pendingId = stage.id;
            } else if (stage.name?.toLowerCase() == 'transfer') {
              transferId = stage.id;
            } else if (stage.name?.toLowerCase() == 'pending') {
              truePendingId = stage.id;
            }
          }
          // ✅ نحفظهم في SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          if (freshId != null) {
            await prefs.setString('fresh_stage_id', freshId);
            print('✅ Saved Fresh stage ID: $freshId');
          }
          if (pendingId != null) {
            await prefs.setString('pending_stage_id', pendingId);
            print('✅ Saved no stage ID: $pendingId');
          }
          if (transferId != null) {
            await prefs.setString('transfer_stage_id', transferId);
            print('✅ Saved Transfer stage ID: $transferId');
          }
          if (truePendingId != null) {
            await prefs.setString('true_pending_stage_id', truePendingId);
            print('✅ Saved Pending stage ID: $truePendingId');
          }
        } else {
          print('⚠️ No stages found.');
        }
        return stageResponse;
      } else {
        print('❌ Failed to load stages. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 Error fetching stages: $e');
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
