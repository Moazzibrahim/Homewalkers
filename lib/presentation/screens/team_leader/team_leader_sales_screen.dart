// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class TeamLeaderSalesScreen extends StatelessWidget {
  const TeamLeaderSalesScreen({super.key});

  Future<String> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    // ✅ كشف نوع الجهاز
    final bool isTabletDevice = () {
      final data = MediaQuery.of(context);
      final physicalSize = data.size;
      final diagonal = math.sqrt(
        math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
      );
      final inches = diagonal / (data.devicePixelRatio * 160);
      return inches >= 7.0;
    }();

    // ✅ عوامل التصغير حسب الجهاز
    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;

    return FutureBuilder<String>(
      future: getCurrentUserName(),
      builder: (context, snapshot) {
        final currentUserName = snapshot.data ?? '';

        return BlocProvider(
          create:
              (context) =>
                  GetLeadsCountInTeamLeaderCubit(GetLeadsCountApiService())
                    ..fetchLeadsCount(),
          child: BlocBuilder<
            GetLeadsCountInTeamLeaderCubit,
            GetLeadsCountInTeamLeaderState
          >(
            builder: (context, state) {
              return Scaffold(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.backgroundlightmode
                        : Constants.backgroundDarkmode,
                appBar: CustomAppBar(
                  title: 'Sales',
                  onBack: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeamLeaderTabsScreen(),
                      ),
                    );
                  },
                ),
                body: Column(
                  children: [
                    // 🔍 Search Bar - نفس ديزاين Admin
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        (16 * tabletWidthScale).w,
                        (16 * tabletHeightScale).h,
                        (16 * tabletWidthScale).w,
                        (8 * tabletHeightScale).h,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xffE6E8EB)
                                  : const Color(0xff333333),
                          borderRadius: BorderRadius.circular(
                            (10 * tabletScale).r,
                          ),
                        ),
                        child: TextField(
                          controller: nameController,
                          onChanged: (value) {
                            context
                                .read<GetLeadsCountInTeamLeaderCubit>()
                                .filterSalesByName(value);
                          },
                          style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                          decoration: InputDecoration(
                            hintText: 'Search sales agents by name...',
                            hintStyle: TextStyle(
                              color: const Color(0xff737783),
                              fontSize: (14 * tabletFontScale).sp,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: const Color(0xff737783),
                              size: (20 * tabletFontScale).sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: (16 * tabletWidthScale).w,
                              vertical: (14 * tabletHeightScale).h,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 📃 List
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state is GetLeadsCountInTeamLeaderLoading) {
                            return _buildShimmerList(
                              context,
                              isTabletDevice,
                              tabletScale,
                              tabletFontScale,
                              tabletWidthScale,
                              tabletHeightScale,
                            );
                          } else if (state is GetLeadsCountInTeamLeaderLoaded) {
                            final salesList = state.data.data;

                            if (salesList == null || salesList.isEmpty) {
                              return Center(
                                child: Text(
                                  'No sales agents found',
                                  style: TextStyle(
                                    fontSize: (14 * tabletFontScale).sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            if (isTabletDevice) {
                              return GridView.builder(
                                padding: EdgeInsets.all((16 * tabletScale).r),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing:
                                          (16 * tabletWidthScale).w,
                                      mainAxisSpacing:
                                          (16 * tabletHeightScale).h,
                                      childAspectRatio: 1.8,
                                    ),
                                itemCount: salesList.length,
                                itemBuilder: (context, index) {
                                  final item = salesList[index];
                                  final isMe =
                                      item.salesName?.trim().toLowerCase() ==
                                      currentUserName.trim().toLowerCase();
                                  return _buildSalesCard(
                                    item.salesName ?? 'No Name',
                                    item.totalLeads?.toInt() ?? 0,
                                    isMe,
                                    context,
                                    tabletScale,
                                    tabletFontScale,
                                    tabletWidthScale,
                                    tabletHeightScale,
                                    item.salesID, // ✅ أضفده
                                  );
                                },
                              );
                            } else {
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (16 * tabletWidthScale).w,
                                  vertical: (8 * tabletHeightScale).h,
                                ),
                                itemCount: salesList.length,
                                itemBuilder: (context, index) {
                                  final item = salesList[index];
                                  final isMe =
                                      item.salesName?.trim().toLowerCase() ==
                                      currentUserName.trim().toLowerCase();
                                  return _buildSalesCard(
                                    item.salesName ?? 'No Name',
                                    item.totalLeads?.toInt() ?? 0,
                                    isMe,
                                    context,
                                    tabletScale,
                                    tabletFontScale,
                                    tabletWidthScale,
                                    tabletHeightScale,
                                    item.salesID, // ✅ أضفده
                                  );
                                },
                              );
                            }
                          } else if (state is GetLeadsCountInTeamLeaderError) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all((16 * tabletScale).r),
                                child: Text(
                                  state.message,
                                  style: TextStyle(
                                    fontSize: (16 * tabletFontScale).sp,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black87
                                            : Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSalesCard(
    String name,
    int leadsCount,
    bool isMe,
    BuildContext context,
    double tabletScale,
    double tabletFontScale,
    double tabletWidthScale,
    double tabletHeightScale,
    String? salesId, // ✅ أضفده
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Avatar initials
    final initials =
        name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join();

    return Container(
      margin: EdgeInsets.only(bottom: (12 * tabletHeightScale).h),
      decoration: BoxDecoration(
        color:
            isMe
                ? (isDark
                    ? Constants.maincolor.withOpacity(0.1)
                    : Constants.maincolor.withOpacity(0.05))
                : (isDark ? const Color(0xff1e1e1e) : Colors.white),
        borderRadius: BorderRadius.circular((16 * tabletScale).r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: (8 * tabletScale).r,
            offset: Offset(0, (2 * tabletHeightScale).h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all((16 * tabletScale).r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row: Avatar + Name + Leads ──
            Row(
              children: [
                // Avatar
                Container(
                  width: (56 * tabletWidthScale).w,
                  height: (56 * tabletHeightScale).h,
                  decoration: BoxDecoration(
                    color: Constants.maincolor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular((12 * tabletScale).r),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: (18 * tabletFontScale).sp,
                        fontWeight: FontWeight.bold,
                        color: Constants.maincolor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (12 * tabletWidthScale).w),

                // Name + Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: name,
                          style: TextStyle(
                            fontSize: (15 * tabletFontScale).sp,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF0D1B2A),
                          ),
                          children:
                              isMe
                                  ? [
                                    TextSpan(
                                      text: ' (Me)',
                                      style: TextStyle(
                                        color: Constants.maincolor,
                                        fontSize: (13 * tabletFontScale).sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]
                                  : [],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: (2 * tabletHeightScale).h),
                      Text(
                        'Sales',
                        style: TextStyle(
                          fontSize: (13 * tabletFontScale).sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Leads Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (12 * tabletWidthScale).w,
                    vertical: (6 * tabletHeightScale).h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Constants.maincolor.withOpacity(0.2)
                            : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular((20 * tabletScale).r),
                  ),
                  child: Text(
                    '$leadsCount Leads',
                    style: TextStyle(
                      fontSize: (13 * tabletFontScale).sp,
                      fontWeight: FontWeight.w600,
                      color: Constants.maincolor,
                    ),
                  ),
                ),
              ],
            ),

            // ── Divider ──
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: (12 * tabletHeightScale).h,
              ),
              child: Divider(
                height: 1,
                color: isDark ? Colors.grey[800] : Colors.grey[100],
              ),
            ),

            // ── Sales label row ──
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => TeamLeaderAssignScreen(
                          data: false,
                          transferfromdata: true,
                          salesName: salesId, // ✅ بيجي من الـ parameter
                        ),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: (14 * tabletFontScale).sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff003178),
                    ),
                  ),
                  SizedBox(width: (4 * tabletWidthScale).w),
                  Icon(
                    Icons.chevron_right,
                    size: (16 * tabletFontScale).sp,
                    color: Constants.maincolor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList(
    BuildContext context,
    bool isTabletDevice,
    double tabletScale,
    double tabletFontScale,
    double tabletWidthScale,
    double tabletHeightScale,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: (16 * tabletWidthScale).w,
        vertical: (8 * tabletHeightScale).h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: (12 * tabletHeightScale).h),
            padding: EdgeInsets.all((16 * tabletScale).r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular((16 * tabletScale).r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: (56 * tabletWidthScale).w,
                      height: (56 * tabletHeightScale).h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (12 * tabletScale).r,
                        ),
                      ),
                    ),
                    SizedBox(width: (12 * tabletWidthScale).w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: (16 * tabletHeightScale).h,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          SizedBox(height: (6 * tabletHeightScale).h),
                          Container(
                            height: (12 * tabletHeightScale).h,
                            width: (80 * tabletWidthScale).w,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: (80 * tabletWidthScale).w,
                      height: (32 * tabletHeightScale).h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          (20 * tabletScale).r,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (12 * tabletHeightScale).h),
                Container(height: 1, color: Colors.white),
                SizedBox(height: (12 * tabletHeightScale).h),
                Container(
                  height: (13 * tabletHeightScale).h,
                  width: (100 * tabletWidthScale).w,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
