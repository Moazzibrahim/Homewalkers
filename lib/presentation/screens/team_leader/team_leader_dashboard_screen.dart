// ignore_for_file: file_names, camel_case_types, deprecated_member_use, avoid_print, unused_field, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamLeaderDashboardScreen extends StatefulWidget {
  const TeamLeaderDashboardScreen({super.key});

  @override
  State<TeamLeaderDashboardScreen> createState() =>
      _TeamLeaderDashboardScreenState();

  static Widget _iconBox(IconData icon, void Function() onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE8F1F2),
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
                  : Color(0xff1e1e1e),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Constants.maincolor, size: 30),
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
              textAlign: TextAlign.center,
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

class _TeamLeaderDashboardScreenState extends State<TeamLeaderDashboardScreen>
    with WidgetsBindingObserver {
  late GetLeadsTeamLeaderCubit _teamLeaderCubit;
  final String _userName = 'User';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 👈 لمراقبة حالة التطبيق
    checkAuth();

    // إنشاء Cubit مرة واحدة فقط
    _teamLeaderCubit = GetLeadsTeamLeaderCubit(GetLeadsService())
      ..getLeadsByTeamLeader();

    SalesCubit(GetAllSalesApiService()).fetchAllSales();

    // تهيئة الإشعارات
    context.read<NotificationCubit>().initNotifications();
    print("init notifications called");
  }

  Future<String> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 👇 لما التطبيق يرجع من الخلفية
    if (state == AppLifecycleState.resumed) {
      print("App resumed — refreshing team leader leads...");
      _teamLeaderCubit.getLeadsByTeamLeader(); // إعادة تحميل الداتا
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _teamLeaderCubit.close(); // إغلاق الـ Cubit لتفادي memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          // 👈 نستخدم value عشان نمرر نفس نسخة Cubit اللي أنشأناها
          value: _teamLeaderCubit,
        ),
        BlocProvider(
          create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
      ],
      child: Scaffold(
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
              TeamLeaderDashboardScreen._iconBox(Icons.notifications_none, () {
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
        body: RefreshIndicator(
          onRefresh: () async {
            await _teamLeaderCubit.getLeadsByTeamLeader();
            context.read<SalesCubit>().fetchAllSales();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FutureBuilder(
                          future: checkAuth(),
                          builder: (
                            BuildContext context,
                            AsyncSnapshot snapshot,
                          ) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                      Theme.of(context).brightness ==
                                              Brightness.light
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        TeamLeaderDashboardScreen._dashboardCard(
                                          'Leads',
                                          '...',
                                          Icons.group,
                                          context,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Center(child: CircularProgressIndicator()),
                            ],
                          );
                        } else if (state is GetLeadsTeamLeaderSuccess) {
                          return FutureBuilder(
                            future: SharedPreferences.getInstance(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final prefs = snapshot.data!;
                              final loggedSalesId =
                                  prefs.getString('teamleader_userlog_id') ?? '';
                              final allLeads = state.leadsData.data ?? [];
              
                              // ✅ Fresh Leads = No Stage assigned to loggedSalesId
                              final freshLeads =
                                  allLeads.where((lead) {
                                    final stage =
                                        (lead.stage?.name ?? '').toLowerCase();
                                    final assignedId = lead.sales?.id ?? '';
                                    print(
                                      "🔍 Lead Stage: $stage, Assigned TeamLeaderId: $assignedId, Logged TeamLeaderId: $loggedSalesId",
                                    );
                                    return stage == 'no stage' &&
                                        assignedId == loggedSalesId;
                                  }).toList();
              
                              final noStageLeads =
                                  allLeads.where((lead) {
                                    final stage =
                                        (lead.stage?.name ?? '').toLowerCase();
                                    final assignedId = lead.sales?.id ?? '';
                                    print(
                                      "🔍 Lead Stage: $stage, Assigned TeamLeaderId: $assignedId, Logged TeamLeaderId: $loggedSalesId",
                                    );
                                    return stage == 'no stage' &&
                                        assignedId != loggedSalesId;
                                  }).toList();
              
                              // ✅ بعد كده بنحسب باقي الـ Stages
                              final otherStages =
                                  allLeads.where((lead) {
                                    final stage =
                                        (lead.stage?.name ?? '').toLowerCase();
                                    return stage != 'no stage';
                                  }).toList();
              
                              // 📊 نعمل Map بالأعداد
                              final Map<String, int> stageCounts = {
                                "Fresh": freshLeads.length,
                                "No Stage": noStageLeads.length,
                              };
              
                              // ✅ نضيف باقي stages
                              for (var lead in otherStages) {
                                final stageName = lead.stage?.name ?? 'Unknown';
                                stageCounts[stageName] =
                                    (stageCounts[stageName] ?? 0) + 1;
                              }
              
                              print("✅ Fresh Count = ${freshLeads.length}");
                              print("✅ No Stage Count = ${noStageLeads.length}");
              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TeamLeaderDashboardScreen._dashboardCard(
                                          'Leads',
                                          '${allLeads.length}',
                                          Icons.group,
                                          context,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const TeamLeaderAssignScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1.5,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children:
                                        stageCounts.entries.map((entry) {
                                          return TeamLeaderDashboardScreen._dashboardCard(
                                            entry.key,
                                            entry.value.toString(),
                                            Icons.timeline,
                                            context,
                                            onTap: () {
                                              // final stageNameToSend =
                                              //     entry.key == 'Fresh'
                                              //         ? 'No Stage'
                                              //         : entry.key;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          TeamLeaderAssignScreen(
                                                            stageName: entry.key,
                                                          ),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                child: TeamLeaderDashboardScreen._dashboardCard(
                                  'Leads',
                                  '0',
                                  Icons.group,
                                  context,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
