// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';
import 'package:homewalkers_app/presentation/screens/marketier/leads_marketier_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_profile_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_menu_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';

class MarketierTabsScreen extends StatefulWidget {
  final String? name;
  const MarketierTabsScreen({super.key, this.name});

  @override
  State<MarketierTabsScreen> createState() => _MarketierTabsScreenState();
}

class _MarketierTabsScreenState extends State<MarketierTabsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().initNotifications();
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    /// ✅ Detect Tablet
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;

    final navHeight = isTablet ? 90.0 : 70.0;
    final fabSpacing = isTablet ? 110.0 : 75.0;
    final fabSize = isTablet ? 70.0 : 56.0;

    return Scaffold(
      backgroundColor:
          isLight
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,

      body: WillPopScope(
        onWillPop: () async => false,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            MarketerDashboardScreen(),
            BlocProvider(
              create: (_) => GetLeadsMarketerCubit(GetLeadsService()),
              child: LeadsMarketierScreen(
                showDuplicatesOnly: true,
                data: false,
                transferefromdata: true,
              ),
            ),
            MarketerProfileScreen(),
            BlocProvider(
              create: (context) => AuthCubit(LoginApiService()),
              child: MarketierMenuScreen(),
            ),
          ],
        ),
      ),

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: BottomAppBar(
        color: isLight ? Colors.white : Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 12,
        child: SizedBox(
          height: navHeight,
          child: Row(
            children: [
              /// LEFT SIDE
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _onTap(0),
                      child: _bottomBarItem(
                        'Dashboard',
                        _currentIndex == 0,
                        imagePath: 'assets/images/analytics.png',
                        isTablet: isTablet,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onTap(1),
                      child: _bottomBarItem(
                        'Leads',
                        _currentIndex == 1,
                        imagePath: 'assets/images/leads.png',
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ),

              /// SPACE FOR FAB
              SizedBox(width: fabSpacing),

              /// RIGHT SIDE
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _onTap(2),
                      child: _bottomBarItem(
                        'Profile',
                        _currentIndex == 2,
                        imagePath: 'assets/images/profile.png',
                        isTablet: isTablet,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onTap(3),
                      child: _bottomBarItem(
                        'Menu',
                        _currentIndex == 3,
                        imagePath: 'assets/images/menu.png',
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// ================= FAB =================
      floatingActionButton: SizedBox(
        height: fabSize,
        width: fabSize,
        child: FloatingActionButton(
          backgroundColor:
              isLight ? Constants.maincolor : Constants.mainDarkmodecolor,
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateLeadScreen()),
            );
          },
          child: Icon(Icons.add, size: isTablet ? 36 : 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// ================= ITEM =================
  Widget _bottomBarItem(
    String label,
    bool active, {
    required String imagePath,
    required bool isTablet,
  }) {
    final color =
        active
            ? (Theme.of(context).brightness == Brightness.light
                ? Constants.maincolor
                : Constants.mainDarkmodecolor)
            : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          height: isTablet ? 32 : 24,
          width: isTablet ? 32 : 24,
          color: color,
        ),
        SizedBox(height: isTablet ? 6 : 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: isTablet ? 15 : 12,
          ),
        ),
      ],
    );
  }
}
