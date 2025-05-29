// ignore_for_file: file_names, camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/sales_image.png'),
              radius: 24,
            ),
            const SizedBox(width: 12),
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
                        'Hello $name',
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

      body: Padding(
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
            Row(
              children: [
                // LEADS Count
                BlocBuilder<GetLeadsCubit, GetLeadsState>(
                  builder: (context, state) {
                    if (state is GetLeadsLoading) {
                      return _dashboardCard(
                        'Leads',
                        '...',
                        Icons.group,
                        context,
                      );
                    } else if (state is GetLeadsSuccess) {
                      return _dashboardCard(
                        'Leads',
                        '${state.assignedModel.count}',
                        Icons.group,
                        context,
                      );
                    } else if (state is GetLeadsError) {
                      return _dashboardCard('Leads', '0', Icons.group, context);
                    }
                    return _dashboardCard('Leads', '0', Icons.group, context);
                  },
                ),
                SizedBox(width: 12),
                // DEALS Count (Filtered)
                BlocBuilder<GetLeadsCubit, GetLeadsState>(
                  builder: (context, state) {
                    if (state is GetLeadsLoading) {
                      return _dashboardCard(
                        'Deals',
                        '...',
                        Icons.work_outline,
                        context,
                      );
                    } else if (state is GetLeadsSuccess) {
                      final doneDeals =
                          state.assignedModel.data!
                              .where((lead) => lead.stage?.name == "Done Deal")
                              .toList();
                      return _dashboardCard(
                        'Deals',
                        '${doneDeals.length}',
                        Icons.work_outline,
                        context,
                      );
                    } else if (state is GetLeadsError) {
                      return _dashboardCard(
                        'Deals',
                        '0',
                        Icons.work_outline,
                        context,
                      );
                    }
                    return _dashboardCard(
                      'Deals',
                      '0',
                      Icons.work_outline,
                      context,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 25),
            // Stack(
            //   children: [
            //     Container(
            //       padding: EdgeInsets.all(20),
            //       decoration: BoxDecoration(
            //         color: Color(0xff2D6A78),
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: const [
            //               Text(
            //                 'Next Appointment',
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.w600,
            //                 ),
            //               ),
            //               Chip(
            //                 label: Text('See Detail'),
            //                 backgroundColor: Colors.white,
            //                 labelStyle: TextStyle(color: Color(0xff2D6A78)),
            //               ),
            //             ],
            //           ),
            //           SizedBox(height: 20),
            //           Row(
            //             children: [
            //               CircleAvatar(
            //                 backgroundImage: AssetImage(
            //                   'assets/images/appointment.png',
            //                 ),
            //                 radius: 20,
            //               ),
            //               SizedBox(width: 10),
            //               Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: const [
            //                   Text(
            //                     '319 Haul Road',
            //                     style: TextStyle(
            //                       color: Colors.white,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                   ),
            //                   Text(
            //                     'Glenrock, WY 12345',
            //                     style: TextStyle(color: Colors.white70),
            //                   ),
            //                 ],
            //               ),
            //             ],
            //           ),
            //           SizedBox(height: 20),
            //           Wrap(
            //             spacing: 50,
            //             runSpacing: 10,
            //             children: const [
            //               _infoItem('Appointment Date', 'Nov 18 2021, 17:00'),
            //               _infoItem('Room Area', '100 M²'),
            //               _infoItem('People', '10'),
            //               _infoItem('Price', '\$5750'),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //     // الديكور الأبيض المنحني
            //     Positioned(
            //       bottom: 0,
            //       right: 0,
            //       child: Container(
            //         width: 140,
            //         height: 130,
            //         decoration: BoxDecoration(
            //           color: Colors.white.withOpacity(0.3),
            //           borderRadius: const BorderRadius.only(
            //             topLeft: Radius.circular(110),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
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

// class _infoItem extends StatelessWidget {
//   final String label;
//   final String value;

//   const _infoItem(this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 130,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
//           SizedBox(height: 4),
//           Text(value, style: TextStyle(color: Colors.white, fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }
