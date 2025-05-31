// ignore_for_file: file_names, camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamLeaderDashboardScreen extends StatelessWidget {
  const TeamLeaderDashboardScreen({super.key});

  Future<String> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              GetLeadsTeamLeaderCubit(GetLeadsService())
                ..getLeadsByTeamLeader(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              FutureBuilder<String>(
                future: checkAuth(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final name = snapshot.data ?? 'User';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xff080719)
                                    : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          'Team Leader',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const Spacer(),
              _iconBox(Icons.comment_rounded, () {}),
              const SizedBox(width: 8),
              _iconBox(Icons.notifications_none, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesNotificationsScreen(),
                  ),
                );
              }),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FutureBuilder(
                    future: checkAuth(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("hello ....");
                      } else if (snapshot.hasError) {
                        return const Text('Hello');
                      } else {
                        return Text(
                          'Hello ${snapshot.data}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xff080719)
                                    : Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<GetLeadsTeamLeaderCubit, GetLeadsTeamLeaderState>(
                builder: (context, state) {
                  if (state is GetLeadsTeamLeaderLoading) {
                    return Row(
                      children: [
                        _dashboardCard('Leads', '...', Icons.group, context),
                        const SizedBox(width: 12),
                        _dashboardCard(
                          'Deals',
                          '...',
                          Icons.work_outline,
                          context,
                        ),
                      ],
                    );
                  } else if (state is GetLeadsTeamLeaderSuccess) {
                    final allLeads = state.leadsData.data ?? [];
                    final doneDeals =
                        allLeads
                            .where((lead) => lead.stage?.name == "Done Deal")
                            .toList();
                    return Row(
                      children: [
                        _dashboardCard(
                          'Leads',
                          '${allLeads.length}',
                          Icons.group,
                          context,
                        ),
                        const SizedBox(width: 12),
                        _dashboardCard(
                          'Deals',
                          '${doneDeals.length}',
                          Icons.work_outline,
                          context,
                        ),
                      ],
                    );
                  } else if (state is GetLeadsTeamLeaderError) {
                    return Row(
                      children: [
                        _dashboardCard('Leads', '0', Icons.group, context),
                        const SizedBox(width: 12),
                        _dashboardCard(
                          'Deals',
                          '0',
                          Icons.work_outline,
                          context,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      _dashboardCard('Leads', '0', Icons.group, context),
                      const SizedBox(width: 12),
                      _dashboardCard('Deals', '0', Icons.work_outline, context),
                    ],
                  );
                },
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _iconBox(IconData icon, void Function() onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE8F1F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Color(0xff2D6A78)),
        onPressed: onPressed,
      ),
    );
  }

  static Widget _dashboardCard(
    String title,
    String number,
    IconData icon,
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          // color: Color(0xffF5F8F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xff2D6A78), size: 30),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Color(0xff080719)
                        : Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            Text(
              number,
              style: TextStyle(
                fontSize: 20,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Color(0xff080719)
                        : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
