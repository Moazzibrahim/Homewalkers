// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/update_service.dart';
import 'package:homewalkers_app/presentation/screens/company_name_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';

class DeciderScreen extends StatelessWidget {
  const DeciderScreen({super.key});

  Future<Map<String, dynamic>> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final savedDomain = prefs.getString('company_domain');

    // 🔥 لو مفيش token، يبقى مفيش داعي للـ domain
    if (token == null || token.isEmpty) {
      print("❌ No token found, ignoring saved domain");
      // امسح domain لو موجود
      if (savedDomain != null && savedDomain.isNotEmpty) {
        await prefs.remove('company_domain');
      }
      Constants.baseUrl = "";
      return {'hasToken': false, 'role': null};
    }

    // لو فيه token بس مفيش domain، ده خطأ
    if (savedDomain == null || savedDomain.isEmpty) {
      print("❌ Token exists but no domain, clearing token");
      await prefs.remove('token');
      Constants.baseUrl = "";
      return {'hasToken': false, 'role': null};
    }

    // بس كده نحدد الـ baseUrl
    Constants.baseUrl = "https://$savedDomain/api/v1";
    print("✅ Loaded Base URL: ${Constants.baseUrl}");

    return {'hasToken': true, 'role': role};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          final data = snapshot.data;
          final hasToken = data?['hasToken'] == true;
          final role = data?['role'];

          // 👈 هنا نعمل update check
          WidgetsBinding.instance.addPostFrameCallback((_) {
            UpdateService.checkForUpdate(context);
          });

          if (hasToken && role == 'Sales') {
            context.read<NotificationCubit>().initNotifications();
            return const SalesTabsScreen(); // ✅ إذا كان الدور "sales"
          } else if (hasToken && role == 'Team Leader') {
            context.read<NotificationCubit>().initNotifications();
            return const TeamLeaderTabsScreen();
          } else if (hasToken && role == 'Manager') {
            context.read<NotificationCubit>().initNotifications();
            return const TabsScreenManager();
          } else if (hasToken && role == 'Marketer') {
            context.read<NotificationCubit>().initNotifications();
            return const MarketierTabsScreen();
          } else if (hasToken && role == 'Admin') {
            context.read<NotificationCubit>().initNotifications();
            return const AdminTabsScreen();
          } else {
            return const CompanySelectionScreen(); // ❌ إذا لم يوجد توكن أو الدور ليس "sales"
          }
        }
      },
    );
  }
}
