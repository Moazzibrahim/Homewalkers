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
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notification_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 🧠 State class for NotificationCubit
class NotificationState {
  final String? token;
  final String? error;
  final bool isLoading;
  final bool isLoadingMore; // ✅ NEW: loading more pages
  final bool hasMore; // ✅ NEW: are there more pages?
  final int currentPage; // ✅ NEW: current page number

  NotificationState({
    this.token,
    this.error,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  NotificationState copyWith({
    String? token,
    String? error,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationState(
      token: token ?? this.token,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// 🚀 NotificationCubit class to handle Firebase messaging and API requests
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState());

  List<NotificationItem> notifications = [];
  bool _isInitialized = false;

  // ✅ Pagination constants
  static const int _pageSize = 10;

  /// 🔔 Initializes notification system and handles listeners
  Future<void> initNotifications() async {
    try {
      if (_isInitialized) return;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('salesId');

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
        return;
      }

      String? apnsTokenStr;
      if (Platform.isIOS) {
        String? apnsToken;
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

      await _saveAndSendToken(token);

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
        NotificationNavigationHelper.handleNavigation(
          _normalizeData(message.data),
        );
      });

      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          NotificationNavigationHelper.handleNavigation(
            _normalizeData(initialMessage.data),
          );
        });
      }
    } catch (e) {
      log("⚠️ initNotifications error: $e");
      emit(state.copyWith(error: e.toString()));
    }
  }

  Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    data.forEach((key, value) {
      if (value is String) {
        try {
          result[key] = jsonDecode(value);
        } catch (_) {
          result[key] = value;
        }
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  Future<void> _saveAndSendToken(String? token) async {
    if (token == null || token.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    // final oldToken = prefs.getString('NewfcmToken');
    final oldToken = prefs.getString('fcm_token'); // ✅ نفس الـ key
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

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;

    log("📩 ===== NEW NOTIFICATION RECEIVED =====");
    log("📩 Message ID: ${message.messageId}");
    log("📩 Message Type: ${message.messageType}");
    log("📩 Notification Title: ${notification?.title}");
    log("📩 Notification Body: ${notification?.body}");
    log("📩 Data Keys: ${message.data.keys.toList()}");
    log("📩 Data: ${message.data}");

    Map<String, dynamic> finalData = Map<String, dynamic>.from(message.data);

    if (finalData.isEmpty && notification != null) {
      log("⚠️ Empty data payload - extracting info from notification");

      final title = notification.title ?? '';
      final body = notification.body ?? '';

      final fullText = '$title $body'.toLowerCase();

      log("📝 Full notification text: $fullText");

      String? type;

      if (_containsAnyWord(fullText, [
        'comment',
        'تعليق',
        'commented',
        'comments',
      ])) {
        type = 'comment';
        log("💬 Detected type: comment");
      } else if (_containsAnyWord(fullText, [
        'assign',
        'assigned',
        'اسناد',
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
        type = 'assign';
        log("📌 Detected type: assign/transfer/new lead");
      } else {
        type = 'unknown';
        log("❓ Unknown notification type");
      }

      finalData = {
        'typenotification': type,
        'message': body,
        'title': title,
        'body': body,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      };

      log("📩 Created data from notification: $finalData");
    } else {
      log("📩 Using existing data payload");

      if (!finalData.containsKey('typenotification') ||
          finalData['typenotification'] == null) {
        final title = notification?.title ?? '';
        final body = notification?.body ?? '';
        final messageText = finalData['message']?.toString() ?? '';
        final fullText = '$title $body $messageText'.toLowerCase();

        if (_containsAnyWord(fullText, ['comment', 'تعليق'])) {
          finalData['typenotification'] = 'comment';
        } else if (_containsAnyWord(fullText, [
          'assign',
          'assigned',
          'اسناد',
          'تحويل',
          'transfer',
          'transferred',
          'new lead',
          'new_lead',
          'newlead',
        ])) {
          finalData['typenotification'] = 'assign';
        }

        log("📩 Added typenotification: ${finalData['typenotification']}");
      }

      if (notification != null) {
        finalData['title'] = finalData['title'] ?? notification.title;
        finalData['body'] = finalData['body'] ?? notification.body;
      }

      finalData['click_action'] =
          finalData['click_action'] ?? 'FLUTTER_NOTIFICATION_CLICK';
    }

    if (Platform.isIOS && notification != null) {
      log(
        "🍎 iOS Native foreground notification shown by FCM. Skipping local notification.",
      );
      return;
    }

    final title = notification?.title ?? finalData['title']?.toString() ?? "";
    final body = notification?.body ?? finalData['body']?.toString() ?? '';
    final payload = jsonEncode(finalData);

    log("🔔 Showing local notification:");
    log("🔔 Title: $title");
    log("🔔 Body: $body");
    log("🔔 Payload: $payload");

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

  bool _containsAnyWord(String text, List<String> words) {
    final lowerText = text.toLowerCase();
    return words.any((word) => lowerText.contains(word.toLowerCase()));
  }

  Future<void> sendNotificationToToken({
    required String title,
    required String body,
    required String fcmtokennnn,
  }) async {
    await _sendWithRetry(fcmToken: fcmtokennnn, title: title, body: body);
  }

  Future<void> sendNotificationToTokens({
    required String title,
    required String body,
    required List<String> fcmTokens,
  }) async {
    if (fcmTokens.isEmpty) return;
    for (final fcmToken in fcmTokens) {
      if (fcmToken.isEmpty) continue;
      await _sendWithRetry(fcmToken: fcmToken, title: title, body: body);
    }
  }

  Future<void> _sendWithRetry({
    required String fcmToken,
    required String title,
    required String body,
    int maxRetries = 2,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/Notification/send-fcm');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "fcmToken": fcmToken,
            "title": title,
            "body": body,
          }),
        );

        // ✅ حاول تقرأ الـ body في أي حالة
        Map<String, dynamic> responseBody = {};
        try {
          responseBody = jsonDecode(response.body);
        } catch (_) {}

        final errorMessage = responseBody['error']?.toString() ?? '';

        // ✅ الاتنين errors اللي بتحصل
        final isMissingAuth = errorMessage.toLowerCase().contains(
          'missing required authentication credential',
        );
        final isNotFound = errorMessage.toLowerCase().contains(
          'requested entity was not found',
        );

        if (response.statusCode == 200 && !isMissingAuth && !isNotFound) {
          log('✅ Notification sent to: $fcmToken');
          return; // ✅ نجح
        }

        if (isMissingAuth || isNotFound) {
          log('⚠️ Known FCM error on attempt $attempt: $errorMessage');
          if (attempt < maxRetries) {
            await Future.delayed(const Duration(seconds: 2));
            continue; // 🔁 retry
          }
        } else {
          // ❌ error تاني مش من الاتنين دول
          log('❌ Unknown error: ${response.statusCode} - ${response.body}');
          return;
        }
      } catch (e) {
        log('❌ Attempt $attempt exception: $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    log('❌ All $maxRetries attempts failed for token: $fcmToken');
  }

  // Future<void> sendNotificationToToken({
  //   required String title,
  //   required String body,
  //   required String fcmtokennnn,
  // }) async {
  //   try {
  //     final url = Uri.parse('${Constants.baseUrl}/Notification/send-fcm');
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token') ?? 'unknown_sender';
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode({
  //         "fcmToken": fcmtokennnn,
  //         "title": title,
  //         "body": body,
  //       }),
  //     );
  //     print("Sending notification to token: $fcmtokennnn");

  //     if (response.statusCode == 200) {
  //       log('✅ Notification sent to: $fcmtokennnn');
  //     } else {
  //       log('❌ Failed to send: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     log('❌ Error sending notification: $e');
  //   }
  // }

  // Future<void> sendNotificationToTokens({
  //   required String title,
  //   required String body,
  //   required List<String> fcmTokens,
  // }) async {
  //   if (fcmTokens.isEmpty) return;

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token') ?? '';
  //     final url = Uri.parse('${Constants.baseUrl}/Notification/send-fcm');

  //     for (final fcmToken in fcmTokens) {
  //       if (fcmToken.isEmpty) continue;

  //       final response = await http.post(
  //         url,
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $token',
  //         },
  //         body: jsonEncode({
  //           "fcmToken": fcmToken,
  //           "title": title,
  //           "body": body,
  //         }),
  //       );

  //       if (response.statusCode == 200) {
  //         log('✅ Notification sent to: $fcmToken');
  //       } else {
  //         log(
  //           '❌ Failed to send to $fcmToken: ${response.statusCode} - ${response.body}',
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     log('❌ Error sending notifications: $e');
  //   }
  // }

  // ✅ ==================== PAGINATION METHODS ====================

  /// 📥 Fetch first page of notifications for specific salesId (refresh / first load)
  Future<void> fetchNotifications() async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          hasMore: true,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final receiverId = prefs.getString('salesId');

      if (receiverId == null || receiverId.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'No salesId found'));
        return;
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/Notification?receiver=$receiverId&page=1&pageSize=$_pageSize',
      );

      log("📥 Fetching page 1: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        log('✅ Notifications fetched successfully');
        final decoded = jsonDecode(response.body);
        final model = NotificationModel.fromJson(decoded);
        final newItems = model.data ?? [];

        // ✅ Replace list on first page
        notifications = newItems;

        // ✅ If returned less than pageSize → no more pages
        final hasMore = newItems.length >= _pageSize;

        emit(
          state.copyWith(isLoading: false, currentPage: 1, hasMore: hasMore),
        );

        log("📦 Page 1 loaded: ${newItems.length} items | hasMore: $hasMore");
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

  /// 📥 Load next page (pagination) for specific salesId
  Future<void> fetchMoreNotifications() async {
    // ✅ Guard: don't load if already loading or no more pages
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      final nextPage = state.currentPage + 1;

      emit(state.copyWith(isLoadingMore: true, error: null));

      final prefs = await SharedPreferences.getInstance();
      final receiverId = prefs.getString('salesId');

      if (receiverId == null || receiverId.isEmpty) {
        emit(state.copyWith(isLoadingMore: false, error: 'No salesId found'));
        return;
      }

      final url = Uri.parse(
        '${Constants.baseUrl}/Notification?receiver=$receiverId&page=$nextPage&pageSize=$_pageSize',
      );

      log("📥 Fetching page $nextPage: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = NotificationModel.fromJson(decoded);
        final newItems = model.data ?? [];

        // ✅ Append new items to existing list
        notifications = [...notifications, ...newItems];

        final hasMore = newItems.length >= _pageSize;

        emit(
          state.copyWith(
            isLoadingMore: false,
            currentPage: nextPage,
            hasMore: hasMore,
          ),
        );

        log(
          "📦 Page $nextPage loaded: ${newItems.length} items | hasMore: $hasMore",
        );
      } else {
        emit(
          state.copyWith(
            isLoadingMore: false,
            error: 'Failed to load more notifications',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  /// 📦 Fetch first page of all notifications (admin or global access)
  Future<void> fetchAllNotifications() async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          hasMore: true,
        ),
      );

      final url = Uri.parse(
        '${Constants.baseUrl}/Notification?page=1&pageSize=$_pageSize',
      );

      log("📥 Fetching all notifications page 1: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = NotificationModel.fromJson(decoded);
        final newItems = model.data ?? [];

        notifications = newItems;

        final hasMore = newItems.length >= _pageSize;

        emit(
          state.copyWith(isLoading: false, currentPage: 1, hasMore: hasMore),
        );

        log(
          "📦 All notifications page 1: ${newItems.length} items | hasMore: $hasMore",
        );
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

  /// 📦 Load next page of all notifications (admin or global access)
  Future<void> fetchMoreAllNotifications() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      final nextPage = state.currentPage + 1;

      emit(state.copyWith(isLoadingMore: true, error: null));

      final url = Uri.parse(
        '${Constants.baseUrl}/Notification?page=$nextPage&pageSize=$_pageSize',
      );

      log("📥 Fetching all notifications page $nextPage: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = NotificationModel.fromJson(decoded);
        final newItems = model.data ?? [];

        notifications = [...notifications, ...newItems];

        final hasMore = newItems.length >= _pageSize;

        emit(
          state.copyWith(
            isLoadingMore: false,
            currentPage: nextPage,
            hasMore: hasMore,
          ),
        );

        log(
          "📦 All notifications page $nextPage: ${newItems.length} items | hasMore: $hasMore",
        );
      } else {
        emit(
          state.copyWith(
            isLoadingMore: false,
            error: 'Failed to load more notifications',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  // ✅ ==================== END PAGINATION METHODS ====================

  /// 🛑 Stop listening to notifications & unsubscribe
  Future<void> disposeNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salesId = prefs.getString('salesId');

      await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');

      if (salesId != null && salesId.isNotEmpty) {
        await FirebaseMessaging.instance.unsubscribeFromTopic("user_$salesId");
        log("🚫 Unsubscribed from user topic user_$salesId");
      }

      await FirebaseMessaging.instance.deleteToken();
      log("🧹 FCM Token Deleted from Firebase");

      _isInitialized = false;
      log("🔕 Notification listeners stopped successfully");
    } catch (e) {
      log("❌ Error in disposeNotifications: $e");
    }
  }
}
