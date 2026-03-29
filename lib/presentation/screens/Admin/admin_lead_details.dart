// ignore_for_file: unused_local_variable, use_build_context_synchronously, must_be_immutable, non_constant_identifier_names, avoid_print, unnecessary_to_list_in_spreads, deprecated_member_use
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/models/leadsAdminModelWithPagination.dart';
import 'package:homewalkers_app/data/models/new_admin_users_model.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_add_comment_admin.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/assign_lead_markter_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminLeadDetails extends StatefulWidget {
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
  final String? salesfcmToken;
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
  final num? unitPrice;
  final String? unitnumber;
  final num? commissionratio;
  final num? commissionmoney;
  final num? cashbackratio;
  final num? cashbackmoney;
  final CommentDetails? lastcommentFirst;
  final CommentDetails? lastcommentNext;
  final String? linkCampaign;
  final String? campaignRedirectLink;
  final String? question1_text;
  final String? question1_answer;
  final String? question2_text;
  final String? question2_answer;
  final String? question3_text;
  final String? question3_answer;
  final String? question4_text;
  final String? question4_answer;
  final String? question5_text;
  final String? question5_answer;

  AdminLeadDetails({
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
    this.salesfcmToken,
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
    this.unitPrice,
    this.unitnumber,
    this.commissionratio,
    this.commissionmoney,
    this.cashbackratio,
    this.cashbackmoney,
    this.lastcommentFirst,
    this.lastcommentNext,
    this.linkCampaign,
    this.campaignRedirectLink,
    this.question1_text,
    this.question1_answer,
    this.question2_text,
    this.question2_answer,
    this.question3_text,
    this.question3_answer,
    this.question4_text,
    this.question4_answer,
    this.question5_text,
    this.question5_answer,
  });
  @override
  State<AdminLeadDetails> createState() => _SalesLeadsDetailsScreenState();
}

class _SalesLeadsDetailsScreenState extends State<AdminLeadDetails> {
  String userRole = '';
  @override
  void initState() {
    super.initState();
    checkRoleName();
  }

  Future<void> checkRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    log("lead commission ratio: ${widget.commissionratio}");
    setState(() {
      userRole = role;
    });
  }

  String formatDateTimeToDubai(String dateStr) {
    try {
      final utcTime = DateTime.parse(dateStr).toUtc();
      final dubaiTime = utcTime.add(const Duration(hours: 4));
      final day = dubaiTime.day.toString().padLeft(2, '0');
      final month = dubaiTime.month.toString().padLeft(2, '0');
      final year = dubaiTime.year;
      int hour = dubaiTime.hour;
      final minute = dubaiTime.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$day/$month/$year - ${hour.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (e) {
      return dateStr;
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
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primaryColor =
              isDark ? Constants.mainDarkmodecolor : Constants.maincolor;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor:
                isDark
                    ? Constants.backgroundDarkmode
                    : Constants.backgroundlightmode,
            appBar: CustomAppBar(
              title: "Lead Details",
              onBack: () => Navigator.pop(context),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hero Header Card
                      _buildHeroHeaderCard(isDark, primaryColor),
                      SizedBox(height: 10.h),
                      // Last Comment Section
                      _buildLastCommentSection(isDark, primaryColor),
                      SizedBox(height: 16.h),
                      // Action Buttons Row (All Comments & Add Comment)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStyledButton(
                              label: "All Comments",
                              icon: Icons.comment,
                              isOutlined: true,
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
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStyledButton(
                              label: "Add Comment",
                              icon: Icons.add_comment,
                              isOutlined: false,
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
                                        child: MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                              create: (_) => AddCommentCubit(),
                                            ),
                                            BlocProvider(
                                              create:
                                                  (context) =>
                                                      ChangeStageCubit(),
                                            ),
                                          ],
                                          child: CustomAddCommentAdmin(
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
                                  if (widget.salesfcmToken != null) {
                                    context
                                        .read<NotificationCubit>()
                                        .sendNotificationToToken(
                                          title: "Lead Comment",
                                          body:
                                              "${widget.leadName} تم إضافة تعليق جديد ✅",
                                          fcmtokennnn: widget.salesfcmToken!,
                                        );
                                  }
                                }
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Lead Information Section
                      _buildInfoSection(isDark, primaryColor),
                      SizedBox(height: 16.h),

                      // Notes Section
                      _buildNotesSection(isDark, primaryColor),
                      SizedBox(height: 20.h),
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

  Widget _buildHeroHeaderCard(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                  : [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name and Stage
          Column(
            children: [
              Text(
                widget.leadName ?? 'No Name',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.leadStage ?? 'No Stage',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Contact Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactChip(
                icon: Icons.phone,
                label: widget.leadPhone ?? 'No Phone',
                onTap: () => makePhoneCall("+${widget.leadPhone}"),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              SizedBox(width: 12.w),
              _buildContactChip(
                icon: Icons.email,
                label:
                    (widget.leadEmail != null &&
                            widget.leadEmail!.trim().isNotEmpty)
                        ? widget.leadEmail!
                        : 'No Email',
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // WhatsApp and Second Phone Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leadwhatsappnumber != null &&
                  widget.leadwhatsappnumber!.isNotEmpty)
                _buildActionChip(
                  icon: FontAwesomeIcons.whatsapp,
                  label: "WhatsApp",
                  onTap: () async {
                    final phone = widget.leadwhatsappnumber?.replaceAll(
                      RegExp(r'\D'),
                      '',
                    );
                    final url = "https://wa.me/$phone";
                    try {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Could not open WhatsApp."),
                        ),
                      );
                    }
                  },
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
              if (widget.leadwhatsappnumber != null &&
                  widget.leadwhatsappnumber!.isNotEmpty)
                SizedBox(width: 12.w),
              if (widget.secondphonenumber != null &&
                  widget.secondphonenumber!.isNotEmpty)
                _buildActionChip(
                  icon: Icons.phone_forwarded,
                  label: "Second Phone",
                  onTap: () => makePhoneCall("+${widget.secondphonenumber}"),
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
            ],
          ),
          SizedBox(height: 10.h),
          // Action Buttons Row (Assign Lead, Copy, Done Deal Details)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildStyledButton(
                  label: "Assign Lead",
                  icon: Icons.person_add,
                  isOutlined: true,
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder:
                          (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(create: (_) => AssignleadCubit()),
                              BlocProvider(
                                create:
                                    (_) => LeadCommentsCubit(
                                      GetAllLeadCommentsApiService(),
                                    )..fetchLeadComments(widget.leedId),
                              ),
                              BlocProvider(
                                create:
                                    (_) =>
                                        SalesCubit(GetAllSalesApiService())
                                          ..fetchAllSales(),
                              ),
                              BlocProvider(
                                create:
                                    (_) =>
                                        StagesCubit(StagesApiService())
                                          ..fetchStages(),
                              ),
                            ],
                            child: AssignLeadMarkterDialog(
                              leadIds: [widget.leedId],
                              leadId: widget.leedId,
                              leadStage: widget.leadStageId,
                              leadStages: widget.leadStages,
                              mainColor: primaryColor,
                            ),
                          ),
                    );
                  },
                  primaryColor: primaryColor,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.w),
              _buildCopyButton(isDark, primaryColor),
              if (widget.leadStage == "Done Deal" ||
                  widget.leadStage == "EOI") ...[
                SizedBox(width: 12.w),
                _buildDetailsButton(isDark, primaryColor),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12.sp),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            FaIcon(icon, size: 14.sp, color: primaryColor),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color primaryColor,
    required bool isDark,
    bool isOutlined = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: isOutlined ? Colors.transparent : primaryColor,
        side: isOutlined ? BorderSide(color: primaryColor, width: 1.5) : null,
        elevation: isOutlined ? 0 : 2,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: isOutlined ? primaryColor : Colors.white,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isOutlined ? primaryColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(bool isDark, Color primaryColor) {
    final totalSubmissions = int.tryParse(widget.totalsubmissions ?? '') ?? 0;
    return InkWell(
      onTap: () {
        if (totalSubmissions > 1) {
          showDialog(
            context: context,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20.h),
                    constraints: BoxConstraints(maxHeight: 500.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.h),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.copy, color: primaryColor),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Duplicate Leads",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children:
                                  (widget.leadversions as List<LeadVersionnn>?)
                                      ?.map((version) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 16.h),
                                          padding: EdgeInsets.all(12.h),
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.white.withOpacity(
                                                      0.05,
                                                    )
                                                    : Color(0xFFF8F9FA),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                version.name ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              SizedBox(height: 8.h),
                                              _buildMiniInfoRow(
                                                Icons.business,
                                                "Project",
                                                version.project?.name ??
                                                    'No Project',
                                              ),
                                              _buildMiniInfoRow(
                                                Icons.apartment,
                                                "Developer",
                                                version
                                                        .project
                                                        ?.developer
                                                        ?.name ??
                                                    'No Developer',
                                              ),
                                              _buildMiniInfoRow(
                                                Icons.chat,
                                                "Communication Way",
                                                version
                                                        .communicationway
                                                        ?.name ??
                                                    'No Communication Way',
                                              ),
                                              _buildMiniInfoRow(
                                                Icons.date_range,
                                                "Creation Date",
                                                version.recordedAt != null
                                                    ? formatDateTimeToDubai(
                                                      version.recordedAt!,
                                                    )
                                                    : 'No Date',
                                              ),
                                              _buildMiniInfoRow(
                                                Icons.device_hub,
                                                "Channel",
                                                version.chanel?.name ??
                                                    'No Channel',
                                              ),
                                              _buildMiniInfoRow(
                                                Icons.campaign,
                                                "Campaign",
                                                version.campaign?.campainName ??
                                                    'No Campaign',
                                              ),
                                              _buildMiniInfoRow(
                                                Icons.person,
                                                "Added By",
                                                version.addby?.name ??
                                                    'No Added By',
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList() ??
                                  [],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        } else {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: Text(
                    "No Duplicates",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  content: Text(
                    "This lead has no duplicates.",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK", style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.h),
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        child: Icon(
          Icons.content_copy_outlined,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildDetailsButton(bool isDark, Color primaryColor) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Container(
                  padding: EdgeInsets.all(20.h),
                  constraints: BoxConstraints(maxHeight: 500.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.h),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.done_all, color: primaryColor),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "${widget.leadStage} Details",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.leadName ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              _buildMiniInfoRow(
                                Icons.home,
                                "Unit Number",
                                widget.unitnumber?.toString() ?? 'N/A',
                              ),
                              _buildMiniInfoRow(
                                Icons.attach_money,
                                "Unit Price",
                                widget.unitPrice?.toString() ?? 'N/A',
                              ),
                              _buildMiniInfoRow(
                                Icons.percent,
                                "Commission Ratio",
                                "${widget.commissionratio?.toString()}%",
                              ),
                              _buildMiniInfoRow(
                                Icons.money,
                                "Commission Money",
                                widget.commissionmoney?.toString() ??
                                    'No Commission Money',
                              ),
                              _buildMiniInfoRow(
                                Icons.card_giftcard,
                                "Cashback Ratio",
                                "${widget.cashbackratio?.toString()}%",
                              ),
                              _buildMiniInfoRow(
                                Icons.money,
                                "Cashback Money",
                                widget.cashbackmoney?.toString() ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10.h),
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        child: Icon(Icons.done_all, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildInfoSection(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            Icons.info_outline,
            "Lead Information",
            primaryColor,
          ),
          SizedBox(height: 16.h),

          // Grid layout for info rows
          Wrap(
            spacing: 16.w,
            runSpacing: 12.h,
            children: [
              _buildInfoTile(
                Icons.work_outline,
                "Job Description",
                widget.jobdescription?.isNotEmpty == true
                    ? widget.jobdescription!
                    : 'No job description',
              ),
              _buildInfoTile(
                Icons.person_outline,
                "Sales Name",
                widget.leadSalesName ?? 'No Sales',
              ),
              _buildInfoTile(
                Icons.email_outlined,
                "Email",
                widget.leadEmail ?? 'No Email',
              ),
              _buildInfoTile(
                Icons.phone_outlined,
                "Phone",
                widget.leadPhone ?? 'No Phone',
              ),
              _buildInfoTile(
                Icons.business,
                "Project",
                widget.leadProject ?? 'No Project',
              ),
              _buildInfoTile(
                Icons.apartment,
                "Developer",
                widget.leaddeveloper ?? 'No Developer',
              ),
              _buildInfoTile(
                Icons.campaign,
                "Campaign",
                widget.leadcampaign ?? 'No Campaign',
              ),
              if (widget.linkCampaign != null &&
                  widget.linkCampaign!.isNotEmpty)
                _buildInfoTile(
                  Icons.link,
                  "Campaign Link",
                  widget.linkCampaign!,
                ),
              if (widget.campaignRedirectLink != null &&
                  widget.campaignRedirectLink!.isNotEmpty)
                _buildInfoTile(
                  Icons.open_in_browser,
                  "Redirect Link",
                  widget.campaignRedirectLink!,
                ),
              _buildInfoTile(
                Icons.calendar_today,
                "Creation Date",
                formatDateTimeToDubai(widget.leadCreationDate!),
              ),
              _buildInfoTile(
                Icons.wifi_tethering,
                "Channel",
                widget.leadChannel ?? 'No Channel',
              ),
              _buildInfoTile(
                Icons.format_list_numbered,
                "Total Submissions",
                widget.totalsubmissions ?? '0',
              ),
            ],
          ),

          // Questions Section
          if (_hasQuestions()) ...[
            SizedBox(height: 20.h),
            Divider(color: primaryColor.withOpacity(0.2)),
            SizedBox(height: 16.h),
            _buildSectionHeader(
              Icons.quiz,
              "Additional Questions",
              primaryColor,
            ),
            SizedBox(height: 16.h),
            ..._buildQuestionsList(primaryColor, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 32.w - 32.w) / 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Constants.maincolor),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Color(0xFF6A6A75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastCommentSection(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            Icons.chat_bubble_outline,
            "Last Comment",
            primaryColor,
          ),
          SizedBox(height: 16.h),
          _buildCommentBubble(
            title: "Comment",
            content: widget.lastcommentFirst?.text ?? 'No comment available.',
            primaryColor: primaryColor,
          ),
          SizedBox(height: 16.h),
          _buildCommentBubble(
            title: "Action Plan",
            content: widget.lastcommentNext?.text ?? 'No action available.',
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBubble({
    required String title,
    required String content,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3.w, height: 14.h, color: primaryColor),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: SelectableText(
            content,
            style: TextStyle(fontSize: 13.sp, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.note_alt, "Notes", primaryColor),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(14.h),
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              (widget.leadNotes == null || widget.leadNotes!.isEmpty)
                  ? 'No notes found'
                  : widget.leadNotes!,
              style: TextStyle(fontSize: 13.sp, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.h),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: primaryColor),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Constants.maincolor),
          SizedBox(width: 8.w),
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasQuestions() {
    return (widget.question1_text != null &&
            widget.question1_text!.isNotEmpty) ||
        (widget.question2_text != null && widget.question2_text!.isNotEmpty) ||
        (widget.question3_text != null && widget.question3_text!.isNotEmpty) ||
        (widget.question4_text != null && widget.question4_text!.isNotEmpty) ||
        (widget.question5_text != null && widget.question5_text!.isNotEmpty);
  }

  List<Widget> _buildQuestionsList(Color primaryColor, bool isDark) {
    final questions = [
      if (widget.question1_text != null && widget.question1_text!.isNotEmpty)
        _buildQuestionItem(
          widget.question1_text!,
          widget.question1_answer ?? 'No answer provided',
          primaryColor,
        ),
      if (widget.question2_text != null && widget.question2_text!.isNotEmpty)
        _buildQuestionItem(
          widget.question2_text!,
          widget.question2_answer ?? 'No answer provided',
          primaryColor,
        ),
      if (widget.question3_text != null && widget.question3_text!.isNotEmpty)
        _buildQuestionItem(
          widget.question3_text!,
          widget.question3_answer ?? 'No answer provided',
          primaryColor,
        ),
      if (widget.question4_text != null && widget.question4_text!.isNotEmpty)
        _buildQuestionItem(
          widget.question4_text!,
          widget.question4_answer ?? 'No answer provided',
          primaryColor,
        ),
      if (widget.question5_text != null && widget.question5_text!.isNotEmpty)
        _buildQuestionItem(
          widget.question5_text!,
          widget.question5_answer ?? 'No answer provided',
          primaryColor,
        ),
    ];

    return questions;
  }

  Widget _buildQuestionItem(
    String question,
    String answer,
    Color primaryColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, size: 16.sp, color: primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xFF6A6A75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Original buildInfoRow preserved for backward compatibility
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

class QuestionRow extends StatelessWidget {
  final String question;
  final String answer;

  const QuestionRow({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? Constants.mainDarkmodecolor : Constants.maincolor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline, size: 18, color: primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 26.w),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xff6A6A75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
