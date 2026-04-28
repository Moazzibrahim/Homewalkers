// lib/core/utils/notification_navigation_helper.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/Admin_with_pagination/fetch_data_with_pagination.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/notifications_model.dart';
import 'package:homewalkers_app/main.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/leads_marketier_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationNavigationHelper {
  static bool _isNavigating = false;

  /// 🧠 الطريقة الرئيسية للتعامل مع التنقل بناءً على نوع الإشعار
  static Future<void> handleNavigation(dynamic notificationData) async {
    if (_isNavigating) {
      log("⏳ Navigation already in progress, skipping...");
      return;
    }

    _isNavigating = true;

    log("🧭 ===== NAVIGATION HANDLER =====");
    log("🧭 Raw data: $notificationData");
    log("🧭 Data type: ${notificationData.runtimeType}");

    try {
      NotificationItem? item;

      if (notificationData is NotificationItem) {
        item = notificationData;
      } else if (notificationData is Map<String, dynamic>) {
        log("🧭 Map keys: ${notificationData.keys.toList()}");

        // ✅ لو الـ data ناقص، نحاول نكمل من المعلومات المتاحة
        if (!notificationData.containsKey('lead') &&
            !notificationData.containsKey('typenotification')) {
          log("⚠️ Incomplete data, trying to extract from available info");

          // نجمع كل النصوص المتاحة للفحص
          final title =
              notificationData['title']?.toString().toLowerCase() ?? '';
          final body = notificationData['body']?.toString().toLowerCase() ?? '';
          final fullMessage = '$title $body';

          log("📝 Full message to check: $fullMessage");

          // حط البيانات المتاحة
          notificationData['message'] =
              notificationData['message'] ??
              notificationData['body'] ??
              notificationData['title'] ??
              '';
          notificationData['lead'] = notificationData['lead'] ?? '{"_id":""}';
          notificationData['receiver'] =
              notificationData['receiver'] ?? '{"_id":""}';
        }

        try {
          item = NotificationItem.fromJson(notificationData);
        } catch (e) {
          log("❌ Error parsing: $e");
          item = NotificationItem(
            message: notificationData['message'] ?? notificationData['body'],
            typenotification: notificationData['typenotification'],
          );
        }
      }

      if (item == null) {
        log("⚠️ Item is null, navigating to notifications");
        _navigateToNotifications();
        return;
      }

      // ✅ نجمع كل النصوص اللي هنفحص فيها
      final type = item.typenotification?.toLowerCase() ?? '';
      final message = item.message?.toLowerCase() ?? '';

      // ✅ نضيف title و body في حالة إنهم موجودين في الـ raw data
      String title = '';
      String body = '';
      if (notificationData is Map<String, dynamic>) {
        title = notificationData['title']?.toString().toLowerCase() ?? '';
        body = notificationData['body']?.toString().toLowerCase() ?? '';
      }

      // ✅ النص الكامل اللي هنفحص فيه كل الكلمات المفتاحية
      final fullText = '$type $message $title $body';

      log(
        "📱 Navigation → type='$type', message='$message', title='$title', body='$body'",
      );
      log("📱 Full text to check: $fullText");

      await Future.delayed(const Duration(milliseconds: 500));

      // ============================================
      // ✅ الكشف عن نوع الإشعار بناءً على الكلمات المفتاحية
      // ============================================

      // ✅ 1. Comment Detection
      if (_containsAnyWord(fullText, [
        'comment',
        'تعليق',
        'commented',
        'comments',
      ])) {
        log("💬 Detected: COMMENT notification");
        await _handleCommentNavigation(item);
        return;
      }

      // ✅ 2. Assign / Transfer / New Lead Detection
      if (_containsAnyWord(fullText, [
        'assign',
        'assigned',
        'اسناد',
        'assigned',
        'Reminder',
        'تحويل',
        'transfer',
        'transferred',
        'new lead',
        'new_lead',
        'newlead',
        'lead created',
        'leadcreated',
        'created lead',
      ])) {
        log("📌 Detected: ASSIGN/TRANSFER/NEW LEAD notification");
        await _handleAssignNavigation(item);
        return;
      }

      // ✅ 3. لو الـ type موجود وصريح
      if (type.isNotEmpty) {
        switch (type) {
          case 'comment':
          case 'تعليق':
            log("💬 Detected from type: COMMENT");
            await _handleCommentNavigation(item);
            return;

          case 'assign':
          case 'assigned':
          case 'Reminder':
          case 'lead-assigned':
          case 'lead_transfer':
          case 'transfer':
          case 'new_lead':
          case 'lead_created':
            log("📌 Detected from type: ASSIGN/TRANSFER/NEW LEAD");
            await _handleAssignNavigation(item);
            return;
        }
      }

      // ✅ لو مفيش lead ID، روح على الإشعارات
      if (item.lead?.id == null || item.lead!.id!.isEmpty) {
        log("⚠️ No lead ID, navigating to notifications");
        _navigateToNotifications();
        return;
      }

      log("⚠️ No specific handler matched, going to notifications");
      _navigateToNotifications();
    } catch (e) {
      log("❌ Error in handleNavigation: $e");
      _navigateToNotifications();
    } finally {
      _isNavigating = false;
    }
  }

  /// ✅ دالة مساعدة للبحث عن أي كلمة في النص
  static bool _containsAnyWord(String text, List<String> words) {
    final lowerText = text.toLowerCase();
    return words.any((word) => lowerText.contains(word.toLowerCase()));
  }

  /// 💬 التنقل عند الإشعار من نوع "comment"
  static Future<void> _handleCommentNavigation(NotificationItem item) async {
    final leadId = item.lead?.id;

    if (leadId == null || leadId.isEmpty) {
      log("⚠️ No lead ID for comment notification, going to notifications");
      _navigateToNotifications();
      return;
    }

    final managerFcm = item.lead?.sales?.manager?.fcmToken;

    final nav = navigatorKey.currentState;
    if (nav == null) {
      log("⚠️ Navigator not ready for comment navigation");
      return;
    }

    log("💬 Navigating to comment screen for lead: $leadId");

    nav.pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (_) => SalesCommentsScreen(
              leedId: leadId,
              fcmtoken: item.lead?.sales?.userlog?.fcmToken ?? '',
              leadName: item.lead?.name ?? 'Lead',
              managerfcm: managerFcm,
            ),
      ),
      (route) => route.isFirst,
    );
  }

  /// 📌 التنقل عند الإشعار من نوع "assign" أو "transfer" أو "new_lead"
  static Future<void> _handleAssignNavigation(NotificationItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('role');
    final salesId = prefs.getString('salesId');

    log("👤 User Info - Role: $userRole, SalesId: $salesId");

    // ✅ لو مفيش role، روح على الإشعارات
    if (userRole == null || userRole.isEmpty) {
      log("⚠️ No role found in SharedPreferences");
      _navigateToNotifications();
      return;
    }

    final nav = navigatorKey.currentState;
    if (nav == null) {
      log("⚠️ Navigator not ready for assign navigation");
      return;
    }

    final role = userRole.toLowerCase().trim();
    log("📌 Navigating to assign screen for role: $role");

    switch (role) {
      case 'sales':
        log("✅ Opening SalesLeadsScreen");
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (_) =>
                    const SalesLeadsScreen(data: false, transferfromdata: true),
          ),
          (route) => route.isFirst,
        );
        break;

      case 'teamleader':
        log("✅ Opening TeamLeaderAssignScreen");
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (_) => const TeamLeaderAssignScreen(
                  data: false,
                  transferfromdata: true,
                ),
          ),
          (route) => route.isFirst,
        );
        break;

      case 'manager':
        log("✅ Opening ManagerLeadsScreen");
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => ManagerLeadsScreen(data: true)),
          (route) => route.isFirst,
        );
        break;

      case 'marketer':
        log("✅ Opening LeadsMarketierScreen with BlocProvider");
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) {
              return BlocProvider(
                create: (_) => GetLeadsMarketerCubit(GetLeadsService()),
                child: const LeadsMarketierScreen(
                  data: false,
                  transferefromdata: true,
                ),
              );
            },
          ),
          (route) => route.isFirst,
        );
        break;

      case 'admin':
        log("✅ Opening AdminLeadsScreen with BlocProvider");
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) {
              return BlocProvider(
                create:
                    (_) =>
                        AllLeadsCubitWithPagination(LeadsApiServiceWithQuery()),
                child: const AdminLeadsScreen(
                  data: false,
                  transferefromdata: true,
                ),
              );
            },
          ),
          (route) => route.isFirst,
        );
        break;

      default:
        log("⚠️ Unhandled role: $role, going to notifications");
        _navigateToNotifications();
    }
  }

  /// 📱 التنقل الافتراضي إلى صفحة الإشعارات
  static void _navigateToNotifications() {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      log("⚠️ Navigator not ready for notification navigation");
      return;
    }

    log("📱 Navigating to SalesNotificationsScreen directly");

    // ✅ روح مباشرة على صفحة الإشعارات من غير wrapper
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SalesNotificationsScreen()),
      (route) => route.isFirst,
    );
  }
}
