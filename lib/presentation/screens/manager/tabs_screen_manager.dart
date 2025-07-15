import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_profile_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_team_leader_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';

class TabsScreenManager extends StatefulWidget {
  final String? name;
  const TabsScreenManager({super.key, this.name});

  @override
  State<TabsScreenManager> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreenManager> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

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
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      body: WillPopScope(
        onWillPop: () async {
          // منع الرجوع إلى الشاشة السابقة
          return false;
        },
        child: Column(
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
                  ManagerDashboardScreen(),
                  ManagerLeadsScreen(),
                  ManagerTeamLeaderScreen(),
                  ManagerProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color:   Theme.of(context).brightness == Brightness.light
                ? Colors
                    .white // لون الخلفية
                : Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _onTap(0),
                child: _bottomBarItem(
                  null,
                  'Dashboard',
                  _currentIndex == 0,
                  imagePath: 'assets/images/analytics.png',
                ),
              ),
              GestureDetector(
                onTap: () => _onTap(1),
                child: _bottomBarItem(
                  null,
                  'Leads',
                  _currentIndex == 1,
                  imagePath: 'assets/images/leads.png',
                ),
              ),
              const SizedBox(width: 40), // للمساحة الخاصة بزر الفلوتينج
              GestureDetector(
                onTap: () => _onTap(2),
                child: _bottomBarItem(
                  null,
                  'Team Leader',
                  _currentIndex == 2,
                  imagePath: 'assets/images/team_leader.png',
                ),
              ),
              GestureDetector(
                onTap: () => _onTap(3),
                child: _bottomBarItem(
                  null,
                  'Profile',
                  _currentIndex == 3,
                  imagePath: 'assets/images/profile.png',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:Theme.of(context).brightness == Brightness.light ? Constants.maincolor :Constants.mainDarkmodecolor ,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateLeadScreen()),
          );
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _bottomBarItem(
    IconData? icon,
    String label,
    bool active, {
    String? imagePath,
  }) {
    final color =
        active
            ? Theme.of(context).brightness == Brightness.light
                ? Constants.maincolor
                : Constants.mainDarkmodecolor
            : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        imagePath != null
            ? Image.asset(imagePath, height: 24, width: 24, color: color)
            : Icon(icon, color: color),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
