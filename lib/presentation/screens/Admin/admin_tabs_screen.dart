// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore_for_file: deprecated_member_use
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/Admin_with_pagination/fetch_data_with_pagination.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_menu_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_sales_sceen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit.dart';

// shared_admin_navbar.dart
class SharedAdminNavBar extends StatelessWidget {
  final int currentIndex;
  const SharedAdminNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = BlocProvider(
          create:
              (_) =>
                  GetAllUsersCubit(GetAllUsersApiService())..fetchStagesStats(),
          child: const AdminDashboardScreen(showNavBar: true), // ✅ true
        );
        break;
      case 1:
        page = BlocProvider(
          create:
              (_) => AllLeadsCubitWithPagination(LeadsApiServiceWithQuery()),
          child: const AdminLeadsScreen(
            data: false,
            transferefromdata: true,
            showNavBar: true, // ✅ true
          ),
        );
        break;
      case 2:
        page = const AdminSalesSceen(showNavBar: true); // ✅ true
        break;
      case 3:
        page = BlocProvider(
          create: (_) => AuthCubit(LoginApiService()),
          child: AdminMenuScreen(showNavBar: true), // ✅ true
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
                Icons.business,
                Icons.business,
                'Sales',
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

class AdminTabsScreen extends StatefulWidget {
  final String? name;
  const AdminTabsScreen({super.key, this.name});

  @override
  State<AdminTabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<AdminTabsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
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
                      BlocProvider(
                        create:
                            (context) =>
                                GetAllUsersCubit(GetAllUsersApiService())
                                  ..fetchStagesStats(),
                        child: AdminDashboardScreen(showNavBar: false),
                      ),
                      BlocProvider(
                        create:
                            (_) => AllLeadsCubitWithPagination(
                              LeadsApiServiceWithQuery(),
                            ),
                        child: const AdminLeadsScreen(
                          data: false,
                          transferefromdata: true,
                          showNavBar: false,
                        ),
                      ),
                      AdminSalesSceen(showNavBar: false),
                      BlocProvider(
                        create: (context) => AuthCubit(LoginApiService()),
                        child: AdminMenuScreen(showNavBar: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 12, // فوق شريط التبويبات بشوية
              right: 16, // في الجنب مش النص
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
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
                  label: 'Sales',
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
