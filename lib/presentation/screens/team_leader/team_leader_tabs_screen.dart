// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore_for_file: deprecated_member_use
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_dashboard_leads_count.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_profile_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_sales_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_cubit.dart';

// ─────────────────────────────────────────────
// SharedTeamLeaderNavBar - بدون FAB خالص
// ─────────────────────────────────────────────
class SharedTeamLeaderNavBar extends StatelessWidget {
  final int currentIndex;
  const SharedTeamLeaderNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = BlocProvider(
          create:
              (context) =>
                  TeamleaderDashboardCubit(TeamleaderDashboardApiService()),
          child: const TeamLeaderDashboardScreen(showNavBar: true),
        );
        break;
      case 1:
        page = const TeamLeaderAssignScreen(
          data: false,
          transferfromdata: true,
          showNavBar: true,
        );
        break;
      case 2:
        page = const TeamLeaderSalesScreen(showNavBar: true);
        break;
      case 3:
        page = BlocProvider(
          create: (context) => AuthCubit(LoginApiService()),
          child: const TeamLeaderProfileScreen(showNavBar: true),
        );
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Container بسيط بدون Stack أو FAB
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                0,
                Icons.dashboard_outlined,
                Icons.dashboard,
                'DASHBOARD',
                isDark,
              ),
              _buildNavItem(
                context,
                1,
                Icons.people_outline,
                Icons.people,
                'LEADS',
                isDark,
              ),
              _buildNavItem(
                context,
                2,
                Icons.business,
                Icons.business,
                'SALES',
                isDark,
              ),
              _buildNavItem(
                context,
                3,
                Icons.person_outline,
                Icons.person,
                'PROFILE',
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    bool isDark,
  ) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color:
                  isActive
                      ? Constants.mainlightmodecolor
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive
                        ? Constants.mainlightmodecolor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TeamLeaderTabsScreen
// ─────────────────────────────────────────────
class TeamLeaderTabsScreen extends StatefulWidget {
  final String? name;
  const TeamLeaderTabsScreen({super.key, this.name});

  @override
  State<TeamLeaderTabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TeamLeaderTabsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().initNotifications();
    print("init notifications called");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Constants.backgroundDarkmode
              : Constants.backgroundlightmode,

      // ✅ FAB في الـ Scaffold بيتحسب أوتوماتيك فوق الـ bottomNavigationBar
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF003178), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Constants.maincolor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateLeadScreen()),
            );
          },
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: WillPopScope(
        onWillPop: () async => false,
        // ✅ شيلنا الـ Stack والـ Column وخلينا PageView مباشرة
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            BlocProvider(
              create:
                  (context) =>
                      TeamleaderDashboardCubit(TeamleaderDashboardApiService()),
              child: TeamLeaderDashboardScreen(showNavBar: false),
            ),
            TeamLeaderAssignScreen(
              data: false,
              transferfromdata: true,
              showNavBar: false,
            ),
            TeamLeaderSalesScreen(showNavBar: false),
            BlocProvider(
              create: (context) => AuthCubit(LoginApiService()),
              child: TeamLeaderProfileScreen(showNavBar: false),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'DASHBOARD',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'LEADS',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.business,
                  activeIcon: Icons.business,
                  label: 'SALES',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'PROFILE',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = _currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color:
                  isActive
                      ? Constants.mainlightmodecolor
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive
                        ? Constants.mainlightmodecolor
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
