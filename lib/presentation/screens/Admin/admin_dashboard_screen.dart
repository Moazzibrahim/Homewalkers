// ignore_for_file: file_names, camel_case_types, deprecated_member_use, use_build_context_synchronously, unused_field, avoid_print

import 'dart:async';
import 'dart:math' as math; // ✅ للكشف عن التابلت
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/Admin_with_pagination/fetch_data_with_pagination.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/data/data_sources/meeting/get_meeting_comments.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_data_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_sales_sceen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/meetingCommentsScreen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/meeting/cubit/meetingcomments_cubit.dart'
    show MeetingCommentsCubit;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class AdminDashboardShimmer extends StatelessWidget {
  const AdminDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ كشف نوع الجهاز
    final bool isTabletDevice = () {
      final data = MediaQuery.of(context);
      final physicalSize = data.size;
      final diagonal = math.sqrt(
        math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
      );
      final inches = diagonal / (data.devicePixelRatio * 160);
      return inches >= 7.0;
    }();

    // ✅ عوامل التصغير
    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: EdgeInsets.only(top: (8 * tabletHeightScale).h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTabletDevice ? 3 : 2, // ✅ تابلت: 3 أعمدة
        crossAxisSpacing: (16 * tabletWidthScale).w,
        mainAxisSpacing: (16 * tabletHeightScale).h,
        childAspectRatio: isTabletDevice ? 1.6 : 1.4, // ✅ تابلت: نسبة أوسع
      ),
      itemCount: isTabletDevice ? 9 : 6, // ✅ تابلت: عرض شيمرات أكثر
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            padding: EdgeInsets.all((16 * tabletScale).r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular((20 * tabletScale).r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: (12 * tabletHeightScale).h,
                      width: (80 * tabletWidthScale).w,
                      color: Colors.white,
                    ),
                    Container(
                      height: (40 * tabletHeightScale).h,
                      width: (40 * tabletWidthScale).w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: (24 * tabletHeightScale).h,
                  width: (60 * tabletWidthScale).w,
                  color: Colors.white,
                ),
                Container(
                  height: (8 * tabletHeightScale).h,
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
    BuildContext context, {
    required bool isTabletDevice,
    required double tabletScale,
    required double tabletFontScale,
    required double tabletWidthScale,
    required double tabletHeightScale,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular((12 * tabletScale).r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: (1 * tabletScale).r,
            blurRadius: (10 * tabletScale).r,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: (24 * tabletFontScale).sp,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.all((8 * tabletScale).r),
        constraints: BoxConstraints(
          minWidth: (40 * tabletWidthScale).w,
          minHeight: (40 * tabletHeightScale).h,
        ),
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
    required int totalCount,
    required bool isTabletDevice,
    required double tabletScale,
    required double tabletFontScale,
    required double tabletWidthScale,
    required double tabletHeightScale,
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
      case 'data centre':
        selectedIcon = Icons.dashboard_customize_rounded;
        break;
      default:
        selectedIcon = icon ?? Icons.bar_chart_rounded;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular((20 * tabletScale).r),
      child: Container(
        padding: EdgeInsets.all((16 * tabletScale).r),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular((20 * tabletScale).r),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: (15 * tabletScale).r,
              offset: Offset(0, (5 * tabletHeightScale).h),
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
                      fontSize: (12 * tabletFontScale).sp,
                      color: isDarkMode ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  height: (40 * tabletHeightScale).h,
                  width: (40 * tabletWidthScale).w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          title == 'Leads' ||
                                  title == 'Sales' ||
                                  title == 'Data Centre'
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
                  child: Icon(
                    selectedIcon,
                    color: Colors.white,
                    size: (20 * tabletFontScale).sp,
                  ),
                ),
              ],
            ),

            Text(
              number.isEmpty ? '' : number,
              style: TextStyle(
                fontSize: (25 * tabletFontScale).sp,
                color: isDarkMode ? Colors.white : const Color(0xFF0D1B2A),
                fontWeight: FontWeight.w600,
              ),
            ),

            // ✅ Progress Bar - متجاوب
            ClipRRect(
              borderRadius: BorderRadius.circular((6 * tabletScale).r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: (8 * tabletHeightScale).h,
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
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed — refreshing admin dashboard data...");
      context.read<GetAllUsersCubit>().fetchStagesStats();
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
            builder:
                (_) => BlocProvider(
                  create:
                      (context) =>
                          GetAllUsersCubit(GetAllUsersApiService())
                            ..fetchLeadStagesSummary(),
                  child: const AdminDataDashboardScreen(),
                ),
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
  Widget build(BuildContext context) {
    // ✅ كشف نوع الجهاز داخل الـ build
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

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: isTabletDevice ? (120 * tabletHeightScale).h : 100.h,
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
                    fontSize: (22 * tabletFontScale).sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: (16 * tabletFontScale).sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AdminDashboardScreen._iconBox(
              Icons.event,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create:
                              (context) => MeetingCommentsCubit(
                                MeetingCommentsApiService(),
                              ),
                          child: MeetingCommentsScreen(),
                        ),
                  ),
                );
              },
              context,
              isTabletDevice: isTabletDevice,
              tabletScale: tabletScale,
              tabletFontScale: tabletFontScale,
              tabletWidthScale: tabletWidthScale,
              tabletHeightScale: tabletHeightScale,
            ),
            SizedBox(width: (12 * tabletWidthScale).w),
            AdminDashboardScreen._iconBox(
              Icons.notifications_none,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesNotificationsScreen(),
                  ),
                );
              },
              context,
              isTabletDevice: isTabletDevice,
              tabletScale: tabletScale,
              tabletFontScale: tabletFontScale,
              tabletWidthScale: tabletWidthScale,
              tabletHeightScale: tabletHeightScale,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<GetAllUsersCubit>().fetchStagesStats();
        },
        color: Constants.maincolor,
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Constants.backgroundDarkmode,
        strokeWidth: (3 * tabletScale).r,
        displacement: (40 * tabletHeightScale).h,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (16 * tabletWidthScale).w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: (10 * tabletHeightScale).h),
                // 👋 Greeting Row with Data Centre Button
                Row(
                  children: [
                    // 👋 Hello section
                    Row(
                      children: [
                        Text(
                          'Hello $_userName',
                          style: TextStyle(
                            fontSize: (18 * tabletFontScale).sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(width: (8 * tabletWidthScale).w),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: (24 * tabletFontScale).sp),
                        ),
                      ],
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
                SizedBox(height: (20 * tabletHeightScale).h),
                // 📊 BlocBuilder للكاردات
                BlocBuilder<GetAllUsersCubit, GetAllUsersState>(
                  builder: (context, usersState) {
                    if (usersState is StagesStatsLoading) {
                      return const AdminDashboardShimmer();
                    }
                    if (usersState is StagesStatsSuccess) {
                      final allUsers =
                          (usersState.data.totalLeads ?? 0).toInt();
                      final allSales =
                          (usersState.data.activeSales ?? 0).toInt();
                      final List<Widget> statCards = [
                        // 📋 Leads Card
                        AdminDashboardScreen._dashboardCard(
                          'Leads',
                          '$allUsers',
                          Icons.group,
                          context,
                          totalCount: allUsers,
                          isTabletDevice: isTabletDevice,
                          tabletScale: tabletScale,
                          tabletFontScale: tabletFontScale,
                          tabletWidthScale: tabletWidthScale,
                          tabletHeightScale: tabletHeightScale,
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
                                      child: const AdminLeadsScreen(
                                        data: false,
                                        transferefromdata: true,
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
                        // 👤 Sales Card
                        AdminDashboardScreen._dashboardCard(
                          'Sales',
                          '$allSales',
                          Icons.person,
                          context,
                          totalCount: allSales,
                          isTabletDevice: isTabletDevice,
                          tabletScale: tabletScale,
                          tabletFontScale: tabletFontScale,
                          tabletWidthScale: tabletWidthScale,
                          tabletHeightScale: tabletHeightScale,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminSalesSceen(),
                                ),
                              ),
                        ),
                        // ✅ Cards لكل المراحل (من غير Data Centre)
                        ...usersState.data.stages!
                            .where(
                              (entry) => entry.stage?.toLowerCase() != 'follow',
                            )
                            .map(
                              (entry) => AdminDashboardScreen._dashboardCard(
                                entry.stage!,
                                entry.leadsCount.toString(),
                                Icons.timeline,
                                context,
                                totalCount: allUsers,
                                isTabletDevice: isTabletDevice,
                                tabletScale: tabletScale,
                                tabletFontScale: tabletFontScale,
                                tabletWidthScale: tabletWidthScale,
                                tabletHeightScale: tabletHeightScale,
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
                                                showDuplicatesOnly: true,
                                                data: false,
                                                transferefromdata: true,
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
                                                data: false,
                                                transferefromdata: true,
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: (16 * tabletWidthScale).w,
                          mainAxisSpacing: (16 * tabletHeightScale).h,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: statCards.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) => statCards[i],
                      );
                    }
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all((16 * tabletScale).r),
                        child: Text(
                          "Couldn't load data.",
                          style: TextStyle(
                            fontSize: (16 * tabletFontScale).sp,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black87
                                    : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: (20 * tabletHeightScale).h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
