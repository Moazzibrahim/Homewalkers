// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print, unnecessary_brace_in_string_interps, unused_local_variable
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/marketer_dashboard_model.dart';
import 'package:homewalkers_app/presentation/screens/marketier/leads_marketier_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_data_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketerDashboardScreen extends StatefulWidget {
  const MarketerDashboardScreen({super.key});

  @override
  State<MarketerDashboardScreen> createState() =>
      _MarketerDashboardScreenState();

  static Widget _iconBox(IconData icon, void Function() onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE8F1F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Constants.maincolor),
        onPressed: onPressed,
      ),
    );
  }

  static Widget _dashboardCard(
    String title,
    String number,
    IconData icon,
    BuildContext context, {
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Color(0xff1e1e1e),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Constants.maincolor, size: 30),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Color(0xff080719)
                        : Colors.white,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              number,
              style: TextStyle(
                fontSize: 20,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Color(0xff080719)
                        : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketerDashboardScreenState extends State<MarketerDashboardScreen>
    with WidgetsBindingObserver {
  late GetLeadsMarketerCubit _marketerCubit;
  // ignore: unused_field
  final String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 👈 مراقبة حالة التطبيق
    checkAuth();

    // إنشاء Cubit مرة واحدة فقط
    _marketerCubit = GetLeadsMarketerCubit(GetLeadsService())
      ..fetchMarketerDashboard();

    // تهيئة الإشعارات
    context.read<NotificationCubit>().initNotifications();
    print("init notifications called");
  }

  Future<String> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed — refreshing marketer dashboard...");
      _marketerCubit.fetchMarketerDashboard(); // 👈 تحديث البيانات عند الرجوع
    }
  }

  // ✅ زر Data Centre الجديد
  Widget _dataCentreButton({
    required bool isTabletDevice,
    required double tabletScale,
    required double tabletFontScale,
    required double tabletWidthScale,
    required double tabletHeightScale,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MarketerDataDashboardScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular((12 * tabletScale).r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal:
              isTabletDevice
                  ? (16 * tabletWidthScale).w
                  : (12 * tabletWidthScale).w,
          vertical:
              isTabletDevice
                  ? (12 * tabletHeightScale).h
                  : (8 * tabletHeightScale).h,
        ),
        decoration: BoxDecoration(
          color: Constants.maincolor.withOpacity(0.1),
          borderRadius: BorderRadius.circular((12 * tabletScale).r),
          border: Border.all(
            color: Constants.maincolor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dashboard_customize_rounded,
              color: Constants.maincolor,
              size:
                  isTabletDevice
                      ? (20 * tabletFontScale).sp
                      : (18 * tabletFontScale).sp,
            ),
            SizedBox(
              width:
                  isTabletDevice
                      ? (8 * tabletWidthScale).w
                      : (4 * tabletWidthScale).w,
            ),
            Text(
              'Data Centre',
              style: TextStyle(
                color: Constants.maincolor,
                fontSize:
                    isTabletDevice
                        ? (16 * tabletFontScale).sp
                        : (14 * tabletFontScale).sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              width:
                  isTabletDevice
                      ? (4 * tabletWidthScale).w
                      : (2 * tabletWidthScale).w,
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Constants.maincolor,
              size:
                  isTabletDevice
                      ? (16 * tabletFontScale).sp
                      : (14 * tabletFontScale).sp,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _marketerCubit.close(); // 👈 قفل الكيوبت لتفادي memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTabletDevice = () {
      final data = MediaQuery.of(context);
      final physicalSize = data.size;
      final diagonal = math.sqrt(
        math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
      );
      final inches = diagonal / (data.devicePixelRatio * 160);
      return inches >= 7.0;
    }();

    // ✅ عوامل التصغير حسب الجهاز
    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;

    // ✅ عدد الأعمدة في GridView
    final int crossAxisCount = isTabletDevice ? 3 : 2;
    // ✅ نسبة العرض إلى الارتفاع
    final double childAspectRatio = isTabletDevice ? 1.6 : 1.4;
    return BlocProvider.value(
      // 👈 نستخدم value عشان نمرر نفس نسخة الكيوبت اللي أنشأناها في initState
      value: _marketerCubit,
      child: Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: AppBar(
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Constants.backgroundDarkmode,
          elevation: 0,
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              FutureBuilder<String>(
                future: checkAuth(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final name = snapshot.data ?? 'User';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xff080719)
                                    : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          'Marketer',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const Spacer(),
              MarketerDashboardScreen._iconBox(Icons.notifications_none, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesNotificationsScreen(),
                  ),
                );
              }),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _marketerCubit.fetchMarketerDashboard(); // 👈 هنا التحديث
            await Future.delayed(Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), // 👈 مهم لتفعيل السحب
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FutureBuilder(
                        future: checkAuth(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("hello ....");
                          } else if (snapshot.hasError) {
                            return const Text('Hello');
                          } else {
                            return Text(
                              'Hello ${snapshot.data}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? const Color(0xff080719)
                                        : Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                      const Spacer(),
                      // 🗄️ Data Centre Button
                      _dataCentreButton(
                        isTabletDevice: isTabletDevice,
                        tabletScale: tabletScale,
                        tabletFontScale: tabletFontScale,
                        tabletWidthScale: tabletWidthScale,
                        tabletHeightScale: tabletHeightScale,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // تم استبدال PieChart بـ BarChart في هذا التعديل
                  // ... (نفس الكود السابق حتى BlocBuilder)
                  BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
                    builder: (context, state) {
                      if (state is GetMarketerDashboardLoading) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MarketerDashboardScreen._dashboardCard(
                                    'Leads',
                                    '...',
                                    Icons.group,
                                    context,
                                  ),
                                ),
                                // SizedBox(width: 12),
                                // Expanded(
                                //   child: _dashboardCard(
                                //     'Deals',
                                //     '...',
                                //     Icons.work_outline,
                                //     context,
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      } else if (state is GetMarketerDashboardSuccess) {
                        final allLeads = state.dashboardModel.data ?? [];
                        final totalLeads = state.dashboardModel.totalLeads ?? 0;
                        final duplicatesCount =
                            allLeads
                                .firstWhere(
                                  (e) => e.stageName == "Duplicate",
                                  orElse: () => StageData(),
                                )
                                .leadCount ??
                            0;
                        final Map<String, StageData> stageMap = {
                          for (var stage in allLeads)
                            if ((stage.stageName ?? '').isNotEmpty &&
                                stage.stageName != "Duplicate")
                              stage.stageName!:
                                  stage, // بدل ما نخزن بس العدد نخزن StageData كاملة
                        };

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MarketerDashboardScreen._dashboardCard(
                                    'Leads',
                                    '${totalLeads}',
                                    Icons.group,
                                    context,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => BlocProvider(
                                                create:
                                                    (_) =>
                                                        GetLeadsMarketerCubit(
                                                          GetLeadsService(),
                                                        ),
                                                child:
                                                    const LeadsMarketierScreen(
                                                      data: false,
                                                      transferefromdata: true,
                                                    ),
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.5,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                if (duplicatesCount > 0)
                                  MarketerDashboardScreen._dashboardCard(
                                    'Duplicates',
                                    '$duplicatesCount',
                                    Icons.copy_all,
                                    context,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => BlocProvider(
                                                create:
                                                    (_) =>
                                                        GetLeadsMarketerCubit(
                                                          GetLeadsService(),
                                                        ),
                                                child:
                                                    const LeadsMarketierScreen(
                                                      showDuplicatesOnly: false,
                                                      data: false,
                                                      transferefromdata: true,
                                                    ),
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ...stageMap.entries.map((entry) {
                                  final stageData = entry.value;
                                  return MarketerDashboardScreen._dashboardCard(
                                    entry.key, // هنا الاسم يفضل للعرض
                                    (stageData.leadCount ?? 0).toString(),
                                    Icons.timeline,
                                    context,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => BlocProvider(
                                                create:
                                                    (_) =>
                                                        GetLeadsMarketerCubit(
                                                          GetLeadsService(),
                                                        ),
                                                child: LeadsMarketierScreen(
                                                  stageName:
                                                      stageData
                                                          .stageId, // هنا تبعت الـ stageId
                                                  showDuplicatesOnly: true,
                                                  data: false,
                                                  transferefromdata: true,
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: MarketerDashboardScreen._dashboardCard(
                                'Leads',
                                '0',
                                Icons.group,
                                context,
                              ),
                            ),
                            // SizedBox(width: 12),
                            // Expanded(
                            //   child: _dashboardCard(
                            //     'Deals',
                            //     '0',
                            //     Icons.work_outline,
                            //     context,
                            //   ),
                            // ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
