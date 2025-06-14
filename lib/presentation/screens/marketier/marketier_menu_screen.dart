import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/presentation/screens/login_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/area_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/campaign_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/cancel_reason_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/channel_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/communication_way_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/developer_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_profile_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/project_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/region_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketierMenuScreen extends StatelessWidget {
  const MarketierMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String> checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }
    final List<_MenuItem> menuItems = [
      _MenuItem(icon: Icons.person_outline, label: 'Profile',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketerProfileScreen()));
      },),
      _MenuItem(icon: Icons.chat_outlined, label: 'Communication Way',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunicationWayScreen()));
      },),
      _MenuItem(icon: Icons.developer_mode_outlined, label: 'Developer',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DeveloperScreen()));
      },),
      _MenuItem(icon: Icons.business_outlined, label: 'Project',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectScreen()));
      },),
      _MenuItem(icon: Icons.alt_route_outlined, label: 'Channel',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChannelScreen()));
      },),
      _MenuItem(icon: Icons.cancel_outlined, label: 'Cancel Reason',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CancelReasonScreen()));
      },),
      _MenuItem(icon: Icons.campaign_outlined, label: 'Campaign',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CampaignScreen()));
      }),
      _MenuItem(icon: Icons.map_outlined, label: 'Region',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegionScreen()));
      }),
      _MenuItem(icon: Icons.location_on_outlined, label: 'Area',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AreaScreen()));
      }),
      _MenuItem(icon: Icons.logout, label: 'Sign Out',onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      },),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  FutureBuilder(
                    future: checkAuthName(), // ✅ جلب الاسم
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(" hello ....");
                    } else if (snapshot.hasError) {
                      return const Text('Hello');
                    } else {
                      return Text(
                        '${snapshot.data}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xff080719)
                                  : Colors.white,
                        ),
                      );
                    }
                  },
                ),
                      Text(
                        'Marketer',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_none_rounded, size: 28),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.separated(
                  itemCount: menuItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F0F1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            item.icon,
                            color: const Color(0xFF1E4D57),
                          ),
                        ),
                        title: Text(
                          item.label,
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: item.onTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final void Function()? onTap;

  _MenuItem({required this.icon, required this.label, this.onTap});
}
