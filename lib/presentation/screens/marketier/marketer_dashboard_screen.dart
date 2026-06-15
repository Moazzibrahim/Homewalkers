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
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────
//  Helper: icon bg / icon color / progress color
// ─────────────────────────────────────────────
Color _getIconBgColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFFE8F0FE);
    case 'duplicates':
      return const Color(0xFFFFF3E0);
    default:
      return const Color(0xFFE8F0FE);
  }
}

Color _getIconColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFF2563EB);
    case 'duplicates':
      return const Color(0xFFF59E0B);
    default:
      return const Color(0xFF003178);
  }
}

Color _getProgressColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFF2563EB);
    case 'duplicates':
      return const Color(0xFFF59E0B);
    case 'fresh':
    case 'no answer':
    case 'cancel meeting':
      return const Color(0xFF003178);
    case 'follow after meeting':
    case 'long follow':
    case 'meeting':
    case 'assigned':
    case 'delivered':
      return const Color(0xFF003178);
    case 'not interested':
      return Colors.black;
    default:
      return const Color(0xFF003178);
  }
}

IconData _getStageIcon(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return Icons.group_rounded;
    case 'duplicates':
      return Icons.copy_all_rounded;
    case 'fresh':
      return Icons.fiber_new_rounded;
    case 'follow':
    case 'follow up':
    case 'long follow':
      return Icons.call;
    case 'no answer':
      return Icons.phone_missed_rounded;
    case 'transfer':
      return Icons.sync_alt_rounded;
    case 'interested':
      return Icons.favorite;
    case 'not interested':
      return Icons.thumb_down_alt_rounded;
    case 'follow after meeting':
      return Icons.history;
    case 'pending':
      return Icons.hourglass_empty_rounded;
    case 'done deal':
    case 'eoi':
      return Icons.celebration;
    case 'cancel meeting':
      return Icons.cancel_rounded;
    case 'meeting':
      return Icons.people_alt_rounded;
    case 'assigned':
      return Icons.check;
    case 'delivered':
      return Icons.done_all;
    default:
      return Icons.timeline;
  }
}

// ─────────────────────────────────────────────
//  Shimmer
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
//  Main Screen
// ─────────────────────────────────────────────
class MarketerDashboardScreen extends StatefulWidget {
  const MarketerDashboardScreen({super.key});

  @override
  State<MarketerDashboardScreen> createState() =>
      _MarketerDashboardScreenState();

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

    final IconData selectedIcon = _getStageIcon(title);
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
          mainAxisSize: MainAxisSize.min,
          children: [
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
class _MarketerDashboardScreenState extends State<MarketerDashboardScreen>
    with WidgetsBindingObserver {
  late GetLeadsMarketerCubit _marketerCubit;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();

    _marketerCubit = GetLeadsMarketerCubit(GetLeadsService())
      ..fetchMarketerDashboard();

    context.read<NotificationCubit>().initNotifications();
    print("init notifications called");
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User';
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed — refreshing marketer dashboard...");
      _marketerCubit.fetchMarketerDashboard();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _marketerCubit.close();
    super.dispose();
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
                  : (14 * tabletWidthScale).w,
          vertical:
              isTabletDevice
                  ? (12 * tabletHeightScale).h
                  : (10 * tabletHeightScale).h,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
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
              'Data Centre',
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
    final double childAspectRatio = isTabletDevice ? 2.1 : 2.0;
    return BlocProvider.value(
      value: _marketerCubit,
      child: Scaffold(
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
                    // ── Row 1: Logo + Notifications ──────────────
                    Row(
                      children: [
                        Container(
                          width: (30 * tabletWidthScale).w,
                          height: (30 * tabletHeightScale).h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF003178), Color(0xFF0D47A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              (7 * tabletScale).r,
                            ),
                          ),
                          child: Icon(
                            Icons.business,
                            color: Colors.white,
                            size: (16 * tabletFontScale).sp,
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
                        MarketerDashboardScreen._iconBox(
                          Icons.notifications_none,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const SalesNotificationsScreen(),
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

                    // ── Row 2: Welcome + Name + Data Centre ─
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
            _marketerCubit.fetchMarketerDashboard();
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

                  // ── Stats Grid ───────────────────────
                  BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
                    builder: (context, state) {
                      if (state is GetMarketerDashboardLoading) {
                        return const MarketerDashboardShimmer();
                      }

                      if (state is GetMarketerDashboardSuccess) {
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
                              stage.stageName!: stage,
                        };

                        final List<Widget> statCards = [
                          // Leads card
                          MarketerDashboardScreen._dashboardCard(
                            'Leads',
                            '$totalLeads',
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
                                          showDuplicatesOnly: true,
                                          data: false,
                                          transferefromdata: true,
                                          leadsCount:
                                              totalLeads
                                                  .toInt(), // ✅ بعت الـ count
                                        ),
                                      ),
                                ),
                              );
                            },
                          ),

                          // Duplicates card (only if count > 0)
                          if (duplicatesCount > 0)
                            MarketerDashboardScreen._dashboardCard(
                              'Duplicates',
                              '$duplicatesCount',
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
                                            showDuplicatesOnly: false,
                                            data: false,
                                            transferefromdata: true,
                                            leadsCount:
                                                duplicatesCount
                                                    .toInt(), // ✅ بعت الـ count
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),

                          // Stage cards
                          ...stageMap.entries.map((entry) {
                            final stageData = entry.value;
                            return MarketerDashboardScreen._dashboardCard(
                              entry.key,
                              (stageData.leadCount ?? 0).toString(),
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
                                            transferefromdata: true,
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

                      // Error / empty state
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all((16 * tabletScale).r),
                          child: Text(
                            "Couldn't load data.",
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
