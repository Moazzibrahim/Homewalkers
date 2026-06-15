// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';

class ManagerTeamLeaderScreen extends StatefulWidget {
  const ManagerTeamLeaderScreen({super.key});

  @override
  State<ManagerTeamLeaderScreen> createState() =>
      _ManagerTeamLeaderScreenState();
}

class _ManagerTeamLeaderScreenState extends State<ManagerTeamLeaderScreen> {
  String? selectedTeamLeaderName;
  Map<String, List<LeadData>> groupedLeads = {};

  @override
  void initState() {
    super.initState();
    context.read<GetManagerLeadsCubit>().getManagerDashboardCounts();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor:
          isLight ? const Color(0xffF4F6F8) : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: "Team Leaders",
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TabsScreenManager()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
          builder: (context, state) {
            if (state is GetManagerDashboardSuccess) {
              final dashboard =
                  context.read<GetManagerLeadsCubit>().dashboardDataS;
              final teamLeaders = dashboard?.data?.teamLeaders ?? [];

              if (teamLeaders.isEmpty) {
                return const Center(child: Text("No Team Leaders."));
              }

              selectedTeamLeaderName ??= teamLeaders.first.teamLeaderInfo?.name;

              final selectedLeader = teamLeaders.firstWhere(
                (leader) =>
                    leader.teamLeaderInfo?.name == selectedTeamLeaderName,
                orElse: () => teamLeaders.first,
              );

              final salesList = selectedLeader.sales ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Text(
                    "Manage and oversee your executive team leaders and their respective sales associates.",
                    style: TextStyle(
                      color: const Color(0xff7F8689),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SELECT LEADER label
                  Text(
                    "SELECT LEADER",
                    style: TextStyle(
                      color: const Color(0xff7F8689),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : const Color(0xff1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isLight
                                ? const Color(0xffE0E0E0)
                                : const Color(0xff333333),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTeamLeaderName,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Constants.maincolor,
                          size: 26,
                        ),
                        style: TextStyle(
                          color: isLight ? Colors.black87 : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        items:
                            teamLeaders.map((leader) {
                              return DropdownMenuItem<String>(
                                value: leader.teamLeaderInfo?.name,
                                child: Text(leader.teamLeaderInfo?.name ?? ''),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTeamLeaderName = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Team Leader Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isLight ? Colors.white : const Color(0xff1E1E1E),
                      boxShadow:
                          isLight
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : [],
                    ),
                    child: Row(
                      children: [
                        // Blue left accent bar
                        Container(
                          width: 4,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Constants.maincolor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Avatar
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xffEAEEF5),
                          child: Icon(
                            Icons.person,
                            color: const Color(0xff8A9BB5),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLeader.teamLeaderInfo?.name ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color:
                                      isLight ? Colors.black87 : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffEAEEF5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "TEAM LEADER",
                                  style: TextStyle(
                                    color: Constants.maincolor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                selectedLeader.teamLeaderInfo?.email ??
                                    'No email',
                                style: const TextStyle(
                                  color: Color(0xff7F8689),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // "Your Sales" header with member count badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Sales",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isLight ? Colors.black87 : Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Constants.maincolor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${salesList.length} Members",
                          style: TextStyle(
                            color: Constants.maincolor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sales List
                  Expanded(
                    child: ListView.separated(
                      itemCount: salesList.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final sales = salesList[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color:
                                isLight
                                    ? Colors.white
                                    : const Color(0xff1E1E1E),
                            boxShadow:
                                isLight
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xffEAEEF5),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xff8A9BB5),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name + Role
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sales.name ?? "Unknown Sales",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isLight
                                                ? Colors.black87
                                                : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Sales Executive",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff7F8689),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow
                              Icon(
                                Icons.chevron_right,
                                color: const Color(0xffB0BEC5),
                                size: 22,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is GetManagerLeadsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetManagerLeadsFailure) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text("No data available."));
          },
        ),
      ),
    );
  }
}
