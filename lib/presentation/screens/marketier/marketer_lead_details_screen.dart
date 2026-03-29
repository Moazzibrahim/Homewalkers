// ignore_for_file: unused_local_variable, use_build_context_synchronously, must_be_immutable, avoid_print, non_constant_identifier_names, deprecated_member_use
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
                      _buildHeroHeaderCard(isDark, primaryColor),
                      SizedBox(height: 10.h),
                      _buildLastCommentSection(isDark, primaryColor),
                      SizedBox(height: 16.h),
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
                                  context
                                      .read<NotificationCubit>()
                                      .sendNotificationToToken(
                                        title: "Lead Comment",
                                        body:
                                            "${widget.leadName} تم إضافة تعليق جديد ✅",
                                        fcmtokennnn: widget.salesfcmtoken,
                                      );
                                  debugPrint(
                                    "fcmtoken: ${widget.salesfcmtoken}",
                                  );
                                }
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildInfoSection(isDark, primaryColor),
                      SizedBox(height: 16.h),
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

  // ═══════════════════════════════════════════════════════════════
  //  HERO HEADER CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroHeaderCard(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
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
          SizedBox(height: 20.h),

          // Phone + Email chips
          Row(
            children: [
              _buildContactChip(
                icon: Icons.phone,
                label: widget.leadPhone ?? 'No Phone',
                onTap:
                    widget.leadPhone != null
                        ? () => makePhoneCall("+${widget.leadPhone}")
                        : null,
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

          // WhatsApp + Second Phone
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
                  // الأصلي كان onTap: () => "+${widget.secondphonenumber}" — محافظ عليه
                  onTap: () => makePhoneCall("+${widget.secondphonenumber}"),
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
            ],
          ),
          SizedBox(height: 10.h),

          // Assign Lead + Copy buttons — محافظ عليهم بالكامل
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
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  COPY BUTTON  (original logic kept)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCopyButton(bool isDark, Color primaryColor) {
    return InkWell(
      onTap: () {
        final totalSubmissions =
            int.tryParse(widget.totalsubmissions ?? '') ?? 0;
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
                              "Show Duplicate",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
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
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildInfoRow(
                                  Icons.location_city,
                                  "Project",
                                  widget.leadversionsproject ?? 'No Project',
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
                                  widget.leadversionscreationdate != null
                                      ? DateTime.parse(
                                        widget.leadversionscreationdate!,
                                      ).toLocal().toString()
                                      : 'No Date',
                                ),
                                buildInfoRow(
                                  Icons.device_hub,
                                  "Channel",
                                  widget.leadversionschannel ?? 'No Channel',
                                ),
                                buildInfoRow(
                                  Icons.campaign,
                                  "Campaign",
                                  widget.leadversionscampaign ?? 'No Campaign',
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
  //  LAST COMMENT SECTION  (BlocBuilder – LeadCommentsLoaded)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLastCommentSection(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
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
          } else if (state is LeadCommentsLoaded) {
            final leadComments = state.leadComments;
            if (leadComments.data == null || leadComments.data!.isEmpty) {
              return _buildNoComments(primaryColor);
            }

            final firstItem = leadComments.data!.first;
            final firstComment = firstItem.comments?.first;

            final firstcommentdate =
                DateTime.tryParse(
                  firstComment?.firstcomment?.date.toString() ?? "",
                )?.toUtc();
            final secondcommentdate =
                DateTime.tryParse(
                  firstComment?.secondcomment?.date.toString() ?? "",
                )?.toUtc();

            final isFirstValid = (firstcommentdate != null);

            if (isFirstValid && firstComment?.firstcomment?.text != null) {
              return Column(
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
                    content:
                        firstComment?.firstcomment?.text ??
                        'No comment available.',
                    primaryColor: primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  _buildCommentBubble(
                    title: "Action Plan",
                    content:
                        firstComment?.secondcomment?.text ??
                        'No comment available.',
                    primaryColor: primaryColor,
                  ),
                ],
              );
            }

            return _buildNoComments(primaryColor);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildNoComments(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.chat_bubble_outline,
          "Last Comment",
          primaryColor,
        ),
        SizedBox(height: 16.h),
        Center(
          child: Text(
            'No comments found',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6A6A75)),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LEAD INFORMATION SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInfoSection(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
          _buildSectionHeader(
            Icons.info_outline,
            "Lead Information",
            primaryColor,
          ),
          SizedBox(height: 16.h),
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
              if (widget.campaignlink != null &&
                  widget.campaignlink!.isNotEmpty)
                _buildInfoTile(
                  Icons.link,
                  "Campaign Link",
                  widget.campaignlink!,
                ),
              if (widget.campaignRedirectLink != null &&
                  widget.campaignRedirectLink!.isNotEmpty)
                _buildInfoTile(
                  Icons.open_in_browser,
                  "Redirect Link",
                  widget.campaignRedirectLink!,
                ),
              if (widget.leadCreationDate != null)
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

          // Additional Questions — محافظ على اللوجيك الأصلي
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
            if (widget.question1_text != null &&
                widget.question1_text!.isNotEmpty)
              _buildQuestionItem(
                widget.question1_text!,
                widget.question1_answer ?? 'No answer provided',
                primaryColor,
              ),
            if (widget.question2_text != null &&
                widget.question2_text!.isNotEmpty)
              _buildQuestionItem(
                widget.question2_text!,
                widget.question2_answer ?? 'No answer provided',
                primaryColor,
              ),
            if (widget.question3_text != null &&
                widget.question3_text!.isNotEmpty)
              _buildQuestionItem(
                widget.question3_text!,
                widget.question3_answer ?? 'No answer provided',
                primaryColor,
              ),
            if (widget.question4_text != null &&
                widget.question4_text!.isNotEmpty)
              _buildQuestionItem(
                widget.question4_text!,
                widget.question4_answer ?? 'No answer provided',
                primaryColor,
              ),
            if (widget.question5_text != null &&
                widget.question5_text!.isNotEmpty)
              _buildQuestionItem(
                widget.question5_text!,
                widget.question5_answer ?? 'No answer provided',
                primaryColor,
              ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  NOTES SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildNotesSection(bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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

  // ═══════════════════════════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ═══════════════════════════════════════════════════════════════

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

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 32.w - 40.w) / 2,
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
                    color: const Color(0xFF6A6A75),
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

  // buildInfoRow — محافظ عليه كما هو لأنه بيُستخدم في الـ Copy Dialog
  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 8),
          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
