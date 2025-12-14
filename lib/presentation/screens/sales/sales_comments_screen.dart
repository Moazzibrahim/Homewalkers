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
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesCommentsScreen extends StatefulWidget {
  final String leedId;
  final String? fcmtoken;
  final String? leadName;
  final String? managerfcm;

  const SalesCommentsScreen({
    super.key,
    required this.leedId,
    required this.fcmtoken,
    required this.leadName,
    this.managerfcm,
  });

  @override
  State<SalesCommentsScreen> createState() => _SalesCommentsScreenState();
}

class _SalesCommentsScreenState extends State<SalesCommentsScreen> {
  final TextStyle titleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  final TextStyle subtitleStyle = const TextStyle(color: Colors.grey);
  final TextStyle commentTextStyle = const TextStyle(fontSize: 14);
  bool? isClearHistory;
  DateTime? clearHistoryTime;
  String? nextActionDate;
  bool isPrefsLoaded = false;
  bool hasFetchedCommentsOnce = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    nextActionDate = prefs.getString('stageDateUpdated');
    log('nextActionDate: $nextActionDate');
    if (role != "Admin" && role != "Marketer") {
      await _loadClearHistoryStatus(prefs);
    } else {
      setState(() {
        isPrefsLoaded = true;
      });
    }
  }

  Future<void> _loadClearHistoryStatus(SharedPreferences prefs) async {
    final timeString = prefs.getString('clear_history_time');
    final isCleared = prefs.getBool('clearHistory');

    if (mounted) {
      setState(() {
        clearHistoryTime =
            timeString != null ? DateTime.tryParse(timeString) : null;
        isClearHistory = isCleared;
        isPrefsLoaded = true;
      });
    }

    debugPrint('Clear History Time: $clearHistoryTime');
    debugPrint('Is Clear History: $isClearHistory');
  }

  Future<String> checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'User';
  }

  Future<String> checkRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'User';
  }

  bool isValidComment({
    required bool isClearHistory,
    required DateTime? clearHistoryTime,
    required DateTime? firstDate,
    required DateTime? secondDate,
    required String? firstText,
    required String? secondText,
  }) {
    if (!isClearHistory) return true;
    if (clearHistoryTime == null) return true;

    bool firstOk =
        firstDate != null && firstDate.isAfter(clearHistoryTime) && (firstText?.isNotEmpty ?? false);
    bool secondOk =
        secondDate != null && secondDate.isAfter(clearHistoryTime) && (secondText?.isNotEmpty ?? false);

    return firstOk || secondOk;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = LeadCommentsCubit(GetAllLeadCommentsApiService());
            cubit.fetchLeadAssignedData(widget.leedId).then((_) {
              cubit.fetchLeadComments(widget.leedId);
            });
            return cubit;
          },
        ),
        BlocProvider(create: (_) => EditCommentCubit(EditCommentApiService())),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LeadCommentsCubit, LeadCommentsState>(
            listener: (context, state) {
              if (state is ReplySentSuccessfully) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.read<LeadCommentsCubit>().fetchLeadComments(widget.leedId);
                });
              }
            },
          ),
          BlocListener<EditCommentCubit, EditCommentState>(
            listener: (context, state) {
              if (state is EditCommentSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment edited successfully')),
                );
              } else if (state is EditCommentFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to edit comment')),
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
              if (!isPrefsLoaded) return const Center(child: CircularProgressIndicator());
              if (state is LeadCommentsLoading && !hasFetchedCommentsOnce) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is LeadCommentsError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is LeadCommentsLoaded && isPrefsLoaded) {
                hasFetchedCommentsOnce = true;
                final leadComments = state.leadComments;
                final filteredData = leadComments.data!.where((item) {
                  final first = item.comments?.first.firstcomment;
                  final second = item.comments?.first.secondcomment;

                  final firstDate = DateTime.tryParse(first?.date?.toString() ?? '')?.toUtc().add(const Duration(hours: 4));
                  final secondDate = DateTime.tryParse(second?.date?.toString() ?? '')?.toUtc().add(const Duration(hours: 4));

                  return isValidComment(
                    isClearHistory: isClearHistory ?? false,
                    clearHistoryTime: clearHistoryTime,
                    firstDate: firstDate,
                    secondDate: secondDate,
                    firstText: first?.text,
                    secondText: second?.text,
                  );
                }).toList();

                if (filteredData.isEmpty) return const Center(child: Text('No comments found'));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final dataItem = filteredData[index];
                    return buildCommentCard(context, dataItem);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget buildCommentCard(BuildContext context, DataItem dataItem) {
    final TextStyle commentTitleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.light
          ? Constants.maincolor
          : Constants.mainDarkmodecolor,
    );
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm a');
    final firstComment = dataItem.comments?.first.firstcomment;
    final secondComment = dataItem.comments?.first.secondcomment;
    final reply = dataItem.comments?.first.replies;
    final salesName = dataItem.comments?.first.sales?.name;
    final leadName = dataItem.leed?.name;

    final firstDate = DateTime.tryParse(firstComment?.date?.toString() ?? '')?.toUtc().add(const Duration(hours: 4));
    final secondDate = (nextActionDate != null
            ? DateTime.tryParse(nextActionDate!)?.toUtc()
            : DateTime.tryParse(secondComment?.date?.toString() ?? '')?.toUtc())
        ?.add(const Duration(hours: 4));

    if (!isValidComment(
      isClearHistory: isClearHistory ?? false,
      clearHistoryTime: clearHistoryTime,
      firstDate: firstDate,
      secondDate: secondDate,
      firstText: firstComment?.text,
      secondText: secondComment?.text,
    )) {
      return const SizedBox.shrink();
    }

    bool isFirstValid = firstComment?.text?.isNotEmpty ?? false;
    bool isSecondValid = secondComment?.text?.isNotEmpty ?? false;

    String formatDate(DateTime? date) {
      if (date == null) return '';
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    final firstDateString = firstDate != null ? dateFormat.format(firstDate) : 'N/A';
    final secondDateString = secondDate != null ? dateFormat.format(secondDate) : 'N/A';

    if ((isFirstValid && firstComment?.text != null) || (isSecondValid && secondComment?.text != null)) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: checkAuthName(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Text(" ....");
                          if (snapshot.hasError) return const Text('Error fetching name');
                          return Text(
                            '$salesName',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xff080719)
                                  : Colors.white,
                            ),
                          );
                        },
                      ),
                      FutureBuilder(
                        future: checkRoleName(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Text(" ....");
                          if (snapshot.hasError) return const Text('Error fetching name');
                          return Text(
                            '$leadName',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xff080719)
                                  : Colors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isFirstValid) ...[
                Text('First action', style: commentTitleStyle),
                SelectableText(firstComment?.text ?? 'No Comment', style: const TextStyle(fontSize: 14)),
                if (firstComment?.date != null)
                  Text("comment at :$firstDateString", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
              const SizedBox(height: 6),
              if (isSecondValid) ...[
                Text('Second action', style: commentTitleStyle),
                SelectableText(secondComment?.text ?? 'No Comment', style: const TextStyle(fontSize: 14)),
                if (secondComment?.date != null)
                  Text("next action at : $secondDateString", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
              const SizedBox(height: 8),
              Text('Replies:', style: commentTitleStyle),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (reply != null && reply.isNotEmpty)
                    ? reply.map((r) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.text ?? 'No Reply Text', style: const TextStyle(fontSize: 14)),
                              if (r.date != null)
                                Text(
                                  "replied at: ${formatDate(r.date)}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                            ],
                          ),
                        );
                      }).toList()
                    : [const Text('No Replies')],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final TextEditingController replyController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text("Write a reply"),
                          content: TextField(
                            controller: replyController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Type your reply here...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                              ),
                              onPressed: () async {
                                final replyText = replyController.text.trim();
                                if (replyText.isEmpty) return;
                                Navigator.pop(ctx);
                                context.read<LeadCommentsCubit>().sendReplyToComment(
                                      commentId: dataItem.comments?.first.id ?? '',
                                      replyText: replyText,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply sent!')));
                                if (widget.fcmtoken != null) {
                                  context.read<NotificationCubit>().sendNotificationToToken(
                                        title: "Comment Reply",
                                        body: "تم الرد على التعليق بنجاح ✅ ${widget.leadName}",
                                        fcmtokennnn: widget.fcmtoken!,
                                      );
                                  if (widget.managerfcm != null) {
                                    context.read<NotificationCubit>().sendNotificationToToken(
                                          title: "Comment Reply",
                                          body: "تم الرد على التعليق بنجاح ✅ ${widget.leadName}",
                                          fcmtokennnn: widget.managerfcm!,
                                        );
                                  }
                                }
                                context.read<LeadCommentsCubit>().fetchLeadComments(widget.leedId);
                              },
                              child: const Text("Send", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.reply, color: Colors.white),
                  label: const Text("Reply", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
                  ),
                ),
              ),
              FutureBuilder(
                future: checkRoleName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
                  if (snapshot.hasData && snapshot.data == "Admin") {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Edit", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                        ),
                        onPressed: () {
                          final firstTextController = TextEditingController(text: firstComment?.text ?? '');
                          final secondTextController = TextEditingController(text: secondComment?.text ?? '');
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text('Edit Comment'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(controller: firstTextController, decoration: const InputDecoration(labelText: 'First Comment')),
                                    const SizedBox(height: 10),
                                    TextField(controller: secondTextController, decoration: const InputDecoration(labelText: 'Second Comment')),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).brightness == Brightness.light
                                          ? Constants.maincolor
                                          : Constants.mainDarkmodecolor,
                                    ),
                                    onPressed: () {
                                      final firstText = firstTextController.text.trim();
                                      final secondText = secondTextController.text.trim();
                                      Navigator.pop(ctx);
                                      context.read<EditCommentCubit>().editComment(
                                            commentId: dataItem.comments?.first.id ?? '',
                                            firstText: firstText,
                                            secondText: secondText,
                                          ).then((isSuccess) {
                                            if (isSuccess) {
                                              context.read<LeadCommentsCubit>().fetchLeadComments(widget.leedId);
                                              if (widget.fcmtoken != null) {
                                                context.read<NotificationCubit>().sendNotificationToToken(
                                                      title: "Lead",
                                                      body: " comment has been edited ✅ on ${widget.leadName}",
                                                      fcmtokennnn: widget.fcmtoken!,
                                                    );
                                                if (widget.managerfcm != null) {
                                                  context.read<NotificationCubit>().sendNotificationToToken(
                                                        title: "Lead",
                                                        body: " comment has been edited ✅ on ${widget.leadName}",
                                                        fcmtokennnn: widget.managerfcm!,
                                                      );
                                                }
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text(" Failed to edit comment ❌")),
                                              );
                                            }
                                          });
                                    },
                                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
