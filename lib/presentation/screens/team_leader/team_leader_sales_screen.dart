// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math; // ✅ للكشف عن التابلت

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
                    // 🔍 Search - متجاوب بالكامل
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (16 * tabletWidthScale).w,
                        vertical: (12 * tabletHeightScale).h,
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
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: const Color(0xff969696),
                            fontSize: (12 * tabletFontScale).sp,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: (20 * tabletFontScale).sp,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: (16 * tabletWidthScale).w,
                            vertical: (12 * tabletHeightScale).h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                              width: (1 * tabletScale).r,
                            ),
                            borderRadius: BorderRadius.circular(
                              (8 * tabletScale).r,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                              width: (1.5 * tabletScale).r,
                            ),
                            borderRadius: BorderRadius.circular(
                              (8 * tabletScale).r,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 🧾 Titles - متجاوب بالكامل
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (18 * tabletWidthScale).w,
                        vertical: (8 * tabletHeightScale).h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sales Name',
                            style: TextStyle(
                              fontSize: (14 * tabletFontScale).sp,
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                          ),
                          Text(
                            'Leads Number',
                            style: TextStyle(
                              fontSize: (14 * tabletFontScale).sp,
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 📃 List - متجاوب بالكامل
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state is GetLeadsCountInTeamLeaderLoading) {
                            return Center(
                              child: SizedBox(
                                height: (40 * tabletHeightScale).h,
                                width: (40 * tabletWidthScale).w,
                                child: const CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is GetLeadsCountInTeamLeaderLoaded) {
                            final salesList = state.data.data;

                            return ListView.builder(
                              itemCount: salesList!.length,
                              padding: EdgeInsets.symmetric(
                                horizontal: (16 * tabletWidthScale).w,
                                vertical: (4 * tabletHeightScale).h,
                              ),
                              itemBuilder: (context, index) {
                                final item = salesList[index];
                                final isMe =
                                    item.salesName?.trim().toLowerCase() ==
                                    currentUserName.trim().toLowerCase();

                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: (12 * tabletHeightScale).h,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: (12 * tabletWidthScale).w,
                                    vertical: (8 * tabletHeightScale).h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      (12 * tabletScale).r,
                                    ),
                                    color:
                                        isMe
                                            ? Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Constants.maincolor
                                                    .withOpacity(0.05)
                                                : Constants.mainDarkmodecolor
                                                    .withOpacity(0.1)
                                            : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text:
                                                    item.salesName ?? 'No Name',
                                                style: TextStyle(
                                                  fontSize:
                                                      (14 * tabletFontScale).sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                children:
                                                    isMe
                                                        ? [
                                                          TextSpan(
                                                            text: ' (Me)',
                                                            style: TextStyle(
                                                              color:
                                                                  Constants
                                                                      .maincolor,
                                                              fontSize:
                                                                  (13 *
                                                                          tabletFontScale)
                                                                      .sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ]
                                                        : [],
                                              ),
                                            ),
                                            SizedBox(
                                              height: (4 * tabletHeightScale).h,
                                            ),
                                            Text(
                                              'Sales',
                                              style: TextStyle(
                                                fontSize:
                                                    (12 * tabletFontScale).sp,
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? Constants.maincolor
                                                        : Constants
                                                            .mainDarkmodecolor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: (12 * tabletWidthScale).w,
                                          vertical: (6 * tabletHeightScale).h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Constants.maincolor
                                                    : Constants
                                                        .mainDarkmodecolor,
                                            width: (1 * tabletScale).r,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            (8 * tabletScale).r,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.totalLeads ?? 0}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: (14 * tabletFontScale).sp,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Constants.maincolor
                                                    : Constants
                                                        .mainDarkmodecolor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
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
}
