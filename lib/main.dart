// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_for_signup_api_service.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/screens/decider_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homewalkers_app/presentation/screens/splash_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users_signup/cubit/getalluserssignup_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/theme/theme_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("[Background] Message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    debugPrint("✅ Firebase initialized. Active apps: ${Firebase.apps.length}");

    // Check if app is actually configured
    if (Firebase.apps.isEmpty) {
      debugPrint("⚠️ No Firebase apps configured after initializeApp()");
    }
  } catch (e) {
    debugPrint("❌ Firebase initialization or token retrieval failed: $e");
  }

  // Small delay to ensure native side is ready
  await Future.delayed(const Duration(seconds: 1));

  // تهيئة الثيم
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  final initialTheme = isDark ? ThemeMode.dark : ThemeMode.light;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null && response.payload!.isNotEmpty) {
        log("📲 Local Notification clicked: ${response.payload}");
        try {
          final data = jsonDecode(response.payload!);
          final target = data['target'];
          final id = data['id'];

          if (target == 'order' && id != null) {
            navigatorKey.currentState?.pushNamed(
              '/orderDetails',
              arguments: id,
            );
          } else if (target == 'chat') {
            navigatorKey.currentState?.pushNamed('/chat');
          } else {
            navigatorKey.currentState?.pushNamed('/notifications');
          }
        } catch (e) {
          log("⚠️ Error parsing notification payload: $e");
          navigatorKey.currentState?.pushNamed('/notifications');
        }
      } else {
        navigatorKey.currentState?.pushNamed('/notifications');
      }
    },
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  runApp(MyApp(initialTheme: initialTheme));
}

StreamSubscription<PhoneState>? _phoneSubscription;


Future<bool> _checkFirstLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
  }

  return isFirstLaunch;
}

class MyApp extends StatelessWidget {
  final ThemeMode initialTheme;

  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(initialTheme)),
        BlocProvider(create: (_) => StagesCubit(StagesApiService())),
        BlocProvider(
          create: (_) {
            final cubit = NotificationCubit();
            cubit.initNotifications();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => GetLeadsCubit(GetLeadsService())),
        BlocProvider<GetLeadsTeamLeaderCubit>(
          create: (_) => GetLeadsTeamLeaderCubit(GetLeadsService()),
        ),
        BlocProvider(create: (_) => GetManagerLeadsCubit(GetLeadsService())),
        BlocProvider(
          create:
              (_) =>
                  GetLeadsMarketerCubit(GetLeadsService())
                    ..getLeadsByMarketer(),
        ),
        BlocProvider(
          create:
              (_) => GetAllUsersCubit(GetAllUsersApiService())..fetchAllUsers(),
          //  ..fetchLeadsInTrash(),
        ),
        BlocProvider(
          create:
              (_) =>
                  GetalluserssignupCubit(GetAllUsersForSignupApiService())
                    ..fetchUsers(),
        ),
        BlocProvider<SalesCubit>(
          create:
              (context) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
        // BlocProvider(create: (_) => CommentsCubit(Newcommentsapiservice())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, __) {
              return MaterialApp(
                title: 'Realatix CRM',
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: ThemeData.light().copyWith(
                  textTheme: ThemeData.light().textTheme.apply(
                    fontFamily: 'Montserrat',
                  ),
                ),

                darkTheme: ThemeData.dark().copyWith(
                  textTheme: ThemeData.dark().textTheme.apply(
                    fontFamily: 'Montserrat',
                  ),
                ),

                themeMode: themeMode,
                home: FutureBuilder<bool>(
                  future: _checkFirstLaunch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final isFirstLaunch = snapshot.data ?? true;
                    return isFirstLaunch
                        ? const SplashScreen()
                        : const DeciderScreen();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
