import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_profile_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_sales_screen.dart';

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
              ? Colors.grey[200]
              : Color(0xff080719),
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
                  TeamLeaderDashboardScreen(),
                  TeamLeaderSalesScreen(),
                  TeamLeaderAssignScreen(),
                  TeamLeaderProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                  Icons.dashboard,
                  'Dashboard',
                  _currentIndex == 0,
                ),
              ),
              GestureDetector(
                onTap: () => _onTap(1),
                child: _bottomBarItem(
                  Icons.groups,
                  'sales',
                  _currentIndex == 1,
                ),
              ),
              const SizedBox(width: 40), // للمساحة الخاصة بزر الفلوتينج
              GestureDetector(
                onTap: () => _onTap(2),
                child: _bottomBarItem(
                  Icons.assignment,
                  'assign',
                  _currentIndex == 2,
                ),
              ),
              GestureDetector(
                onTap: () => _onTap(3),
                child: _bottomBarItem(
                  Icons.person_outline,
                  'Profile',
                  _currentIndex == 3,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton( 
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.maincolor
                : Constants.mainDarkmodecolor,
        onPressed: () {
          // أضف وظيفة الزر هنا
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

  Widget _bottomBarItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color:
              active
                  ? Theme.of(context).brightness == Brightness.light
                      ? Constants.maincolor
                      : Constants.mainDarkmodecolor
                  : Colors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            color:
                active
                    ? Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor
                    : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
