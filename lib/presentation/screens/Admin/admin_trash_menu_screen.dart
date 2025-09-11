import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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

class AdminTrashMenuScreen extends StatelessWidget {
  const AdminTrashMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> menuItems = [
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
                    child: CommunicationWayTrash(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.man,
        label: 'sales',
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
                    child: SalesTrashScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.person,
        label: 'users',
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
                    child: UsersTrashScreen(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.timeline_outlined,
        label: 'stages',
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
                    child: StagesTrashScreen(),
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
                    child: DevelopersTrash(),
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
                    child: ProjectsTrash(),
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
                    child: ChannelsTrash(),
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
                    child: CancelReasonTrash(),
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
                    child: CampaignTrash(),
                  ),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.location_city,
        label: 'city',
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
                    child: CitiesTrashScreen(),
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
                    child: RegionTrash(),
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
                    child: AreaTrash(),
                  ),
            ),
          );
        },
      ),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Constants.backgroundlightmode : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: "Trash",
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Expanded(
                child: ListView.separated(
                  itemCount: menuItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Container(
                      decoration: BoxDecoration(
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
                            color: Constants.maincolor,
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
