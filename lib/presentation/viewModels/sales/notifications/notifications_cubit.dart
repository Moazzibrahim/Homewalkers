// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homewalkers_app/main.dart'; // تأكد أن فيه navigatorKey
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// حالة لإدارة إشعارات التطبيق
class NotificationState {
  final String? token;
  final String? error;

  NotificationState({this.token, this.error});
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState());

  void initNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // طلب الإذن من المستخدم
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      log("🔐 Permission status: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log("❌ Notifications permission denied");
        emit(NotificationState(error: "Permission denied"));
        return;
      }

      // أخذ التوكن وتخزينه
      final token = await messaging.getToken();
      log("🔑 FCM Token: $token");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token ?? '');
      emit(NotificationState(token: token));

      // اشتراك في topic (اختياري)
      await messaging.subscribeToTopic('all_users');

      // إنشاء قناة الإشعارات للأندرويد
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

      // إعدادات الإشعارات لـ iOS
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      // إشعار أثناء تشغيل التطبيق (foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("📩 Received foreground message: ${message.data}");

        final notification = message.notification;
        final androidData = notification?.android;

        String title = notification?.title ?? message.data['title'] ?? '📢 إشعار';
        String body = notification?.body ?? message.data['body'] ?? '📬 لديك رسالة جديدة';

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
      });

      // التطبيق في الخلفية وتم الضغط على الإشعار
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("📲 Notification clicked with data: ${message.data}");
        _handleNotificationNavigation(message.data);
      });

      // تم فتح التطبيق من إشعار أثناء termination
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        log("📦 App opened from terminated state: ${initialMessage.data}");
        _handleNotificationNavigation(initialMessage.data);
      }
    } catch (e) {
      log("⚠️ Error initializing notifications: $e");
      emit(NotificationState(error: e.toString()));
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // مثال على التنقل حسب نوع الإشعار
    final target = data['target'];
    final id = data['id'];

    if (target == 'order' && id != null) {
      navigatorKey.currentState?.pushNamed('/orderDetails', arguments: id);
    } else if (target == 'chat') {
      navigatorKey.currentState?.pushNamed('/chat');
    } else {
      // تنقل افتراضي
      navigatorKey.currentState?.pushNamed('/notifications');
    }
  }
}
