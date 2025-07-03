import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class TeamLeaderSalesScreen extends StatelessWidget {
  const TeamLeaderSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

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
                // 🔍 Search & Filter
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          onChanged: (value) {
                            // optional: local filter
                            context
                                .read<GetLeadsCountInTeamLeaderCubit>()
                                .filterSalesByName(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: GoogleFonts.montserrat(
                              color: const Color(0xff969696),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
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
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                      ),
                      Text(
                        'Leads Number',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              Theme.of(context).brightness == Brightness.light
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
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetLeadsCountInTeamLeaderLoaded) {
                        final salesList = state.data.data;

                        return ListView.builder(
                          itemCount: salesList!.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final item = salesList[index];
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
                                        Text(
                                          item.salesName ?? 'No Name',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Sales',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color:
                                                Theme.of(context).brightness ==
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
                                                : Constants.mainDarkmodecolor,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${item.totalLeads ?? 0}',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Constants.maincolor
                                                : Constants.mainDarkmodecolor,
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
  }
}
