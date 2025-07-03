// ignore_for_file: unused_local_variable, use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_add_comment_admin.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_change_stage_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_info_row_widget.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/assign_lead_markter_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLeadDetails extends StatefulWidget {
  final String leedId;
  final String? leadName;
  final String? leadEmail;
  final String? leadPhone;
  String? leadStage;
  final String? leadStageId;
  final String? leadcampaign;
  final String? leadProject;
  final String? leadCreationDate;
  final String? leadCreationTime;
  final String? leadChannel;
  final String? leadLastComment;
  final String? leadNotes;
  final String? leaddeveloper;
  final String? salesfcmToken;
  AdminLeadDetails({
    super.key,
    required this.leedId,
    this.leadName,
    this.leadEmail,
    this.leadPhone,
    this.leadStage,
    this.leadStageId,
    this.leadcampaign,
    this.leadProject,
    this.leadCreationDate,
    this.leadCreationTime,
    this.leadChannel,
    this.leadLastComment,
    this.leadNotes,
    this.leaddeveloper,
    this.salesfcmToken,
  });
  @override
  State<AdminLeadDetails> createState() => _SalesLeadsDetailsScreenState();
}

class _SalesLeadsDetailsScreenState extends State<AdminLeadDetails> {
  String userRole = '';
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  @override
  void initState() {
    super.initState();
    checkRoleName();
    checkClearHistoryTime();
    checkIsClearHistory();
  }

  Future<void> checkRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    setState(() {
      userRole = role;
    });
  }

  Future<void> checkClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final time = prefs.getString('clear_history_time');
    if (time != null) {
      setState(() {
        clearHistoryTimee = DateTime.tryParse(time);
      });
      debugPrint('آخر مرة تم فيها الضغط على Clear History: $time');
    }
  }

  Future<void> checkIsClearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final iscleared = prefs.getBool('clearHistory');
    if (mounted) {
      setState(() {
        isClearHistoryy = iscleared;
      });
    }
    debugPrint('Clear History: $iscleared');
  }

  @override
  Widget build(BuildContext context) {
    // Use MultiBlocProvider to provide all necessary cubits at the top level of this screen.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => StagesCubit(StagesApiService())),
        BlocProvider(
          create:
              (context) =>
                  LeadCommentsCubit(GetAllLeadCommentsApiService())
                    ..fetchLeadComments(widget.leedId),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: "Leads Details",
              onBack: () => Navigator.pop(context),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${widget.leadName}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${widget.leadStage}',
                            style: TextStyle(color: Color(0xff0B603B)),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                size: 16,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${widget.leadPhone}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 13.w),
                              Icon(
                                Icons.email,
                                size: 16,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                              ),
                              SizedBox(width: 3.w),
                              Flexible(
                                child: Text(
                                  '${widget.leadEmail}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Color(0xffFFFFFF)
                                          : Color(0xff080719),
                                  side: const BorderSide(
                                    color: Color.fromRGBO(15, 118, 135, 0.5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 9.h,
                                  ),
                                ),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder:
                                        (context) => AssignLeadMarkterDialog(
                                          leadIds: [widget.leedId],
                                          leadId: widget.leedId,
                                          salesfcmtoken: widget.salesfcmToken!,
                                          mainColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                        ),
                                  );
                                },
                                child: Text(
                                  'Assign Lead',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 22.w),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Color(0xffFFFFFF)
                                          : Color(0xff080719),
                                  side: const BorderSide(
                                    color: Color.fromRGBO(15, 118, 135, 0.5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 9.h,
                                  ),
                                ),
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final String salesId =
                                      prefs.getString('salesIdD') ?? '';
                                  CustomChangeStageDialog.showChangeDialog(
                                    context: context,
                                    leadStage: widget.leadStage,
                                    leedId: widget.leedId,
                                    salesId: salesId,
                                    onStageChanged: (newStage) {
                                      setState(() {
                                        widget.leadStage = newStage;
                                      });
                                    },
                                  );
                                },
                                child: Text(
                                  'Change stage ',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lead Information :',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: Color(0xff6A6A75),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          InfoRow(
                            icon: Icons.apartment,
                            label: 'Project',
                            value: '${widget.leadProject}',
                          ),
                          InfoRow(
                            icon: Icons.developer_board,
                            label: 'Developer',
                            value: '${widget.leaddeveloper}',
                          ),
                          InfoRow(
                            icon: Icons.campaign,
                            label: 'campaign',
                            value: '${widget.leadcampaign}',
                          ),
                          InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Creation Date',
                            value: '${widget.leadCreationDate}',
                          ),
                          InfoRow(
                            icon: Icons.link,
                            label: 'Channel',
                            value: '${widget.leadChannel}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // This container no longer needs its own BlocProvider.
                    // It uses the one from MultiBlocProvider.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
                        builder: (context, state) {
                          if (state is LeadCommentsLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is LeadCommentsError) {
                            return Center(
                              child: Text('Error: ${state.message}'),
                            );
                          } else if (state is LeadCommentsLoaded) {
                            final leadComments = state.leadComments;
                            if (leadComments.data == null ||
                                leadComments.data!.isEmpty) {
                              return Center(child: Text('No comments found'));
                            }
                            final firstItem = leadComments.data!.first;
                            final firstComment = firstItem.comments?.first;
                            final firstcommentdate =
                                DateTime.tryParse(
                                  firstComment?.firstcomment?.date.toString() ??
                                      "",
                                )?.toUtc();
                            final secondcommentdate =
                                DateTime.tryParse(
                                  firstComment?.secondcomment?.date
                                          .toString() ??
                                      "",
                                )?.toUtc();
                            final isFirstValid =
                                isClearHistoryy != true ||
                                (firstcommentdate != null &&
                                    firstcommentdate.isAfter(
                                      clearHistoryTimee!,
                                    ));
                            final isSecondValid =
                                isClearHistoryy != true ||
                                (secondcommentdate != null &&
                                    secondcommentdate.isAfter(
                                      clearHistoryTimee!,
                                    ));
                            if ((isFirstValid &&
                                firstComment?.firstcomment?.text != null)) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Last Comment",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                      color: Color(0xff6A6A75),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    "Comment",
                                    style: TextStyle(
                                      color: Constants.maincolor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 7.h),
                                  Text(
                                    firstComment?.firstcomment?.text ??
                                        'No comment available.',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 7.h),
                                  Text(
                                    "Action (Plan)",
                                    style: TextStyle(
                                      color: Constants.maincolor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 7.h),
                                  Text(
                                    firstComment?.secondcomment?.text ??
                                        'No comment available.',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Center(child: Text('No comments found'));
                          } else {
                            return SizedBox(); // Or a Placeholder
                          }
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromRGBO(15, 118, 135, 0.5),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text('${widget.leadNotes}')],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xff2C6975)),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SalesCommentsScreen(
                                        leedId: widget.leedId,
                                        fcmtoken: widget.salesfcmToken,
                                        leadName: widget.leadName,
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              'All Comments',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff326677),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            onPressed: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (_) => BlocProvider(
                                      create: (_) => AddCommentCubit(),
                                      child: CustomAddCommentAdmin(
                                        buttonName: "add comment",
                                        optionalName: "add comment",
                                        leadId: widget.leedId,
                                      ),
                                    ),
                              );
                              if (result == true) {
                                context
                                    .read<LeadCommentsCubit>()
                                    .fetchLeadComments(widget.leedId);
                                // ✅ إرسال إشعار بعد الإضافة
                                if (widget.salesfcmToken != null) {
                                  context
                                      .read<NotificationCubit>()
                                      .sendNotificationToToken(
                                        title: "Lead Comment",
                                        body: " ${widget.leadName} تم إضافة تعليق جديد ✅",
                                        fcmtokennnn:
                                            widget.salesfcmToken!, // تأكد إن الاسم متطابق مع `NotificationCubit`
                                      );
                                }
                              }
                            },
                            child: Text(
                              'Add Comment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
