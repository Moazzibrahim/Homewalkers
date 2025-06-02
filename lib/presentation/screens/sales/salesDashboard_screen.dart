// ignore_for_file: file_names, camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesdashboardScreen extends StatelessWidget {
  const SalesdashboardScreen({super.key});

  Future<String> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            FutureBuilder<String>(
              future: checkAuth(), // ✅ جلب الاسم
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
                        'Sales',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FutureBuilder(
                    future: checkAuth(), // ✅ جلب الاسم

                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(" hello ....");
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
                  SizedBox(width: 8),
                  Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              SizedBox(height: 20),
              BlocBuilder<GetLeadsCubit, GetLeadsState>(
                builder: (context, state) {
                  if (state is GetLeadsLoading) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _dashboardCard(
                                'Leads',
                                '...',
                                Icons.group,
                                context,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dashboardCard(
                                'Deals',
                                '...',
                                Icons.work_outline,
                                context,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  } else if (state is GetLeadsSuccess) {
                    final allLeads = state.assignedModel.data ?? [];
                    final doneDeals =
                        allLeads
                            .where((lead) => lead.stage?.name == "Done Deal")
                            .toList();
                    final Map<String, int> stageCounts = {};
                    for (var lead in allLeads) {
                      final stageName = lead.stage?.name ?? 'Unknown';
                      stageCounts[stageName] =
                          (stageCounts[stageName] ?? 0) + 1;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _dashboardCard(
                                'Leads',
                                '${allLeads.length}',
                                Icons.group,
                                context,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SalesLeadsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dashboardCard(
                                'Deals',
                                '${doneDeals.length}',
                                Icons.work_outline,
                                context,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SalesLeadsScreen(
                                            stageName: "Done Deal",
                                          ),
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
                                return _dashboardCard(
                                  entry.key,
                                  entry.value.toString(),
                                  Icons.timeline,
                                  context,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SalesLeadsScreen(
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
                  } else {
                    return Row(
                      children: [
                        Expanded(
                          child: _dashboardCard(
                            'Leads',
                            '0',
                            Icons.group,
                            context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dashboardCard(
                            'Deals',
                            '0',
                            Icons.work_outline,
                            context,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 25),
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
                  ? Color(0xffF5F8F9)
                  : Color(0xff1e1e1e),
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
