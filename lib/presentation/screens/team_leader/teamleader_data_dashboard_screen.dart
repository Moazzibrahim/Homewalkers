// ignore_for_file: file_names, camel_case_types, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_state.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamleaderDataDashboardScreen extends StatefulWidget {
  const TeamleaderDataDashboardScreen({super.key});

  @override
  State<TeamleaderDataDashboardScreen> createState() =>
      _TeamLeaderDashboardScreenState();

  static Widget _iconBox(IconData icon, void Function() onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Constants.maincolor),
        onPressed: onPressed,
      ),
    );
  }

  static Widget _dashboardCard(
    String title,
    String number,
    IconData icon,
    BuildContext context, {
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : const Color(0xff1e1e1e),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Constants.maincolor, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color(0xff080719)
                        : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              number,
              style: TextStyle(
                fontSize: 20,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color(0xff080719)
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

class _TeamLeaderDashboardScreenState
    extends State<TeamleaderDataDashboardScreen>
    with WidgetsBindingObserver {
  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'User';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<TeamleaderDashboardCubit>().fetchDashboardData();
    context.read<GetLeadsTeamLeaderCubit>().getLeadsByTeamLeader();
    context.read<NotificationCubit>().initNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<TeamleaderDashboardCubit>().fetchDashboardData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Constants.backgroundDarkmode,
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            //  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
            FutureBuilder<String>(
              future: _getUserName(),
              builder: (context, snapshot) {
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
                      ),
                    ),
                    const Text(
                      'Team Leader',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            TeamleaderDataDashboardScreen._iconBox(
              Icons.notifications_none,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SalesNotificationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TeamleaderDashboardCubit>().fetchDashboardData();
          await context.read<SalesCubit>().fetchAllSales();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: const [
                Text('Data centre Dashboard', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),

            BlocBuilder<TeamleaderDashboardCubit, TeamleaderDashboardState>(
              builder: (context, state) {
                if (state is TeamleaderDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TeamleaderDashboardError) {
                  return Center(child: Text(state.message));
                }

                if (state is TeamleaderDashboardDataSuccess) {
                  // <-- هنا استخدمنا state الصح
                  final dashboard = state.data.data?.dashboard ?? []; 
                  final teamleaderInfopending =
                      state.data.data?.teamLeaderPending?.salesIds ?? [];
                  final String firstSalesIdPending =
                      teamleaderInfopending.isNotEmpty
                          ? teamleaderInfopending.first
                          : '';
                  final totalLeads = state.data.data?.summary?.totalLeads ?? 0;
                  final teamLeaderFresh = state.data.data?.teamLeaderFresh;
                  final teamleaderfreshcount = teamLeaderFresh?.leadsCount ?? 0;
                  final teamLeaderPending = state.data.data?.teamLeaderPending;
                  final teamleaderpendingcount =
                      teamLeaderPending?.leadsCount ?? 0;

                  // نخفي أي stage عددها = 0
                  final visibleStages =
                      dashboard
                          .where((e) => (e.leadsCount ?? 0) > 0)
                          .where((e) => e.stageName?.toLowerCase() != 'fresh')
                          .toList();

                  final hasLeads =
                      totalLeads > 0 ||
                      teamleaderfreshcount > 0 ||
                      teamleaderpendingcount > 0 ||
                      visibleStages.isNotEmpty;

                  if (!hasLeads) {
                    return const Center(
                      child: Text(
                        "No leads found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leads
                      Row(
                        children: [
                          Expanded(
                            child: TeamleaderDataDashboardScreen._dashboardCard(
                              'Leads',
                              totalLeads.toString(),
                              Icons.group,
                              context,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const TeamLeaderAssignScreen(
                                          data: false,
                                          transferfromdata: false,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Fresh
                      if (teamLeaderFresh != null && teamleaderfreshcount > 0)
                        Row(
                          children: [
                            Expanded(
                              child:
                                  TeamleaderDataDashboardScreen._dashboardCard(
                                    'Fresh',
                                    '$teamleaderfreshcount',
                                    Icons.timeline,
                                    context,
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TeamLeaderAssignScreen(
                                                stageName: "fresh",
                                                data: false,
                                                transferfromdata: false,
                                                stageId:
                                                    teamLeaderFresh.stageId,
                                                salesName: firstSalesIdPending,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                      if (teamLeaderFresh != null && teamleaderfreshcount > 0)
                        const SizedBox(height: 18),
                      // Pending
                      if (teamLeaderPending != null &&
                          teamleaderpendingcount > 0)
                        Row(
                          children: [
                            Expanded(
                              child:
                                  TeamleaderDataDashboardScreen._dashboardCard(
                                    'Team Leader Pending',
                                    '$teamleaderpendingcount',
                                    Icons.pending_actions,
                                    context,
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TeamLeaderAssignScreen(
                                                stageName:
                                                    "Team Leader Pending",
                                                data: false,
                                                transferfromdata: false,
                                                stageId:
                                                    teamLeaderPending.stageId,
                                                salesName: firstSalesIdPending,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                      if (teamLeaderPending != null &&
                          teamleaderpendingcount > 0)
                        const SizedBox(height: 18),

                      // باقي الـ stages
                      if (visibleStages.isNotEmpty)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.5,
                          children:
                              visibleStages.map((item) {
                                return TeamleaderDataDashboardScreen._dashboardCard(
                                  item.stageName ?? '',
                                  '${item.leadsCount ?? 0}',
                                  Icons.timeline,
                                  context,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => TeamLeaderAssignScreen(
                                              stageName: item.stageName,
                                              data: false,
                                              transferfromdata: false,
                                              stageId: item.stageId,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                        ),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
