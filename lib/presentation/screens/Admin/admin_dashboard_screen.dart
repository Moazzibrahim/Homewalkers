// ignore_for_file: file_names, camel_case_types, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_sales_sceen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();

  /// A styled container for icons, like the notification icon.
  static Widget _iconBox(
    IconData icon,
    void Function() onPressed,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        // Dynamic background color for the icon box
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        ),
        onPressed: onPressed,
      ),
    );
  }

  /// A styled card for the dashboard, matching the new design.
  static Widget _dashboardCard(
    String title,
    String number,
    IconData icon,
    BuildContext context, {
    void Function()? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Dynamic background color for the card
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Color(0xff1e1e1e),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      // Dynamic color for the card title
                      color: isDarkMode ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          title == 'Leads' || title == 'Sales'
                              ? [
                                Constants.maincolor,
                                Constants.mainDarkmodecolor,
                              ]
                              : [
                                const Color(0xff50E3C2),
                                const Color(0xffA0FFED),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ],
            ),
            Text(
              number,
              style: TextStyle(
                fontSize: 25,
                // Dynamic color for the main number
                color: isDarkMode ? Colors.white : const Color(0xFF0D1B2A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth();
    context.read<NotificationCubit>().initNotifications();
    print("init notifications called");
  }

  // Fetches the user's name from shared preferences for display.
  Future<String> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    // Using MultiBlocProvider to provide both Cubits to the screen.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => GetAllUsersCubit(GetAllUsersApiService())..fetchAllUsers(),
        ),
        BlocProvider(
          create:
              (context) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
      ],
      child: Scaffold(
        // Use system UI color for background
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 100,
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Constants.backgroundDarkmode,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              // Welcome message for the admin
              FutureBuilder<String>(
                future: checkAuth(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueGrey,
                      ),
                    );
                  } else {
                    final name = snapshot.data ?? 'User';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            // Dynamic color for AppBar title
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const Spacer(),
              // Notification Icon
              AdminDashboardScreen._iconBox(Icons.notifications_none, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesNotificationsScreen(),
                  ),
                );
              }, context),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Greeting text
                Row(
                  children: [
                    FutureBuilder(
                      future: checkAuth(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            'Hello ${snapshot.data}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              // Dynamic color for greeting text
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          );
                        }
                        return Text(
                          "Hello ....",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 20),
                // Main content area that displays user stats
                // Nesting BlocBuilders to get data from both sources.
                BlocBuilder<SalesCubit, SalesState>(
                  builder: (context, salesState) {
                    return BlocBuilder<GetAllUsersCubit, GetAllUsersState>(
                      builder: (context, usersState) {
                        // Loading State: Show a spinner if either cubit is loading.
                        if (usersState is GetAllUsersLoading ||
                            salesState is SalesLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        // Success State: Build the UI when both cubits have data.
                        if (usersState is GetAllUsersSuccess &&
                            salesState is SalesLoaded) {
                          final allUsers = usersState.users.data ?? [];
                          final duplicatesCount =
                              allUsers
                                  .where(
                                    (user) =>
                                        (user.allVersions?.length ?? 0) > 1,
                                  )
                                  .length;
                          final allSales = salesState.salesData.data ?? [];
                          final salesCount = allSales.length;
                          // Calculate counts for different lead stages from the users list.
                          final Map<String, int> stageCounts = {};
                          for (var lead in allUsers) {
                            final stageName = lead.stage?.name ?? 'Unknown';
                            stageCounts[stageName] =
                                (stageCounts[stageName] ?? 0) + 1;
                          }
                          // Create a list of all cards to display.
                          final List<Widget> statCards = [
                            AdminDashboardScreen._dashboardCard(
                              'Leads',
                              '${allUsers.length}',
                              Icons.group,
                              context,
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AdminLeadsScreen(),
                                    ),
                                  ),
                            ),
                            // Using salesCount from SalesCubit.
                            AdminDashboardScreen._dashboardCard(
                              'Sales',
                              '$salesCount',
                              Icons.person,
                              context,
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AdminSalesSceen(),
                                    ),
                                  ),
                            ),
                            ...stageCounts.entries.map((entry) {
                              const iconMap = {"Done Deal": Icons.work};
                              return AdminDashboardScreen._dashboardCard(
                                entry.key,
                                entry.value.toString(),
                                iconMap[entry.key] ?? Icons.timeline,
                                context,
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AdminLeadsScreen(
                                              stageName: entry.key,
                                            ),
                                      ),
                                    ),
                              );
                            }),
                            if (duplicatesCount > 0)
                              AdminDashboardScreen._dashboardCard(
                                'Duplicates',
                                '$duplicatesCount',
                                Icons.copy_all, // أيقونة تمثّل التكرار
                                context,
                                onTap: () {
                                  // ممكن تروح لصفحة فيها تفاصيل أو تعمل حاجة معينة
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AdminLeadsScreen(
                                            showDuplicatesOnly: true,
                                          ),
                                    ),
                                  );
                                },
                              ),
                          ];
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.4,
                                ),
                            itemCount: statCards.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return statCards[index];
                            },
                          );
                        }

                        // Error/Initial State: Show a default or error message.
                        return const Center(child: Text("Couldn't load data."));
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
