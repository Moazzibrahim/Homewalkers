// ignore_for_file: unused_local_variable, avoid_print
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/notifications_model.dart';
import 'package:homewalkers_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 🧠 State class for NotificationCubit
class NotificationState {
  final String? token;
  final String? error;
  final bool isLoading;

  NotificationState({
    this.token,
    this.error,
    this.isLoading = false,
  });

  NotificationState copyWith({
    String? token,
    String? error,
    bool? isLoading,
  }) {
    return NotificationState(
      token: token ?? this.token,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 🚀 NotificationCubit class to handle Firebase messaging and API requests
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState());

  List<NotificationItem> notifications = [];

  /// 🔔 Initializes notification system and handles listeners
  Future<void> initNotifications() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      log("🔐 Permission status: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        emit(state.copyWith(error: "Permission denied"));
        return;
      }

      final token = await messaging.getToken();
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role');
      final userId = prefs.getString('salesId');

      await prefs.setString('fcm_token', token ?? '');
      emit(state.copyWith(token: token));

      log("🔑 FCM Token: $token");
      log("👤 User ID: $userId");
      log("🧑‍💼 Role: $role");

      // Subscribe to common topic
      await messaging.subscribeToTopic('all_users');

      // Android notification channel
      if (Platform.isAndroid) {
        const androidChannel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
        );
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
      }

      // iOS permissions
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      // Foreground message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      // Background click handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("📲 Notification clicked: ${message.data}");
        _handleNotificationNavigation(message.data);
      });

      // App launched from terminated state
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        log("📦 Opened from terminated: ${initialMessage.data}");
        _handleNotificationNavigation(initialMessage.data);
      }
    } catch (e) {
      log("⚠️ initNotifications error: $e");
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// 💬 Show local push notification
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? '📢 إشعار';
    final body = notification?.body ?? message.data['body'] ?? '📬 رسالة جديدة';

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// 🧭 Navigate based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final target = data['target'];
    final id = data['id'];

    if (target == 'order' && id != null) {
      navigatorKey.currentState?.pushNamed('/orderDetails', arguments: id);
    } else if (target == 'chat') {
      navigatorKey.currentState?.pushNamed('/chat');
    } else {
      navigatorKey.currentState?.pushNamed('/notifications');
    }
  }

  /// 🚀 Send notification to a specific FCM token
  Future<void> sendNotificationToToken({
    required String title,
    required String body,
    required String fcmtokennnn,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/Notification/send-fcm');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fcmToken": fcmtokennnn,
          "title": title,
          "body": body,
        }),
      );

      if (response.statusCode == 200) {
        log('✅ Notification sent to: $fcmtokennnn');
      } else {
        log('❌ Failed to send: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('❌ Error sending notification: $e');
    }
  }

  /// 📥 Fetch notifications for specific salesId
  Future<void> fetchNotifications() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final prefs = await SharedPreferences.getInstance();
      final receiverId = prefs.getString('salesId');

      if (receiverId == null || receiverId.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'No salesId found'));
        return;
      }

      final url = Uri.parse('${Constants.baseUrl}/Notification?receiver=$receiverId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = NotificationModel.fromJson(decoded);
        notifications = model.data ?? [];
        emit(state.copyWith(isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to load notifications'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// 📦 Fetch all notifications (admin or global access)
  Future<void> fetchAllNotifications() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final url = Uri.parse('${Constants.baseUrl}/Notification');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = NotificationModel.fromJson(decoded);
        notifications = model.data ?? [];
        emit(state.copyWith(isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to load notifications'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
