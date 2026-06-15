// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/add_menu_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/delete_menu_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/update_menu_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_advanced_search.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_profile_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_trash_menu_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/sales_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/stages_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/users_screen.dart';
import 'package:homewalkers_app/presentation/screens/cities_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/area_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/campaign_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/cancel_reason_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/channel_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/communication_way_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/developer_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/project_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/region_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminMenuScreen extends StatefulWidget {
  final bool showNavBar; // ← أضف ده

  const AdminMenuScreen({super.key, this.showNavBar = true});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    // ── Management items ──────────────────────────────────────────────────
    final List<_MenuItem> managementItems = [
      _MenuItem(
        icon: Icons.person_outline,
        label: 'Profile',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider(
                    create: (_) => AuthCubit(LoginApiService()),
                    child: const AdminProfileScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.chat_outlined,
        label: 'Communication Way',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: CommunicationWayScreen(),
                  ),
            ),
          );
        },
      ),
    ];

    // ── Operations items ──────────────────────────────────────────────────
    final List<_MenuItem> operationsItems = [
      _MenuItem(
        icon: Icons.trending_up_outlined,
        label: 'Sales',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: SalesScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.group_outlined,
        label: 'Users',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: UsersScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.timeline_outlined,
        label: 'Stages',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: StagesScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.developer_mode_outlined,
        label: 'Developer',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: DeveloperScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.business_outlined,
        label: 'Project',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: ProjectScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.alt_route_outlined,
        label: 'Channel',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: ChannelScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.cancel_outlined,
        label: 'Cancel Reason',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: CancelReasonScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.campaign_outlined,
        label: 'Campaign',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: CampaignScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.location_city,
        label: 'City',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: CitiesScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.map_outlined,
        label: 'Region',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: RegionScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.location_on_outlined,
        label: 'Area',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: AreaScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.delete_outline,
        label: 'Trash',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider<AddInMenuCubit>(
                    create:
                        (_) => AddInMenuCubit(
                          AddMenuApiService(),
                          UpdateMenuApiService(),
                          DeleteMenuApiService(),
                        ),
                    child: AdminTrashMenuScreen(),
                  ),
            ),
          );
        },
      ),
    ];

    final _MenuItem signOutItem = _MenuItem(
      icon: Icons.logout,
      label: 'Sign Out',
      onTap: () async {
        context.read<AuthCubit>().logout(context);
      },
      isDestructive: true,
    );

    // ── All items combined for search ─────────────────────────────────────
    final List<_MenuItem> allItems = [
      ...managementItems,
      ...operationsItems,
      signOutItem,
    ];

    // ── Filter based on search query ──────────────────────────────────────
    final bool isSearching = _searchQuery.isNotEmpty;
    final List<_MenuItem> filteredItems =
        isSearching
            ? allItems
                .where(
                  (item) => item.label.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList()
            : [];

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? Constants.backgroundDarkmode : const Color(0xFFF0EFED);
    final Color cardBg =
        isDark ? Constants.backgroundDarkmode : const Color(0xFFF0EFED);
    final Color iconBg =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xffE6E8EB);

    return Scaffold(
      bottomNavigationBar:
          widget.showNavBar ? SharedAdminNavBar(currentIndex: 3) : null,
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ─────────────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: const Color(0xFFC9D6E3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: const Icon(
                          Icons.person,
                          size: 28,
                          color: Color(0xFF4A6FA5),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: _checkAuthName(),
                            builder: (context, snapshot) {
                              final name =
                                  snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? 'Hello ...'
                                      : snapshot.hasError
                                      ? 'Hello'
                                      : '${snapshot.data}';
                              return Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : const Color(0xFF111111),
                                ),
                              );
                            },
                          ),
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const SalesNotificationsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: scaffoldBg,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                          color:
                              isDark ? Colors.white : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // ── Search Bar ───────────────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: TextStyle(
                          fontSize: 14.sp,
                          color:
                              isDark ? Colors.white : const Color(0xFF111111),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Quick find...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ),
                    ),
                    // Clear button
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 18.sp,
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // ── Content ───────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child:
                      isSearching
                          // ── Search results ──────────────────────────────────
                          ? filteredItems.isEmpty
                              ? Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40.h),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 48.sp,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'No results for "$_searchQuery"',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : _MenuGroup(
                                items: filteredItems,
                                cardBg: cardBg,
                                iconBg: iconBg,
                                isDark: isDark,
                                scaffoldBg: scaffoldBg,
                              )
                          // ── Normal grouped view ─────────────────────────────
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(label: 'Management'),
                              SizedBox(height: 8.h),
                              _MenuGroup(
                                items: managementItems,
                                cardBg: cardBg,
                                iconBg: iconBg,
                                isDark: isDark,
                                scaffoldBg: scaffoldBg,
                              ),
                              SizedBox(height: 14.h),
                              _SectionLabel(label: 'Operations'),
                              SizedBox(height: 8.h),
                              _MenuGroup(
                                items: operationsItems,
                                cardBg: cardBg,
                                iconBg: iconBg,
                                isDark: isDark,
                                scaffoldBg: scaffoldBg,
                              ),
                              SizedBox(height: 14.h),
                              _MenuGroup(
                                items: [signOutItem],
                                cardBg: cardBg,
                                iconBg: iconBg,
                                isDark: isDark,
                                scaffoldBg: scaffoldBg,
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Menu group ───────────────────────────────────────────────────────────────

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({
    required this.items,
    required this.cardBg,
    required this.iconBg,
    required this.isDark,
    required this.scaffoldBg,
  });

  final List<_MenuItem> items;
  final Color cardBg;
  final Color iconBg;
  final bool isDark;
  final Color scaffoldBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return InkWell(
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? Radius.circular(16.r) : Radius.zero,
              bottom: isLast ? Radius.circular(16.r) : Radius.zero,
            ),
            onTap: item.onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                border:
                    isLast
                        ? null
                        : Border(
                          bottom: BorderSide(color: scaffoldBg, width: 1),
                        ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color:
                          item.isDestructive ? const Color(0xFFFEE2E2) : iconBg,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      item.icon,
                      size: 19.sp,
                      color:
                          item.isDestructive
                              ? const Color(0xFFE24B4A)
                              : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF444444)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color:
                            item.isDestructive
                                ? const Color(0xFFE24B4A)
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF111111)),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Data model ───────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final void Function()? onTap;
  final bool isDestructive;

  _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });
}
