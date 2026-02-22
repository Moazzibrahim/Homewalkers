// ignore_for_file: unused_local_variable, use_build_context_synchronously, must_be_immutable, avoid_print, unrelated_type_equality_checks
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_add_comment_sheet.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_info_row_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SalesLeadsDetailsScreen extends StatefulWidget {
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
  final String? fcmtoken;
  final String? teamleaderfcmtoken;
  final String? managerfcmtoken;
  final String? leadwhatsappnumber;
  final String? jobdescription;
  final String? secondphonenumber;
  final String? laststageupdated;
  final String? stageId;
  final String? leadLastDateAssigned;
  final bool? resetcreationdate;
  final bool? isleadAssigned;
  SalesLeadsDetailsScreen({
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
    this.fcmtoken,
    this.teamleaderfcmtoken,
    this.managerfcmtoken,
    this.leadwhatsappnumber,
    this.jobdescription,
    this.secondphonenumber,
    this.laststageupdated,
    this.stageId,
    this.leadLastDateAssigned,
    this.isleadAssigned,
    this.resetcreationdate,
  });
  @override
  State<SalesLeadsDetailsScreen> createState() =>
      _SalesLeadsDetailsScreenState();
}

class _SalesLeadsDetailsScreenState extends State<SalesLeadsDetailsScreen> {
  String userRole = '';
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  @override
  void initState() {
    super.initState();
    print("fcmtoken: ${widget.fcmtoken}");
    print("isleadAssigned: ${widget.isleadAssigned}");
    checkRoleName();
    checkClearHistoryTime();
    checkIsClearHistory();
  }

  Future<void> checkClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final time = prefs.getString('clear_history_time');
    final lastdateassigned = widget.leadLastDateAssigned;
    log('lastdateassigned: $lastdateassigned');
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

  Future<void> checkRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    setState(() {
      userRole = role;
    });
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
    } else {
      print('Could not launch $phoneUri');
    }
  }

  String formatDateTimeToDubai(String dateStr) {
    try {
      // Parse and ensure UTC base
      final utcTime = DateTime.parse(dateStr).toUtc();

      // Convert to Dubai timezone (UTC+4)
      final dubaiTime = utcTime.add(const Duration(hours: 4));

      // Format the output
      final day = dubaiTime.day.toString().padLeft(2, '0');
      final month = dubaiTime.month.toString().padLeft(2, '0');
      final year = dubaiTime.year;

      // Convert to 12-hour format with AM/PM
      int hour = dubaiTime.hour;
      final minute = dubaiTime.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$day/$month/$year - ${hour.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (e) {
      return dateStr; // fallback في حال كان التاريخ مش صحيح
    }
  }

  String normalizePhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.startsWith('00')) {
      cleaned = '+${cleaned.substring(2)}';
    }

    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }

    return cleaned;
  }

  bool isValidComment({
    required bool isClearHistory,
    required DateTime? firstDate,
    required String? firstText,
  }) {
    /// لو مش عامل clear history → اعرض الكل
    if (isClearHistory) return true;

    if (widget.leadLastDateAssigned == null ||
        widget.leadLastDateAssigned!.isEmpty) {
      return true;
    }

    final lastAssignedDate = DateTime.tryParse(
      widget.leadLastDateAssigned!,
    )?.toUtc().add(const Duration(hours: 4));

    if (lastAssignedDate == null) return true;

    /// ❗ اعتمد على first comment فقط
    return firstDate != null &&
        firstDate.isAfter(lastAssignedDate) &&
        (firstText?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => StagesCubit(StagesApiService())),
        BlocProvider(
          create:
              (context) => LeadCommentsCubit(GetAllLeadCommentsApiService())
                ..fetchNewComments(leadId: widget.leedId, page: 1, limit: 10),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.backgroundlightmode
                    : Constants.backgroundDarkmode,
            appBar: CustomAppBar(
              title: "Leads Details",
              onBack: () => Navigator.pop(context, widget.leadStage),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 24 : 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isTablet
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                          children: [
                            /// 🔹 Name + Stage
                            Text(
                              widget.leadName ?? '',
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),

                            Text(
                              widget.leadStage ?? '',
                              style: TextStyle(
                                color: const Color(0xff0B603B),
                                fontSize: isTablet ? 16 : 12,
                              ),
                            ),

                            SizedBox(height: isTablet ? 20 : 12),

                            /// 🔹 Contact Info
                            Wrap(
                              alignment:
                                  isTablet
                                      ? WrapAlignment.start
                                      : WrapAlignment.center,
                              runSpacing: 12,
                              spacing: 24,
                              children: [
                                /// Phone
                                if (widget.leadPhone != null &&
                                    widget.leadPhone!.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: isTablet ? 22 : 16,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Constants.maincolor
                                                : Constants.mainDarkmodecolor,
                                      ),
                                      SizedBox(width: 6),
                                      InkWell(
                                        onTap:
                                            () => makePhoneCall(
                                              "+${widget.leadPhone}",
                                            ),
                                        child: Text(
                                          widget.leadPhone!,
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                /// Email
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: isTablet ? 22 : 16,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                    SizedBox(width: 6),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: isTablet ? 350 : 160,
                                      ),
                                      child: Text(
                                        (widget.leadEmail == null ||
                                                widget.leadEmail!.isEmpty)
                                            ? 'no email'
                                            : widget.leadEmail!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isTablet ? 15 : 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                /// WhatsApp
                                if (widget.leadwhatsappnumber != null &&
                                    widget.leadwhatsappnumber!.isNotEmpty)
                                  InkWell(
                                    onTap: () async {
                                      final normalizedPhone =
                                          normalizePhoneNumber(
                                            widget.leadwhatsappnumber!,
                                          );
                                      final waPhone = normalizedPhone
                                          .replaceAll(RegExp(r'\D'), '');
                                      final url = "https://wa.me/$waPhone";
                                      await launchUrl(
                                        Uri.parse(url),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          size: isTablet ? 22 : 18,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          widget.leadwhatsappnumber!,
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                /// Second Phone
                                if (widget.secondphonenumber != null &&
                                    widget.secondphonenumber!.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: isTablet ? 22 : 16,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Constants.maincolor
                                                : Constants.mainDarkmodecolor,
                                      ),
                                      SizedBox(width: 6),
                                      InkWell(
                                        onTap:
                                            () => makePhoneCall(
                                              "+${widget.secondphonenumber}",
                                            ),
                                        child: Text(
                                          widget.secondphonenumber!,
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w), // بدل const
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            12.r,
                          ), // responsive radius
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lead Information :',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: const Color(0xff6A6A75),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            InfoRow(
                              icon: Icons.work,
                              label: 'job description',
                              value:
                                  widget.jobdescription?.isNotEmpty == true
                                      ? widget.jobdescription!
                                      : 'no job description',
                            ),
                            SizedBox(height: 6.h),
                            InfoRow(
                              icon: Icons.apartment,
                              label: 'Project',
                              value: '${widget.leadProject}',
                            ),
                            SizedBox(height: 6.h),
                            InfoRow(
                              icon: Icons.developer_board,
                              label: 'Developer',
                              value: '${widget.leaddeveloper}',
                            ),
                            SizedBox(height: 6.h),
                            InfoRow(
                              icon: Icons.campaign,
                              label: 'campaign',
                              value: '${widget.leadcampaign}',
                            ),
                            SizedBox(height: 6.h),
                            // نفس اللوجيك بدون تغيير
                            if (widget.leadCreationDate == false)
                              InfoRow(
                                icon: Icons.calendar_today,
                                label: 'Creation Date',
                                value: formatDateTimeToDubai(
                                  widget.leadCreationDate!,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: BlocBuilder<
                          LeadCommentsCubit,
                          LeadCommentsState
                        >(
                          builder: (context, state) {
                            if (state is LeadCommentsLoading) {
                              return Center(
                                child: SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(),
                                ),
                              );
                            } else if (state is LeadCommentsError) {
                              return Center(
                                child: Text(
                                  'Error: ${state.message}',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              );
                            } else if (state is NewCommentsLoaded) {
                              final newCommentsData = state.newComments;

                              if (newCommentsData.comments == null ||
                                  newCommentsData.comments!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No comments available',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                );
                              }

                              final lastComment =
                                  newCommentsData.comments!.first;

                              final firstCommentDate = DateTime.tryParse(
                                lastComment.firstcomment?.date.toString() ?? '',
                              )?.toUtc().add(const Duration(hours: 4));

                              final secondCommentDate = DateTime.tryParse(
                                lastComment.secondcomment?.date.toString() ??
                                    '',
                              )?.toUtc().add(const Duration(hours: 4));

                              print(
                                'firstCommentDate Dubai: $firstCommentDate',
                              );
                              print(
                                'secondCommentDate Dubai: $secondCommentDate',
                              );
                              print('clearHistoryDubai: $clearHistoryTimee');

                              final bool hasFirstComment =
                                  lastComment.firstcomment?.text?.isNotEmpty ??
                                  false;

                              final bool hasSecondComment =
                                  lastComment.secondcomment?.text?.isNotEmpty ??
                                  false;

                              if (!hasFirstComment && !hasSecondComment) {
                                return Center(
                                  child: Text(
                                    'No comments available',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Last Comment",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                      color: const Color(0xff6A6A75),
                                    ),
                                  ),

                                  SizedBox(height: 10.h),

                                  if (hasFirstComment) ...[
                                    Text(
                                      "Comment",
                                      style: TextStyle(
                                        color: Constants.maincolor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    SizedBox(height: 7.h),

                                    SelectableText(
                                      lastComment.firstcomment?.text ??
                                          'No comment available.',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),

                                    SizedBox(height: 7.h),
                                  ],

                                  if (hasSecondComment) ...[
                                    Text(
                                      "Action (Plan)",
                                      style: TextStyle(
                                        color: Constants.maincolor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    SizedBox(height: 7.h),

                                    SelectableText(
                                      lastComment.secondcomment?.text ??
                                          'No action available.',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'No comments available',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
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
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Constants.maincolor),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (widget.leadNotes == null ||
                                            widget.leadNotes!.isEmpty)
                                        ? 'No notes found'
                                        : widget.leadNotes!,
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = constraints.maxWidth >= 600;

                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Constants.maincolor,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 30.w : 20.w,
                                      vertical: isTablet ? 14.h : 12.h,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => BlocProvider(
                                              create:
                                                  (_) =>
                                                      LeadCommentsCubit(
                                                          GetAllLeadCommentsApiService(),
                                                        )
                                                        ..fetchLeadComments(
                                                          widget.leedId,
                                                        )
                                                        ..fetchLeadAssignedData(
                                                          widget.leedId,
                                                        ),
                                              child: SalesCommentsScreen(
                                                leedId: widget.leedId,
                                                fcmtoken: widget.fcmtoken,
                                                leadName: widget.leadName,
                                                managerfcm:
                                                    widget.managerfcmtoken,
                                                leadLastDateAssigned:
                                                    widget.leadLastDateAssigned,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'All Comments',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16.sp : 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Constants.maincolor,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 12.w),

                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 30.w : 20.w,
                                      vertical: isTablet ? 14.h : 12.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
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
                                          (_) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  MediaQuery.of(
                                                    context,
                                                  ).viewInsets.bottom,
                                            ),
                                            child: BlocProvider(
                                              create: (_) => AddCommentCubit(),
                                              child: AddCommentBottomSheet(
                                                buttonName: "add comment",
                                                optionalName: "add comment",
                                                leadId: widget.leedId,
                                                leadStage: widget.leadStage,
                                                laststageupdated:
                                                    widget.laststageupdated,
                                                stageId: widget.stageId,
                                              ),
                                            ),
                                          ),
                                    );

                                    if (result == true) {
                                      context
                                          .read<LeadCommentsCubit>()
                                          .fetchLeadComments(widget.leedId);

                                      if (widget.fcmtoken != null) {
                                        context
                                            .read<NotificationCubit>()
                                            .sendNotificationToToken(
                                              title: "Lead Comment",
                                              body:
                                                  " ${widget.leadName} تم إضافة تعليق جديد ✅",
                                              fcmtokennnn: widget.fcmtoken!,
                                            );

                                        context
                                            .read<NotificationCubit>()
                                            .sendNotificationToToken(
                                              title: "Lead Comment",
                                              body:
                                                  " ${widget.leadName} تم إضافة تعليق جديد ✅",
                                              fcmtokennnn:
                                                  widget.managerfcmtoken!,
                                            );
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Add Comment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 15.sp : 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
