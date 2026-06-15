// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, library_private_types_in_public_api
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/campaign_api_service.dart';
import 'package:homewalkers_app/data/data_sources/communication_way_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/manager_new/manager_leads_pagiantion_model.dart';
import 'package:homewalkers_app/presentation/screens/manager/leads_details_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_dashboard_data_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/manager/assign_lead_dialog_manager.dart';
import 'package:homewalkers_app/presentation/widgets/manager/manager_custom_filter_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/edit_lead_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManagerLeadsScreen extends StatefulWidget {
  final String? stageName;
  final bool showDuplicatesOnly;
  final bool shouldRefreshOnOpen;
  final bool? data;
  final String? salesId;
  final List<String>? salesIds;
  const ManagerLeadsScreen({
    super.key,
    this.stageName,
    this.showDuplicatesOnly = false,
    this.shouldRefreshOnOpen = false,
    this.data,
    this.salesId,
    this.salesIds,
  });

  @override
  State<ManagerLeadsScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<ManagerLeadsScreen> {
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  String? managername;
  String? managerid;
  bool isLoading = false;

  final String selectedSalesId = '';
  String? _selectedSalesFcmToken;
  bool _showCheckboxes = false;
  List<LeadData> selectedLeadsData = [];
  bool isSelectionMode = false;
  List<bool> selected = [];
  final Set<String> _selectedSalesIds = {};
  final Set<String> _selectedLeadStagesIds = {};
  final Set<String> _selectedLeads = {};
  Set<int> selectedLeadIds = {};
  late GetManagerLeadsCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;
  final FocusNode _searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  late ResponsiveSalesValues _responsive;
  Timer? _debounce;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    checkClearHistoryTime();
    checkIsClearHistory();
    init();
    searchController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit = context.read<GetManagerLeadsCubit>();
      _cubit.getManagerLeadsPagination(
        data: widget.data ?? false,
        stageIds: [widget.stageName ?? ''],
        ignoreDuplicate: widget.showDuplicatesOnly,
        salesIds:
            widget.salesIds ??
            (widget.salesId != null ? [widget.salesId!] : null),
      );
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore) {
        setState(() => _isFetchingMore = true);
        context
            .read<GetManagerLeadsCubit>()
            .loadMoreManagerLeads(data: widget.data ?? false)
            .then((_) {
              if (mounted) setState(() => _isFetchingMore = false);
            });
      }
    }
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      managername = prefs.getString('name');
      managerid = prefs.getString('salesId');
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

  bool get isTablet {
    final data = MediaQuery.of(context);
    final physicalSize = data.size;
    final diagonal = math.sqrt(
      math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160);
    return inches >= 7.0;
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

  // ─────────────────────────────────────────────
  // NEW CARD DESIGN (matches the screenshot)
  // ─────────────────────────────────────────────
  Widget _buildLeadCard({
    required LeadManager lead,
    required BuildContext parentContext,
  }) {
    final String leadStagetype = lead.stage?.name ?? "";
    final String? leadstageupdated = lead.stagedateupdated;

    // ── Outdated logic ──
    DateTime? stageUpdatedDate;
    bool isOutdated = false;
    if (leadstageupdated != null) {
      try {
        stageUpdatedDate = DateTime.parse(leadstageupdated);
        final now = DateTime.now().toUtc();
        final diff = now.difference(stageUpdatedDate).inMinutes;
        isOutdated = diff > 1;
      } catch (_) {
        stageUpdatedDate = null;
      }
    }

    // ── Left bar color (same logic as TeamLeader) ──
    Color leftBarColor;
    if (leadStagetype == "Not Interested" || leadStagetype == "Transfer") {
      leftBarColor = Colors.black;
    } else if ((leadStagetype == "Follow Up" ||
            leadStagetype == "Follow" ||
            leadStagetype == "Follow After Meeting" ||
            leadStagetype == "No Answer" ||
            leadStagetype == "No Stage" ||
            leadStagetype == "Meeting" ||
            leadStagetype == "Interested") &&
        isOutdated) {
      leftBarColor = Colors.orangeAccent;
    } else {
      leftBarColor = Constants.maincolor;
    }

    // ── Stage badge color ──
    final bool isFinalStage =
        stageUpdatedDate != null &&
        (leadStagetype == "Done Deal" ||
            leadStagetype == "Fresh" ||
            leadStagetype == "EOI" ||
            leadStagetype == "Cancel Meeting" ||
            leadStagetype == "Pending");

    Color stageColor;
    if (leadStagetype == "Not Interested" || leadStagetype == "Transfer") {
      stageColor = Colors.black;
    } else {
      stageColor =
          isFinalStage
              ? Constants.maincolor
              : isOutdated
              ? const Color(0xffFEB300)
              : Constants.maincolor;
    }

    final bool isOutdatedStage =
        (leadStagetype == "Follow Up" ||
            leadStagetype == "Follow After Meeting" ||
            leadStagetype == "Follow" ||
            leadStagetype == "Meeting" ||
            leadStagetype == "No Stage" ||
            leadStagetype == "No Answer" ||
            leadStagetype == "Interested") &&
        isOutdated;

    final bool isSelected = _selectedLeads.contains(lead.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showCheckboxes = true;
          _selectedLeads.add(lead.id!);
          _selectedLeadStagesIds.add(lead.stage?.id ?? '');
        });
      },
      onTap: () async {
        if (_showCheckboxes) {
          setState(() {
            if (_selectedLeads.contains(lead.id)) {
              _selectedLeads.remove(lead.id);
            } else {
              _selectedLeads.add(lead.id!);
            }
          });
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BlocProvider(
                  create:
                      (_) => LeadCommentsCubit(GetAllLeadCommentsApiService()),
                  child: LeadsDetailsManagerScreen(
                    leedId: lead.id!,
                    leadName: lead.name ?? '',
                    leadPhone: lead.phone ?? '',
                    leadEmail: lead.email ?? '',
                    leadStage: lead.stage?.name ?? '',
                    leadStageId: lead.stage?.id ?? '',
                    leadChannel: lead.chanel?.name ?? '',
                    leadCreationDate:
                        lead.createdAt != null
                            ? formatDateTimeToDubai(lead.createdAt!)
                            : '',
                    leadProject: lead.project?.name ?? '',
                    leadLastComment: lead.lastcommentdate ?? '',
                    leadcampaign: lead.campaign?.campainName ?? "campaign",
                    leaddeveloper:
                        lead.project?.developer?.name ?? "no developer",
                    fcmtoken: lead.sales?.userlog?.fcmToken ?? '',
                    leadwhatsappnumber: lead.whatsappnumber,
                    jobdescription: lead.jobdescription ?? 'no job description',
                    secondphonenumber: lead.phonenumber2,
                    laststageupdated: leadstageupdated,
                    stageId: lead.stage?.id ?? '',
                    leadSalesName: lead.sales?.name ?? '',
                    leadLastDateAssigned: lead.lastdateassign,
                    question1_text: lead.question1_text,
                    question1_answer: lead.question1_answer,
                    question2_text: lead.question2_text,
                    question2_answer: lead.question2_answer,
                    question3_text: lead.question3_text,
                    question3_answer: lead.question3_answer,
                    question4_text: lead.question4_text,
                    question4_answer: lead.question4_answer,
                    question5_text: lead.question5_text,
                    question5_answer: lead.question5_answer,
                    salesFcmTokens:
                        lead.sales?.userlog?.fcmTokens
                            ?.map((e) => e.token ?? '')
                            .where((t) => t.isNotEmpty)
                            .toList(),
                  ),
                ),
          ),
        );
        context.read<GetManagerLeadsCubit>().getManagerLeadsPagination(
          data: widget.data ?? false,
          stageIds: [widget.stageName ?? ''],
          ignoreDuplicate: widget.showDuplicatesOnly,
          salesIds: widget.salesIds,
        );
      },
      // borderRadius: BorderRadius.circular(22.r),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Constants.maincolor.withOpacity(0.08)
                  : isDark
                  ? const Color(0xff111827)
                  : Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ── LEFT COLOR BAR ──
              Container(
                width: 5.w,
                decoration: BoxDecoration(
                  color: leftBarColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22.r),
                    bottomLeft: Radius.circular(22.r),
                  ),
                ),
              ),

              // ── CARD CONTENT ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 22.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── TOP ROW: stage badge + date + checkbox ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                // CHECKBOX
                                if (_showCheckboxes &&
                                    _selectedLeads.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(right: 8.w),
                                    child: Checkbox(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      activeColor: Constants.maincolor,
                                      value: isSelected,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          5.r,
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedLeads.add(lead.id!);
                                            _selectedSalesIds.add(
                                              lead.sales?.id ?? '',
                                            );
                                            _selectedLeadStagesIds.add(
                                              lead.stage?.id ?? '',
                                            );
                                          } else {
                                            _selectedLeads.remove(lead.id);
                                            _selectedSalesIds.remove(
                                              lead.sales?.id ?? '',
                                            );
                                            _selectedLeadStagesIds.remove(
                                              lead.stage?.id ?? '',
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                // STAGE BADGE
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 7.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isOutdatedStage
                                              ? stageColor
                                              : stageColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Text(
                                      ((lead.stage?.name ?? "No Stage").length >
                                              10)
                                          ? "${(lead.stage?.name ?? "No Stage").substring(0, 10).toUpperCase()}..."
                                          : (lead.stage?.name ?? "No Stage")
                                              .toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color:
                                            isOutdatedStage
                                                ? const Color(0xff6A4800)
                                                : stageColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // STAGE DATE
                          Text(
                            lead.stagedateupdated != null
                                ? formatDateTimeToDubai(lead.stagedateupdated!)
                                : "N/A",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // ── LEAD NAME ──
                      Text(
                        lead.name ?? "No Name",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xff111827),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // ── PROJECT NAME ──
                      Text(
                        (lead.project?.name ?? "").toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Constants.maincolor,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── SALESMAN + CREATED DATE ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SALESMAN",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  lead.sales?.name ?? "None",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xff111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          if (lead.resetcreationdate == false)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "CREATED",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  lead.date != null
                                      ? formatDateTimeToDubai(lead.date!)
                                      : "N/A",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xff111827),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      SizedBox(height: 10.h),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      SizedBox(height: 10.h),

                      // ── PHONE + ACTION BUTTONS ──
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                final phone = lead.phone ?? '';
                                String formatted;
                                if (phone.startsWith('+')) {
                                  // إذا كان الرقم يبدأ بـ + بالفعل، استخدمه كما هو
                                  formatted = phone;
                                } else if (phone.startsWith('0')) {
                                  // إذا كان يبدأ بـ 0، استخدمه كما هو
                                  formatted = phone;
                                } else {
                                  // إذا لم يبدأ بـ 0 أو +، أضف +
                                  formatted = '+$phone';
                                }
                                makePhoneCall(formatted);
                              },
                              child: Text(
                                lead.phone ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : const Color(0xff111827),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // 📞 Phone button
                              InkWell(
                                onTap: () {
                                  final phone = lead.phone ?? '';
                                  String formatted;
                                  if (phone.startsWith('+')) {
                                    // إذا كان الرقم يبدأ بـ + بالفعل، استخدمه كما هو
                                    formatted = phone;
                                  } else if (phone.startsWith('0')) {
                                    // إذا كان يبدأ بـ 0، استخدمه كما هو
                                    formatted = phone;
                                  } else {
                                    // إذا لم يبدأ بـ 0 أو +، أضف +
                                    formatted = '+$phone';
                                  }
                                  makePhoneCall(formatted);
                                },
                                borderRadius: BorderRadius.circular(40.r),
                                child: Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.phone_in_talk_outlined,
                                    color: Constants.maincolor,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              // 💬 WhatsApp button
                              InkWell(
                                onTap: () async {
                                  final rawPhone =
                                      (lead.phone?.isNotEmpty == true
                                              ? lead.phone
                                              : lead.whatsappnumber)
                                          ?.replaceAll(RegExp(r'\D'), '') ??
                                      '';
                                  final formatted =
                                      rawPhone.startsWith('0')
                                          ? rawPhone
                                          : '+$rawPhone';
                                  final url = "https://wa.me/$formatted";
                                  try {
                                    await launchUrl(
                                      Uri.parse(url),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Could not open WhatsApp.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(40.r),
                                child: Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xffDCFCE7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.green,
                                      size: 22.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),

                              // 💬 COMMENT ICON ✅
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: BlocProvider(
                                            create:
                                                (_) => LeadCommentsCubit(
                                                  GetAllLeadCommentsApiService(),
                                                )..fetchLeadComments(lead.id!),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: BlocBuilder<
                                                LeadCommentsCubit,
                                                LeadCommentsState
                                              >(
                                                builder: (
                                                  context,
                                                  commentState,
                                                ) {
                                                  if (commentState
                                                      is LeadCommentsLoading) {
                                                    return const CommentShimmer();
                                                  } else if (commentState
                                                      is LeadCommentsError) {
                                                    return SizedBox(
                                                      height: 100,
                                                      child: Center(
                                                        child: Text(
                                                          "No comments available.",
                                                        ),
                                                      ),
                                                    );
                                                  } else if (commentState
                                                      is LeadCommentsLoaded) {
                                                    final commentsData =
                                                        commentState
                                                            .leadComments
                                                            .data;
                                                    if (commentsData == null ||
                                                        commentsData.isEmpty) {
                                                      return const Text(
                                                        'No comments available.',
                                                      );
                                                    }
                                                    final commentsList =
                                                        commentsData
                                                            .first
                                                            .comments ??
                                                        [];
                                                    final validComments =
                                                        commentsList
                                                            .where(
                                                              (c) =>
                                                                  (c
                                                                          .firstcomment
                                                                          ?.text
                                                                          ?.isNotEmpty ??
                                                                      false) ||
                                                                  (c
                                                                          .secondcomment
                                                                          ?.text
                                                                          ?.isNotEmpty ??
                                                                      false),
                                                            )
                                                            .toList();
                                                    final firstEntry =
                                                        validComments.isNotEmpty
                                                            ? validComments
                                                                .first
                                                            : null;
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Last Comment",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          firstEntry
                                                                  ?.firstcomment
                                                                  ?.text ??
                                                              'No comments available.',
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Text(
                                                          "Action (Plan)",
                                                          style: TextStyle(
                                                            color:
                                                                Constants
                                                                    .maincolor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          firstEntry
                                                                  ?.secondcomment
                                                                  ?.text ??
                                                              'No action available.',
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                  return const SizedBox(
                                                    height: 100,
                                                    child: Text("No comments"),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(40.r),
                                child: Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: Constants.maincolor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.comment_outlined,
                                    color: Constants.maincolor,
                                    size: 20.sp,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _responsive = ResponsiveSalesValues.fromContext(context);

    Widget buildAssignButtons() {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // إذا كانت الشيكات غير ظاهرة أو مفيش حاجة مختارة
      if (!_showCheckboxes || _selectedLeads.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: _responsive.cardMarginHorizontal.w,
          vertical: 8.h,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// CHECK ICON
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Constants.maincolor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.check, color: Colors.white, size: 22.sp),
            ),

            SizedBox(width: 14.w),

            /// SELECTED TEXT - ديناميكي
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_selectedLeads.length} ${_selectedLeads.length == 1 ? 'Lead' : 'Leads'}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  "Selected",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),

            SizedBox(width: 15.w),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// DIVIDER
                  Container(
                    height: 50.h,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),

                  // =========================
                  // ASSIGN
                  // =========================
                  InkWell(
                    onTap: () async {
                      if (_selectedLeads.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least one lead"),
                          ),
                        );
                        return;
                      }
                      final result = await showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(create: (_) => AssignleadCubit()),
                              BlocProvider(
                                create:
                                    (_) => LeadCommentsCubit(
                                      GetAllLeadCommentsApiService(),
                                    )..fetchLeadComments(
                                      _selectedLeads.toList()[0],
                                    ),
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
                            child: AssignLeadDialogManager(
                              mainColor:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                              leadIds: _selectedLeads.toList(),
                              leadId: _selectedLeads.toList()[0],
                              fcmtoken: _selectedSalesFcmToken ?? '',
                              onAssignSuccess: () async {
                                setState(() {
                                  selected.clear();
                                  selectedLeadsData.clear();
                                  _showCheckboxes = false;
                                  _selectedLeads.clear();
                                  _selectedSalesIds.clear();
                                  _selectedLeadStagesIds.clear();
                                });
                                await _cubit.getManagerLeadsPagination(
                                  data: widget.data ?? false,
                                  stageIds: [widget.stageName ?? ''],
                                  ignoreDuplicate: widget.showDuplicatesOnly,
                                  salesIds:
                                      widget.salesIds ??
                                      (widget.salesId != null
                                          ? [widget.salesId!]
                                          : null),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Lead assigned successfully! ✅",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                      if (result == true) {
                        context
                            .read<GetManagerLeadsCubit>()
                            .getManagerLeadsPagination(
                              data: widget.data ?? false,
                              stageIds: [widget.stageName ?? ''],
                              ignoreDuplicate: widget.showDuplicatesOnly,
                              salesIds:
                                  widget.salesIds ??
                                  (widget.salesId != null
                                      ? [widget.salesId!]
                                      : null),
                            );
                        setState(() {
                          _showCheckboxes = false;
                          _selectedLeads.clear();
                          _selectedSalesIds.clear();
                          _selectedLeadStagesIds.clear();
                        });
                      }
                      log('Assign lead result: $result');
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.ios_share_outlined,
                          color: Colors.grey.shade700,
                          size: 25.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "ASSIGN",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// DIVIDER
                  Container(
                    height: 50.h,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  // =========================
                  // EDIT - يشتغل بس لو مختار 1
                  // =========================
                  InkWell(
                    onTap:
                        _selectedLeads.length == 1
                            ? () async {
                              // ✅ الطريقة الصحيحة لجلب الـ lead المختار
                              final leadsList =
                                  context
                                      .read<GetManagerLeadsCubit>()
                                      .allLeads; // استخدم allLeads مش leads
                              final selectedLead = leadsList.firstWhere(
                                (lead) =>
                                    lead.id.toString() == _selectedLeads.first,
                                orElse: () => LeadManager(),
                              );

                              // ✅ تأكد من وجود البيانات قبل فتح الديالوج
                              print("Selected Lead ID: ${selectedLead.id}");
                              print("Selected Lead Name: ${selectedLead.name}");
                              print(
                                "Selected Lead Phone: ${selectedLead.phone}",
                              );
                              print(
                                "Selected Lead Stage ID: ${selectedLead.stage?.id}",
                              );
                              print(
                                "Selected Lead Project ID: ${selectedLead.project?.id}",
                              );

                              final result = await showDialog(
                                context: context,
                                builder:
                                    (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create:
                                              (_) => EditLeadCubit(
                                                EditLeadApiService(),
                                              ),
                                        ),
                                        BlocProvider(
                                          create:
                                              (_) => ProjectsCubit(
                                                ProjectsApiService(),
                                              )..fetchProjects(),
                                        ),
                                        BlocProvider(
                                          create:
                                              (_) => StagesCubit(
                                                StagesApiService(),
                                              )..fetchStages(),
                                        ),
                                        BlocProvider(
                                          create:
                                              (_) => GetCommunicationWaysCubit(
                                                CommunicationWayApiService(),
                                              )..fetchCommunicationWays(),
                                        ),
                                        BlocProvider(
                                          create:
                                              (_) => ChannelCubit(
                                                GetChannelsApiService(),
                                              )..fetchChannels(),
                                        ),
                                        BlocProvider(
                                          create:
                                              (_) => GetCampaignsCubit(
                                                CampaignApiService(),
                                              )..fetchCampaigns(),
                                        ),
                                        BlocProvider(
                                          create:
                                              (_) => SalesCubit(
                                                GetAllSalesApiService(),
                                              )..fetchAllSales(),
                                        ),
                                      ],
                                      child: EditLeadDialog(
                                        userId: selectedLead.id ?? '',
                                        initialName: selectedLead.name ?? '',
                                        initialStalesId:
                                            selectedLead.sales?.id ?? '',
                                        initialEmail: selectedLead.email ?? '',
                                        initialPhone: selectedLead.phone ?? '',
                                        initialPhone2:
                                            selectedLead.phonenumber2 ??
                                            '', // ✅ أضف هذا
                                        initialWhatsappNumber:
                                            selectedLead.whatsappnumber ??
                                            '', // ✅ أضف هذا
                                        // initialNotes: selectedLead.notes ?? '',
                                        initialProjectId:
                                            selectedLead.project?.id,
                                        initialStageId: selectedLead.stage?.id,
                                        initialChannelId:
                                            selectedLead.chanel?.id,
                                        initialCampaignId:
                                            selectedLead.campaign?.id,
                                        initialCommunicationWayId:
                                            selectedLead.communicationway?.id,
                                        isCold: selectedLead.leedtype == "Cold",
                                        onSuccess: () {
                                          final leadsCubit =
                                              context
                                                  .read<GetManagerLeadsCubit>();
                                          leadsCubit.getManagerLeadsPagination(
                                            data: widget.data ?? false,
                                            stageIds: [widget.stageName ?? ''],
                                            ignoreDuplicate:
                                                widget.showDuplicatesOnly,
                                            salesIds:
                                                widget.salesIds ??
                                                (widget.salesId != null
                                                    ? [widget.salesId!]
                                                    : null),
                                          );
                                        },
                                      ),
                                    ),
                              );
                              if (result == true) {
                                context
                                    .read<GetManagerLeadsCubit>()
                                    .getManagerLeadsPagination(
                                      data: widget.data ?? false,
                                      stageIds: [widget.stageName ?? ''],
                                      ignoreDuplicate:
                                          widget.showDuplicatesOnly,
                                      salesIds:
                                          widget.salesIds ??
                                          (widget.salesId != null
                                              ? [widget.salesId!]
                                              : null),
                                    );
                              }
                            }
                            : null,
                    child: Opacity(
                      opacity: _selectedLeads.length == 1 ? 1.0 : 0.5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.grey.shade700,
                            size: 25.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "EDIT",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
      builder: (context, state) {
        if (state is GetManagerDashboardSuccess && widget.stageName != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GetManagerLeadsCubit>().getManagerLeadsPagination(
              data: widget.data ?? false,
              stageIds: [widget.stageName ?? ''],
              ignoreDuplicate: widget.showDuplicatesOnly,
              salesIds:
                  widget.salesIds ??
                  (widget.salesId != null ? [widget.salesId!] : null),
            );
          });
        }
        return Scaffold(
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            title: _isSearchVisible ? null : "Leads",
            onBack: () {
              if (widget.data == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TabsScreenManager(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagerDashboardDataScreen(),
                  ),
                );
              }
            },
            extraActions: [
              BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
                builder: (context, state) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: _isSearchVisible ? 200.w : 45.w,
                        height: 45.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border:
                              _isSearchVisible
                                  ? Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                    width: 1.5.w,
                                  )
                                  : null,
                        ),
                        child:
                            _isSearchVisible
                                ? Row(
                                  children: [
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.search,
                                      size: 20.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        focusNode: _searchFocusNode,
                                        autofocus: true,
                                        onChanged: (value) {
                                          final cubit =
                                              context
                                                  .read<GetManagerLeadsCubit>();
                                          _debounce?.cancel();
                                          _debounce = Timer(
                                            const Duration(milliseconds: 500),
                                            () {
                                              cubit.getManagerLeadsPagination(
                                                search: value.trim(),
                                                data: widget.data ?? false,
                                                stageIds: [
                                                  widget.stageName ?? '',
                                                ],
                                                ignoreDuplicate:
                                                    widget.showDuplicatesOnly,
                                                salesIds:
                                                    widget.salesIds ??
                                                    (widget.salesId != null
                                                        ? [widget.salesId!]
                                                        : null),
                                              );
                                            },
                                          );
                                        },
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search...',
                                          hintStyle: TextStyle(
                                            color: const Color(0xff969696),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 0,
                                            horizontal: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        searchController.clear();
                                        setState(() {
                                          _isSearchVisible = false;
                                        });
                                        _searchFocusNode.unfocus();
                                        final cubit =
                                            context
                                                .read<GetManagerLeadsCubit>();
                                        cubit.getManagerLeadsPagination(
                                          search: null,
                                          data: widget.data ?? false,
                                          stageIds: [widget.stageName ?? ''],
                                          ignoreDuplicate:
                                              widget.showDuplicatesOnly,
                                          salesIds:
                                              widget.salesIds ??
                                              (widget.salesId != null
                                                  ? [widget.salesId!]
                                                  : null),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 8.w),
                                        child: Icon(
                                          Icons.clear,
                                          size: 18.sp,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                  ],
                                )
                                : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSearchVisible = true;
                                    });
                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () {
                                        _searchFocusNode.requestFocus();
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    size: 22.sp,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                  ),
                                ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showFilterDialogManagerr(
                              context,
                              widget.data ?? false,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (_showCheckboxes && _selectedLeads.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SafeArea(child: buildAssignButtons()),
                ),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state is GetManagerLeadsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetManagerCrmLeadsSuccess) {
                      final cubit = context.read<GetManagerLeadsCubit>();
                      final leads = cubit.allLeads;
                      if (leads.isEmpty) {
                        return const Center(child: Text('No leads found.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          final cubit = context.read<GetManagerLeadsCubit>();
                          await cubit.getManagerLeadsPagination(
                            data: widget.data ?? false,
                            stageIds: [widget.stageName ?? ''],
                            ignoreDuplicate: widget.showDuplicatesOnly,
                            salesIds:
                                widget.salesIds ??
                                (widget.salesId != null
                                    ? [widget.salesId!]
                                    : null),
                          );
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: leads.length + (_isFetchingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == leads.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Constants.maincolor,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      "Loading more...",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final lead = leads[index];
                            return _buildLeadCard(
                              lead: lead,
                              parentContext: context,
                            );
                          },
                        ),
                      );
                    } else if (state is GetManagerLeadsFailure) {
                      return Center(child: Text(' ${state.message}'));
                    } else {
                      return const Center(child: Text('No leads found.'));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

class _ActionIcon extends StatelessWidget {
  final Widget icon;
  const _ActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey[100],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconTheme(
        data: IconThemeData(
          size: 22,
          color: isDark ? Colors.white : Constants.maincolor,
        ),
        child: icon,
      ),
    );
  }
}

class CommentShimmer extends StatelessWidget {
  const CommentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 14, width: 120, color: Colors.white),
            const SizedBox(height: 10),
            Container(height: 12, width: double.infinity, color: Colors.white),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.white,
            ),
            const SizedBox(height: 15),
            Container(height: 14, width: 100, color: Colors.white),
            const SizedBox(height: 10),
            Container(height: 12, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
