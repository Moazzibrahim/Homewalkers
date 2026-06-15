// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print, unnecessary_brace_in_string_interps, unused_local_variable
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/marketer_dashboard_model.dart';
import 'package:homewalkers_app/presentation/screens/marketier/leads_marketier_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────
//  Helper Functions
// ─────────────────────────────────────────────
Color _getIconBgColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFFE8F0FE);
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
    default:
      return const Color(0xFFE8F0FE);
  }
}

Color _getIconColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFF2563EB);
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
    case 'interested':
      return const Color(0xFF003178);
    case 'follow after meeting':
    case 'long follow':
    case 'meeting':
    case 'assigned':
    case 'delivered':
      return const Color(0xFF003178);
    case 'not interested':
      return const Color(0xFF003178);
    case 'pending':
      return const Color(0xFF003178);
    default:
      return const Color(0xFF003178);
  }
}

// ─────────────────────────────────────────────
//  Shimmer Component
// ─────────────────────────────────────────────
class MarketerDashboardShimmer extends StatelessWidget {
  const MarketerDashboardShimmer({super.key});

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
//  Main Marketer Dashboard Screen
// ─────────────────────────────────────────────
class MarketerDataDashboardScreen extends StatefulWidget {
  const MarketerDataDashboardScreen({super.key});

  @override
  State<MarketerDataDashboardScreen> createState() =>
      _MarketerDashboardScreenState();

  // ── Icon Box ──
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

  // ── Dashboard Card (Same design as Admin) ──
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
      case 'leads':
        selectedIcon = Icons.group_rounded;
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
          children: [
            // ── Icon (left) + Title & Number (right) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
            // ── Progress Bar ──
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

class _MarketerDashboardScreenState extends State<MarketerDataDashboardScreen>
    with WidgetsBindingObserver {
  late GetLeadsMarketerCubit _marketerCubit;
  final String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkAuth();

    _marketerCubit = GetLeadsMarketerCubit(GetLeadsService())
      ..fetchMarketerDataDashboard();

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
      _marketerCubit.fetchMarketerDataDashboard();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _marketerCubit.close();
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

    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    final int crossAxisCount = isTabletDevice ? 3 : 2;
    final double childAspectRatio = isTabletDevice ? 2.1 : 2.0;
    return BlocProvider.value(
      value: _marketerCubit,
      child: Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Constants.backgroundDarkmode,
          elevation: 0,
          toolbarHeight: isTabletDevice ? (120 * tabletHeightScale).h : 100.h,
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
                            fontSize: (18 * tabletFontScale).sp,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xff080719)
                                    : Colors.white,
                          ),
                        ),
                        Text(
                          'Marketer',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: (16 * tabletFontScale).sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const Spacer(),
              MarketerDataDashboardScreen._iconBox(
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
            _marketerCubit.fetchMarketerDataDashboard();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: Constants.maincolor,
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Constants.backgroundDarkmode,
          strokeWidth: (3 * tabletScale).r,
          displacement: (40 * tabletHeightScale).h,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (16 * tabletWidthScale).w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: (16 * tabletHeightScale).h),
                  BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
                    builder: (context, state) {
                      // ── Loading ──
                      if (state is GetMarketerDashboardLoading) {
                        return const MarketerDashboardShimmer();
                      }

                      // ── Success ──
                      if (state is GetMarketerDashboardSuccess) {
                        final allLeads = state.dashboardModel.data ?? [];
                        final totalLeads = state.dashboardModel.totalLeads ?? 0;

                        final Map<String, StageData> stageMap = {
                          for (var stage in allLeads)
                            if ((stage.stageName ?? '').isNotEmpty &&
                                stage.stageName != "Duplicate")
                              stage.stageName!: stage,
                        };

                        final List<Widget> statCards = [
                          // ── Leads Total Card ──
                          MarketerDataDashboardScreen._dashboardCard(
                            'Leads',
                            '$totalLeads',
                            Icons.group_rounded,
                            context,
                            totalCount: totalLeads.toInt(),
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
                                      (context) => BlocProvider(
                                        create:
                                            (_) => GetLeadsMarketerCubit(
                                              GetLeadsService(),
                                            ),
                                        child: LeadsMarketierScreen(
                                          data: false,
                                          transferefromdata: false,
                                          leadsCount:
                                              totalLeads
                                                  .toInt(), // ✅ بعت الـ count
                                        ),
                                      ),
                                ),
                              );
                            },
                          ),

                          // ── Stage Cards ──
                          ...stageMap.entries.map((entry) {
                            final stageData = entry.value;
                            return MarketerDataDashboardScreen._dashboardCard(
                              entry.key,
                              (stageData.leadCount ?? 0).toString(),
                              Icons.timeline,
                              context,
                              totalCount: totalLeads.toInt(),
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
                                        (context) => BlocProvider(
                                          create:
                                              (_) => GetLeadsMarketerCubit(
                                                GetLeadsService(),
                                              ),
                                          child: LeadsMarketierScreen(
                                            stageName: stageData.stageId,
                                            showDuplicatesOnly: true,
                                            data: false,
                                            transferefromdata: false,
                                            leadsCount:
                                                stageData.leadCount
                                                    ?.toInt(), // ✅ بعت الـ count
                                          ),
                                        ),
                                  ),
                                );
                              },
                            );
                          }),
                        ];

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: (10 * tabletWidthScale).w,
                                mainAxisSpacing: (10 * tabletHeightScale).h,
                                childAspectRatio: childAspectRatio,
                              ),
                          itemCount: statCards.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, i) => statCards[i],
                        );
                      }

                      // ── Error / Empty ──
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all((16 * tabletScale).r),
                          child: Text(
                            "No Data found",
                            style: TextStyle(
                              fontSize: (16 * tabletFontScale).sp,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
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
      ),
    );
  }
}
