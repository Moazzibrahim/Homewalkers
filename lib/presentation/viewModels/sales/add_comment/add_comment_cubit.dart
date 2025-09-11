// add_comment_cubit.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/add_comment_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_comment_state.dart';

class AddCommentCubit extends Cubit<AddCommentState> {
  AddCommentCubit() : super(AddCommentInitial());

  Future<void> addComment({
    required String sales,
    required String text1,
    required String text2,
    required String date,
    required String leed,
    required String userlog,
    required String usernamelog,
  }) async {
    emit(AddCommentLoading());

    try {
      final response = await AddCommentApiService.addComment(
        sales: sales,
        text1: text1,
        text2: text2,
        date: date,
        leed: leed,
        userlog: userlog,
        usernamelog: usernamelog,
      );

      if (response != null) {
        emit(AddCommentSuccess(response));
      } else {
        emit(AddCommentError(" Failed to add comment"));
      }
    } catch (e) {
      emit(AddCommentError(e.toString()));
    }
  }

  Future<void> editLastDateComment(String id) async {
  final link = '${Constants.baseUrl}/users/$id';
  final url = Uri.parse(link);

  final now = DateTime.now().toUtc();
  final String currentDateTime = now.toIso8601String();

  Map<String, dynamic> body = {'lastcommentdate': currentDateTime};

  try {
    // جلب التوكن من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // إضافة التوكن هنا
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("✅ lastcommentdate updated successfully.");
    } else {
      print(
        "❌ Failed to update last comment date: ${response.statusCode} - ${response.body}",
      );
    }
  } catch (e) {
    print("❌ Error updating last comment date: $e");
  }
}
}
