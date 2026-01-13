// ignore_for_file: unused_local_variable, use_build_context_synchronously, must_be_immutable, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_add_comment_sheet.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_change_stage_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/custom_info_row_widget.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/assign_lead_markter_dialog.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketerLeadDetailsScreen extends StatefulWidget {
  final String leedId;
  final String? leadName;
  final String? leadEmail;
  final String? leadPhone;
  String? leadStage;
  final String? leadSalesName;
  List<dynamic>? leadStages;
  final String? leadStageId;
  final String? leadcampaign;
  final String? leadProject;
  final String? leadCreationDate;
  final String? leadCreationTime;
  final String? leadChannel;
  final String? leadLastComment;
  final String? leadNotes;
  final String? leaddeveloper;
  final String salesfcmtoken;
  final String? leadwhatsappnumber;
  final String? jobdescription;
  final String? secondphonenumber;
  final String? laststageupdated;
  final String? stageId;
  final String? totalsubmissions;
  final List? leadversions;
  final String? leadversionscampaign;
  final String? leadversionsproject;
  final String? leadversionsdeveloper;
  final String? leadversionschannel;
  final String? leadversionscreationdate;
  final String? leadversionscommunicationway;
  MarketerLeadDetailsScreen({
    super.key,
    required this.leedId,
    this.leadName,
    this.leadEmail,
    this.leadPhone,
    this.leadStage,
    this.leadSalesName,
    this.leadStages,
    this.leadStageId,
    this.leadcampaign,
    this.leadProject,
    this.leadCreationDate,
    this.leadCreationTime,
    this.leadChannel,
    this.leadLastComment,
    this.leadNotes,
    this.leaddeveloper,
    required this.salesfcmtoken,
    this.leadwhatsappnumber,
    this.jobdescription,
    this.secondphonenumber,
    this.laststageupdated,
    this.stageId,
    this.totalsubmissions,
    this.leadversions,
    this.leadversionscampaign,
    this.leadversionsproject,
    this.leadversionsdeveloper,
    this.leadversionschannel,
    this.leadversionscreationdate,
    this.leadversionscommunicationway,
  });
  @override
  State<MarketerLeadDetailsScreen> createState() =>
      _SalesLeadsDetailsScreenState();
}

class _SalesLeadsDetailsScreenState extends State<MarketerLeadDetailsScreen> {
  String userRole = '';
  @override
  void initState() {
    super.initState();
    checkRoleName();
  }

  Future<void> checkRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    setState(() {
      userRole = role;
    });
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
                                    overflow: TextOverflow.ellipsis,
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
                                    (widget.leadEmail != null &&
                                            widget.leadEmail!.trim().isNotEmpty)
                                        ? widget.leadEmail!
                                        : 'No Email',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            // Row 2: WhatsApp and Second Phone
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                      color: Constants.maincolor,
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
                                          (context) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                create:
                                                    (_) => AssignleadCubit(),
                                              ),
                                              BlocProvider(
                                                create:
                                                    (_) => LeadCommentsCubit(
                                                      GetAllLeadCommentsApiService(),
                                                    )..fetchLeadComments(
                                                      widget.leedId,
                                                    ),
                                              ),
                                              BlocProvider(
                                                create:
                                                    (_) => SalesCubit(
                                                      GetAllSalesApiService(),
                                                    )..fetchAllSales(),
                                              ),
                                              BlocProvider(
                                                create:
                                                    (_) => StagesCubit(
                                                      StagesApiService(),
                                                    )..fetchStages(),
                                              ),
                                            ],
                                            child: AssignLeadMarkterDialog(
                                              leadIds: [widget.leedId],
                                              leadId: widget.leedId,
                                              leadStage: widget.leadStageId,
                                              leadStages: widget.leadStages,
                                              mainColor:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                            ),
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
                                // THIS IS THE COPY BUTTON
                                InkWell(
                                  onTap: () {
                                    final totalSubmissions =
                                        int.tryParse(
                                          widget.totalsubmissions ?? '',
                                        ) ??
                                        0;
                                    if (totalSubmissions > 1) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundColor:
                                                                Theme.of(
                                                                          context,
                                                                        ).brightness ==
                                                                        Brightness
                                                                            .light
                                                                    ? Constants
                                                                        .maincolor
                                                                    : Constants
                                                                        .mainDarkmodecolor,
                                                            child: Icon(
                                                              Icons.copy,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Text(
                                                            "Show Duplicate",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.close,
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                    ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            widget.leadName ??
                                                                "",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment
                                                                .centerLeft,
                                                        child: Text(
                                                          "Lead Information :",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors
                                                                    .grey[700],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      buildInfoRow(
                                                        Icons.location_city,
                                                        "Project",
                                                        widget.leadversionsproject ??
                                                            'No Project',
                                                      ),
                                                      buildInfoRow(
                                                        Icons.settings,
                                                        "Developer",
                                                        widget.leadversionsdeveloper ??
                                                            'No Developer',
                                                      ),
                                                      buildInfoRow(
                                                        Icons.chat,
                                                        "Communication Way",
                                                        widget.leadversionscommunicationway ??
                                                            'No Communication Way',
                                                      ),
                                                      buildInfoRow(
                                                        Icons.date_range,
                                                        "Creation Date",
                                                        widget.leadversionscreationdate !=
                                                                null
                                                            ? DateTime.parse(
                                                              widget
                                                                  .leadversionscreationdate!,
                                                            ).toLocal().toString()
                                                            : 'No Date',
                                                      ),
                                                      buildInfoRow(
                                                        Icons.device_hub,
                                                        "Channel",
                                                        widget.leadversionschannel ??
                                                            'No Channel',
                                                      ),
                                                      buildInfoRow(
                                                        Icons.campaign,
                                                        "Campaign",
                                                        widget.leadversionscampaign ??
                                                            'No Campaign',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                "No Duplicates",
                                              ),
                                              content: const Text(
                                                "This lead has no duplicates.",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            ),
                                      );
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                    child: Icon(
                                      Icons.content_copy_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                // ElevatedButton(
                                //   style: ElevatedButton.styleFrom(
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(4),
                                //     ),
                                //     backgroundColor:
                                //         Theme.of(context).brightness ==
                                //                 Brightness.light
                                //             ? Color(0xffFFFFFF)
                                //             : Color(0xff080719),
                                //     side: const BorderSide(
                                //       color: Constants.maincolor,
                                //     ),
                                //     padding: EdgeInsets.symmetric(
                                //       horizontal: 16.w,
                                //       vertical: 9.h,
                                //     ),
                                //   ),
                                //   onPressed: () async {
                                //     final prefs =
                                //         await SharedPreferences.getInstance();
                                //     final String salesId =
                                //         prefs.getString('salesIdD') ?? '';
                                //     CustomChangeStageDialog.showChangeDialog(
                                //       context: context,
                                //       leadStage: widget.leadStage,
                                //       leedId: widget.leedId,
                                //       salesId: salesId,
                                //       onStageChanged: (newStage) {
                                //         setState(() {
                                //           widget.leadStage = newStage;
                                //         });
                                //       },
                                //     );
                                //   },
                                //   child: Text(
                                //     'Change stage ',
                                //     style: TextStyle(
                                //       fontSize: 15.sp,
                                //       fontWeight: FontWeight.w500,
                                //       color:
                                //           Theme.of(context).brightness ==
                                //                   Brightness.light
                                //               ? Constants.maincolor
                                //               : Constants.mainDarkmodecolor,
                                //     ),
                                //   ),
                                // ),
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
                              icon: Icons.email,
                              label: 'Email',
                              value: '${widget.leadEmail}',
                            ),
                            InfoRow(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: '${widget.leadPhone}',
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
                            InfoRow(
                              icon: Icons.list,
                              label: 'Total Submissions',
                              value: widget.totalsubmissions ?? '0',
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
                        child: BlocBuilder<
                          LeadCommentsCubit,
                          LeadCommentsState
                        >(
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
                                    firstComment?.firstcomment?.date
                                            .toString() ??
                                        "",
                                  )?.toUtc();
                              final secondcommentdate =
                                  DateTime.tryParse(
                                    firstComment?.secondcomment?.date
                                            .toString() ??
                                        "",
                                  )?.toUtc();
                              final isFirstValid = (firstcommentdate != null);
                              final isSecondValid = (secondcommentdate != null);
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
                                    SelectableText(
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
                                    SelectableText(
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
                                              (_) => LeadCommentsCubit(
                                                GetAllLeadCommentsApiService(),
                                              )..fetchLeadComments(
                                                widget.leedId,
                                              ),
                                          child: SalesCommentsScreen(
                                            leedId: widget.leedId,
                                            fcmtoken: widget.salesfcmtoken,
                                            leadName: widget.leadName,
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
                                  // تحديث التعليقات بعد الإضافة
                                  context
                                      .read<LeadCommentsCubit>()
                                      .fetchLeadComments(widget.leedId);

                                  // إرسال إشعار بعد الإضافة
                                  context
                                      .read<NotificationCubit>()
                                      .sendNotificationToToken(
                                        title: "Lead Comment",
                                        body:
                                            " ${widget.leadName} تم إضافة تعليق جديد ✅",
                                        fcmtokennnn: widget.salesfcmtoken,
                                      );

                                  debugPrint(
                                    "fcmtoken: ${widget.salesfcmtoken}",
                                  );
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
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 8),
          Text("$title : ", style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
