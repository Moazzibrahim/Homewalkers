// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/login_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/theme/theme_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // 📌 import intl package

class TeamLeaderProfileScreen extends StatelessWidget {
  const TeamLeaderProfileScreen({super.key});

  Future<String> checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  Future<String> checkAuthphone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    return phone ?? '';
  }

  Future<String> checkAuthEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    return email ?? 'sales@gmail.com';
  }

  Future<String> getCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('createdAt');
    print("CreatedAt: $value"); // ⬅ تحقق إذا القيمة null
    return value!;
  }

  Future<String> getUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('updatedAt') ?? '';
  }

  Future<bool> isUserActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('active') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    print("Current ThemeMode: ${context.watch<ThemeCubit>().state}");

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: "Profile",
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeamLeaderTabsScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Profile image & name
            Column(
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
                SizedBox(height: 4),
                Text(
                  "Team leader",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // General Information
            _buildInfoCard(context),
            SizedBox(height: 10),

            // Contact Info
            _buildContactCard(context),
            SizedBox(height: 10),

            // Dark Mode Toggle
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_4,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Dark Mode:",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value:
                          context.watch<ThemeCubit>().state == ThemeMode.dark,
                      onChanged: (_) async {
                        print("Toggling theme");
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      activeColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 6),

            // Sign out
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
                title: Text(
                  "Sign Out",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  await prefs.remove('role');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // 🔄 Remove all previous routes
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "General Information:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // ✅ الحالة
            FutureBuilder<bool>(
              future: isUserActive(),
              builder: (context, snapshot) {
                String status =
                    snapshot.connectionState == ConnectionState.done
                        ? (snapshot.data == true ? "Active" : "Inactive")
                        : 'Loading...';
                return infoRow(Icons.timelapse, "Status :", status, context);
              },
            ),

            // ✅ تاريخ الإنشاء
            FutureBuilder<String>(
              future: getCreatedAt(),
              builder: (context, snapshot) {
                String createdAtFormatted = 'Loading...';
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.isNotEmpty) {
                  try {
                    DateTime parsedDate = DateTime.parse(snapshot.data!);
                    createdAtFormatted = DateFormat(
                      'dd MMM yyyy - hh:mm a',
                    ).format(parsedDate);
                  } catch (e) {
                    createdAtFormatted = snapshot.data!;
                  }
                }
                return infoRow(
                  Icons.calendar_today,
                  "Created Date :",
                  createdAtFormatted,
                  context,
                );
              },
            ),
            // ✅ تاريخ التحديث
            FutureBuilder<String>(
              future: getUpdatedAt(),
              builder: (context, snapshot) {
                String updatedAtFormatted = 'Loading...';
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.isNotEmpty) {
                  try {
                    DateTime parsedDate = DateTime.parse(snapshot.data!);
                    updatedAtFormatted = DateFormat(
                      'dd MMM yyyy - hh:mm a',
                    ).format(parsedDate);
                  } catch (e) {
                    updatedAtFormatted = snapshot.data!;
                  }
                }
                return infoRow(
                  Icons.update,
                  "Updated Date :",
                  updatedAtFormatted,
                  context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            // ✅ Phone (async)
            FutureBuilder<String>(
              future: checkAuthphone(),
              builder: (context, snapshot) {
                String phone =
                    snapshot.connectionState == ConnectionState.done
                        ? snapshot.data ?? ''
                        : 'Loading...';
                return infoRow(Icons.phone, "Phone :", phone, context);
              },
            ),
            // ✅ Email (async)
            FutureBuilder<String>(
              future: checkAuthEmail(),
              builder: (context, snapshot) {
                String email =
                    snapshot.connectionState == ConnectionState.done
                        ? snapshot.data ?? ''
                        : 'Loading...';
                return infoRow(Icons.email, "Email :", email, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Color(0xff6A6A75),
              fontSize: 15,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
