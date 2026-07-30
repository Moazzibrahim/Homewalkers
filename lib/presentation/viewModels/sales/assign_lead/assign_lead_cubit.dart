// assign_cubit.dart
// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignleadCubit extends Cubit<AssignState> {
  AssignleadCubit() : super(AssignInitial());
  Future<void> assignUserAndLead({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String teamleadersId,
  }) async {
    emit(AssignLoading());

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final postUrl = '${Constants.baseUrl}/Sales/sales-by-email';

      final postBody = {"leadIds": leadIds, "clearHistory": false};

      log("📤 POST URL: $postUrl");
      log("📦 POST BODY: $postBody");

      final postResponse = await dio.put(
        postUrl,
        data: postBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $token', // مهم جدا
          },
        ),
      );

      log("✅ POST STATUS CODE: ${postResponse.statusCode}");
      log("📥 POST RESPONSE DATA: ${postResponse.data}");

      emit(AssignSuccess());
    } on DioException catch (e) {
      log("❌ DIO ERROR");
      log("🔴 STATUS CODE: ${e.response?.statusCode}");
      log("🔴 RESPONSE DATA: ${e.response?.data}");

      emit(AssignFailure('❌ Dio Error: ${e.response?.data ?? e.message}'));
    } catch (e) {
      emit(AssignFailure('❌ Error during assignment: $e'));
    }
  }

  Future<void> assignUserAndLeadTeamLeader({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String teamleadersId,
    required String salesId,
    required String stageId,
    bool? clearhistory,
  }) async {
    emit(AssignLoading());

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final String? salesIdFromPrefs = prefs.getString('salesId');

    log("🔑 token: $token");
    log("🔑 salesIdFromPrefs: $salesIdFromPrefs");

    try {
      for (String leadId in leadIds) {
        // ===== PUT (الراوت الجديد) =====
        final putUrl =
            '${Constants.baseUrl}/users/assign/simple/$leadId/$salesIdFromPrefs/$salesId';
        final putBody = {
          "clearHistory": clearhistory,
          "stage": stageId,
        };

        log("➡️ PUT URL: $putUrl");
        log("➡️ PUT BODY: $putBody");

        try {
          final putResponse = await dio.put(
            putUrl,
            data: putBody,
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

          if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
            log("❌ PUT failed for lead $leadId => ${putResponse.statusCode}");
            log("❌ Response data: ${putResponse.data}");
            emit(AssignFailure('❌ Failed to assign lead in PUT: $leadId'));
            return;
          }

          log("✅ PUT success for lead $leadId => ${putResponse.statusCode}");
        } on DioException catch (dioError) {
          log("❌ DioException while assigning lead $leadId");
          log("❌ Type: ${dioError.type}");
          log("❌ Message: ${dioError.message}");
          log("❌ Status code: ${dioError.response?.statusCode}");
          log("❌ Response data: ${dioError.response?.data}");
          log("❌ Request URL: ${dioError.requestOptions.uri}");

          emit(
            AssignFailure(
              '❌ Error assigning lead $leadId: '
              '${dioError.response?.data ?? dioError.message}',
            ),
          );
          return;
        }

        // // ===== POST ===== (Fire & Forget)
        // final postUrl = '${Constants.baseUrl}/LeadAssigned';
        // final postBody = {
        //   "LeadId": leadId,
        //   "date_Assigned": dateAssigned,
        //   "Assigned_From": teamleadersId,
        //   "Assigned_to": salesId,
        //   "clearHistory": clearhistory,
        // };

        // unawaited(
        //   dio
        //       .post(
        //         postUrl,
        //         data: postBody,
        //         options: Options(headers: {'Content-Type': 'application/json'}),
        //       )
        //       .then((res) {
        //         log("📩 POST success for lead $leadId => ${res.statusCode}");
        //       })
        //       .catchError((e) {
        //         log("⚠️ POST failed for lead $leadId => $e");
        //       }),
        // );

        if (clearhistory != null) {
          await prefs.setBool('clearHistory', clearhistory);
        }
      }

      log('🎉 All leads assigned successfully');
      log("salesId: $salesId");
      log("clearhistory: $clearhistory");

      emit(AssignSuccess());
    } catch (e, stackTrace) {
      log("❌ Unexpected Error: $e");
      log("❌ StackTrace: $stackTrace");
      emit(AssignFailure('❌ Error during combined assignment: $e'));
    }
  }

  Future<void> assignLeadFromManager({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String salesId,
    required String stageId, // ✅ جديد - زي التيم ليدر بالظبط
    bool? isClearhistory,
  }) async {
    emit(AssignLoading());

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final managerId = prefs.getString('salesId'); // ✅ بدل managerIdspecific
    final token = prefs.getString('token');

    try {
      for (String leadId in leadIds) {
        // ===== PUT =====
        final putUrl =
            '${Constants.baseUrl}/users/leads/assign/$leadId/$managerId/$salesId';
        final putBody = {
          "assign": "true",
          "lastdateassign": lastDateAssign,
          "sales": salesId,
          "stage": stageId,
        };

        final putResponse = await dio.put(
          putUrl,
          data: putBody,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
          emit(AssignFailure('❌ Failed to assign lead in PUT: $leadId'));
          log('❌ Failed to assign lead in PUT: $leadId');
          return;
        }

        log("✅ PUT success for lead $leadId");

        // ===== POST ===== (Fire & Forget)
        final postUrl = '${Constants.baseUrl}/LeadAssigned';
        final postBody = {
          "LeadId": leadId,
          "date_Assigned": dateAssigned,
          "Assigned_From": managerId,
          "Assigned_to": salesId,
          "clearHistory": isClearhistory,
        };

        unawaited(
          dio
              .post(
                postUrl,
                data: postBody,
                options: Options(headers: {'Content-Type': 'application/json'}),
              )
              .then((res) {
                log("📩 POST success for lead $leadId => ${res.statusCode}");
              })
              .catchError((e) {
                log("⚠️ POST failed for lead $leadId => $e");
              }),
        );

        // ✅ Save clearHistory locally
        if (isClearhistory != null) {
          await prefs.setBool('clearHistory', isClearhistory);
        }
      }

      // ===== كله نجح =====
      log('🎉 All leads assigned successfully');
      log("📌 ManagerId: $managerId");
      log("📌 SalesId: $salesId");
      log("📌 clearHistory: $isClearhistory");

      emit(AssignSuccess());
    } catch (e) {
      emit(AssignFailure('❌ Error during combined assignment: $e'));
    }
  }

  Future<void> assignLeadFromMarkter({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String salesId,
    bool? isClearhistory,
    String? stage,
    bool assigntype = false, // false = Salesman | true = Team Leader
    bool resetcreationdate = false, // false = show | true = hide
    bool hidesalesnameonleadcomments = false,
  }) async {
    emit(AssignLoading());

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final marketerId = prefs.getString('salesId');
    final token = prefs.getString('token');

    try {
      for (String leadId in leadIds) {
        // ===== PUT =====
        final putUrl =
            '${Constants.baseUrl}/users/leads/assign/$leadId/$marketerId/$salesId';
        final putBody = {
          // "assign": "true",
          // "lastdateassign": lastDateAssign,
          // "sales": salesId,
          "clearHistory": isClearhistory,
          if (stage != null) "stage": stage,
          // 🆕 NEW KEYS
          "assigntype": assigntype,
          "resetcreationdate": resetcreationdate,
          "hidesalesnameonleadcomments": hidesalesnameonleadcomments,
        };

        final putResponse = await dio.put(
          putUrl,
          data: putBody,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
          emit(AssignFailure('❌ Failed to assign lead in PUT: $leadId'));

          log('❌ Failed to assign lead in PUT: $leadId');
          return;
        }

        log("✅ PUT success for lead $leadId");
        log(
          assigntype ? "👑 Assigned as TEAM LEADER" : "👤 Assigned as SALESMAN",
        );

        // // ===== POST ===== (Fire & Forget)
        // final postUrl = '${Constants.baseUrl}/LeadAssigned';
        // final postBody = {
        //   "LeadId": leadId,
        //   "date_Assigned": dateAssigned,
        //   "Assigned_From": marketerId,
        //   "Assigned_to": salesId,
        //   "clearHistory": isClearhistory,
        // };

        // unawaited(
        //   dio
        //       .post(
        //         postUrl,
        //         data: postBody,
        //         options: Options(headers: {'Content-Type': 'application/json'}),
        //       )
        //       .then((res) {
        //         log("📩 POST success for lead $leadId => ${res.statusCode}");
        //       })
        //       .catchError((e) {
        //         log("⚠️ POST failed for lead $leadId => $e");
        //       }),
        // );

        // ✅ Save clearHistory locally
        if (isClearhistory != null) {
          await prefs.setBool('clearHistory', isClearhistory);
        }
      }

      // ===== كله نجح =====
      log('🎉 All leads assigned successfully');
      log("📌 MarketerId: $marketerId");
      log("📌 SalesId: $salesId");
      log("📌 clearHistory: $isClearhistory");

      emit(AssignSuccess());
    } catch (e) {
      log('❌ Error during combined assignment: $e');
      emit(AssignFailure('❌ Error during combined assignment: $e'));
    }
  }
}
