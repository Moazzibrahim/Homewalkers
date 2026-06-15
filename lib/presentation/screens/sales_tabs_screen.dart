// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore_for_file: deprecated_member_use
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/screens/sales/salesDashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_assign_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_profile_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';

class SharedSalesNavBar extends StatelessWidget {
  final int currentIndex;
  const SharedSalesNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const SalesdashboardScreen(showNavBar: true);
        break;
      case 1:
        page = const SalesLeadsScreen(
          data: false,
          transferfromdata: true,
          showNavBar: true,
        );
        break;
      case 2:
        page = const SalesAssignLeadsScreen(
          data: false,
          transferfromdata: true,
          showNavBar: true,
        );
        break;
      case 3:
        page = BlocProvider(
          create: (_) => AuthCubit(LoginApiService()),
          child: const SalesProfileScreen(showNavBar: true),
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
                Icons.assignment_outlined,
                Icons.assignment,
                'ASSIGN',
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

class SalesTabsScreen extends StatefulWidget {
  final String? name;

  const SalesTabsScreen({super.key, this.name});

  @override
  State<SalesTabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<SalesTabsScreen> {
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
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      SalesdashboardScreen(showNavBar: false),

                      SalesLeadsScreen(
                        data: false,
                        transferfromdata: true,
                        showNavBar: false,
                      ),

                      SalesAssignLeadsScreen(
                        data: false,
                        transferfromdata: true,
                        showNavBar: false,
                      ),

                      BlocProvider(
                        create: (_) => AuthCubit(LoginApiService()),
                        child: SalesProfileScreen(showNavBar: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Floating Button نفس تصميم الادمن
            Positioned(
              bottom: 12,
              right: 16,
              child: Container(
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
                      MaterialPageRoute(
                        builder: (context) => const CreateLeadScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, size: 28, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

      /// Bottom Navigation نفس تصميم الادمن
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
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'ASSIGN',
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
