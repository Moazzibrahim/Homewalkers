import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/marketer/add_menu_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/delete_menu_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/update_menu_api_service.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/area_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/campaign_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/cancel_reason_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/channels_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/cities_trash_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/communication_way_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/developers_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/projects_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/region_trash.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/sales_trash_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/stages_trash_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/trash/users_trash_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Add_in_menu/cubit/add_in_menu_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class AdminTrashMenuScreen extends StatefulWidget {
  const AdminTrashMenuScreen({super.key});

  @override
  State<AdminTrashMenuScreen> createState() => _AdminTrashMenuScreenState();
}

class _AdminTrashMenuScreenState extends State<AdminTrashMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigate(BuildContext context, Widget screen) {
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
              child: screen,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? Constants.backgroundDarkmode : const Color(0xFFF0EFED);
    final Color cardBg =
        isDark ? Constants.backgroundDarkmode : const Color(0xFFF0EFED);
    final Color iconBg =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xffE6E8EB);

    final List<_TrashItem> items = [
      _TrashItem(
        icon: Icons.chat_outlined,
        label: 'Communication Way',
        screen: CommunicationWayTrash(),
      ),
      _TrashItem(icon: Icons.man, label: 'Sales', screen: SalesTrashScreen()),
      _TrashItem(
        icon: Icons.person,
        label: 'Users',
        screen: UsersTrashScreen(),
      ),
      _TrashItem(
        icon: Icons.timeline_outlined,
        label: 'Stages',
        screen: StagesTrashScreen(),
      ),
      _TrashItem(
        icon: Icons.developer_mode_outlined,
        label: 'Developer',
        screen: DevelopersTrash(),
      ),
      _TrashItem(
        icon: Icons.business_outlined,
        label: 'Project',
        screen: ProjectsTrash(),
      ),
      _TrashItem(
        icon: Icons.alt_route_outlined,
        label: 'Channel',
        screen: ChannelsTrash(),
      ),
      _TrashItem(
        icon: Icons.cancel_outlined,
        label: 'Cancel Reason',
        screen: CancelReasonTrash(),
      ),
      _TrashItem(
        icon: Icons.campaign_outlined,
        label: 'Campaign',
        screen: CampaignTrash(),
      ),
      _TrashItem(
        icon: Icons.location_city,
        label: 'City',
        screen: CitiesTrashScreen(),
      ),
      _TrashItem(
        icon: Icons.map_outlined,
        label: 'Region',
        screen: RegionTrash(),
      ),
      _TrashItem(
        icon: Icons.location_on_outlined,
        label: 'Area',
        screen: AreaTrash(),
      ),
    ];

    final filtered =
        _searchQuery.isEmpty
            ? items
            : items
                .where(
                  (i) => i.label.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: CustomAppBar(
        title: "Trash",
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),

              // ── Search Bar ───────────────────────────────────────────
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
                        onChanged:
                            (value) => setState(() => _searchQuery = value),
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
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
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

              // ── Section Label ────────────────────────────────────────
              if (_searchQuery.isEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                  child: Text(
                    'DELETED ITEMS',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      letterSpacing: 1,
                    ),
                  ),
                ),

              // ── List ─────────────────────────────────────────────────
              Expanded(
                child:
                    filtered.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                        )
                        : SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              children: List.generate(filtered.length, (index) {
                                final item = filtered[index];
                                final isLast = index == filtered.length - 1;

                                return InkWell(
                                  borderRadius: BorderRadius.vertical(
                                    top:
                                        index == 0
                                            ? Radius.circular(16.r)
                                            : Radius.zero,
                                    bottom:
                                        isLast
                                            ? Radius.circular(16.r)
                                            : Radius.zero,
                                  ),
                                  onTap: () => _navigate(context, item.screen),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      border:
                                          isLast
                                              ? null
                                              : Border(
                                                bottom: BorderSide(
                                                  color: scaffoldBg,
                                                  width: 1,
                                                ),
                                              ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38.w,
                                          height: 38.w,
                                          decoration: BoxDecoration(
                                            color: iconBg,
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                          ),
                                          child: Icon(
                                            item.icon,
                                            size: 19.sp,
                                            color:
                                                isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF444444),
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
                                                  isDark
                                                      ? Colors.white
                                                      : const Color(0xFF111111),
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

class _TrashItem {
  final IconData icon;
  final String label;
  final Widget screen;
  _TrashItem({required this.icon, required this.label, required this.screen});
}
