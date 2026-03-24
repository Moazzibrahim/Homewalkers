// ignore_for_file: unused_local_variable, avoid_print
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
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

  NotificationState({this.token, this.error, this.isLoading = false});

  NotificationState copyWith({String? token, String? error, bool? isLoading}) {
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
  bool _isInitialized = false;

  /// 🔔 Initializes notification system and handles listeners
  Future<void> initNotifications() async {
    try {
      if (_isInitialized) return;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('salesId');

      // ✅ تأكد أن userId موجود قبل بدء التهيئة
      if (userId == null || userId.isEmpty) {
        log("⏳ Skipping notification init: No salesId found.");
        return;
      }

      _isInitialized = true;

      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      log("🔐 Permission status: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        emit(state.copyWith(error: "Permission denied"));
        _showDebugInfo("❌ Permission DENIED", "null", "null");
        return;
      }

      // 🍎 On iOS, we MUST get the APNs token first before FCM token
      String? apnsTokenStr;
      if (Platform.isIOS) {
        String? apnsToken;
        // Retry up to 5 times with delay, APNs token may take time on real devices
        for (int i = 0; i < 5; i++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) break;
          log("⏳ Waiting for APNs token... attempt ${i + 1}/5");
          await Future.delayed(const Duration(seconds: 2));
        }
        apnsTokenStr = apnsToken;
        log("🍎 APNs Token: $apnsToken");
        if (apnsToken == null) {
          log("⚠️ APNs token is null after retries. FCM may not work on iOS.");
        }
      }

      final token = await messaging.getToken();
      log("🔑 FCM Token: $token");

      // 🐛 DEBUG: Show visible info on TestFlight (REMOVE AFTER DEBUGGING)
      _showDebugInfo(
        "✅ ${settings.authorizationStatus}",
        apnsTokenStr ?? "null",
        token ?? "null",
      );

      // 📝 حفظ التوكن وإرساله للسيرفر
      await _saveAndSendToken(token);

      // 🔁 تحديث التوكن
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        log("🔁 FCM Token updated: $newToken");
        await _saveAndSendToken(newToken);
      });

      final role = prefs.getString('role');
      log("🔑 FCM Token: $token");
      log("👤 User ID: $userId");
      log("🧑‍💼 Role: $role");

      await messaging.subscribeToTopic('all_users');

      if (Platform.isAndroid) {
        const androidChannel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
        );
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(androidChannel);
      }

      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("📲 Notification clicked: ${message.data}");
        _handleNotificationNavigation(message.data);
      });

      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        log("📦 Opened from terminated: ${initialMessage.data}");
        _handleNotificationNavigation(initialMessage.data);
      }
    } catch (e) {
      log("⚠️ initNotifications error: $e");
      _showDebugInfo("❌ ERROR", "error", e.toString());
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// 🐛 DEBUG: Show visible dialog for TestFlight debugging (REMOVE AFTER FIXING)
  void _showDebugInfo(
    String permissionStatus,
    String apnsToken,
    String fcmToken,
  ) {
    // Delay to make sure the navigator is ready
    Future.delayed(const Duration(seconds: 2), () {
      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;
      showDialog(
        context: ctx,
        builder:
            (context) => AlertDialog(
              title: const Text("🐛 Notification Debug Info"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Permission: $permissionStatus",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "APNs Token: ${apnsToken.length > 20 ? '${apnsToken.substring(0, 20)}...' : apnsToken}",
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "FCM Token: ${fcmToken.length > 20 ? '${fcmToken.substring(0, 20)}...' : fcmToken}",
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      "Full FCM: $fcmToken",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    });
  }

  Future<void> _saveAndSendToken(String? token) async {
    if (token == null || token.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('NewfcmToken');
    log("📌 Current FCM Token: $token");
    log("📌 Saved Old Token: $oldToken");

    if (oldToken != token) {
      await prefs.setString('fcm_token', token);
      emit(state.copyWith(token: token));
      log("🔁 Token changed. Old: $oldToken → New: $token");

      try {
        final userId = prefs.getString('salesId');
        if (userId == null || userId.isEmpty) {
          log("⚠️ No userId found. Skipping token send.");
          return;
        }

        final url = Uri.parse(
          '${Constants.baseUrl}/Notification/updatefcmtoken',
        );
        final body = jsonEncode({'userId': userId, 'fcmToken': token});

        log("📤 Sending token update: $body");

        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        log(
          "📨 Response from server: ${response.statusCode} - ${response.body}",
        );

        if (response.statusCode == 200) {
          log('✅ New FCM token sent to server.');
        } else {
          log('❌ Failed to update FCM token: ${response.statusCode}');
        }
      } catch (e) {
        log('❌ Error sending token to server: $e');
      }
    } else {
      log("♻️ FCM token unchanged. Skipping update.");
    }
  }

  /// 💬 Show local push notification
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;

    // On iOS, if the message has a notification object, FCM natively handles showing the foreground
    // alert because we use `setForegroundNotificationPresentationOptions` in main.dart.
    // Calling `flutterLocalNotificationsPlugin.show` here would cause duplicate notifications.
    if (Platform.isIOS && notification != null) {
      log(
        "🍎 iOS Native foreground notification shown by FCM. Skipping local notification.",
      );
      return;
    }

    final title = notification?.title ?? message.data['title'] ?? '📢 إشعار';
    final body = notification?.body ?? message.data['body'] ?? '📬 رسالة جديدة';
    final payload = jsonEncode(message.data);

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
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
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? 'unknown_sender';
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "fcmToken": fcmtokennnn,
          "title": title,
          "body": body,
        }),
      );
      print("Sending notification to token: $fcmtokennnn");

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

      final url = Uri.parse(
        '${Constants.baseUrl}/Notification?receiver=$receiverId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = NotificationModel.fromJson(decoded);
        notifications = model.data ?? [];
        emit(state.copyWith(isLoading: false));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Failed to load notifications',
          ),
        );
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
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Failed to load notifications',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// 🛑 Stop listening to notifications & unsubscribe
  Future<void> disposeNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salesId = prefs.getString('salesId');

      // ✅ Unsubscribe from topics if you used them
      await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');

      if (salesId != null && salesId.isNotEmpty) {
        await FirebaseMessaging.instance.unsubscribeFromTopic("user_$salesId");
        log("🚫 Unsubscribed from user topic user_$salesId");
      }

      // ✅ Delete FCM Token locally (extra safety)
      await FirebaseMessaging.instance.deleteToken();
      log("🧹 FCM Token Deleted from Firebase");

      // ✅ Clear current listeners
      _isInitialized = false;
      log("🔕 Notification listeners stopped successfully");
    } catch (e) {
      log("❌ Error in disposeNotifications: $e");
    }
  }
}
