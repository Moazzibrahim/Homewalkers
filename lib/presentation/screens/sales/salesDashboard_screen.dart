// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/dialog_utils.dart';
import 'package:homewalkers_app/data/data_sources/get_sales_dashboard_count_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. تحويل الويدجت إلى StatefulWidget
class SalesdashboardScreen extends StatefulWidget {
  const SalesdashboardScreen({super.key});

  @override
  State<SalesdashboardScreen> createState() => _SalesdashboardScreenState();
}

class _SalesdashboardScreenState extends State<SalesdashboardScreen>
    with WidgetsBindingObserver {
  String _userName = 'User';
  late SalesDashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();

    _dashboardCubit = SalesDashboardCubit(SalesDashboardApiService());

    // ⚠️ استخدم addPostFrameCallback للتأكد من بناء الشاشة أولاً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashboardCubit.fetchDashboard();
    });

    context.read<NotificationCubit>().initNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ⚠️ إضافة تأخير للتأكد من استقرار التطبيق
      Future.delayed(const Duration(milliseconds: 300), () {
        _dashboardCubit.fetchDashboard();
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

    return BlocProvider.value(
      // 👈 نستخدم .value عشان نمرر نفس الـ cubit اللي أنشأناه في initState
      value: _dashboardCubit,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Text(
                    'Sales',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
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
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _dashboardCubit.fetchDashboard();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isTablet(context) ? 32 : 20,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Text(
                          'Hello $_userName',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(width: 8),
                        const Text('👋', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                          return Center(child: Text(state.message));
                        } else if (state is SalesDashboardSuccess) {
                          final cubit = context.read<SalesDashboardCubit>();
                          final stages = cubit.getVisibleStages(state.response);

                          final totalLeads =
                              state.response.data?.summary?.totalLeads ?? 0;

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
                                                (_) => const SalesLeadsScreen(),
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
                                        ? 4 // تابلت كبير 10 inch
                                        : isTablet
                                        ? 3 // تابلت 7–8 inch
                                        : 2, // موبايل
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
    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xff1e1e1e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        ),
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
    final isTablet = ResponsiveHelper.isTablet(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: isTablet ? 140 : 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : const Color(0xff1e1e1e),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Constants.maincolor, size: isTablet ? 36 : 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w400,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color(0xff080719)
                        : Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              number,
              style: TextStyle(
                fontSize: isTablet ? 26 : 20,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color(0xff080719)
                        : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
