// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/edit_comment_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/models/newCommentsModel.dart';
import 'package:homewalkers_app/presentation/viewModels/edit_comment/cubit/edit_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesCommentsScreen extends StatefulWidget {
  final String leedId;
  final String? fcmtoken;
  final String? leadName;
  final String? managerfcm;
  final String? leadLastDateAssigned;
  final bool? hideSalesName;

  const SalesCommentsScreen({
    super.key,
    required this.leedId,
    required this.fcmtoken,
    required this.leadName,
    this.managerfcm,
    this.leadLastDateAssigned,
    this.hideSalesName,
  });

  @override
  State<SalesCommentsScreen> createState() => _SalesCommentsScreenState();
}

class _SalesCommentsScreenState extends State<SalesCommentsScreen> {
  bool isPrefsLoaded = false;
  late final LeadCommentsCubit _commentsCubit;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _commentsCubit = LeadCommentsCubit(GetAllLeadCommentsApiService());
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    userRole = prefs.getString('role');
    isPrefsLoaded = true;
    if (mounted) setState(() {});
    await _commentsCubit.fetchAllLeadData(widget.leedId);
  }

  Future<String> checkAuthName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'User';
  }

  Future<String> checkRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _commentsCubit),
        BlocProvider(create: (_) => EditCommentCubit(EditCommentApiService())),
      ],
      child: Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Constants.backgroundDarkmode,
        appBar: CustomAppBar(
          title: "comments",
          onBack: () => Navigator.pop(context),
        ),
        body: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
          builder: (context, state) {
            if (!isPrefsLoaded || state is LeadCommentsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LeadCommentsError) {
              return Center(child: Text(state.message));
            }

            if (state is NewCommentsLoaded) {
              final comments = state.newComments.comments ?? [];

              if (comments.isEmpty) {
                return const Center(child: Text('No comments found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return buildCommentCard(context, comments[index]);
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget buildCommentCard(BuildContext context, Commentt comment) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final dateFormat = DateFormat('d MMM yyyy, hh:mm a');
    final dateOnlyFormat = DateFormat('d MMM yyyy');

    final firstComment = comment.firstcomment;
    final secondComment = comment.secondcomment;
    final reply = comment.replies ?? [];
    final salesName = comment.sales?.name ?? "User";

    final firstDate = firstComment?.date?.toUtc().add(const Duration(hours: 4));
    final secondDate = secondComment?.date?.toUtc().add(
      const Duration(hours: 4),
    );

    final bool isFirstValid = firstComment?.text?.isNotEmpty ?? false;
    final bool isSecondValid = secondComment?.text?.isNotEmpty ?? false;

    String formatDate(DateTime? date) {
      if (date == null) return '';
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    final firstDateString =
        firstDate != null ? dateFormat.format(firstDate) : 'N/A';
    final secondDateString =
        secondDate != null ? dateFormat.format(secondDate) : 'N/A';
    final cardDateString =
        firstDate != null ? dateOnlyFormat.format(firstDate) : '';

    if (!isFirstValid && !isSecondValid) return const SizedBox.shrink();

    final cardBg = isLight ? const Color(0xffF0F2F5) : const Color(0xFF1E1E2C);
    final replyBg = isLight ? const Color(0xFFF2F3F5) : const Color(0xFF2A2A3A);
    final textColor = isLight ? const Color(0xFF0D0D1A) : Colors.white;
    final subColor = isLight ? Colors.grey.shade500 : Colors.grey.shade400;

    String initials(String name) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2)
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return name.isNotEmpty ? name[0].toUpperCase() : 'U';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main Card ──────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (widget.hideSalesName != true) ...[
                      // ✅
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFE8EAF6),
                        child: Text(
                          initials(salesName),
                          style: TextStyle(
                            color: Constants.maincolor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salesName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            widget.leadName ?? '',
                            style: TextStyle(color: subColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 14),

                // First Comment
                if (isFirstValid) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 3,
                          decoration: BoxDecoration(
                            color: Constants.maincolor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Comment',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Constants.maincolor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                firstComment?.text ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                firstDateString,
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Second Comment
                if (isSecondValid) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 3,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Next Plan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                secondComment?.text ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'next: $secondDateString',
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Footer: date + Edit + Reply ────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Text(
                cardDateString,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 16),

              // Edit (Admin only)
              FutureBuilder(
                future: checkRoleName(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == "Admin") {
                    return GestureDetector(
                      onTap: () {
                        final firstTextController = TextEditingController(
                          text: firstComment?.text ?? '',
                        );
                        final secondTextController = TextEditingController(
                          text: secondComment?.text ?? '',
                        );
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Edit Comment'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: firstTextController,
                                      decoration: const InputDecoration(
                                        labelText: 'First Comment',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: secondTextController,
                                      decoration: const InputDecoration(
                                        labelText: 'Second Comment',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isLight
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                    onPressed: () {
                                      final firstText =
                                          firstTextController.text.trim();
                                      final secondText =
                                          secondTextController.text.trim();
                                      final commentId = comment.id;
                                      if (commentId == null) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Unable to edit comment: missing id ❌",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.pop(ctx);
                                      context
                                          .read<EditCommentCubit>()
                                          .editComment(
                                            commentId: commentId,
                                            firstText: firstText,
                                            secondText: secondText,
                                          )
                                          .then((isSuccess) {
                                            if (isSuccess) {
                                              context
                                                  .read<LeadCommentsCubit>()
                                                  .fetchAllLeadData(
                                                    widget.leedId,
                                                  );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Failed to edit comment ❌",
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                    },
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),

              const SizedBox(width: 16),

              // Reply
              GestureDetector(
                onTap: () async {
                  final replyController = TextEditingController();
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
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
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final replyText = replyController.text.trim();
                                if (replyText.isEmpty) return;
                                final commentId = comment.id;
                                if (commentId == null) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Unable to send reply: missing comment id ❌",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(ctx);
                                await context
                                    .read<LeadCommentsCubit>()
                                    .sendReplyToComment(
                                      commentId: commentId,
                                      replyText: replyText,
                                    );
                                context
                                    .read<LeadCommentsCubit>()
                                    .fetchAllLeadData(widget.leedId);
                              },
                              child: const Text("Send"),
                            ),
                          ],
                        ),
                  );
                },
                child: Text(
                  'Reply',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Replies ────────────────────────────────────────
        if (reply.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: FutureBuilder<String>(
              future: checkAuthName(),
              builder: (context, snapshot) {
                final adminName = snapshot.data ?? 'Admin';
                return Column(
                  children:
                      reply.map((r) {
                        final replyDate = r is Map ? r['date'] : null;
                        final replyText = r is Map ? (r['text'] ?? '') : '';
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 3,
                                margin: const EdgeInsets.only(
                                  left: 3,
                                  right: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: replyBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: replyBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(
                                          0xFFDDE1F0,
                                        ),
                                        child: Text(
                                          initials(adminName),
                                          style: TextStyle(
                                            color: Constants.maincolor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              adminName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              replyText.toString(),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: textColor,
                                              ),
                                            ),
                                            if (replyDate != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                formatDate(
                                                  DateTime.tryParse(
                                                    replyDate.toString(),
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: subColor,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          )
        else
          const SizedBox(height: 16),
      ],
    );
  }
}
