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
  String? selectedTeamLeaderName; // اسم الـ Team Leader المختار
  Map<String, List<LeadData>> groupedLeads = {}; // تخزين الـ data المجمعة

  @override
  void initState() {
    super.initState();
    // طلب البيانات عند بدء الشاشة
    context.read<GetManagerLeadsCubit>().getManagerDashboardCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
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
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
          builder: (context, state) {
            if (state is GetManagerDashboardSuccess) {
              final dashboard =
                  context.read<GetManagerLeadsCubit>().dashboardDataS;

              final teamLeaders = dashboard?.data?.teamLeaders ?? [];

              if (teamLeaders.isEmpty) {
                return const Center(child: Text(" No Team Leaders."));
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
                  Text(
                    "Your Team Leader and Sales That related with you.",
                    style: TextStyle(
                      color: Color(0xff7F8689),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),

                  /// Dropdown Team Leaders
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: "Select Team Leaders",
                      hintStyle: TextStyle(
                        color: Color(0xffABABAD),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    value: selectedTeamLeaderName,
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

                  SizedBox(height: 16),

                  /// Team Leader Info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          Brightness.light == Theme.of(context).brightness
                              ? Colors.grey[100]
                              : Color(0xff1e1e1e),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLeader.teamLeaderInfo?.name ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text("Role: Team Leader"),
                              SizedBox(height: 4),
                              Text(
                                "Email: ${selectedLeader.teamLeaderInfo?.email ?? 'No email'}",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your Sales",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  /// Sales List
                  Expanded(
                    child: ListView.separated(
                      itemCount: salesList.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final sales = salesList[index];
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Color(0xff1E1E1E),
                            boxShadow: [
                              if (Theme.of(context).brightness ==
                                  Brightness.light)
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Constants.maincolor
                                    .withOpacity(.15),
                                child: Icon(
                                  Icons.person,
                                  color: Constants.maincolor,
                                  size: 20,
                                ),
                              ),

                              SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  sales.name ?? "Unknown Sales",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
              return Center(child: CircularProgressIndicator());
            } else if (state is GetManagerLeadsFailure) {
              return Center(child: Text(state.message));
            }
            return Center(child: Text("لا توجد بيانات."));
          },
        ),
      ),
    );
  }
}
