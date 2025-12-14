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
    final salesId = prefs.getString('salesId');
    final token = prefs.getString('token');

    if (salesId == null) {
      emit(AssignFailure('Missing salesId from SharedPreferences'));
      return;
    }

    try {
      await Future.wait(
        leadIds.map((leadId) async {
          // ===== PUT =====
          final putUrl = '${Constants.baseUrl}/users/$leadId';
          final putBody = {
            "assign": "true",
            "lastdateassign": lastDateAssign,
            "sales": teamleadersId,
          };

          log("🚀 Sending PUT for $leadId");
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
          log("✅ PUT done for $leadId");

          if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
            throw Exception('Failed to assign lead in PUT: $leadId');
          }

          // ===== POST ===== (Fire & Forget – من غير await)
          final postUrl = '${Constants.baseUrl}/LeadAssigned';
          final postBody = {
            "LeadId": leadId,
            "date_Assigned": dateAssigned,
            "Assigned_From": salesId,
            "Assigned_to": teamleadersId,
          };
          unawaited(
            dio.post(
              postUrl,
              data: postBody,
              options: Options(headers: {'Content-Type': 'application/json'}),
            ),
          );
          log("📤 POST triggered for $leadId");
        }),
      );

      // ✅ كله نجح
      log('🎉 All leads assigned successfully');
      log("teamleadersId: $teamleadersId");
      log("salesId: $salesId");
      emit(AssignSuccess());
    } catch (e) {
      emit(AssignFailure('❌ Error during combined assignment: $e'));
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

    try {
      for (String leadId in leadIds) {
        // ===== PUT =====
        final putUrl = '${Constants.baseUrl}/users/$leadId';
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
          return;
        }

        log("✅ PUT success for lead $leadId");

        // ===== POST ===== (Fire & Forget)
        final postUrl = '${Constants.baseUrl}/LeadAssigned';
        final postBody = {
          "LeadId": leadId,
          "date_Assigned": dateAssigned,
          "Assigned_From": teamleadersId,
          "Assigned_to": salesId,
          "clearHistory": clearhistory,
        };

        // نخليه unawaited (مش يوقف العملية)
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

        // ✅ Save clearHistory locally (once is enough, بس نعملها هنا عشان تبقى مضمونة)
        if (clearhistory != null) {
          await prefs.setBool('clearHistory', clearhistory);
        }
      }

      // ===== كله نجح =====
      log('🎉 All leads assigned successfully');
      log("teamleadersId: $teamleadersId");
      log("salesId: $salesId");
      log("clearhistory: $clearhistory");

      emit(AssignSuccess());
    } catch (e) {
      emit(AssignFailure('❌ Error during combined assignment: $e'));
    }
  }

  Future<void> assignLeadFromManager({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String salesId,
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
    final managerId = prefs.getString('managerIdspecific');
    final token = prefs.getString('token');

    try {
      for (String leadId in leadIds) {
        // ===== PUT =====
        final putUrl = '${Constants.baseUrl}/users/$leadId';
        final putBody = {
          "assign": "true",
          "lastdateassign": lastDateAssign,
          "sales": salesId,
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
        final putUrl = '${Constants.baseUrl}/users/leads/assign/$leadId/$marketerId/$salesId';
        final putBody = {
          // "assign": "true",
          // "lastdateassign": lastDateAssign,
          // "sales": salesId,
          "clearHistory": isClearhistory,
          if (stage != null) "stage": stage,
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
