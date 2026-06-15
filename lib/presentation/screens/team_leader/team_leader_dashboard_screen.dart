// ignore_for_file: file_names, camel_case_types, deprecated_member_use, use_build_context_synchronously

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_dashboard_leads_count.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/teamleader_data_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color _getIconBgColor(String title) {
  switch (title.toLowerCase()) {
    case 'leads':
      return const Color(0xFFE8F0FE);
    case 'fresh':
      return const Color(0xFFE8F0FE);
    case 'team leader pending':
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
    case 'fresh':
      return const Color(0xFF003178);
    case 'team leader pending':
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
    case 'team leader pending':
      return const Color(0xFF003178);
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

class TeamLeaderDashboardScreen extends StatefulWidget {
  const TeamLeaderDashboardScreen({super.key});

  @override
  State<TeamLeaderDashboardScreen> createState() =>
      _TeamLeaderDashboardScreenState();
}

class _TeamLeaderDashboardScreenState extends State<TeamLeaderDashboardScreen>
    with WidgetsBindingObserver {
  String _userName = 'User';
  late TeamleaderDashboardCubit _dashboardCubit;

  // تعريف المتغيرات المطلوبة
  late bool isTabletDevice;
  late double tabletScale;
  late double tabletFontScale;
  late double tabletWidthScale;
  late double tabletHeightScale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();

    _dashboardCubit = TeamleaderDashboardCubit(TeamleaderDashboardApiService());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashboardCubit.fetchDashboard();
    });

    context.read<NotificationCubit>().initNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تهيئة المتغيرات
    _initializeResponsiveVariables();
  }

  void _initializeResponsiveVariables() {
    final data = MediaQuery.of(context);
    final physicalSize = data.size;
    final diagonal = math.sqrt(
      math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160);
    isTabletDevice = inches >= 7.0;

    tabletScale = isTabletDevice ? 0.85 : 1.0;
    tabletFontScale = isTabletDevice ? 0.85 : 1.0;
    tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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
      value: _dashboardCubit,
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
                    // ── Row 1: Logo + Icons ──────────────
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
                        _iconBox(Icons.notifications_none, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const SalesNotificationsScreen(),
                            ),
                          );
                        }),
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
                        _dataCentreButton(),
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
            await _dashboardCubit.fetchDashboard();
            await context.read<SalesCubit>().fetchAllSales();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: (16 * tabletWidthScale).w,
                  vertical: (16 * tabletHeightScale).h,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    BlocBuilder<
                      TeamleaderDashboardCubit,
                      TeamleaderDashboardState
                    >(
                      builder: (context, state) {
                        if (state is TeamleaderDashboardLoading) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 📊 Leads Card في Grid صغير
                              GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          isLargeTablet
                                              ? 4
                                              : isTablet
                                              ? 3
                                              : 2,
                                      crossAxisSpacing:
                                          (10 * tabletWidthScale).w,
                                      mainAxisSpacing:
                                          (10 * tabletHeightScale).h,
                                      childAspectRatio:
                                          isLargeTablet
                                              ? 1.6
                                              : isTablet
                                              ? 1.5
                                              : 1.78,
                                    ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return _dashboardCard(
                                    'Leads',
                                    '...',
                                    Icons.group,
                                    totalCount: 0,
                                  );
                                },
                              ),
                              SizedBox(height: (24 * tabletHeightScale).h),
                              const Center(child: CircularProgressIndicator()),
                            ],
                          );
                        } else if (state is TeamleaderDashboardError) {
                          return const Center(child: Text("No Data Found"));
                        } else if (state is TeamleaderDashboardSuccess) {
                          final dashboard =
                              state.response.data?.dashboard ?? [];
                          final teamleaderInfooFresh =
                              state
                                  .response
                                  .data
                                  ?.teamLeaderPending
                                  ?.salesIds ??
                              [];
                          final String firstSalesIdFresh =
                              teamleaderInfooFresh.isNotEmpty
                                  ? teamleaderInfooFresh.first
                                  : '';

                          final totalLeads =
                              state.response.data?.summary?.totalLeads ?? 0;
                          final teamLeaderFresh =
                              state.response.data?.teamLeaderFresh;
                          final teamleaderfreshcount =
                              teamLeaderFresh?.leadsCount ?? 0;
                          final teamLeaderPending =
                              state.response.data?.teamLeaderPending;
                          final teamleaderpendingcount =
                              teamLeaderPending?.leadsCount ?? 0;

                          /// ✅ نخفي أي stage عددها = 0
                          final visibleStages =
                              dashboard
                                  .where((e) => (e.leadsCount ?? 0) > 0)
                                  .where(
                                    (e) =>
                                        e.stageName?.toLowerCase() != 'fresh',
                                  )
                                  .toList();

                          // عدد الـ items = Leads + Fresh + Pending + باقي الـ stages
                          int itemCount = 1; // Leads card
                          if (teamLeaderFresh != null &&
                              teamleaderfreshcount > 0) {
                            itemCount++; // Fresh card
                          }
                          if (teamLeaderPending != null &&
                              teamleaderpendingcount > 0) {
                            itemCount++; // Pending card
                          }
                          itemCount += visibleStages.length;

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      isLargeTablet
                                          ? 4
                                          : isTablet
                                          ? 3
                                          : 2,
                                  crossAxisSpacing: (10 * tabletWidthScale).w,
                                  mainAxisSpacing: (10 * tabletHeightScale).h,
                                  childAspectRatio:
                                      isLargeTablet
                                          ? 1.6
                                          : isTablet
                                          ? 1.5
                                          : 1.78,
                                ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              int currentIndex = 0;

                              // 📊 Leads Card (always first)
                              if (index == currentIndex) {
                                return _dashboardCard(
                                  'Leads',
                                  totalLeads.toString(),
                                  Icons.group,
                                  totalCount: totalLeads.toInt(),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const TeamLeaderAssignScreen(
                                              data: false,
                                              transferfromdata: true,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }
                              currentIndex++;

                              // 🌱 Fresh Card (if exists)
                              if (teamLeaderFresh != null &&
                                  teamleaderfreshcount > 0) {
                                if (index == currentIndex) {
                                  return _dashboardCard(
                                    'Fresh',
                                    '$teamleaderfreshcount',
                                    Icons.timeline,
                                    totalCount: totalLeads.toInt(),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TeamLeaderAssignScreen(
                                                stageName: "fresh",
                                                data: false,
                                                transferfromdata: true,
                                                stageId:
                                                    teamLeaderFresh.stageId,
                                                salesName: firstSalesIdFresh,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                currentIndex++;
                              }

                              // ⏳ Pending Card (if exists)
                              if (teamLeaderPending != null &&
                                  teamleaderpendingcount > 0) {
                                if (index == currentIndex) {
                                  return _dashboardCard(
                                    'Team Leader Pending',
                                    '$teamleaderpendingcount',
                                    Icons.pending_actions,
                                    totalCount: totalLeads.toInt(),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TeamLeaderAssignScreen(
                                                stageName:
                                                    "Team Leader Pending",
                                                data: false,
                                                transferfromdata: true,
                                                stageId:
                                                    teamLeaderPending.stageId,
                                                salesName: firstSalesIdFresh,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                currentIndex++;
                              }

                              // 🎯 باقي الـ stages
                              final stageIndex = index - currentIndex;
                              if (stageIndex >= 0 &&
                                  stageIndex < visibleStages.length) {
                                final item = visibleStages[stageIndex];
                                return _dashboardCard(
                                  item.stageName ?? '',
                                  '${item.leadsCount ?? 0}',
                                  Icons.timeline,
                                  totalCount: totalLeads.toInt(),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => TeamLeaderAssignScreen(
                                              stageName: item.stageName,
                                              data: false,
                                              transferfromdata: true,
                                              stageId: item.stageId,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }

                              return const SizedBox();
                            },
                          );
                        } else {
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      isLargeTablet
                                          ? 4
                                          : isTablet
                                          ? 3
                                          : 2,
                                  crossAxisSpacing: (10 * tabletWidthScale).w,
                                  mainAxisSpacing: (10 * tabletHeightScale).h,
                                  childAspectRatio:
                                      isLargeTablet
                                          ? 1.6
                                          : isTablet
                                          ? 1.5
                                          : 1.78,
                                ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return _dashboardCard(
                                'Leads',
                                '0',
                                Icons.group,
                                totalCount: 0,
                              );
                            },
                          );
                        }
                      },
                    ),
                    SizedBox(height: (25 * tabletHeightScale).h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ IconBox Widget
  Widget _iconBox(IconData icon, void Function() onPressed) {
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

  // ✅ Dashboard Card Widget
  Widget _dashboardCard(
    String title,
    String number,
    IconData? icon, {
    void Function()? onTap,
    required int totalCount,
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
      case 'team leader pending':
        selectedIcon = Icons.pending_actions;
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
        padding: EdgeInsets.all((12 * tabletScale).r),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon (left) + Title & Number (right) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon box
                Container(
                  height: (38 * tabletHeightScale).h,
                  width: (38 * tabletWidthScale).w,
                  decoration: BoxDecoration(
                    color: isDarkMode ? iconColor.withOpacity(0.15) : iconBg,
                    borderRadius: BorderRadius.circular((10 * tabletScale).r),
                  ),
                  child: Icon(
                    selectedIcon,
                    color: iconColor,
                    size: (19 * tabletFontScale).sp,
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
                          fontSize: (8.5 * tabletFontScale).sp,
                          color: isDarkMode ? Colors.white54 : Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: (2 * tabletHeightScale).h),
                      Text(
                        number.isEmpty ? '0' : number,
                        style: TextStyle(
                          fontSize: (18 * tabletFontScale).sp,
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
            SizedBox(height: (12 * tabletHeightScale).h),
            // ── Progress Bar ──────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular((4 * tabletScale).r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: (3.5 * tabletHeightScale).h,
                backgroundColor: Colors.grey.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ زر Data Centre
  Widget _dataCentreButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BlocProvider(
                  create:
                      (context) => TeamleaderDashboardCubit(
                        TeamleaderDashboardApiService(),
                      ),
                  child: const TeamleaderDataDashboardScreen(),
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
}

// ✅ Helper Class for Responsive
class ResponsiveHelper {
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isLargeTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 900;
  }
}