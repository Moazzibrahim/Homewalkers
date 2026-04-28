// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print, unused_field, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/all_request_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_team_leader_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/request_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerDashboardDataScreen extends StatefulWidget {
  const ManagerDashboardDataScreen({super.key});

  @override
  State<ManagerDashboardDataScreen> createState() =>
      _ManagerDashboardScreenState();

  static Widget _iconBox(
    IconData icon,
    void Function() onPressed,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Constants.maincolor, size: 22),
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
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
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isTablet ? 140 : 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Constants.maincolor, size: isTablet ? 36 : 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xff080719),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              number,
              style: TextStyle(
                fontSize: isTablet ? 26 : 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xff080719),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerDashboardScreenState extends State<ManagerDashboardDataScreen>
    with WidgetsBindingObserver {
  late GetManagerLeadsCubit _managerCubit;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();

    // إنشاء Cubit مرة واحدة فقط
    _managerCubit = GetManagerLeadsCubit(GetLeadsService())
      ..getManagerDashboardDataCounts();

    // تهيئة الإشعارات
    context.read<NotificationCubit>().initNotifications();
    print("init notifications called");
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('name') ?? 'User';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed — refreshing manager dashboard data counts...");
      _managerCubit.getManagerDashboardDataCounts();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _managerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تحديد نوع الجهاز
    final bool isTablet = width >= 600;
    final bool isLandscape = orientation == Orientation.landscape;

    // عدد الأعمدة يتغير حسب المقاس
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

    return BlocProvider.value(
      value: _managerCubit,
      child: Scaffold(
        backgroundColor:
            isDark
                ? Constants.backgroundDarkmode
                : Constants.backgroundlightmode,
        appBar: AppBar(
          backgroundColor: isDark ? Constants.backgroundDarkmode : Colors.white,
          elevation: 0,
          toolbarHeight: 100,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Constants.maincolor),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => TabsScreenManager()),
              );
            },
          ),
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xff080719),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Constants.maincolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Manager',
                      style: TextStyle(
                        color: Constants.maincolor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // أيقونة طلبات الـ Leads (جديدة)
              // ManagerDashboardDataScreen._iconBox(FontAwesomeIcons.box, () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const RequestsHistoryScreen(),
              //     ),
              //   );
              // }, context),
              // SizedBox(width: 8.w),
              ManagerDashboardDataScreen._iconBox(Icons.notifications_none, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesNotificationsScreen(),
                  ),
                );
              }, context),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _managerCubit.getManagerDashboardDataCounts();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 20,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // الهيدر
                    Row(
                      children: [
                        Text(
                          'Data Centre Dashboard',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: isTablet ? 28 : 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your team and leads performance',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ زر طلب الليدز (تم إضافته هنا)
                    // في دالة build داخل _ManagerDashboardScreenState

                    // ✅ زر طلب الليدز (تم تعديله لاستقبال النتيجة)
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton.icon(
                    //     onPressed: () async {
                    //       // ✅ أضف async
                    //       // ✅ انتظر النتيجة من الشاشة
                    //       final result = await Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => const RequestLeadsScreen(),
                    //         ),
                    //       );

                    //       // ✅ إذا تم تقديم طلب جديد (result == true)، قم بتحديث البيانات
                    //       if (result == true) {
                    //         _managerCubit.getManagerDashboardDataCounts();

                    //         // ✅ Optional: إظهار رسالة للمستخدم
                    //         if (mounted) {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             const SnackBar(
                    //               content: Text(
                    //                 'Dashboard refreshed successfully!',
                    //               ),
                    //               backgroundColor: Colors.green,
                    //               duration: Duration(seconds: 2),
                    //             ),
                    //           );
                    //         }
                    //       }
                    //     },
                    //     icon: Icon(
                    //       Icons.add_circle_outline,
                    //       size: isTablet ? 22 : 20,
                    //     ),
                    //     label: Text(
                    //       'Request New Leads',
                    //       style: TextStyle(
                    //         fontSize: isTablet ? 16 : 14,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Constants.maincolor,
                    //       foregroundColor: Colors.white,
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: 20,
                    //         vertical: isTablet ? 16 : 14,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(14),
                    //       ),
                    //       elevation: 0,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 28),

                    // محتوى الداشبورد
                    BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
                      builder: (context, state) {
                        if (state is GetManagerLeadsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                              /// كل الكروت في Grid واحدة مرنة
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
                                  ManagerDashboardDataScreen._dashboardCard(
                                    "Total Leads",
                                    "${summary?.totalLeads ?? 0}",
                                    Icons.group,
                                    context,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ManagerLeadsScreen(
                                                data: false,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  ManagerDashboardDataScreen._dashboardCard(
                                    "Total Sales",
                                    "${summary?.totalSales ?? 0}",
                                    Icons.supervisor_account,
                                    context,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ManagerTeamLeaderScreen(),
                                        ),
                                      );
                                    },
                                  ),

                                  /// Fresh
                                  ManagerDashboardDataScreen._dashboardCard(
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
                                                stageName:
                                                    managerFresh?.stageId,
                                                data: false,
                                                salesId:
                                                    managerFresh?.salesIds !=
                                                                null &&
                                                            managerFresh!
                                                                .salesIds!
                                                                .isNotEmpty
                                                        ? managerFresh
                                                            .salesIds!
                                                            .first
                                                        : null,
                                              ),
                                        ),
                                      );
                                    },
                                  ),

                                  /// Pending
                                  ManagerDashboardDataScreen._dashboardCard(
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
                                                stageName:
                                                    managerPending?.stageId,
                                                data: false,
                                                salesId:
                                                    managerPending?.salesIds !=
                                                                null &&
                                                            managerPending!
                                                                .salesIds!
                                                                .isNotEmpty
                                                        ? managerPending
                                                            .salesIds!
                                                            .first
                                                        : null,
                                              ),
                                        ),
                                      );
                                    },
                                  ),

                                  /// باقي الـ stages
                                  ...stages.map((stage) {
                                    return ManagerDashboardDataScreen._dashboardCard(
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
                                                  data: false,
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
                    const SizedBox(height: 25),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
