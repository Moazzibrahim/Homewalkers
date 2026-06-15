// ignore_for_file: file_names, camel_case_types, deprecated_member_use, use_build_context_synchronously, unused_field, avoid_print

import 'dart:async';
import 'dart:math' as math;
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
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/all_request_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/meetingCommentsScreen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/meeting/cubit/meetingcomments_cubit.dart'
    show MeetingCommentsCubit;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────
//  Helper: icon bg / icon color / progress color
// ─────────────────────────────────────────────
Color _getIconBgColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFFE8F0FE);
    case 'sales':
      return const Color(0xFFFFF8E6);
    case 'fresh':
      return const Color(0xFFE8F0FE);
    case 'follow up':
    case 'follow':
      return const Color(0xFFE8F0FE);
    case 'follow after meeting':
    case 'long follow':
      return const Color(0xFFE8F0FE);
    case 'interested':
      return const Color(0xFFE8F0FE);
    case 'not interested':
      return const Color(0xFFE8F0FE);
    case 'done deal':
      return const Color(0xFFE8F0FE);
    case 'no answer':
      return const Color(0xFFE8F0FE);
    case 'transfer':
      return const Color(0xFFE8F0FE);
    case 'pending':
      return const Color(0xFFE8F0FE);
    case 'meeting':
      return const Color(0xFFE8F0FE);
    case 'cancel meeting':
      return const Color(0xFFE8F0FE);
    case 'assigned':
      return const Color(0xFFE8F0FE);
    case 'delivered':
      return const Color(0xFFE8F0FE);
    case 'data centre':
      return const Color(0xFFE8F0FE);
    default:
      return const Color(0xFFE8F0FE);
  }
}

Color _getIconColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFF2563EB);
    case 'sales':
      return const Color(0xFFF59E0B);
    case 'fresh':
      return const Color(0xFF003178);
    case 'follow up':
    case 'follow':
      return const Color(0xFF003178);
    case 'follow after meeting':
    case 'long follow':
      return const Color(0xFF003178);
    case 'interested':
      return const Color(0xFF003178);
    case 'not interested':
      return const Color(0xFF003178);
    case 'done deal':
      return const Color(0xFF003178);
    case 'no answer':
      return const Color(0xFF003178);
    case 'transfer':
      return const Color(0xFF003178);
    case 'pending':
      return const Color(0xFF003178);
    case 'meeting':
      return const Color(0xFF003178);
    case 'cancel meeting':
      return const Color(0xFF003178);
    case 'assigned':
      return const Color(0xFF003178);
    case 'delivered':
      return const Color(0xFF16A34A);
    case 'data centre':
      return const Color(0xFF003178);
    default:
      return const Color(0xFF003178);
  }
}

Color _getProgressColor(String title) {
  switch (title.toLowerCase()) {
    case 'fresh':
    case 'no answer':
    case 'cancel meeting':
      return const Color(0xFF003178);
    case 'sales':
      return const Color(0xFFF59E0B);
    case 'follow after meeting':
    case 'long follow':
    case 'meeting':
    case 'assigned':
    case 'delivered':
      return const Color(0xFF003178);
    case 'not interested':
      return Colors.black;
    case 'pending':
      return const Color(0xFF003178);
    default:
      return const Color(0xFF003178);
  }
}

// ─────────────────────────────────────────────
//  Shimmer
// ─────────────────────────────────────────────
class AdminDashboardShimmer extends StatelessWidget {
  const AdminDashboardShimmer({super.key});

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

    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: EdgeInsets.only(top: (8 * tabletHeightScale).h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTabletDevice ? 3 : 2,
        crossAxisSpacing: (16 * tabletWidthScale).w,
        mainAxisSpacing: (16 * tabletHeightScale).h,
        childAspectRatio: isTabletDevice ? 2.0 : 1.8,
      ),
      itemCount: isTabletDevice ? 9 : 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            padding: EdgeInsets.all((14 * tabletScale).r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular((16 * tabletScale).r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: (44 * tabletHeightScale).h,
                      width: (44 * tabletWidthScale).w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (12 * tabletScale).r,
                        ),
                      ),
                    ),
                    SizedBox(width: (10 * tabletWidthScale).w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: (10 * tabletHeightScale).h,
                            width: (60 * tabletWidthScale).w,
                            color: Colors.white,
                          ),
                          SizedBox(height: (6 * tabletHeightScale).h),
                          Container(
                            height: (22 * tabletHeightScale).h,
                            width: (40 * tabletWidthScale).w,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: (5 * tabletHeightScale).h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular((6 * tabletScale).r),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  final bool showNavBar; // ← أضف ده

  const AdminDashboardScreen({super.key, this.showNavBar = true});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();

  // ── Icon Box ──────────────────────────────────
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
                  ? Constants.mainlightmodecolor
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

  // ── Dashboard Card ────────────────────────────
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
    final progress =
        totalCount == 0 ? 0.0 : (count / totalCount).clamp(0.0, 1.0);

    // Icon selection
    IconData selectedIcon;
    switch (title.toLowerCase()) {
      case 'fresh':
        selectedIcon = Icons.fiber_new_rounded;
        break;
      case 'follow':
      case 'follow up':
      case 'long follow':
        selectedIcon = Icons.call;
        break;
      case 'no answer':
        selectedIcon = Icons.phone_missed_rounded;
        break;
      case 'transfer':
        selectedIcon = Icons.sync_alt_rounded;
        break;
      case 'interested':
        selectedIcon = Icons.favorite;
        break;
      case 'not interested':
        selectedIcon = Icons.thumb_down_alt_rounded;
        break;
      case 'follow after meeting':
        selectedIcon = Icons.history;
        break;
      case 'pending':
        selectedIcon = Icons.hourglass_empty_rounded;
        break;
      case 'done deal':
        selectedIcon = Icons.celebration;
        break;
      case 'eoi':
        selectedIcon = Icons.celebration;
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
      case 'leads':
        selectedIcon = Icons.group_rounded;
        break;
      case 'sales':
        selectedIcon = Icons.person_rounded;
        break;
      default:
        selectedIcon = icon ?? Icons.bar_chart_rounded;
    }

    final Color iconBg = _getIconBgColor(title);
    final Color iconColor = _getIconColor(title);
    final Color progressColor = _getProgressColor(title);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular((14 * tabletScale).r),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          (10 * tabletScale).r,
          (10 * tabletScale).r,
          (10 * tabletScale).r,
          (8 * tabletScale).r,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular((14 * tabletScale).r),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: (6 * tabletScale).r,
              offset: Offset(0, (2 * tabletHeightScale).h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 👈 أهم حاجة (تقلل المسافات)

          children: [
            // ── Icon (left) + Title & Number (right) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon box
                Container(
                  height: (40 * tabletHeightScale).h,
                  width: (40 * tabletWidthScale).w,
                  decoration: BoxDecoration(
                    color: isDarkMode ? iconColor.withOpacity(0.15) : iconBg,
                    borderRadius: BorderRadius.circular((10 * tabletScale).r),
                  ),
                  child: Icon(
                    selectedIcon,
                    color: iconColor,
                    size: (20 * tabletFontScale).sp,
                  ),
                ),
                SizedBox(width: (8 * tabletWidthScale).w),
                // Title + Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          fontSize: (9 * tabletFontScale).sp,
                          color: isDarkMode ? Colors.white54 : Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: (2 * tabletHeightScale).h),
                      Text(
                        number.isEmpty ? '0' : number,
                        style: TextStyle(
                          fontSize: (20 * tabletFontScale).sp,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1a2f5e),
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: (18 * tabletHeightScale).h),
            // ── Progress Bar ──────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular((4 * tabletScale).r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: (4 * tabletHeightScale).h,
                backgroundColor: Colors.grey.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  State
// ─────────────────────────────────────────────
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

  // ── Data Centre Button ─────────────────────────
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
                  : (14 * tabletWidthScale).w,
          vertical:
              isTabletDevice
                  ? (12 * tabletHeightScale).h
                  : (10 * tabletHeightScale).h,
        ),
        decoration: BoxDecoration(
          // ✅ زي الصورة: خلفية داكنة للـ Data Center
          gradient: LinearGradient(
            colors: [Color(0xFF003178), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular((12 * tabletScale).r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storage_rounded,
              color: Colors.white,
              size:
                  isTabletDevice
                      ? (18 * tabletFontScale).sp
                      : (16 * tabletFontScale).sp,
            ),
            SizedBox(
              width:
                  isTabletDevice
                      ? (8 * tabletWidthScale).w
                      : (6 * tabletWidthScale).w,
            ),
            Text(
              'Data Center',
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    isTabletDevice
                        ? (15 * tabletFontScale).sp
                        : (13 * tabletFontScale).sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────
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

    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    final int crossAxisCount = isTabletDevice ? 3 : 2;
    final double childAspectRatio = isTabletDevice ? 2.2 : 2.0;

    return Scaffold(
      bottomNavigationBar:
          widget.showNavBar ? SharedAdminNavBar(currentIndex: 0) : null,
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          isTabletDevice ? (105 * tabletHeightScale).h : 131.h,
        ),
        child: Container(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Constants.backgroundDarkmode,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: (16 * tabletWidthScale).w,
                right: (16 * tabletWidthScale).w,
                top: (8 * tabletHeightScale).h,
                bottom: (8 * tabletHeightScale).h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Row 1: Logo + Icons ──────────────
                  Row(
                    children: [
                      Container(
                        width: (30 * tabletWidthScale).w,
                        height: (30 * tabletHeightScale).h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF003178), Color(0xFF0D47A1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            (7 * tabletScale).r,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/icon.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: (7 * tabletWidthScale).w),
                      Text(
                        'REALATIX',
                        style: TextStyle(
                          fontSize: (14 * tabletFontScale).sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1a2f5e),
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      AdminDashboardScreen._iconBox(
                        Icons.notifications_none,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const SalesNotificationsScreen(),
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
                      SizedBox(width: (6 * tabletWidthScale).w),
                      AdminDashboardScreen._iconBox(
                        Icons.event_outlined,
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
                      SizedBox(width: (6 * tabletWidthScale).w),

                      AdminDashboardScreen._iconBox(
                        Icons.history,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const RequestsHistoryScreen(),
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

                  SizedBox(height: (8 * tabletHeightScale).h),
                  const Divider(),

                  // ── Row 2: Welcome + Name + Data Center ─
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: (11 * tabletFontScale).sp,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            _userName,
                            style: TextStyle(
                              fontSize: (20 * tabletFontScale).sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1a2f5e),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _dataCentreButton(
                        isTabletDevice: isTabletDevice,
                        tabletScale: tabletScale,
                        tabletFontScale: tabletFontScale,
                        tabletWidthScale: tabletWidthScale,
                        tabletHeightScale: tabletHeightScale,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                SizedBox(height: (16 * tabletHeightScale).h),

                // ── Stats Grid ───────────────────────
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
                        // Leads
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
                                      child: AdminLeadsScreen(
                                        data: false,
                                        transferefromdata: true,
                                        leadsCount: allUsers,
                                        showNavBar: true, // ← أضف ده
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
                        // Sales
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
                                  builder:
                                      (_) => const AdminSalesSceen(
                                        showNavBar: true,
                                      ),
                                ),
                              ),
                        ),
                        // Stage cards
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
                                                leadsCount:
                                                    entry.leadsCount
                                                        ?.toInt(), // 👈 هنا
                                                showNavBar: true, // ← أضف ده
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
                                                leadsCount:
                                                    entry.leadsCount
                                                        ?.toInt(), // 👈 هنا
                                                showNavBar: true, // ← أضف ده
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
                          crossAxisSpacing: (8 * tabletWidthScale).w,
                          mainAxisSpacing: (8 * tabletHeightScale).h,
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
