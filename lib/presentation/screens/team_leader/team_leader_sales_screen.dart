import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamLeaderSalesScreen extends StatelessWidget {
  const TeamLeaderSalesScreen({super.key});

  Future<String> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

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
                    // 🔍 Search
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: nameController,
                        onChanged: (value) {
                          context
                              .read<GetLeadsCountInTeamLeaderCubit>()
                              .filterSalesByName(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: const Color(0xff969696),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    // 🧾 Titles
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sales Name',
                            style: TextStyle(
                              fontSize: 14,
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
                              fontSize: 14,
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
                    // 📃 List
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state is GetLeadsCountInTeamLeaderLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is GetLeadsCountInTeamLeaderLoaded) {
                            final salesList = state.data.data;

                            return ListView.builder(
                              itemCount: salesList!.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemBuilder: (context, index) {
                                final item = salesList[index];
                                final isMe =
                                    item.salesName?.trim().toLowerCase() ==
                                    currentUserName.trim().toLowerCase();

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
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
                                                  fontSize: 14,
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
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ]
                                                        : [],
                                              ),
                                            ),
                                            Text(
                                              'Sales',
                                              style: TextStyle(
                                                fontSize: 12,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Constants.maincolor
                                                    : Constants
                                                        .mainDarkmodecolor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.totalLeads ?? 0}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
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
                            return Center(child: Text(state.message));
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
