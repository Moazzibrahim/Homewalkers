// ignore_for_file: unused_local_variable, use_build_context_synchronously, must_be_immutable, avoid_print
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

class LeadsDetailsTeamLeaderScreen extends StatefulWidget {
  final String leedId;
  final String? leadName;
  final String? leadEmail;
  final String? leadPhone;
  String? leadStage;
  final String? leadSalesName;
  final String? leadStageId;
  final String? leadcampaign;
  final String? leadProject;
  final String? leadCreationDate;
  final String? leadCreationTime;
  final String? leadChannel;
  final String? leadLastComment;
  final String? leadNotes;
  final String? leaddeveloper;
  final String? userlogname;
  final String? teamleadername;
  final String fcmtoken;
  final String? managerfcmtoken;
  final String? leadwhatsappnumber;
  final String? jobdescription;
  final String? secondphonenumber;
  final String? laststageupdated;
  final String? stageId;
  LeadsDetailsTeamLeaderScreen({
    super.key,
    required this.leedId,
    this.leadName,
    this.leadEmail,
    this.leadPhone,
    this.leadStage,
    this.leadStageId,
    this.leadSalesName,
    this.leadcampaign,
    this.leadProject,
    this.leadCreationDate,
    this.leadCreationTime,
    this.leadChannel,
    this.leadLastComment,
    this.leadNotes,
    this.leaddeveloper,
    this.userlogname,
    this.teamleadername,
    required this.fcmtoken,
    this.managerfcmtoken,
    this.leadwhatsappnumber,
    this.jobdescription,
    this.secondphonenumber,
    this.laststageupdated,
    this.stageId,
  });
  @override
  State<LeadsDetailsTeamLeaderScreen> createState() =>
      _SalesLeadsDetailsScreenState();
}

class _SalesLeadsDetailsScreenState
    extends State<LeadsDetailsTeamLeaderScreen> {
  String userRole = '';
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;

  @override
  void initState() {
    super.initState();
    print("stageupdated in details screen: ${widget.laststageupdated}");
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

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
    } else {
      print('Could not launch $phoneUri');
    }
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
        firstDate != null &&
        firstDate.isAfter(clearHistoryTime) &&
        (firstText?.isNotEmpty ?? false);
    bool secondOk =
        secondDate != null &&
        secondDate.isAfter(clearHistoryTime) &&
        (secondText?.isNotEmpty ?? false);

    return firstOk || secondOk;
  }

  @override
  Widget build(BuildContext context) {
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
            resizeToAvoidBottomInset: true,
            backgroundColor:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.backgroundlightmode
                    : Constants.backgroundDarkmode,
            appBar: CustomAppBar(
              title: "Leads Details",
              onBack: () => Navigator.pop(context),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // color: const Color(0xffF7F9FA),
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
                                InkWell(
                                  onTap:
                                      () =>
                                          makePhoneCall("+${widget.leadPhone}"),
                                  child: Text(
                                    '${widget.leadPhone}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
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
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.leadwhatsappnumber != null &&
                                    widget.leadwhatsappnumber!.isNotEmpty)
                                  InkWell(
                                    onTap: () async {
                                      final phone = widget.leadwhatsappnumber
                                          ?.replaceAll(RegExp(r'\D'), '');
                                      final url = "https://wa.me/$phone";
                                      try {
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Could not open WhatsApp.",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                          size: 18,
                                        ),
                                        SizedBox(width: 5.w),
                                        Text(
                                          "${widget.leadwhatsappnumber}",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (widget.secondphonenumber != null &&
                                    widget.secondphonenumber!.isNotEmpty) ...[
                                  SizedBox(width: 12.w),
                                  Icon(
                                    Icons.phone,
                                    size: 16,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                  ),
                                  SizedBox(width: 3.w),
                                  InkWell(
                                    onTap: () => "+${widget.secondphonenumber}",
                                    child: Text(
                                      " ${widget.secondphonenumber}",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 12.h),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     if (widget.teamleadername != null &&
                            //         widget.userlogname != null &&
                            //         widget.teamleadername == widget.userlogname)
                            //       BlocBuilder<GetLeadsCubit, GetLeadsState>(
                            //         builder: (context, state) {
                            //           return ElevatedButton(
                            //             style: ElevatedButton.styleFrom(
                            //               shape: RoundedRectangleBorder(
                            //                 borderRadius: BorderRadius.circular(
                            //                   4,
                            //                 ),
                            //               ),
                            //               backgroundColor:
                            //                   Theme.of(context).brightness ==
                            //                           Brightness.light
                            //                       ? Color(0xffFFFFFF)
                            //                       : Color(0xff080719),
                            //               side: const BorderSide(
                            //                 color: Color.fromRGBO(
                            //                   15,
                            //                   118,
                            //                   135,
                            //                   0.5,
                            //                 ),
                            //               ),
                            //               padding: EdgeInsets.symmetric(
                            //                 horizontal: 16.w,
                            //                 vertical: 9.h,
                            //               ),
                            //             ),
                            //             onPressed: () async {
                            //               final prefs =
                            //                   await SharedPreferences.getInstance();
                            //               final String salesId =
                            //                   prefs.getString('salesIdD') ?? '';
                            //               CustomChangeStageDialog.showChangeDialog(
                            //                 context: context,
                            //                 leadStage: widget.leadStage,
                            //                 leedId: widget.leedId,
                            //                 salesId: salesId,
                            //                 onStageChanged: (newStage) {
                            //                   setState(() {
                            //                     widget.leadStage = newStage;
                            //                   });
                            //                 },
                            //               );
                            //             },
                            //             child: Text(
                            //               'Change stage ',
                            //               style: TextStyle(
                            //                 fontSize: 15.sp,
                            //                 fontWeight: FontWeight.w500,
                            //                 color:
                            //                     Theme.of(context).brightness ==
                            //                             Brightness.light
                            //                         ? Constants.maincolor
                            //                         : Constants
                            //                             .mainDarkmodecolor,
                            //               ),
                            //             ),
                            //           );
                            //         },
                            //       ),
                            //     // SizedBox(width: 80.w),

                            //     // ElevatedButton(
                            //     //   style: ElevatedButton.styleFrom(
                            //     //     shape: RoundedRectangleBorder(
                            //     //       borderRadius: BorderRadius.circular(4),
                            //     //     ),
                            //     //     backgroundColor:
                            //     //         Theme.of(context).brightness ==
                            //     //                 Brightness.light
                            //     //             ? Color(0xffFFFFFF)
                            //     //             : Color(0xff080719),
                            //     //     side: const BorderSide(
                            //     //       color: Constants.maincolor,
                            //     //     ),
                            //     //     padding: EdgeInsets.symmetric(
                            //     //       horizontal: 16.w,
                            //     //       vertical: 9.h,
                            //     //     ),
                            //     //   ),
                            //     //   onPressed: () async {
                            //     //     final prefs =
                            //     //         await SharedPreferences.getInstance();
                            //     //     final String salesId =
                            //     //         prefs.getString('salesIdD') ?? '';
                            //     //     CustomChangeStageDialog.showChangeDialog(
                            //     //       context: context,
                            //     //       leadStage: widget.leadStage,
                            //     //       leedId: widget.leedId,
                            //     //       salesId: salesId,
                            //     //       onStageChanged: (newStage) {
                            //     //         setState(() {
                            //     //           widget.leadStage = newStage;
                            //     //         });
                            //     //       },
                            //     //     );
                            //     //   },
                            //     //   child: Text(
                            //     //     'Change stage ',
                            //     //     style: TextStyle(
                            //     //       fontSize: 15.sp,
                            //     //       fontWeight: FontWeight.w500,
                            //     //       color:
                            //     //           Theme.of(context).brightness ==
                            //     //                   Brightness.light
                            //     //               ? Constants.maincolor
                            //     //               : Constants.mainDarkmodecolor,
                            //     //     ),
                            //     //   ),
                            //     // ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // color: const Color(0xffF7F9FA),
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
                              icon: Icons.work,
                              label: 'job description',
                              value:
                                  widget.jobdescription?.isNotEmpty == true
                                      ? widget.jobdescription!
                                      : 'no job description',
                            ),
                            InfoRow(
                              icon: Icons.person,
                              label: 'Sales Name',
                              value: '${widget.leadSalesName}',
                            ),
                            InfoRow(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: '${widget.leadPhone}',
                            ),
                            InfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: '${widget.leadEmail}',
                            ),
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
                              value: formatDateTimeToDubai(
                                widget.leadCreationDate!,
                              ),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: BlocBuilder<
                          LeadCommentsCubit,
                          LeadCommentsState>(
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
                                return const Center(
                                  child: Text('No comments found'),
                                );
                              }

                              final lastItem =
                                  leadComments.data!.first; // آخر كومنت
                              final lastComment = lastItem.comments?.first;

                              // تحويل التواريخ لتوقيت دبي (UTC+4)

                              final firstCommentDate = DateTime.tryParse(
                                lastComment?.firstcomment?.date.toString() ??
                                    '',
                              )?.toUtc().add(const Duration(hours: 4));
                              final secondCommentDate = DateTime.tryParse(
                                lastComment?.secondcomment?.date.toString() ??
                                    '',
                              )?.toUtc().add(const Duration(hours: 4));

                              print(
                                'firstCommentDate Dubai: $firstCommentDate',
                              );
                              print(
                                'secondCommentDate Dubai: $secondCommentDate',
                              );
                              print('clearHistoryDubai: $clearHistoryTimee');
                              // استخدام دالة isValidComment على آخر تعليق
                              final showLastComment = isValidComment(
                                isClearHistory: isClearHistoryy ?? false,
                                clearHistoryTime: clearHistoryTimee,
                                firstDate: firstCommentDate,
                                secondDate: secondCommentDate,
                                firstText: lastComment?.firstcomment?.text,
                                secondText: lastComment?.secondcomment?.text,
                              );

                              if (showLastComment) {
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
                                    if (lastComment
                                            ?.firstcomment
                                            ?.text
                                            ?.isNotEmpty ??
                                        false) ...[
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
                                        lastComment?.firstcomment?.text ??
                                            'No comment available.',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 7.h),
                                    ],
                                    if (lastComment
                                            ?.secondcomment
                                            ?.text
                                            ?.isNotEmpty ??
                                        false) ...[
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
                                        lastComment?.secondcomment?.text ??
                                            'No comment available.',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: Text('No comments found'),
                                );
                              }
                            } else {
                              return const SizedBox(); // أو Placeholder
                            }
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // color: const Color(0xffF7F9FA),
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
                                border: Border.all(color: Constants.maincolor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (widget.leadNotes == null ||
                                            widget.leadNotes!.isEmpty)
                                        ? 'No notes found'
                                        : widget.leadNotes!,
                                  ),
                                ],
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
                                side: const BorderSide(
                                  color: Constants.maincolor,
                                ),
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
                                            managerfcm: widget.managerfcmtoken,
                                          ),
                                        ),
                                  ),
                                );
                              },
                              child: Text(
                                'All Comments',
                                style: TextStyle(
                                  fontSize: 16.sp,
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
                                // ✅ فتح الـBottomSheet مباشرة بدون أي دايالوج
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
                                  // ✅ تحديث التعليقات بعد الإضافة
                                  context
                                      .read<LeadCommentsCubit>()
                                      .fetchLeadComments(widget.leedId);
                                  // ✅ إرسال الإشعارات بعد الإضافة
                                  context
                                      .read<NotificationCubit>()
                                      .sendNotificationToToken(
                                        title: "Lead Comment",
                                        body:
                                            " ${widget.leadName} تم إضافة تعليق جديد ✅",
                                        fcmtokennnn: widget.fcmtoken,
                                      );
                                  context
                                      .read<NotificationCubit>()
                                      .sendNotificationToToken(
                                        title: "Lead Comment",
                                        body:
                                            " ${widget.leadName} تم إضافة تعليق جديد ✅",
                                        fcmtokennnn: widget.managerfcmtoken!,
                                      );
                                }
                              },
                              child: Text(
                                'Add Comment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
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
            ),
          );
        },
      ),
    );
  }
}
