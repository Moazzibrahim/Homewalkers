// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/edit_comment_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/presentation/viewModels/edit_comment/cubit/edit_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesCommentsScreen extends StatefulWidget {
  final String leedId;
  final String? fcmtoken;
  final String? leadName;

  const SalesCommentsScreen({
    super.key,
    required this.leedId,
    required this.fcmtoken,
    required this.leadName,
  });

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
    log('leedId: ${widget.leedId}');
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
        clearHistoryTime = DateTime.tryParse(time)?.toUtc();
      });
      debugPrint('آخر مرة تم فيها الضغط على Clear History: $clearHistoryTime');
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  LeadCommentsCubit(GetAllLeadCommentsApiService())
                    ..fetchLeadComments(widget.leedId)..fetchLeadAssignedData(widget.leedId),
        ),
        BlocProvider(create: (_) => EditCommentCubit(EditCommentApiService())),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LeadCommentsCubit, LeadCommentsState>(
            listener: (context, state) {
              if (state is ReplySentSuccessfully) {
                // ✅ إعادة جلب الكومنتات بعد إرسال الرد
                context.read<LeadCommentsCubit>().fetchLeadComments(
                  widget.leedId,
                );
              }
            },
          ),
          BlocListener<EditCommentCubit, EditCommentState>(
            listener: (context, state) {
              if (state is EditCommentSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Comment edited successfully')),
                );
              } else if (state is EditCommentFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to edit comment')),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Constants.backgroundlightmode
                      : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            title: "comments",
            onBack: () => Navigator.pop(context),
          ),
          body: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
            builder: (context, state) {
              if (state is LeadCommentsLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is LeadCommentsError) {
                return Center(child: Text('Error: ////${state.message}'));
              } else if (state is LeadCommentsLoaded) {
                final leadComments = state.leadComments;
                final List<DataItem> filteredData =
                    leadComments.data!.where((item) {
                      if (isClearHistory == true && clearHistoryTime != null) {
                        final firstDate =
                            DateTime.tryParse(
                              item.comments?.first.firstcomment?.date
                                      ?.toString() ??
                                  '',
                            )?.toUtc();
                        final secondDate =
                            DateTime.tryParse(
                              item.comments?.first.secondcomment?.date
                                      ?.toString() ??
                                  '',
                            )?.toUtc();
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
    final firstDate =
        DateTime.tryParse(firstComment?.date?.toString() ?? '')?.toUtc();
    final secondDate =
        DateTime.tryParse(secondComment?.date?.toString() ?? '')?.toUtc();
    log('firstDate: $firstDate');
    log("secondDate: $secondDate");
    final isFirstValid =
    isClearHistory != true ||
    (firstDate != null && clearHistoryTime != null && firstDate.isAfter(clearHistoryTime!));

    final isSecondValid =
    isClearHistory != true ||
    (secondDate != null && clearHistoryTime != null && secondDate.isAfter(clearHistoryTime!));

    // لو لا يوجد ولا كومنت يظهر بعد clear history، متعرضش الكارت أصلاً
    if (!isFirstValid && !isSecondValid) return SizedBox();

    String formatDate(DateTime? date) {
      if (date == null) return '';
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    if ((isFirstValid && firstComment?.text != null) &&
        (isSecondValid && secondComment?.text != null)) {
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
                        builder: (
                          BuildContext context,
                          AsyncSnapshot snapshot,
                        ) {
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
                        builder: (
                          BuildContext context,
                          AsyncSnapshot snapshot,
                        ) {
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
              Text('First action', style: commentTitleStyle),
              Text(
                firstComment?.text ?? 'No Comment',
                style: TextStyle(fontSize: 14),
              ),
              if (firstComment?.date != null)
                Text(
                  "comment at :${formatDate(firstComment?.date)}",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              SizedBox(height: 6),
              Text('Second action', style: commentTitleStyle),
              Text(
                secondComment?.text ?? 'No Comment',
                style: TextStyle(fontSize: 14),
              ),
              if (secondComment?.date != null)
                Text(
                  "comment at : ${formatDate(secondComment!.date)}",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              SizedBox(height: 8),
              Text('Replies:', style: commentTitleStyle),
              SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    (reply != null && reply.isNotEmpty)
                        ? reply.map((r) {
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
                        }).toList()
                        : [Text('No Replies')],
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final TextEditingController replyController =
                        TextEditingController();
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: Text("Write a reply"),
                          content: TextField(
                            controller: replyController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Type your reply here...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                              ),
                              onPressed: () async {
                                final replyText = replyController.text.trim();
                                if (replyText.isEmpty) return;
                                Navigator.pop(ctx); // Close dialog
                                context
                                    .read<LeadCommentsCubit>()
                                    .sendReplyToComment(
                                      commentId:
                                          dataItem.comments?.first.id ?? '',
                                      replyText: replyText,
                                    );
                                // Optional: show a message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Reply sent!')),
                                );
                                if (widget.fcmtoken != null) {
                                  context
                                      .read<NotificationCubit>()
                                      .sendNotificationToToken(
                                        title: "Comment Reply",
                                        body: "تم الرد على التعليق بنجاح ✅ ${widget.leadName}",
                                        fcmtokennnn: widget.fcmtoken!,
                                      );
                                }
                                // Optional: refresh comments
                                context
                                    .read<LeadCommentsCubit>()
                                    .fetchLeadComments(widget.leedId);
                              },
                              child: Text(
                                "Send",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.reply, color: Colors.white),
                  label: Text("Reply", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),
                ),
              ),
              FutureBuilder(
                future: checkRoleName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox();
                  }

                  if (snapshot.hasData && snapshot.data == "Admin") {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.edit, color: Colors.white),
                        label: Text(
                          "Edit",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                        onPressed: () {
                          final firstTextController = TextEditingController(
                            text: firstComment?.text ?? '',
                          );
                          final secondTextController = TextEditingController(
                            text: secondComment?.text ?? '',
                          );
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: Text('Edit Comment'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: firstTextController,
                                      decoration: InputDecoration(
                                        labelText: 'First Comment',
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: secondTextController,
                                      decoration: InputDecoration(
                                        labelText: 'Second Comment',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final firstText =
                                          firstTextController.text.trim();
                                      final secondText =
                                          secondTextController.text.trim();
                                      Navigator.pop(ctx);
                                      context.read<EditCommentCubit>().editComment(
                                            commentId:
                                                dataItem.comments?.first.id ?? '',
                                            firstText: firstText,
                                            secondText: secondText,
                                          )
                                          .then((isSuccess) {
                                            if (isSuccess) {
                                              context
                                                  .read<LeadCommentsCubit>()
                                                  .fetchLeadComments(
                                                    widget.leedId,
                                                  );
                                              if (widget.fcmtoken != null) {
                                                context
                                                    .read<NotificationCubit>()
                                                    .sendNotificationToToken(
                                                      title: "Lead",
                                                      body:
                                                          " comment has been edited ✅ on ${widget.leadName}",
                                                      fcmtokennnn:
                                                          widget.fcmtoken!,
                                                    );
                                              }
                                            } else {
                                              // اختياري: عرض رسالة فشل
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    " Failed to edit comment ❌",
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    return SizedBox(); // No button
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(child: Text("No Comments"));
    }
  }
}
