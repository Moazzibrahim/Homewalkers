// ignore_for_file: file_names, camel_case_types, deprecated_member_use, use_build_context_synchronously, unused_field, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/Admin_with_pagination/fetch_data_with_pagination.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_sales_sceen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
//import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class AdminDashboardShimmer extends StatelessWidget {
  const AdminDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 12, width: 80, color: Colors.white),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Container(height: 24, width: 60, color: Colors.white),
                Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();

  /// A styled container for icons, like the notification icon.
  static Widget _iconBox(
    IconData icon,
    void Function() onPressed,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        // Dynamic background color for the icon box
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
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

  /// A styled card for the dashboard, matching the new design.
  static Widget _dashboardCard(
    String title,
    String number,
    IconData? icon,
    BuildContext context, {
    void Function()? onTap,
    required int totalCount, // ✅ أضف totalCount هنا
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final count = int.tryParse(number) ?? 0;
    final progress = totalCount == 0 ? 0.0 : count / totalCount;

    IconData selectedIcon;
    switch (title.toLowerCase()) {
      case 'fresh':
        selectedIcon = Icons.fiber_new_rounded;
        break;
      case 'follow':
      case 'follow up':
      case 'long follow':
        selectedIcon = Icons.autorenew_rounded;
        break;
      case 'no answer':
        selectedIcon = Icons.phone_missed_rounded;
        break;
      case 'transfer':
        selectedIcon = Icons.sync_alt_rounded;
        break;
      case 'interested':
        selectedIcon = Icons.thumb_up_alt_rounded;
        break;
      case 'not interested':
        selectedIcon = Icons.thumb_down_alt_rounded;
        break;
      case 'follow after meeting':
        selectedIcon = Icons.calendar_today_rounded;
        break;
      case 'pending':
        selectedIcon = Icons.hourglass_empty_rounded;
        break;
      case 'done deal':
        selectedIcon = Icons.check_circle_rounded;
        break;
      case 'cancel meeting':
        selectedIcon = Icons.cancel_rounded;
        break;
      case 'meeting':
        selectedIcon = Icons.people_alt_rounded;
        break;
      case 'assigned':
        selectedIcon = Icons.check;
        break;
      case 'delivered':
        selectedIcon = Icons.done_all;
        break;
      default:
        selectedIcon = icon ?? Icons.bar_chart_rounded;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDarkMode ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          title == 'Leads' || title == 'Sales'
                              ? [
                                Constants.maincolor,
                                Constants.mainDarkmodecolor,
                              ]
                              : [
                                const Color(0xff50E3C2),
                                const Color(0xffA0FFED),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(selectedIcon, color: Colors.white, size: 20),
                ),
              ],
            ),

            Text(
              number,
              style: TextStyle(
                fontSize: 25,
                color: isDarkMode ? Colors.white : const Color(0xFF0D1B2A),
                fontWeight: FontWeight.w600,
              ),
            ),

            // ✅ Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with WidgetsBindingObserver {
  String _userName = 'User';
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<GetAllUsersCubit>().fetchStagesStats();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName = prefs.getString('name') ?? 'User';
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel(); // ✅ نوقف التايمر لما نخرج
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 👇 لما التطبيق يرجع من الخلفية
    if (state == AppLifecycleState.resumed) {
      print("App resumed — refreshing admin dashboard data...");
      context.read<GetAllUsersCubit>().fetchStagesStats();
      // تحديث بيانات المستخدمين
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using MultiBlocProvider to provide both Cubits to the screen.
    return Scaffold(
      // Use system UI color for background
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Constants.backgroundDarkmode,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AdminDashboardScreen._iconBox(Icons.notifications_none, () {
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
          await context.read<GetAllUsersCubit>().fetchStagesStats();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Greeting text
                Row(
                  children: [
                    Text(
                      'Hello $_userName',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 20),
                BlocBuilder<GetAllUsersCubit, GetAllUsersState>(
                  builder: (context, usersState) {
                    if (usersState is StagesStatsLoading) {
                      return const AdminDashboardShimmer();
                    }

                    if (usersState is StagesStatsSuccess) {
                      final allUsers = usersState.data.totalLeads ?? 0;
                      final allSales = usersState.data.activeSales ?? 0;
                      // ✅ ترتيب الـ stages: اللي فيها Leads الأول واللي Zero في الآخر

                      final List<Widget> statCards = [
                        // Leads Card
                        AdminDashboardScreen._dashboardCard(
                          'Leads',
                          '$allUsers',
                          Icons.group,
                          totalCount: allUsers,
                          context,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => BlocProvider(
                                      create:
                                          (_) => AllLeadsCubitWithPagination(
                                            LeadsApiServiceWithQuery(),
                                          ),
                                      child: const AdminLeadsScreen(),
                                    ),
                              ),
                            );
                          },
                        ),
                        // Sales Card
                        AdminDashboardScreen._dashboardCard(
                          'Sales',
                          '$allSales',
                          Icons.person,
                          totalCount: allSales,
                          context,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminSalesSceen(),
                                ),
                              ),
                        ),
                        // ✅ Cards لكل المراحل من API مع الـ count الصحيح
                        ...usersState.data.stages!
                            .where(
                              (entry) => entry.stage?.toLowerCase() != 'follow',
                            )
                            .map(
                              (entry) => AdminDashboardScreen._dashboardCard(
                                entry.stage!,
                                entry.leadsCount.toString(),
                                Icons.timeline,
                                totalCount: allUsers,
                                context,
                                onTap: () {
                                  if (entry.stage?.toLowerCase() ==
                                      "duplicate") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BlocProvider(
                                              create:
                                                  (
                                                    _,
                                                  ) => AllLeadsCubitWithPagination(
                                                    LeadsApiServiceWithQuery(),
                                                  ),
                                              child: AdminLeadsScreen(
                                                // stageName: entry.stage,
                                                showDuplicatesOnly: true,
                                              ),
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BlocProvider(
                                              create:
                                                  (
                                                    _,
                                                  ) => AllLeadsCubitWithPagination(
                                                    LeadsApiServiceWithQuery(),
                                                  ),
                                              child: AdminLeadsScreen(
                                                stageName: entry.stage,
                                                stageId: entry.stageId,
                                              ),
                                            ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                      ];
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.4,
                            ),
                        itemCount: statCards.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) => statCards[i],
                      );
                    }
                    return const Center(child: Text("Couldn't load data."));
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
