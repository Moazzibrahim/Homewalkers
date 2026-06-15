// marketer_lead_details_screen.dart
// ignore_for_file: unused_local_variable, use_build_context_synchronously, must_be_immutable, non_constant_identifier_names, avoid_print, unnecessary_to_list_in_spreads, deprecated_member_use, unnecessary_null_comparison
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_add_comment_sheet.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/assign_lead_markter_dialog.dart';
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
  final String? campaignlink;
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
  final List<String>? salesFcmTokens; // ✅ أضف ده

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
    this.campaignlink,
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
    this.salesFcmTokens,
  });

  @override
  State<MarketerLeadDetailsScreen> createState() =>
      _SalesLeadsDetailsScreenState();
}

class _SalesLeadsDetailsScreenState extends State<MarketerLeadDetailsScreen> {
  String userRole = '';
  bool _showMoreDetails = false;

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

  bool _hasDuplicates() {
    return widget.totalsubmissions != null &&
        (int.tryParse(widget.totalsubmissions!) ?? 0) > 1;
  }

  bool _hasQuestions() {
    return (widget.question1_text != null &&
            widget.question1_text!.isNotEmpty) ||
        (widget.question2_text != null && widget.question2_text!.isNotEmpty) ||
        (widget.question3_text != null && widget.question3_text!.isNotEmpty) ||
        (widget.question4_text != null && widget.question4_text!.isNotEmpty) ||
        (widget.question5_text != null && widget.question5_text!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? Constants.mainDarkmodecolor : Constants.maincolor;

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
                      // Hero Header Card (Admin Style)
                      _buildHeroHeaderCard(isDark, primaryColor),
                      SizedBox(height: 7.h),
                      // Lead Information Section (Admin Style)
                      _buildInfoSection(isDark, primaryColor),
                      SizedBox(height: 16.h),
                      // Last Comment Section (Admin Style)
                      _buildLastCommentSection(isDark, primaryColor),
                      SizedBox(height: 16.h),
                      // Notes Section (Admin Style)
                      _buildNotesSection(isDark, primaryColor),
                      SizedBox(height: 20.h),
                      // Action Buttons Row (Admin Style)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStyledButton(
                              label: "All Comments",
                              icon: Icons.comment,
                              isOutlined: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => SalesCommentsScreen(
                                          leedId: widget.leedId,
                                          fcmtoken: widget.salesfcmtoken,
                                          leadName: widget.leadName,
                                        ),
                                  ),
                                );
                              },
                              primaryColor: Colors.white,
                              isDark: isDark,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStyledButton(
                              label: "Add Comment",
                              icon: Icons.add_comment,
                              isOutlined: true,
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

                                  final tokens =
                                      (widget.salesFcmTokens?.isNotEmpty ==
                                              true)
                                          ? widget.salesFcmTokens!
                                          : (widget.salesfcmtoken != null
                                              ? [widget.salesfcmtoken]
                                              : <String>[]);

                                  if (tokens.isNotEmpty) {
                                    context
                                        .read<NotificationCubit>()
                                        .sendNotificationToTokens(
                                          title: "Lead Comment",
                                          body:
                                              "New Comment added on ${widget.leadName} ✅",
                                          fcmTokens: tokens,
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
                      SizedBox(height: 12.h),
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

  // ═══════════════════════════════════════════════════════════════
  // HERO HEADER CARD (Admin Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroHeaderCard(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(15.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                  : [Colors.white, Colors.white],
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
          // ================= NAME + ASSIGN =================
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.leadName ?? 'No Name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              _buildStyledButton(
                label: "Assign",
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
            ],
          ),
          SizedBox(height: 8.h),
          // ================= STAGE + ACTIONS =================
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Constants.mainlightmodecolor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.leadStage ?? 'No Stage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  if (_hasDuplicates()) _buildCopyButton(isDark, primaryColor),
                ],
              ),
            ],
          ),
          SizedBox(height: 13.h),
          // ================= CONTACT INFO =================
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildContactChip(
                icon: Icons.phone,
                label: "Call",
                onTap: () {
                  final phone = (widget.leadPhone ?? '').trim();
                  final formattedPhone =
                      phone.startsWith('+') || phone.startsWith('0')
                          ? phone
                          : '+$phone';
                  makePhoneCall(formattedPhone);
                },
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              SizedBox(width: 14.w),
              _buildContactChip(
                icon: Icons.email,
                label:
                    (widget.leadEmail != null &&
                            widget.leadEmail!.trim().isNotEmpty)
                        ? widget.leadEmail!
                        : 'No Email',
                onTap: () async {
                  final email = widget.leadEmail?.trim();

                  if (email == null || email.isEmpty) return;

                  final uri = Uri(scheme: 'mailto', path: email);

                  await launchUrl(uri);
                },
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              SizedBox(width: 14.w),
              _buildActionChip(
                icon: FontAwesomeIcons.whatsapp,
                label: "WhatsApp",
                onTap: () async {
                  final phone =
                      (widget.leadwhatsappnumber?.trim().isNotEmpty ?? false)
                          ? widget.leadwhatsappnumber!
                          : (widget.leadPhone ?? '');

                  final cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');

                  if (cleanedPhone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No phone number available."),
                      ),
                    );
                    return;
                  }

                  final url = "https://wa.me/$cleanedPhone";

                  try {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Could not open WhatsApp.")),
                    );
                  }
                },
                isDark: isDark,
                primaryColor: Colors.green,
              ),
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
    return SizedBox(
      width: 90.w,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: primaryColor),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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
    return SizedBox(
      width: 90.w,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, size: 18.sp, color: primaryColor),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(
            color: isOutlined ? Colors.white : Constants.maincolor,
          ),
        ),
        backgroundColor: isOutlined ? Constants.maincolor : primaryColor,
        side: isOutlined ? BorderSide(color: primaryColor, width: 1.5) : null,
        elevation: isOutlined ? 0 : 2,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: isOutlined ? Colors.white : Constants.maincolor,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isOutlined ? Colors.white : Constants.maincolor,
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
                                fontSize: 16.sp,
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
                                    widget.leadName ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                ...(widget.leadversions as List<dynamic>?)?.map(
                                      (version) {
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
                                                      version.recordedAt!
                                                          .toString(),
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
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList() ??
                                    [],
                              ],
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

  // ═══════════════════════════════════════════════════════════════
  // INFO SECTION (Admin Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInfoSection(bool isDark, Color primaryColor) {
    // First 4 tiles
    final basicTiles = [
      _buildInfoTile(
        Icons.phone_outlined,
        "Phone",
        widget.leadPhone ?? 'No Phone',
        showActions: true,
      ),
      if (widget.secondphonenumber != null &&
          widget.secondphonenumber!.isNotEmpty)
        _buildInfoTile(
          Icons.phone_forwarded,
          "Second Phone",
          widget.secondphonenumber ?? 'No Second Phone',
          showActions: true,
        ),

      _buildInfoTile(
        Icons.person_outline,
        "Sales Name",
        widget.leadSalesName ?? 'No Sales',
      ),
      _buildInfoTile(
        Icons.business,
        "Project",
        widget.leadProject ?? 'No Project',
      ),
    ];

    // Extra details
    final extraTiles = [
      _buildInfoTile(
        Icons.work_outline,
        "Job Description",
        widget.jobdescription?.isNotEmpty == true
            ? widget.jobdescription!
            : 'No job description',
      ),
      _buildInfoTile(
        Icons.email_outlined,
        "Email",
        widget.leadEmail ?? 'No Email',
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
      _buildInfoTile(
        Icons.wifi_tethering,
        "Channel",
        widget.leadChannel ?? 'No Channel',
      ),
      if (widget.campaignlink != null && widget.campaignlink!.isNotEmpty)
        _buildInfoTile(Icons.link, "Campaign Link", widget.campaignlink!),
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
        Icons.format_list_numbered,
        "Total Submissions",
        widget.totalsubmissions ?? '0',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "LEAD INFORMATION",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white70 : const Color(0xFF5E5E6A),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),

          /// BASIC TILES
          ...basicTiles,

          /// EXTRA DETAILS
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                _showMoreDetails
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            firstChild: const SizedBox(),
            secondChild: Column(children: extraTiles),
          ),

          SizedBox(height: 8.h),

          /// SHOW MORE
          Divider(color: Colors.grey.withOpacity(0.2)),

          InkWell(
            onTap: () {
              setState(() {
                _showMoreDetails = !_showMoreDetails;
              });
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showMoreDetails ? "SHOW LESS" : "SHOW MORE",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  AnimatedRotation(
                    turns: _showMoreDetails ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                  ),
                ],
              ),
            ),
          ),

          /// QUESTIONS SECTION
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

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    bool showActions = false,
  }) {
    final bool isLink =
        (label == "Campaign Link" || label == "Redirect Link") &&
        value.isNotEmpty;
    final String formattedPhone =
        value.startsWith('+')
            ? value
            : (value.startsWith('0') ? '+2$value' : '+$value');

    Widget tileContent = Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: Constants.maincolor, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isLink ? Constants.maincolor : null,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
          if (showActions && value.isNotEmpty) ...[
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final Uri callUri = Uri(
                      scheme: 'tel',
                      path: formattedPhone,
                    );
                    if (await canLaunchUrl(callUri)) {
                      await launchUrl(callUri);
                    }
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Color(0xffF2F4F7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.call,
                      color: Color(0xff003178),
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () async {
                    final phone = value.replaceAll(RegExp(r'\D'), '');
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
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (isLink) {
      return GestureDetector(
        onTap: () => _launchUrlWithFeedback(value, label),
        child: tileContent,
      );
    }
    return tileContent;
  }

  Future<void> _launchUrlWithFeedback(String url, String type) async {
    if (url.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $type: $url...'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Link opened successfully'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to open link: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LAST COMMENT SECTION (Admin Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLastCommentSection(bool isDark, Color primaryColor) {
    return BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
      builder: (context, state) {
        if (state is LeadCommentsLoading) {
          return Container(
            padding: EdgeInsets.all(20.h),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is LeadCommentsError) {
          return Container(
            padding: EdgeInsets.all(20.h),
            child: Center(child: Text('Error: ${state.message}')),
          );
        } else if (state is LeadCommentsLoaded) {
          final leadComments = state.leadComments;
          if (leadComments.data == null || leadComments.data!.isEmpty) {
            return _buildEmptyLastCommentSection(isDark, primaryColor);
          }

          final firstItem = leadComments.data!.first;
          final firstComment = firstItem.comments?.first;

          if (firstComment?.firstcomment?.text != null) {
            return Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "LAST ACTIVITY",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: isDark ? Colors.white70 : const Color(0xFF4A4A57),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildCommentBubble(
                    title: widget.leadStage ?? "Comment",
                    content:
                        firstComment?.firstcomment?.text ??
                        'No comment available.',
                    primaryColor: const Color(0xFF9C6B00),
                    icon: Icons.history_toggle_off,
                    isDark: isDark,
                    date: firstComment?.firstcomment?.date?.toString(),
                    userName: widget.leadSalesName,
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    "ACTION PLAN",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: isDark ? Colors.white70 : const Color(0xFF4A4A57),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildCommentBubble(
                    title: widget.leadStage ?? "Action",
                    content:
                        firstComment?.secondcomment?.text ??
                        'No action available.',
                    primaryColor: primaryColor,
                    icon: Icons.notifications_none,
                    isDark: isDark,
                    isTimeline: true,
                    date: firstComment?.secondcomment?.date?.toString(),
                    userName: widget.leadSalesName,
                  ),
                ],
              ),
            );
          }
        }
        return _buildEmptyLastCommentSection(isDark, primaryColor);
      },
    );
  }

  Widget _buildEmptyLastCommentSection(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LAST ACTIVITY",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: isDark ? Colors.white70 : const Color(0xFF4A4A57),
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: Text(
              'No comments found',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6A6A75)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBubble({
    required String title,
    required String content,
    required Color primaryColor,
    required IconData icon,
    required bool isDark,
    bool isTimeline = false,
    String? date,
    String? userName,
  }) {
    if (isTimeline) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20.sp),
              ),
              Container(
                width: 2.w,
                height: 90.h,
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                SelectableText(
                  content,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.6,
                    color: isDark ? Colors.white : const Color(0xFF2B2B2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5.w,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.r),
                  bottomLeft: Radius.circular(22.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(icon, color: primaryColor, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        if (date != null)
                          Text(
                            formatDateTimeToDubai(date),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    SelectableText(
                      content,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: primaryColor.withOpacity(0.08),
                          child: Icon(
                            Icons.person,
                            size: 14.sp,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            userName ?? 'Unknown User',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // NOTES SECTION (Admin Style)
  // ═══════════════════════════════════════════════════════════════
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
                color: const Color(0xFF6A6A75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
