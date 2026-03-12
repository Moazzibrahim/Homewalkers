// leads_marketier_screen.dart
// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, unused_field
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/campaign_api_service.dart';
import 'package:homewalkers_app/data/data_sources/communication_way_api_service.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/models/new_marketer_pagination_model.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_lead_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/assign_lead_markter_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/edit_lead_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/marketer_filter_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LeadsMarketierScreen extends StatefulWidget {
  final String? stageName;
  final bool? showDuplicatesOnly;
  final bool shouldRefreshOnOpen;
  final bool? data;
  final bool? transferefromdata;
  const LeadsMarketierScreen({
    super.key,
    this.stageName,
    this.showDuplicatesOnly = false,
    this.shouldRefreshOnOpen = true,
    this.data,
    this.transferefromdata,
  });

  @override
  State<LeadsMarketierScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<LeadsMarketierScreen> {
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  int selectedTab = 0; // 0: Manage Leads, 1: Leads Trash
  // متغير لحفظ نص البحث
  String _searchQuery = '';
  // TextEditingController
  late TextEditingController _nameSearchController;

  // ✅ تعديل المتغيرات لتصبح Lists (Multi-Select)
  List<String> _selectedCountryFilter = [];
  List<String> _selectedDeveloperFilter = [];
  List<String> _selectedProjectFilter = [];
  List<String> _selectedStageFilter = [];
  List<String> _selectedChannelFilter = [];
  List<String> _selectedSalesFilter = [];
  List<String> _selectedCommunicationWayFilter = [];
  List<String> _selectedCampaignFilter = [];

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;
  late bool _showDuplicatesOnly;
  final bool _isSelectAll = false;
  final Set<String> _selectedLeads = {};
  final String selectedSalesId = '';
  String? _selectedSalesFcmToken;
  final Set<String> _selectedSalesIds = {};
  final Set<String> _selectedLeadStagesIds = {};
  bool _showCheckboxes = false;
  final ScrollController _scrollController = ScrollController();
  final bool _isFetchingMore = false;

  // IDs for filters (للبحث المتقدم) - تبقى Lists
  List<String>? _selectedSalesIdsFilter;
  List<String>? _selectedDeveloperIdsFilter;
  List<String>? _selectedProjectIdsFilter;
  List<String>? _selectedChannelIdsFilter;
  List<String>? _selectedCampaignIdsFilter;
  List<String>? _selectedCommunicationWayIdsFilter;
  List<String>? _selectedStageIdsFilter;

  @override
  void initState() {
    super.initState();
    _nameSearchController = TextEditingController();
    // ✅ تحويل الـ stageName الفردي إلى List
    if (widget.stageName != null) {
      _selectedStageFilter = [widget.stageName!];
    }
    _showDuplicatesOnly = widget.showDuplicatesOnly!;
    log("stage name: $_selectedStageFilter");

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stage = widget.stageName;
      // ✅ تحويل الـ stageName الفردي إلى List
      if (stage != null) {
        _selectedStageFilter = [stage];
      }
      if (widget.showDuplicatesOnly != null) {
        _showDuplicatesOnly = widget.showDuplicatesOnly!;
        // مسح الفلتر الخاص بالمرحلة لعرض المكررة فقط
      }

      context.read<GetLeadsMarketerCubit>().fetchLeadsMarketerWithPagination(
        refresh: true,
        stageIds: stage != null ? [stage] : null,
        ignoreDuplicate: _showDuplicatesOnly == true ? true : null,
        data: widget.data,
        transferefromdata: widget.transferefromdata,
      );
    });
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<GetLeadsMarketerCubit>();
      if (!cubit.isLoadingMore && cubit.hasMoreData) {
        log("📜 Loading next page from scroll...");
        cubit.loadNextPage();
      }
    }
  }

  // ✅ دالة تطبيق الفلاتر مع الـ Pagination
  // ✅ دالة تطبيق الفلاتر مع الـ Pagination
  void _applyCurrentFiltersWithPagination() {
    final cubit = context.read<GetLeadsMarketerCubit>();

    log("🚀 Applying filters with IDs to Cubit:");
    log("   Sales IDs: $_selectedSalesIdsFilter");
    log("   Developer IDs: $_selectedDeveloperIdsFilter");
    log("   Project IDs: $_selectedProjectIdsFilter");
    log("   Stage IDs: $_selectedStageIdsFilter");
    log("   Channel IDs: $_selectedChannelIdsFilter");
    log("   Campaign IDs: $_selectedCampaignIdsFilter");
    log("   Communication Way IDs: $_selectedCommunicationWayIdsFilter");

    cubit.filterLeadsMarketerWithPagination(
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      salesIds: _selectedSalesIdsFilter,
      developerIds: _selectedDeveloperIdsFilter,
      projectIds: _selectedProjectIdsFilter,
      channelIds: _selectedChannelIdsFilter,
      campaignIds: _selectedCampaignIdsFilter,
      communicationWayIds: _selectedCommunicationWayIdsFilter,
      stageIds: _selectedStageIdsFilter,
      creationDateFrom: _startDate,
      creationDateTo: _endDate,
      lastStageUpdateFrom: _lastStageUpdateStart,
      lastStageUpdateTo: _lastStageUpdateEnd,
      ignoreDuplicate: _showDuplicatesOnly == true ? true : null,
      data: widget.data,
      transferefromdata: widget.transferefromdata,
    );
  }

  String formatDateTime(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day/$month/$year - $hour:$minute';
    } catch (e) {
      return dateStr;
    }
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
    bool isOutdated = false;
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        //  title: 'Leads',
        onBack: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MarketierTabsScreen()),
            );
          }
        },
        extraActions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200.w,
                child: TextField(
                  controller: _nameSearchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                    _applyCurrentFiltersWithPagination();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: const Color(0xff969696),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
            //    height: 50.h,
             //   width: 50.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1F2),
                  // border: Border.all(
                  //   color:
                  //       Theme.of(context).brightness == Brightness.light
                  //           ? Constants.maincolor
                  //           : Constants.mainDarkmodecolor,
                  // ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),

                  // في leads_marketier_screen.dart - تعديل جزء استقبال الفلاتر من الـ Dialog
                  onPressed: () async {
                    final Map<String, dynamic>?
                    filters = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (dialogContext) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create:
                                  (_) =>
                                      DevelopersCubit(DeveloperApiService())
                                        ..getDevelopers(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      ProjectsCubit(ProjectsApiService())
                                        ..fetchProjects(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      StagesCubit(StagesApiService())
                                        ..fetchStages(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      ChannelCubit(GetChannelsApiService())
                                        ..fetchChannels(),
                            ),
                            BlocProvider(
                              create:
                                  (_) => GetCommunicationWaysCubit(
                                    CommunicationWayApiService(),
                                  )..fetchCommunicationWays(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      GetCampaignsCubit(CampaignApiService())
                                        ..fetchCampaigns(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      SalesCubit(GetAllSalesApiService())
                                        ..fetchAllSales(),
                            ),
                          ],
                          child: MarketerFilterDialog(
                            initialCountry:
                                _selectedCountryFilter.isNotEmpty
                                    ? _selectedCountryFilter
                                    : null,
                            initialDeveloper:
                                _selectedDeveloperFilter.isNotEmpty
                                    ? _selectedDeveloperFilter
                                    : null,
                            initialProject:
                                _selectedProjectFilter.isNotEmpty
                                    ? _selectedProjectFilter
                                    : null,
                            initialStage:
                                _selectedStageFilter.isNotEmpty
                                    ? _selectedStageFilter
                                    : null,
                            initialChannel:
                                _selectedChannelFilter.isNotEmpty
                                    ? _selectedChannelFilter
                                    : null,
                            initialSales:
                                _selectedSalesFilter.isNotEmpty
                                    ? _selectedSalesFilter
                                    : null,
                            initialCommunicationWay:
                                _selectedCommunicationWayFilter.isNotEmpty
                                    ? _selectedCommunicationWayFilter
                                    : null,
                            initialCampaign:
                                _selectedCampaignFilter.isNotEmpty
                                    ? _selectedCampaignFilter
                                    : null,
                            initialSearchName: _nameSearchController.text,
                            initialStartDate: _startDate,
                            initialEndDate: _endDate,
                            initialLastStageUpdateStart: _lastStageUpdateStart,
                            initialLastStageUpdateEnd: _lastStageUpdateEnd,
                          ),
                        );
                      },
                    );

                    if (filters != null) {
                      setState(() {
                        _searchQuery = filters['name'] ?? _searchQuery;
                        _nameSearchController.text = _searchQuery;

                        // ✅ تحديث قوائم الأسماء (للعرض فقط)
                        _selectedCountryFilter = filters['country'] ?? [];
                        _selectedDeveloperFilter = filters['developer'] ?? [];
                        _selectedProjectFilter = filters['project'] ?? [];
                        _selectedStageFilter = filters['stage'] ?? [];
                        _selectedChannelFilter = filters['channel'] ?? [];
                        _selectedSalesFilter = filters['sales'] ?? [];
                        _selectedCommunicationWayFilter =
                            filters['communicationWay'] ?? [];
                        _selectedCampaignFilter = filters['campaign'] ?? [];

                        // ✅ الأهم: تحديث قوائم IDs مباشرة (لأن الـ Dialog يرجع IDs)
                        _selectedSalesIdsFilter =
                            filters['sales']?.isNotEmpty == true
                                ? List<String>.from(filters['sales'])
                                : null;
                        _selectedDeveloperIdsFilter =
                            filters['developer']?.isNotEmpty == true
                                ? List<String>.from(filters['developer'])
                                : null;
                        _selectedProjectIdsFilter =
                            filters['project']?.isNotEmpty == true
                                ? List<String>.from(filters['project'])
                                : null;
                        _selectedStageIdsFilter =
                            filters['stage']?.isNotEmpty == true
                                ? List<String>.from(filters['stage'])
                                : null;
                        _selectedChannelIdsFilter =
                            filters['channel']?.isNotEmpty == true
                                ? List<String>.from(filters['channel'])
                                : null;
                        _selectedCampaignIdsFilter =
                            filters['campaign']?.isNotEmpty == true
                                ? List<String>.from(filters['campaign'])
                                : null;
                        _selectedCommunicationWayIdsFilter =
                            filters['communicationWay']?.isNotEmpty == true
                                ? List<String>.from(filters['communicationWay'])
                                : null;

                        _startDate = filters['startDate'];
                        _endDate = filters['endDate'];
                        _lastStageUpdateStart = filters['lastStageUpdateStart'];
                        _lastStageUpdateEnd = filters['lastStageUpdateEnd'];
                      });

                      // ✅ للتصحيح - طباعة الـ IDs المرسلة
                      print("📊 Sending filters with IDs:");
                      print("   Sales IDs: $_selectedSalesIdsFilter");
                      print("   Developer IDs: $_selectedDeveloperIdsFilter");
                      print("   Project IDs: $_selectedProjectIdsFilter");
                      print("   Stage IDs: $_selectedStageIdsFilter");
                      print("   Channel IDs: $_selectedChannelIdsFilter");
                      print("   Campaign IDs: $_selectedCampaignIdsFilter");
                      print(
                        "   Communication Way IDs: $_selectedCommunicationWayIdsFilter",
                      );

                      // ✅ تطبيق الفلاتر
                      _applyCurrentFiltersWithPagination();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // باقي الكود كما هو...
            if (selectedTab == 0 && _selectedLeads.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    if (_selectedLeads.isNotEmpty)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 🧩 Assign Icon
                              InkWell(
                                onTap: () async {
                                  if (_showCheckboxes &&
                                      _selectedLeads.isNotEmpty) {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                              create: (_) => AssignleadCubit(),
                                            ),
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
                                            mainColor:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Constants.maincolor
                                                    : Constants
                                                        .mainDarkmodecolor,
                                            leadIds: _selectedLeads.toList(),
                                            leadId: _selectedLeads.toList()[0],
                                            leadStages:
                                                _selectedLeadStagesIds.toList(),
                                            leadSalesId:
                                                _selectedSalesIds.toList(),
                                          ),
                                        );
                                      },
                                    );
                                    if (result == true) {
                                      // تحديث البيانات بعد الإسناد
                                      context
                                          .read<GetLeadsMarketerCubit>()
                                          .refreshLeadsMarketer();
                                      setState(() {
                                        _showCheckboxes = false;
                                        _selectedLeads.clear();
                                        _selectedSalesIds.clear();
                                        _selectedLeadStagesIds.clear();
                                      });
                                    }
                                    log('Assign lead result: $result');
                                  }
                                },
                                child: _ActionIcon(
                                  icon: Image.asset(
                                    "assets/images/right.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                    color: Constants.maincolor,
                                  ),
                                ),
                              ),
                              // ✏️ Edit Icon
                              InkWell(
                                onTap: () async {
                                  // نجيب الـ lead المختار من الـ cubit باستخدام leadsDatum
                                  final leadsList =
                                      context
                                          .read<GetLeadsMarketerCubit>()
                                          .leadsDatum;
                                  final selectedLead = leadsList.firstWhere(
                                    (lead) =>
                                        lead.id.toString() ==
                                        _selectedLeads.first,
                                    orElse: () => Datum(),
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
                                                  (
                                                    _,
                                                  ) => GetCommunicationWaysCubit(
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
                                            initialName:
                                                selectedLead.name ?? '',
                                            initialStalesId:
                                                selectedLead.sales?.id ?? '',
                                            initialEmail:
                                                selectedLead.email ?? '',
                                            initialPhone:
                                                selectedLead.phone ?? '',
                                            initialNotes:
                                                selectedLead.jobdescription ??
                                                '',
                                            initialProjectId:
                                                selectedLead.project?.id,
                                            initialStageId:
                                                selectedLead.stage?.id,
                                            initialChannelId:
                                                selectedLead.chanel?.id,
                                            initialCampaignId:
                                                selectedLead.campaign?.id,
                                            initialCommunicationWayId:
                                                selectedLead
                                                    .communicationway
                                                    ?.id,
                                            isCold:
                                                selectedLead.leedtype == "Cold",
                                            onSuccess: () {
                                              // تحديث البيانات بعد التعديل
                                              context
                                                  .read<GetLeadsMarketerCubit>()
                                                  .refreshLeadsMarketer();
                                            },
                                          ),
                                        ),
                                  );
                                  if (result == true) {
                                    context
                                        .read<GetLeadsMarketerCubit>()
                                        .refreshLeadsMarketer();
                                  }
                                },
                                child: const _ActionIcon(
                                  icon: Icon(Icons.edit),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            // Create Lead Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tabs
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                          _searchQuery = ''; // مسح البحث عند تغيير الـ tab
                          _nameSearchController.clear();
                          _selectedCountryFilter = [];
                          _selectedDeveloperFilter = [];
                          _selectedProjectFilter = [];
                          _selectedStageFilter = [];
                          _selectedChannelFilter = [];
                          _selectedSalesFilter = [];
                          _selectedCommunicationWayFilter = [];
                          _selectedCampaignFilter = [];
                        });
                        // استخدام دالة الـ Pagination
                        if (widget.stageName != null &&
                            widget.stageName!.isNotEmpty) {
                          context
                              .read<GetLeadsMarketerCubit>()
                              .fetchLeadsMarketerWithPagination(
                                refresh: true,
                                stageIds: [widget.stageName!],
                                ignoreDuplicate:
                                    _showDuplicatesOnly == true ? true : null,
                                data: widget.data,
                                transferefromdata: widget.transferefromdata,
                              );
                        } else {
                          context
                              .read<GetLeadsMarketerCubit>()
                              .fetchLeadsMarketerWithPagination(
                                refresh: true,
                                ignoreDuplicate:
                                    _showDuplicatesOnly == true ? true : null,
                                data: widget.data,
                                transferefromdata: widget.transferefromdata,
                              );
                        }
                      },
                      child: Column(
                        children: [
                          Text(
                            'Manage Leads',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedTab == 0
                                      ? Constants.maincolor
                                      : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selectedTab == 0)
                            Container(
                              height: 2,
                              width: 50,
                              color: Constants.maincolor,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                          _searchQuery = ''; // مسح البحث عند تغيير الـ tab
                          _nameSearchController.clear();
                          _selectedCountryFilter = [];
                          _selectedDeveloperFilter = [];
                          _selectedProjectFilter = [];
                          _selectedStageFilter = [];
                          _selectedChannelFilter = [];
                          _selectedSalesFilter = [];
                          _selectedCommunicationWayFilter = [];
                          _selectedCampaignFilter = [];
                        });
                        context
                            .read<GetLeadsMarketerCubit>()
                            .getLeadsByMarketerInTrash();
                      },
                      child: Column(
                        children: [
                          Text(
                            'Leads Trash',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedTab == 1
                                      ? Constants.maincolor
                                      : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selectedTab == 1)
                            Container(
                              height: 2,
                              width: 50,
                              color: Constants.maincolor,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 2),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateLeadScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 11, color: Colors.white),
                  label: Text(
                    'Create Lead',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // Leads List Based on State
            Expanded(
              child: BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
                buildWhen: (previous, current) {
                  // متعيدش بناء الشاشة في حالة load more
                  if (current is GetLeadsMarketerPaginationLoading &&
                      current.isLoadingMore) {
                    return false;
                  }
                  return true;
                },
                builder: (context, state) {
                  // حالات الـ Pagination
                  if (state is GetLeadsMarketerPaginationLoading &&
                      !state.isLoadingMore) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is GetLeadsMarketerPaginationSuccess) {
                    final cubit = context.read<GetLeadsMarketerCubit>();
                    final leads = cubit.leadsDatum;
                    final paginationStats = cubit.getPaginationStats();

                    print("🟢 Displaying leads count=${leads.length}");
                    print("📊 Pagination stats: $paginationStats");
                    if (leads.isEmpty && !cubit.isLoadingMore) {
                      return const Center(child: Text('No leads found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _searchQuery = '';
                          _nameSearchController.clear();
                          _selectedCountryFilter = [];
                          _selectedDeveloperFilter = [];
                          _selectedProjectFilter = [];
                          _selectedChannelFilter = [];
                          _selectedSalesFilter = [];
                          _selectedCommunicationWayFilter = [];
                          _selectedCampaignFilter = [];
                          _selectedStageFilter = [];
                        });

                        final cubit = context.read<GetLeadsMarketerCubit>();

                        if (selectedTab == 0) {
                          await cubit.refreshLeadsMarketer();
                        } else {
                          await cubit.getLeadsByMarketerInTrash();
                        }
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: leads.length + (cubit.hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          // إذا كان هذا هو عنصر التحميل
                          if (index >= leads.length) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final lead = leads[index];
                          final leadassign = lead.assign;
                          final salesfcmtoken = lead.sales?.userlog?.fcmToken;
                          final prefs = SharedPreferences.getInstance();
                          final fcmToken = prefs.then(
                            (prefs) => prefs.setString(
                              'fcm_token_sales',
                              salesfcmtoken ?? '',
                            ),
                          );
                          log("fcmToken of sales: $salesfcmtoken");
                          final leadstageupdated = lead.stagedateupdated;
                          final leadStagetype = lead.stage?.name ?? "";

                          // تحويل التاريخ من String إلى DateTime
                          DateTime? stageUpdatedDate;
                          if (leadstageupdated != null) {
                            try {
                              stageUpdatedDate = leadstageupdated;
                              log("stageUpdatedDate: $stageUpdatedDate");
                            } catch (_) {
                              stageUpdatedDate = null;
                            }
                          }
                          if (stageUpdatedDate != null) {
                            final now = DateTime.now().toUtc();
                            log("now: $now");
                            final difference =
                                now.difference(stageUpdatedDate).inMinutes;
                            log("difference: $difference");
                            isOutdated = difference > 1;
                            log("isOutdated: $isOutdated");
                          }

                          return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _showCheckboxes = true;
                                _selectedLeads.add(lead.id!);
                                _selectedLeadStagesIds.add(
                                  lead.stage?.id ?? '',
                                );
                              });
                            },
                            onTap: () async {
                              if (_showCheckboxes) {
                                setState(() {
                                  if (_selectedLeads.contains(lead.id)) {
                                    _selectedLeads.remove(lead.id);
                                    // ✅ لو فاضية خلي الـ showCheckboxes false
                                    if (_selectedLeads.isEmpty) {
                                      _showCheckboxes = false;
                                    }
                                  } else {
                                    _selectedLeads.add(lead.id!);
                                    _selectedLeadStagesIds.add(
                                      lead.stage?.id ?? '',
                                    );
                                  }
                                });
                              } else {
                                final firstVersion =
                                    (lead.allVersions != null &&
                                            lead.allVersions!.isNotEmpty)
                                        ? lead.allVersions!.first
                                        : null;

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => MarketerLeadDetailsScreen(
                                          leedId: lead.id!,
                                          leadName: lead.name ?? '',
                                          leadPhone: lead.phone ?? '',
                                          leadEmail: lead.email ?? '',
                                          leadStage: lead.stage?.name ?? '',
                                          leadStageId: lead.stage?.id ?? '',
                                          leadChannel: lead.chanel?.name ?? '',
                                          leadCreationDate:
                                              lead.createdAt != null
                                                  ? formatDateTimeToDubai(
                                                    lead.createdAt!
                                                        .toIso8601String(),
                                                  )
                                                  : '',
                                          leadProject: lead.project?.name ?? '',
                                          leadLastComment:
                                              lead.lastcommentdate ?? '',
                                          leadcampaign:
                                              lead.campaign?.campainName ??
                                              "campaign",
                                          leadNotes:
                                              lead.jobdescription ?? "no notes",
                                          leaddeveloper:
                                              lead.project?.developer?.name ??
                                              "no developer",
                                          salesfcmtoken: salesfcmtoken!,
                                          leadwhatsappnumber:
                                              lead.whatsappnumber ??
                                              'no whatsapp number',
                                          jobdescription:
                                              lead.jobdescription ??
                                              'no job description',
                                          secondphonenumber:
                                              lead.phonenumber2 ??
                                              'no second phone number',
                                          laststageupdated:
                                              lead.stagedateupdated
                                                  ?.toIso8601String(),
                                          stageId: lead.stage?.id,
                                          totalsubmissions:
                                              lead.totalSubmissions.toString(),
                                          leadversions: lead.allVersions,
                                          leadversionscampaign:
                                              firstVersion
                                                  ?.campaign
                                                  ?.campainName ??
                                              "No campaign",
                                          leadversionsproject:
                                              firstVersion?.project?.name ??
                                              "No project",
                                          leadversionsdeveloper:
                                              firstVersion
                                                  ?.project
                                                  ?.developer
                                                  ?.name ??
                                              "No developer",
                                          leadversionschannel:
                                              firstVersion?.chanel?.name ??
                                              "No channel",
                                          leadversionscreationdate:
                                              firstVersion?.recordedAt
                                                  ?.toIso8601String() ??
                                              "No date",
                                          leadversionscommunicationway:
                                              firstVersion
                                                  ?.communicationway
                                                  ?.name ??
                                              "No communication way",
                                          leadStages: [lead.stage?.id],
                                          leadSalesName: lead.sales?.name ?? '',
                                          campaignlink: lead.campaign?.redirectLink ??
                                              'no campaign link',
                                          campaignRedirectLink:
                                              lead.campaignRedirectLink,
                                          question1_text: lead.question1_text,
                                          question1_answer:
                                              lead.question1_answer,
                                          question2_text: lead.question2_text,
                                          question2_answer:
                                              lead.question2_answer,
                                          question3_text: lead.question3_text,
                                          question3_answer:
                                              lead.question3_answer,
                                          question4_text: lead.question4_text,
                                          question4_answer:
                                              lead.question4_answer,
                                          question5_text: lead.question5_text,
                                          question5_answer:
                                              lead.question5_answer,
                                        ),
                                  ),
                                );
                              }
                            },
                            child: // في دالة itemBuilder داخل ListView.builder
                                Card(
                              color:
                                  _selectedLeads.contains(lead.id)
                                      ? (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey[300]
                                          : Colors.grey[800])
                                      : (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.white
                                          : Colors.grey[900]),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // ❌ إزالة Padding من هنا وجعله داخل Column بدلاً من ذلك
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ كل المحتوى الأساسي داخل Padding
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Row 1: Name and Status Icon
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      if (_showCheckboxes &&
                                                          _selectedLeads
                                                              .isNotEmpty)
                                                        Checkbox(
                                                          activeColor:
                                                              Constants
                                                                  .maincolor,
                                                          value: _selectedLeads
                                                              .contains(
                                                                lead.id,
                                                              ),
                                                          onChanged: (
                                                            bool? value,
                                                          ) {
                                                            setState(() {
                                                              if (value ==
                                                                  true) {
                                                                _selectedLeads
                                                                    .add(
                                                                      lead.id!,
                                                                    );
                                                                _selectedSalesIds.add(
                                                                  lead
                                                                          .sales
                                                                          ?.id ??
                                                                      '',
                                                                );
                                                                _selectedLeadStagesIds.add(
                                                                  lead
                                                                          .stage
                                                                          ?.id ??
                                                                      '',
                                                                );
                                                              } else {
                                                                _selectedLeads
                                                                    .remove(
                                                                      lead.id,
                                                                    );
                                                                _selectedSalesIds
                                                                    .remove(
                                                                      lead.sales?.id ??
                                                                          '',
                                                                    );
                                                                _selectedLeadStagesIds
                                                                    .remove(
                                                                      lead.stage?.id ??
                                                                          '',
                                                                    );
                                                                _showCheckboxes =
                                                                    false;
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      Builder(
                                                        builder: (_) {
                                                          final bool
                                                          isFinalStage =
                                                              stageUpdatedDate !=
                                                                  null &&
                                                              (leadStagetype ==
                                                                      "Done Deal" ||
                                                                  leadStagetype ==
                                                                      "Transfer" ||
                                                                  leadStagetype ==
                                                                      "Fresh" ||
                                                                  leadStagetype ==
                                                                      "Not Interested");
                                                          late final Color
                                                          stageColor;
                                                          if (leadStagetype ==
                                                              "Not Interested") {
                                                            stageColor =
                                                                Colors.black;
                                                          } else {
                                                            stageColor =
                                                                isFinalStage
                                                                    ? Constants
                                                                        .maincolor
                                                                    : isOutdated
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green;
                                                          }
                                                          return Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      8.w,
                                                                  vertical: 4.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: stageColor
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    stageColor,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20.r,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons.circle,
                                                                  color:
                                                                      stageColor,
                                                                  size: 10,
                                                                ),
                                                                SizedBox(
                                                                  width: 6.w,
                                                                ),
                                                                Text(
                                                                  lead
                                                                          .stage
                                                                          ?.name ??
                                                                      "No Stage",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        stageColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Text(
                                                    "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!.toIso8601String()) : "N/A"}",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors.black87
                                                              : Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Text(
                                                  lead.project?.name ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        const Divider(
                                          height: 3,
                                          thickness: 1.5,
                                        ),
                                        SizedBox(height: 20.h),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  lead.name ?? "No Name",
                                                  style: TextStyle(
                                                    fontSize: 19.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12.h),

                                        // Row 2: Phone
                                        InkWell(
                                          onTap: () {
                                            final phone = lead.phone ?? '';
                                            final formattedPhone =
                                                phone.startsWith('0')
                                                    ? phone
                                                    : '+$phone';
                                            makePhoneCall(formattedPhone);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  color:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.light
                                                          ? Colors.grey
                                                          : Constants
                                                              .mainDarkmodecolor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    lead.phone ?? 'N/A',
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 35.h),

                                        // Row 3: Sales and Actions
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                                right: 8,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.person_pin_outlined,
                                                    color:
                                                        Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.light
                                                            ? Colors.grey
                                                            : Constants
                                                                .mainDarkmodecolor,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Text(
                                                      lead.sales?.name ??
                                                          "none",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      // 📞 Phone Call
                                                      InkWell(
                                                        onTap: () {
                                                          final phone =
                                                              lead.phone ?? '';
                                                          final formattedPhone =
                                                              phone.startsWith(
                                                                    '0',
                                                                  )
                                                                  ? phone
                                                                  : '+$phone';
                                                          makePhoneCall(
                                                            formattedPhone,
                                                          );
                                                        },
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              30,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 4,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    Constants
                                                                        .maincolor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: const Icon(
                                                            Icons.phone,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),

                                                      // 💬 WhatsApp
                                                      InkWell(
                                                        onTap: () async {
                                                          final rawPhone =
                                                              (lead.phone?.isNotEmpty ==
                                                                          true
                                                                      ? lead
                                                                          .phone
                                                                      : lead
                                                                          .whatsappnumber)
                                                                  ?.replaceAll(
                                                                    RegExp(
                                                                      r'\D',
                                                                    ),
                                                                    '',
                                                                  ) ??
                                                              '';
                                                          final formattedPhone =
                                                              rawPhone.startsWith(
                                                                    '0',
                                                                  )
                                                                  ? rawPhone
                                                                  : '+$rawPhone';

                                                          final url =
                                                              "https://wa.me/$formattedPhone";
                                                          try {
                                                            await launchUrl(
                                                              Uri.parse(url),
                                                              mode:
                                                                  LaunchMode
                                                                      .externalApplication,
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
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              30,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 4,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    Constants
                                                                        .maincolor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: const FaIcon(
                                                            FontAwesomeIcons
                                                                .whatsapp,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                      // 🗨️ Last Comment
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) {
                                                              final String
                                                              firstCommentText =
                                                                  lead.lastComment?.firstcomment?.text?.isNotEmpty ==
                                                                          true
                                                                      ? lead
                                                                          .lastComment!
                                                                          .firstcomment!
                                                                          .text!
                                                                      : 'No comments available.';

                                                              final String
                                                              secondCommentText =
                                                                  lead.lastComment?.secondcomment?.text?.isNotEmpty ==
                                                                          true
                                                                      ? lead
                                                                          .lastComment!
                                                                          .secondcomment!
                                                                          .text!
                                                                      : 'No action available.';

                                                              return Dialog(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        16.0,
                                                                      ),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
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
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        firstCommentText,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      const Text(
                                                                        "Action (Plan)",
                                                                        style: TextStyle(
                                                                          color:
                                                                              Constants.maincolor,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        secondCommentText,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              30,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 4,
                                                              ),
                                                          decoration:
                                                              const BoxDecoration(
                                                                color:
                                                                    Constants
                                                                        .maincolor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: const Icon(
                                                            Icons
                                                                .chat_bubble_outline,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            // CD Date
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                                right: 8,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.date_range,
                                                    color:
                                                        Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.light
                                                            ? Colors.grey
                                                            : Constants
                                                                .mainDarkmodecolor,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    " ${lead.date != null ? formatDateTimeToDubai(lead.date!.toIso8601String()) : "N/A"}",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ✅ Status Container - خارج Padding ومباشرة تحت المحتوى
                                  // ✅ بدون أي مسافة إضافية بحيث يوصل لحد الكارد
                                  Container(
                                    width: double.infinity,
                                    height: 22.h,
                                    decoration: BoxDecoration(
                                      color:
                                          (() {
                                            if (leadassign == false &&
                                                lead.stage?.name != 'Fresh') {
                                              return Colors.green.shade200;
                                            } else if (lead.stage?.name ==
                                                'Fresh') {
                                              return Colors.grey.shade300;
                                            } else {
                                              return Constants.maincolor
                                                  .withOpacity(0.25);
                                            }
                                          })(),
                                      // ✅ corners مفرغة من أسفل (مستقيمة) لأنها قاعدة الكارد
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12.r),
                                        bottomRight: Radius.circular(12.r),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Builder(
                                          builder: (_) {
                                            String statusText = '';
                                            Color textColor =
                                                Colors.grey.shade700;

                                            if (leadassign == false &&
                                                lead.stage?.name != 'Fresh') {
                                              statusText = 'Approved';
                                              textColor = Colors.green.shade800;
                                            } else if (lead.stage?.name ==
                                                'Fresh') {
                                              statusText = 'Not Assigned';
                                              textColor = Colors.grey.shade700;
                                            } else {
                                              statusText = 'Assigned';
                                              textColor = Constants.maincolor;
                                            }
                                            return Text(
                                              statusText,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is GetLeadsMarketerPaginationFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('failed to load more leads:'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<GetLeadsMarketerCubit>()
                                  .refreshLeadsMarketer();
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is GetLeadsMarketerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetLeadsMarketerFailure) {
                    return Center(child: Text(' ${state.errorMessage}'));
                  } else {
                    return const Center(child: Text('No leads found.'));
                  }
                },
              ),
            ),
          ],
        ),
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
