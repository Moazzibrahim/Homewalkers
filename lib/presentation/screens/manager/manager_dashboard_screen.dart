// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print, unused_field
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_dashboard_data_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();

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

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
    with WidgetsBindingObserver {
  late GetManagerLeadsCubit _managerCubit;
  final String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 👈 نراقب حالة التطبيق
    checkAuth();

    // إنشاء Cubit مرة واحدة فقط
    _managerCubit = GetManagerLeadsCubit(GetLeadsService())
      ..getManagerDashboardCounts();

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
      print("App resumed — refreshing manager dashboard counts...");
      _managerCubit
          .getManagerDashboardCounts(); // 👈 تحديث البيانات لما المستخدم يرجع
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _managerCubit.close(); // 👈 إغلاق Cubit لتفادي memory leaks
    super.dispose();
  }

  Widget _dataCentreButton(BuildContext context, bool isTablet) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManagerDashboardDataScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16.w : 12.w,
          vertical: isTablet ? 12.h : 8.h,
        ),
        decoration: BoxDecoration(
          color: Constants.maincolor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Constants.maincolor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storage_rounded,
              color: Constants.maincolor,
              size: isTablet ? 20 : 18,
            ),
            SizedBox(width: isTablet ? 8.w : 4.w),
            Text(
              'Data Centre',
              style: TextStyle(
                color: Constants.maincolor,
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: isTablet ? 4.w : 2.w),
            Icon(
              Icons.arrow_forward_ios,
              color: Constants.maincolor,
              size: isTablet ? 16 : 14,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // 👈 نستخدم value بدل create عشان نمرر نفس نسخة الكيubit اللي أنشأناها في initState
      value: _managerCubit,
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
                          'Manager',
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
              ManagerDashboardScreen._iconBox(Icons.notifications_none, () {
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final orientation = MediaQuery.of(context).orientation;

            // 👇 تحديد نوع الجهاز
            final bool isTablet = width >= 600;
            final bool isLandscape = orientation == Orientation.landscape;

            // 👇 عدد الأعمدة يتغير حسب المقاس
            int crossAxisCount = 2;

            if (isTablet && isLandscape) {
              crossAxisCount = 4;
            } else if (isTablet) {
              crossAxisCount = 3;
            } else if (isLandscape) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 2;
            }

            return RefreshIndicator(
              onRefresh: () async {
                await _managerCubit.getManagerDashboardCounts();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 16,
                  vertical: 20,
                ),
                child: BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
                  builder: (context, state) {
                    if (state is GetManagerLeadsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GetManagerDashboardSuccess) {
                      final dashboard = state.dashboard.data!;
                      final stages = dashboard.dashboard ?? [];
                      final summary = dashboard.summary;
                      final managerFresh = dashboard.managerFresh;
                      final managerPending = dashboard.managerPending;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 👋 HELLO
                          Row(
                            children: [
                              Text(
                                "Dashboard",
                                style: TextStyle(
                                  fontSize: isTablet ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              // 🗄️ Data Centre Button
                              _dataCentreButton(context, isTablet),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// 🔹 كل الكروت في Grid واحدة مرنة
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: isTablet ? 1.5 : 1.3,
                                ),
                            children: [
                              /// Total Leads
                              ManagerDashboardScreen._dashboardCard(
                                "Total Leads",
                                "${summary?.totalLeads ?? 0}",
                                Icons.group,
                                context,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ManagerLeadsScreen(data: true),
                                    ),
                                  );
                                },
                              ),
                              /// Team Leaders
                              ManagerDashboardScreen._dashboardCard(
                                "Team Leaders",
                                "${summary?.totalTeamLeaders ?? 0}",
                                Icons.supervisor_account,
                                context,
                              ),

                              ManagerDashboardScreen._dashboardCard(
                                "Total Sales",
                                "${summary?.totalSales ?? 0}",
                                Icons.supervisor_account,
                                context,
                              ),

                              /// Fresh
                              ManagerDashboardScreen._dashboardCard(
                                managerFresh?.stageName ?? "Fresh",
                                "${managerFresh?.leadsCount ?? 0}",
                                Icons.fiber_new,
                                context,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ManagerLeadsScreen(
                                            stageName: managerFresh?.stageId,
                                            data:
                                                true, // ✅ نمرر data: true عشان نجيب بيانات الـ Fresh لما نضغط
                                          ),
                                    ),
                                  );
                                },
                              ),

                              /// Pending
                              ManagerDashboardScreen._dashboardCard(
                                managerPending?.stageName ?? "Pending",
                                "${managerPending?.leadsCount ?? 0}",
                                Icons.hourglass_bottom,
                                context,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ManagerLeadsScreen(
                                            stageName: managerPending?.stageId,
                                            data:
                                                true, // ✅ نمرر data: true عشان نجيب بيانات الـ Pending لما نضغط
                                          ),
                                    ),
                                  );
                                },
                              ),

                              /// باقي الـ stages
                              ...stages.map((stage) {
                                return ManagerDashboardScreen._dashboardCard(
                                  stage.stageName ?? "Unknown",
                                  "${stage.leadsCount ?? 0}",
                                  Icons.timeline,
                                  context,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ManagerLeadsScreen(
                                              stageName: stage.stageId,
                                              data:
                                                  true, // ✅ نمرر data: true عشان نجيب بيانات الـ stage لما نضغط
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
                    }

                    return const SizedBox();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
