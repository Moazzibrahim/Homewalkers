// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print, unused_field, use_build_context_synchronously
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_team_leader_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Color helpers (نفس Sales) ─────────────────────────────────────────────────

Color _getIconBgColor(String title) {
  switch (title.toLowerCase()) {
    case 'total leads':
    case 'leads':
      return const Color(0xFFE8F0FE);
    case 'total sales':
    case 'sales':
      return const Color(0xFFFFF8E6);
    case 'delivered':
      return const Color(0xFFE8F0FE);
    default:
      return const Color(0xFFE8F0FE);
  }
}

Color _getIconColor(String title) {
  switch (title.toLowerCase()) {
    case 'total leads':
    case 'leads':
      return const Color(0xFF2563EB);
    case 'total sales':
    case 'sales':
      return const Color(0xFFF59E0B);
    case 'delivered':
      return const Color(0xFF16A34A);
    default:
      return const Color(0xFF003178);
  }
}

Color _getProgressColor(String title) {
  switch (title.toLowerCase()) {
    case 'total sales':
    case 'sales':
      return const Color(0xFFF59E0B);
    case 'not interested':
      return Colors.black;
    default:
      return const Color(0xFF003178);
  }
}

IconData _getIcon(String title, IconData? fallback) {
  switch (title.toLowerCase()) {
    case 'total leads':
    case 'leads':
      return Icons.group_rounded;
    case 'total sales':
    case 'sales':
      return Icons.supervisor_account_rounded;
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
    case 'data centre':
      return Icons.dashboard_customize_rounded;
    default:
      return fallback ?? Icons.bar_chart_rounded;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ManagerDashboardDataScreen extends StatefulWidget {
  const ManagerDashboardDataScreen({super.key});

  @override
  State<ManagerDashboardDataScreen> createState() =>
      _ManagerDashboardDataScreenState();
}

class _ManagerDashboardDataScreenState extends State<ManagerDashboardDataScreen>
    with WidgetsBindingObserver {
  late GetManagerLeadsCubit _managerCubit;
  String _userName = 'User';

  // Responsive vars
  late bool isTabletDevice;
  late double tabletScale;
  late double tabletFontScale;
  late double tabletWidthScale;
  late double tabletHeightScale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();

    _managerCubit = GetManagerLeadsCubit(GetLeadsService())
      ..getManagerDashboardDataCounts();

    context.read<NotificationCubit>().initNotifications();
    print("init notifications called");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initResponsive();
  }

  void _initResponsive() {
    final data = MediaQuery.of(context);
    final size = data.size;
    final diagonal = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160);
    isTabletDevice = inches >= 7.0;

    tabletScale = isTabletDevice ? 0.85 : 1.0;
    tabletFontScale = isTabletDevice ? 0.85 : 1.0;
    tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
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
      Future.delayed(const Duration(milliseconds: 300), () {
        _managerCubit.getManagerDashboardDataCounts();
      });
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
    final isLargeTablet = _isLargeTablet(context);
    final isTablet = _isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _managerCubit,
      child: Scaffold(
        backgroundColor:
            isDark
                ? Constants.backgroundDarkmode
                : Constants.backgroundlightmode,

        // ── AppBar (نفس SalesDataDashboardScreen) ─────────────────────────
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
                  MaterialPageRoute(builder: (_) => TabsScreenManager()),
                );
              },
            ),
          ),
          title: Row(
            children: [
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
              _iconBox(Icons.notifications_none, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SalesNotificationsScreen(),
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Body ───────────────────────────────────────────────────────────
        body: RefreshIndicator(
          onRefresh: () async {
            await _managerCubit.getManagerDashboardDataCounts();
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
                    // ── Header (نفس Sales) ─────────────────────────────────
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
                    const SizedBox(height: 28),

                    // ── BlocBuilder (لوجيك Manager كما هو) ───────────────
                    BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
                      builder: (context, state) {
                        // ── Loading ────────────────────────────────────────
                        if (state is GetManagerLeadsLoading) {
                          return Column(
                            children: [
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
                                itemBuilder:
                                    (_, __) => _dashboardCard(
                                      'Total Leads',
                                      '...',
                                      Icons.group_rounded,
                                      totalCount: 0,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              const Center(child: CircularProgressIndicator()),
                            ],
                          );
                        }

                        // ── Success ────────────────────────────────────────
                        if (state is GetManagerDashboardSuccess) {
                          final dashboard = state.dashboard.data!;
                          final stages = dashboard.dashboard ?? [];
                          final summary = dashboard.summary;
                          final managerFresh = dashboard.managerFresh;
                          final managerPending = dashboard.managerPending;
                          final totalLeads = summary?.totalLeads ?? 0;
                          final totalSales = summary?.totalSales ?? 0;
                          final managerid = dashboard.managerInfo?.id;

                          // بناء قائمة الكروت (نفس لوجيك document 4)
                          final List<Map<String, dynamic>> cards = [
                            {
                              'title': 'Total Leads',
                              'count': totalLeads,
                              'icon': Icons.group_rounded,
                              'onTap':
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              ManagerLeadsScreen(data: false),
                                    ),
                                  ),
                            },
                            {
                              'title': 'Total Sales',
                              'count': totalSales,
                              'icon': Icons.supervisor_account_rounded,
                              'onTap':
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ManagerTeamLeaderScreen(),
                                    ),
                                  ),
                            },
                            if (managerFresh != null)
                              {
                                'title': managerFresh.stageName ?? 'Fresh',
                                'count': managerFresh.leadsCount ?? 0,
                                'icon': Icons.fiber_new_rounded,
                                'onTap':
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ManagerLeadsScreen(
                                              stageName: managerFresh.stageId,
                                              data: false,
                                              salesIds:
                                                  managerid != null
                                                      ? [managerid]
                                                      : null,
                                            ),
                                      ),
                                    ),
                              },
                            if (managerPending != null)
                              {
                                'title': managerPending.stageName ?? 'Pending',
                                'count': managerPending.leadsCount ?? 0,
                                'icon': Icons.hourglass_empty_rounded,
                                'onTap':
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ManagerLeadsScreen(
                                              stageName: managerPending.stageId,
                                              data: false,
                                              salesIds:
                                                  managerid != null
                                                      ? [managerid]
                                                      : null,
                                            ),
                                      ),
                                    ),
                              },
                            ...stages.map(
                              (stage) => {
                                'title': stage.stageName ?? 'Unknown',
                                'count': stage.leadsCount ?? 0,
                                'icon': Icons.timeline,
                                'onTap':
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ManagerLeadsScreen(
                                              stageName: stage.stageId,
                                              data: false,
                                            ),
                                      ),
                                    ),
                              },
                            ),
                          ];

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
                            itemCount: cards.length,
                            itemBuilder: (_, index) {
                              final card = cards[index];
                              return _dashboardCard(
                                card['title'] as String,
                                (card['count'] as num).toString(),
                                card['icon'] as IconData,
                                totalCount: totalLeads.toInt(),
                                onTap: card['onTap'] as void Function(),
                              );
                            },
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

  // ── Widgets ───────────────────────────────────────────────────────────────

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

    final IconData selectedIcon = _getIcon(title, icon);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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

  // ── Responsive helpers ────────────────────────────────────────────────────
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  bool _isLargeTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;
}
