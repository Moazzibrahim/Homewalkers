// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/dialog_utils.dart';
import 'package:homewalkers_app/data/data_sources/get_sales_dashboard_count_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_data_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SalesdashboardScreen extends StatefulWidget {
  final bool showNavBar;
  const SalesdashboardScreen({super.key, this.showNavBar = true});

  @override
  State<SalesdashboardScreen> createState() => _SalesdashboardScreenState();
}

class _SalesdashboardScreenState extends State<SalesdashboardScreen>
    with WidgetsBindingObserver {
  String _userName = 'User';
  late SalesDashboardCubit _dashboardCubit;

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

    _dashboardCubit = SalesDashboardCubit(SalesDashboardApiService());

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
        bottomNavigationBar:
            widget.showNavBar ? SharedSalesNavBar(currentIndex: 0) : null,
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
                    BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
                      builder: (context, state) {
                        if (state is SalesDashboardLoading) {
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
                        } else if (state is SalesDashboardError) {
                          return const Center(child: Text("No Data Found"));
                        } else if (state is SalesDashboardSuccess) {
                          final cubit = context.read<SalesDashboardCubit>();
                          final stages = cubit.getVisibleStages(state.response);

                          // check لو فيه Fresh
                          final hasFresh = stages.any(
                            (e) => e.stageName == 'Fresh',
                          );

                          final filteredStages =
                              hasFresh
                                  ? stages
                                      .where((e) => e.stageName != 'No Stage')
                                      .toList()
                                  : stages;
                          final totalLeads =
                              state.response.data?.summary?.totalLeads ?? 0;

                          // في SalesDashboardSuccess، استبدل الـ Column بده:
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
                            itemCount:
                                filteredStages.length + 1, // +1 for Leads card
                            itemBuilder: (context, index) {
                              // أول item = Leads card
                              if (index == 0) {
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
                                            (_) => const SalesLeadsScreen(
                                              data: false,
                                              transferfromdata: true,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }

                              // باقي الـ items = stages
                              final stage = filteredStages[index - 1];
                              final stageName = stage.stageName ?? '';
                              return _dashboardCard(
                                stageName == 'No Stage' ? 'Fresh' : stageName,
                                '${stage.leadsCount ?? 0}',
                                Icons.timeline,
                                totalCount: totalLeads.toInt(),
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
                                            transferfromdata: true,
                                          ),
                                    ),
                                  );
                                },
                              );
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
          MaterialPageRoute(builder: (_) => const SalesDataDashboardScreen()),
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
