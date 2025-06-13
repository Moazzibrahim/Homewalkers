// main.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/screens/decider_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/theme/theme_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
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
  await Firebase.initializeApp();
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint("🧪 Main.dart direct FCM Token: $token");
  // Initialize SharedPreferences and get saved theme
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  final initialTheme = isDark ? ThemeMode.dark : ThemeMode.light;

  log("Initial Theme: $initialTheme");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  // في main.dart، قبل runApp
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

  runApp(MyApp(initialTheme: initialTheme));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialTheme;

  const MyApp({super.key, required this.initialTheme});

  // داخل MyApp
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(initialTheme)),
        // BlocProvider(create: (_) => RegionCubit(RegionApiService())),
        BlocProvider(create: (_) => StagesCubit(StagesApiService())),
        BlocProvider(
          create: (_) {
            final cubit = NotificationCubit();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cubit.initNotifications();
            });
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => GetLeadsCubit(GetLeadsService())..fetchLeads(),
        ),
        BlocProvider<GetLeadsTeamLeaderCubit>(
          create:
              (_) => GetLeadsTeamLeaderCubit(
                GetLeadsService()..getLeadsDataByTeamLeader(),
              ),
        ),
        BlocProvider(
          create:
              (context) =>
                  GetManagerLeadsCubit(GetLeadsService())..getLeadsByManager(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return ScreenUtilInit(
            designSize: const Size(
              375,
              812,
            ), // مقاس التصميم الأساسي (مثال iPhone X)
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, __) {
              return MaterialApp(
                title: 'Login MVVM Example',
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
                // locale: locale,
                // supportedLocales: const [Locale('en'), Locale('ar')],
                // localizationsDelegates: const [
                //   AppLocalizations.delegate,
                //   GlobalMaterialLocalizations.delegate,
                //   GlobalWidgetsLocalizations.delegate,
                //   GlobalCupertinoLocalizations.delegate,
                // ],
                home: DeciderScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
