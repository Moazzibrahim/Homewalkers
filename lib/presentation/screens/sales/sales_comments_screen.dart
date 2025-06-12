// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesCommentsScreen extends StatefulWidget {
  final String leedId;

  const SalesCommentsScreen({super.key, required this.leedId});

  @override
  State<SalesCommentsScreen> createState() => _SalesCommentsScreenState();
}

class _SalesCommentsScreenState extends State<SalesCommentsScreen> {
  final TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  final TextStyle subtitleStyle = TextStyle(color: Colors.grey);
  final TextStyle commentTextStyle = TextStyle(fontSize: 14);
  bool? isClearHistory;
  DateTime? clearHistoryTime;

  @override
  void initState() {
    super.initState();
    checkClearHistoryTime();
    checkIsClearHistory();
  }

  Future<String> checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    return name ?? 'User';
  }

  Future<String> checkRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    return role ?? 'User';
  }

  Future<void> checkClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final time = prefs.getString('clear_history_time');
    if (time != null) {
      setState(() {
        clearHistoryTime = DateTime.tryParse(time);
      });
      debugPrint('آخر مرة تم فيها الضغط على Clear History: $time');
    }
  }

  Future<void> checkIsClearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final iscleared = prefs.getBool('clearHistory');
    if (mounted) {
      setState(() {
        isClearHistory = iscleared;
      });
    }
    debugPrint('Clear History: $iscleared');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              LeadCommentsCubit(GetAllLeadCommentsApiService())
                ..fetchLeadComments(widget.leedId),
      child: Scaffold(
        appBar: CustomAppBar(
          title: "comments",
          onBack: () => Navigator.pop(context),
        ),
        body: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
          builder: (context, state) {
            if (state is LeadCommentsLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is LeadCommentsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is LeadCommentsLoaded) {
              final leadComments = state.leadComments;
              log("lead id: ${widget.leedId}");

              final List<DataItem> filteredData =
                  leadComments.data!.where((item) {
                    if (isClearHistory == true && clearHistoryTime != null) {
                      final firstDate = DateTime.tryParse(
                        item.comments?.first.firstcomment?.date.toString() ??
                            '',
                      );
                      final secondDate = DateTime.tryParse(
                        item.comments?.first.secondcomment?.date.toString() ??
                            '',
                      );

                      final isFirstValid =
                          firstDate != null &&
                          firstDate.isAfter(clearHistoryTime!);
                      final isSecondValid =
                          secondDate != null &&
                          secondDate.isAfter(clearHistoryTime!);

                      return isFirstValid || isSecondValid;
                    }
                    return true;
                  }).toList();

              if (filteredData.isEmpty) {
                return Center(child: Text('No comments found'));
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final dataItem = filteredData[index];

                  // نقدر نبني كارت لكل DataItem ويعرض أول comment عنده
                  return buildCommentCard(context, dataItem);
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget buildCommentCard(BuildContext context, DataItem dataItem) {
    final TextStyle commentTitleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color:
          Theme.of(context).brightness == Brightness.light
              ? Constants.maincolor
              : Constants.mainDarkmodecolor,
    );

    final firstComment = dataItem.comments?.first.firstcomment;
    final secondComment = dataItem.comments?.first.secondcomment;
    final reply = dataItem.comments?.first.replies;

    if (isClearHistory == true && clearHistoryTime != null) {
      final firstDate = DateTime.tryParse(firstComment?.date.toString() ?? '');
      final secondDate = DateTime.tryParse(
        secondComment?.date.toString() ?? '',
      );

      final isFirstValidd =
          firstDate != null && firstDate.isAfter(clearHistoryTime!);
      final isSecondValidd =
          secondDate != null && secondDate.isAfter(clearHistoryTime!);

      // لو لا يوجد أي تعليق بعد clear time، لا تعرضه
      if (!isFirstValidd && !isSecondValidd) return SizedBox();
    }

    String formatDate(DateTime? date) {
      if (date == null) return '';
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: checkAuthName(), // ✅ جلب الاسم
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(" ....");
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching name');
                        } else {
                          return Text(
                            '${snapshot.data}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
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
                    FutureBuilder(
                      future: checkRoleName(), // ✅ جلب الاسم
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(" ....");
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching name');
                        } else {
                          return Text(
                            '${snapshot.data}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xff080719)
                                      : Colors.grey,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            if (firstComment?.text != null &&
                (isClearHistory == true ||
                    DateTime.parse(
                      firstComment!.date.toString(),
                    ).isAfter(clearHistoryTime!)))
              Text('First action', style: commentTitleStyle),
            Text(
              firstComment?.text ?? 'No First Comment',
              style: TextStyle(fontSize: 14),
            ),
            if (firstComment?.date != null)
              Text(
                "comment at :${formatDate(firstComment!.date)}",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            SizedBox(height: 6),
            if (secondComment?.text != null &&
                (isClearHistory == true ||
                    DateTime.parse(
                      secondComment!.date.toString(),
                    ).isAfter(clearHistoryTime!)))
              Text('Second action', style: commentTitleStyle),
            Text(
              secondComment?.text ?? 'No Second Comment',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            if (reply != null &&
                reply.isNotEmpty &&
                (isClearHistory == true ||
                    DateTime.parse(
                      reply.first.date.toString(),
                    ).isAfter(clearHistoryTime!))) ...[
              Text('Replies:', style: commentTitleStyle),
              SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    reply.map((r) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.text ?? 'No Reply Text',
                              style: TextStyle(fontSize: 14),
                            ),
                            if (r.date != null)
                              Text(
                                "replied at: ${formatDate(r.date)}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],

            if (secondComment?.date != null)
              Text(
                "comment at : ${formatDate(secondComment!.date)}",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     TextButton(
            //       onPressed: () {
            //         showModalBottomSheet(
            //           context: context,
            //           isScrollControlled: true,
            //           backgroundColor: Colors.transparent,
            //           builder:
            //               (_) => AddCommentBottomSheet(
            //                 buttonName: "Edit comment",
            //                 optionalName: "Edit",
            //               ),
            //         );
            //       },
            //       style: TextButton.styleFrom(
            //         minimumSize: Size(60, 32),
            //         backgroundColor:
            //             Theme.of(context).brightness == Brightness.light
            //                 ? Constants.maincolor
            //                 : Constants.mainDarkmodecolor,
            //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(6),
            //         ),
            //       ),
            //       child: Text('Edit', style: TextStyle(color: Colors.white)),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
