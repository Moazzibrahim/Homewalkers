// ignore_for_file: file_names, camel_case_types, deprecated_member_use
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/presentation/screens/marketier/leads_marketier_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketerDashboardScreen extends StatefulWidget {
  const MarketerDashboardScreen({super.key});

  @override
  State<MarketerDashboardScreen> createState() =>
      _MarketerDashboardScreenState();

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

class _MarketerDashboardScreenState extends State<MarketerDashboardScreen>
    with WidgetsBindingObserver {
  late GetLeadsMarketerCubit _marketerCubit;
  // ignore: unused_field
  final String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 👈 مراقبة حالة التطبيق
    checkAuth();

    // إنشاء Cubit مرة واحدة فقط
    _marketerCubit = GetLeadsMarketerCubit(GetLeadsService())
      ..getLeadsByMarketer();

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
    if (state == AppLifecycleState.resumed) {
      print("App resumed — refreshing marketer leads...");
      _marketerCubit.getLeadsByMarketer(); // 👈 تحديث البيانات عند الرجوع
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _marketerCubit.close(); // 👈 قفل الكيوبت لتفادي memory leaks
    super.dispose();
  }

  BarChartData _buildBarChartData(
    Map<String, int> stageCounts,
    List<int> values,
    List<String> stages,
    BuildContext context,
  ) {
    // 1. حساب أعلى قيمة في البيانات لتحديد مدى المحاور
    final double maxValue =
        (values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1)
            .toDouble();

    // 2. حساب الفاصل الزمني (Interval) للمحور الرأسي بشكل ديناميكي
    final double interval = (maxValue / 5).ceilToDouble();
    final double roundedMaxY = (maxValue / interval).ceil() * interval;

    final primaryColor = Constants.maincolor;
    final secondaryColor = Constants.maincolor;

    return BarChartData(
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(y: roundedMaxY, color: Colors.transparent),
        ],
      ),
      maxY: roundedMaxY,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${stages[group.x]}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: rod.toY.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval > 0 ? interval : 1,
            getTitlesWidget: (value, meta) {
              if (value % interval == 0 || value == 0) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.left,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              int i = value.toInt();
              if (i >= 0 && i < stages.length) {
                // The correction is here: 'axisSide' is removed.
                return SideTitleWidget(
                  meta: meta,
                  space: 8.0,
                  angle: -0.785,
                  child: Text(
                    stages[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(stageCounts.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: values[index].toDouble(),
              width: 22,
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // 👈 نستخدم value عشان نمرر نفس نسخة الكيوبت اللي أنشأناها في initState
      value: _marketerCubit,
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
                          'Marketer',
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
              MarketerDashboardScreen._iconBox(Icons.notifications_none, () {
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
            _marketerCubit.getLeadsByMarketer(); // 👈 هنا التحديث
            await Future.delayed(Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), // 👈 مهم لتفعيل السحب
            child: Padding(
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
                  // تم استبدال PieChart بـ BarChart في هذا التعديل
                  // ... (نفس الكود السابق حتى BlocBuilder)
                  BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
                    builder: (context, state) {
                      if (state is GetLeadsMarketerLoading) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MarketerDashboardScreen._dashboardCard(
                                    'Leads',
                                    '...',
                                    Icons.group,
                                    context,
                                  ),
                                ),
                                // SizedBox(width: 12),
                                // Expanded(
                                //   child: _dashboardCard(
                                //     'Deals',
                                //     '...',
                                //     Icons.work_outline,
                                //     context,
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      } else if (state is GetLeadsMarketerSuccess) {
                        final allLeads = state.leadsResponse.data ?? [];
                        final duplicatesCount =
                            allLeads
                                .where(
                                  (user) => (user.allVersions?.length ?? 0) > 1,
                                )
                                .length;
                        // final doneDeals =
                        //     allLeads
                        //         .where((lead) => lead.stage?.name == "Done Deal")
                        //         .toList();
                        final Map<String, int> stageCounts = {};
                        for (var lead in allLeads) {
                          final stageName = lead.stage?.name ?? 'Unknown';
                          stageCounts[stageName] =
                              (stageCounts[stageName] ?? 0) + 1;
                        }
                        final stages = stageCounts.keys.toList();
                        final values = stageCounts.values.toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MarketerDashboardScreen._dashboardCard(
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
                                                  const LeadsMarketierScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.5,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                if (duplicatesCount > 0)
                                  MarketerDashboardScreen._dashboardCard(
                                    'Duplicates',
                                    '$duplicatesCount',
                                    Icons.copy_all,
                                    context,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const LeadsMarketierScreen(
                                                    showDuplicatesOnly: true,
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                                ...stageCounts.entries.map((entry) {
                                  return MarketerDashboardScreen._dashboardCard(
                                    entry.key,
                                    entry.value.toString(),
                                    Icons.timeline,
                                    context,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => LeadsMarketierScreen(
                                                stageName: entry.key,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ],
                            ),

                            SizedBox(height: 24),
                            Text(
                              'Leads by Stage',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Color(0xff080719)
                                        : Colors.white,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 300,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Color(0xffF5F8F9)
                                        : Color(0xff1e1e1e),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: BarChart(
                                _buildBarChartData(
                                  stageCounts,
                                  values,
                                  stages,
                                  context,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: MarketerDashboardScreen._dashboardCard(
                                'Leads',
                                '0',
                                Icons.group,
                                context,
                              ),
                            ),
                            // SizedBox(width: 12),
                            // Expanded(
                            //   child: _dashboardCard(
                            //     'Deals',
                            //     '0',
                            //     Icons.work_outline,
                            //     context,
                            //   ),
                            // ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
