// ignore_for_file: file_names, camel_case_types, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/core/utils/dialog_utils.dart';
import 'package:homewalkers_app/presentation/screens/Admin/all_request_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/request_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_assign_screen.dart'; // تأكد من وجود هذه الشاشة أو قم بتعديل الاسم
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_state.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ====================================================================

class TeamleaderDataDashboardScreen extends StatefulWidget {
  const TeamleaderDataDashboardScreen({super.key});

  @override
  State<TeamleaderDataDashboardScreen> createState() =>
      _TeamLeaderDashboardScreenState();

  static Widget _iconBox(
    IconData icon,
    void Function() onPressed,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Constants.maincolor, size: 22),
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
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
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isTablet ? 140 : 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Constants.maincolor, size: isTablet ? 36 : 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xff080719),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              number,
              style: TextStyle(
                fontSize: isTablet ? 26 : 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xff080719),
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
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Constants.backgroundDarkmode : Constants.backgroundlightmode,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: isDark ? Constants.backgroundDarkmode : Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
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
                        color: isDark ? Colors.white : const Color(0xff080719),
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
            // TeamleaderDataDashboardScreen._iconBox(FontAwesomeIcons.box, () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const RequestsHistoryScreen(),
            //     ),
            //   );
            // }, context),
            // SizedBox(width: 8),
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
              context,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TeamleaderDashboardCubit>().fetchDashboardData();
          await context.read<SalesCubit>().fetchAllSales();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // الهيدر
                  Row(
                    children: [
                      Text(
                        'Data Centre Dashboard',
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '👋',
                        style: TextStyle(fontSize: isTablet ? 28 : 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your team leads and performance',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ زر طلب الليدز (تم إضافته هنا)
                  // الجزء المعدل من دالة build داخل _TeamLeaderDashboardScreenState

                  // // ✅ زر طلب الليدز المعدل
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () async {
                  //       // ✅ أضف async
                  //       // ✅ انتظر النتيجة من الشاشة
                  //       final result = await Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => const RequestLeadsScreen(),
                  //         ),
                  //       );

                  //       // ✅ إذا تم تقديم طلب جديد (result == true)، قم بتحديث البيانات
                  //       if (result == true && mounted) {
                  //         // تحديث بيانات الداشبورد
                  //         await context
                  //             .read<TeamleaderDashboardCubit>()
                  //             .fetchDashboardData();
                  //         await context
                  //             .read<GetLeadsTeamLeaderCubit>()
                  //             .getLeadsByTeamLeader();
                  //         await context
                  //             .read<SalesCubit>()
                  //             .fetchAllSales(); // إذا كان موجوداً

                  //         // عرض رسالة تأكيد
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(
                  //             content: Text(
                  //               'Dashboard refreshed successfully!',
                  //             ),
                  //             backgroundColor: Colors.green,
                  //             duration: Duration(seconds: 2),
                  //           ),
                  //         );
                  //       }
                  //     },
                  //     icon: Icon(
                  //       Icons.add_circle_outline,
                  //       size: isTablet ? 22 : 20,
                  //     ),
                  //     label: Text(
                  //       'Request New Leads',
                  //       style: TextStyle(
                  //         fontSize: isTablet ? 16 : 14,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Constants.maincolor,
                  //       foregroundColor: Colors.white,
                  //       padding: EdgeInsets.symmetric(
                  //         horizontal: 20,
                  //         vertical: isTablet ? 16 : 14,
                  //       ),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(14),
                  //       ),
                  //       elevation: 0,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 28),

                  // محتوى الداشبورد
                  BlocBuilder<
                    TeamleaderDashboardCubit,
                    TeamleaderDashboardState
                  >(
                    builder: (context, state) {
                      if (state is TeamleaderDashboardLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is TeamleaderDashboardError) {
                        return Center(child: Text(state.message));
                      }

                      if (state is TeamleaderDashboardDataSuccess) {
                        final dashboard = state.data.data?.dashboard ?? [];
                        final teamleaderInfopending =
                            state.data.data?.teamLeaderPending?.salesIds ?? [];
                        final String firstSalesIdPending =
                            teamleaderInfopending.isNotEmpty
                                ? teamleaderInfopending.first
                                : '';
                        final totalLeads =
                            state.data.data?.summary?.totalLeads ?? 0;
                        final teamLeaderFresh =
                            state.data.data?.teamLeaderFresh;
                        final teamleaderfreshcount =
                            teamLeaderFresh?.leadsCount ?? 0;
                        final teamLeaderPending =
                            state.data.data?.teamLeaderPending;
                        final teamleaderpendingcount =
                            teamLeaderPending?.leadsCount ?? 0;

                        final visibleStages =
                            dashboard
                                .where((e) => (e.leadsCount ?? 0) > 0)
                                .where(
                                  (e) => e.stageName?.toLowerCase() != 'fresh',
                                )
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
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
                                              (_) =>
                                                  const TeamLeaderAssignScreen(
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
                            if (teamLeaderFresh != null &&
                                teamleaderfreshcount > 0)
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
                                                    (
                                                      _,
                                                    ) => TeamLeaderAssignScreen(
                                                      stageName: "fresh",
                                                      data: false,
                                                      transferfromdata: false,
                                                      stageId:
                                                          teamLeaderFresh
                                                              .stageId,
                                                      salesName:
                                                          firstSalesIdPending,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ],
                              ),
                            if (teamLeaderFresh != null &&
                                teamleaderfreshcount > 0)
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
                                                    (
                                                      _,
                                                    ) => TeamLeaderAssignScreen(
                                                      stageName:
                                                          "Team Leader Pending",
                                                      data: false,
                                                      transferfromdata: false,
                                                      stageId:
                                                          teamLeaderPending
                                                              .stageId,
                                                      salesName:
                                                          firstSalesIdPending,
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
                                crossAxisCount:
                                    ResponsiveHelper.isLargeTablet(context)
                                        ? 4
                                        : (isTablet ? 3 : 2),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: isTablet ? 1.8 : 1.3,
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
                  const SizedBox(height: 25),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
