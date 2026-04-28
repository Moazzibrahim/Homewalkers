// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/dialog_utils.dart';
import 'package:homewalkers_app/data/data_sources/get_sales_dashboard_count_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/all_request_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/request_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesDataDashboardScreen extends StatefulWidget {
  const SalesDataDashboardScreen({super.key});

  @override
  State<SalesDataDashboardScreen> createState() =>
      _SalesDataDashboardScreenState();
}

class _SalesDataDashboardScreenState extends State<SalesDataDashboardScreen>
    with WidgetsBindingObserver {
  String _userName = 'User';
  late SalesDashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();

    _dashboardCubit = SalesDashboardCubit(SalesDashboardApiService());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashboardCubit.fetchDashboardDataCount();
    });

    context.read<NotificationCubit>().initNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _dashboardCubit.fetchDashboardDataCount();
      });
    }
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeTablet = ResponsiveHelper.isLargeTablet(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _dashboardCubit,
      child: Scaffold(
        backgroundColor:
            isDark
                ? Constants.backgroundDarkmode
                : Constants.backgroundlightmode,
        appBar: AppBar(
          backgroundColor: isDark ? Constants.backgroundDarkmode : Colors.white,
          elevation: 0,
          toolbarHeight: isTablet ? 90 : 80,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesTabsScreen(),
                  ),
                );
              },
            ),
          ),
          title: Row(
            children: [
              // معلومات المستخدم
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Constants.maincolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sales',
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
              // _iconBox(FontAwesomeIcons.box, () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const RequestsHistoryScreen(),
              //     ),
              //   );
              // }, context),
              // SizedBox(width: 8),
              // زر الإشعارات
              _iconBox(Icons.notifications_none, () {
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
            await _dashboardCubit.fetchDashboardDataCount();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 20,
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
                      'Track your leads and performance',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                    ),
                    // const SizedBox(height: 24),

                    // // ✅ زر طلب الليدز المعدل - داخل دالة build
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
                    //       if (result == true && mounted) {
                    //         // عرض مؤشر تحميل
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           const SnackBar(
                    //             content: Row(
                    //               children: [
                    //                 SizedBox(
                    //                   width: 20,
                    //                   height: 20,
                    //                   child: CircularProgressIndicator(
                    //                     strokeWidth: 2,
                    //                     color: Colors.white,
                    //                   ),
                    //                 ),
                    //                 SizedBox(width: 12),
                    //                 Text('Refreshing dashboard...'),
                    //               ],
                    //             ),
                    //             backgroundColor: Constants.maincolor,
                    //             duration: Duration(seconds: 1),
                    //           ),
                    //         );

                    //         // ✅ تحديث بيانات الداشبورد
                    //         await _dashboardCubit.fetchDashboardDataCount();

                    //         // عرض رسالة نجاح
                    //         if (mounted) {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             const SnackBar(
                    //               content: Text(
                    //                 '✅ Dashboard updated successfully!',
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
                    const SizedBox(height: 28),

                    // محتوى الداشبورد
                    BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
                      builder: (context, state) {
                        if (state is SalesDashboardLoading) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _dashboardCard(
                                      'Leads',
                                      '...',
                                      Icons.group,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Center(child: CircularProgressIndicator()),
                            ],
                          );
                        } else if (state is SalesDashboardError) {
                          return Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No Data Found",
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is SalesDashboardCountSuccess) {
                          final cubit = context.read<SalesDashboardCubit>();
                          final stages = cubit.getVisibleStagesFromCount(
                            state.data,
                          );

                          final totalLeads =
                              state.data.data?.summary?.totalLeads ?? 0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _dashboardCard(
                                      'Leads',
                                      totalLeads.toString(),
                                      Icons.group,
                                      context,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const SalesLeadsScreen(
                                                  data: false,
                                                  transferfromdata: false,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              GridView.count(
                                crossAxisCount:
                                    isLargeTablet
                                        ? 4
                                        : isTablet
                                        ? 3
                                        : 2,
                                shrinkWrap: true,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: isTablet ? 1.8 : 1.3,
                                physics: const NeverScrollableScrollPhysics(),
                                children:
                                    stages.map((stage) {
                                      final stageName = stage.stageName ?? '';
                                      return _dashboardCard(
                                        stageName == 'No Stage'
                                            ? 'Fresh'
                                            : stageName,
                                        '${stage.leadsCount ?? 0}',
                                        Icons.timeline,
                                        context,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => SalesLeadsScreen(
                                                    stageName:
                                                        stageName == 'Fresh'
                                                            ? 'No Stage'
                                                            : stageName,
                                                    stageId: stage.stageId,
                                                    data: false,
                                                    transferfromdata: false,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                child: _dashboardCard(
                                  'Leads',
                                  '0',
                                  Icons.group,
                                  context,
                                ),
                              ),
                            ],
                          );
                        }
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
    final isTablet = ResponsiveHelper.isTablet(context);
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
