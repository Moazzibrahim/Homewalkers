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
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
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
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
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
  final bool showDuplicatesOnly;
  final bool shouldRefreshOnOpen;
  const LeadsMarketierScreen({
    super.key,
    this.stageName,
    this.showDuplicatesOnly = false,
    this.shouldRefreshOnOpen = true,
  });

  @override
  State<LeadsMarketierScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<LeadsMarketierScreen> {
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  int selectedTab = 0; // 0: Manage Leads, 1: Leads Trash
  // 🟡 جديد: متغير لحفظ نص البحث
  String _searchQuery = '';
  // 🟡 جديد: TextEditingController كـ field في الـ State
  late TextEditingController _nameSearchController;
  // 🟡 جديد: متغيرات لحفظ حالة الفلاتر من الـ dialog
  String? _selectedCountryFilter;
  String? _selectedDeveloperFilter;
  String? _selectedProjectFilter;
  String? _selectedStageFilter;
  String? _selectedChannelFilter;
  String? _selectedSalesFilter;
  String? _selectedCommunicationWayFilter;
  String? _selectedCampaignFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;
  late bool _showDuplicatesOnly;
  final bool _isSelectAll = false;
  final Set<String> _selectedLeads = {};
  final String selectedSalesId = ''; // انت عارف ده من مكان تاني
  String? _selectedSalesFcmToken;
  final Set<String> _selectedSalesIds = {};
  final Set<String> _selectedLeadStagesIds = {};
  bool _showCheckboxes = false; // عشان نتحكم في ظهور الـ Checkbox
  final ScrollController _scrollController = ScrollController();
  final bool _isFetchingMore = false; // 👈 متغير داخلي يمنع التكرار

  @override
  void initState() {
    super.initState();
    _nameSearchController = TextEditingController();
    _selectedStageFilter = widget.stageName;
    _showDuplicatesOnly = widget.showDuplicatesOnly;
    log("stage name: $_selectedStageFilter");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stage = widget.stageName;
      _selectedStageFilter = stage;
      _showDuplicatesOnly = widget.showDuplicatesOnly;

      context.read<GetLeadsMarketerCubit>().getLeadsByMarketer(
        stageFilter: stage, // ⬅️ نمرر الفلتر مباشرة
        duplicatesOnly: _showDuplicatesOnly,
      );
    });
  }

  @override
  void dispose() {
    _nameSearchController.dispose(); // 🟡 مهم: التخلص من الـ controller
    _scrollController.dispose();
    super.dispose();
  }

  // 🟡 دالة مساعدة لتطبيق الفلاتر الشاملة (البحث + الفلاتر من الـ dialog)
  // 🟡 دالة مساعدة لتطبيق الفلاتر الشاملة (البحث + الفلاتر من الـ dialog)
  void _applyCurrentFilters() {
    context.read<GetLeadsMarketerCubit>().filterLeadsMarketer(
      query: _searchQuery, // نص البحث من TextField
      country: _selectedCountryFilter,
      developer: _selectedDeveloperFilter,
      project: _selectedProjectFilter,
      stage: _selectedStageFilter,
      channel: _selectedChannelFilter,
      sales: _selectedSalesFilter,
      communicationWay: _selectedCommunicationWayFilter,
      campaign: _selectedCampaignFilter,
      startDate: _startDate,
      endDate: _endDate,
      lastStageUpdateStart: _lastStageUpdateStart,
      lastStageUpdateEnd: _lastStageUpdateEnd,
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
      return dateStr; // fallback في حال كان التاريخ مش صحيح
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
    bool isOutdated = false; // قد تحتاج لإعادة تقييمها لكل عنصر
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: 'Leads',
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MarketierTabsScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Search & filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // color:
                //     Theme.of(context).brightness == Brightness.light
                //         ? Colors.white
                //         : Constants.backgroundDarkmode,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _nameSearchController, // 🟡 استخدام الـ controller من الـ State
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });

                        if (_searchQuery.isEmpty) {
                          context
                              .read<GetLeadsMarketerCubit>()
                              .getLeadsByMarketer(
                                stageFilter: _selectedStageFilter,
                                duplicatesOnly: _showDuplicatesOnly,
                              );
                        } else {
                          _applyCurrentFilters();
                        }
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
                    height: 50.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1F2),
                      border: Border.all(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
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
                      onPressed: () async {
                        // 🟡 مهم: استقبل القيم الراجعة من الـ dialog
                        final Map<String, dynamic>?
                        filters = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (dialogContext) {
                            // استخدام dialogContext هنا
                            return MultiBlocProvider(
                              // هذا الجزء كان موجود في showFilterDialogMarketer
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
                                      (_) => GetCampaignsCubit(
                                        CampaignApiService(),
                                      )..fetchCampaigns(),
                                ),
                                BlocProvider(
                                  create:
                                      (_) =>
                                          SalesCubit(GetAllSalesApiService())
                                            ..fetchAllSales(),
                                ),
                              ],
                              child: MarketerFilterDialog(
                                // 🟡 تمرير القيم الحالية للـ dialog عشان يعرضها
                                initialCountry: _selectedCountryFilter,
                                initialDeveloper: _selectedDeveloperFilter,
                                initialProject: _selectedProjectFilter,
                                initialStage: _selectedStageFilter,
                                initialChannel: _selectedChannelFilter,
                                initialSales: _selectedSalesFilter,
                                initialCommunicationWay:
                                    _selectedCommunicationWayFilter,
                                initialCampaign: _selectedCampaignFilter,
                                initialSearchName:
                                    _nameSearchController
                                        .text, // 🟡 تمرير نص البحث الحالي
                                initialStartDate: _startDate,
                                initialEndDate: _endDate,
                                initialLastStageUpdateStart:
                                    _lastStageUpdateStart,
                                initialLastStageUpdateEnd: _lastStageUpdateEnd,
                              ),
                            );
                          },
                        );
                        if (filters != null) {
                          // 🟡 تحديث متغيرات الـ State بالفلتر الجديدة
                          setState(() {
                            // 🟡 استخدم الـ `query` اللي رجع من الـ dialog لو مبعوت، أو احتفظ باللي موجود
                            _searchQuery = filters['name'] ?? _searchQuery;
                            _nameSearchController.text =
                                _searchQuery; // تحديث الـ TextField
                            _selectedCountryFilter = filters['country'];
                            _selectedDeveloperFilter = filters['developer'];
                            _selectedProjectFilter = filters['project'];
                            _selectedStageFilter = filters['stage'];
                            _selectedChannelFilter = filters['channel'];
                            _selectedSalesFilter = filters['sales'];
                            _selectedCommunicationWayFilter =
                                filters['communicationWay'];
                            _selectedCampaignFilter = filters['campaign'];
                            _startDate = filters['startDate'];
                            _endDate = filters['endDate'];
                            _lastStageUpdateStart =
                                filters['lastStageUpdateStart'];
                            _lastStageUpdateEnd = filters['lastStageUpdateEnd'];
                          });
                          _applyCurrentFilters(); // 🟡 تطبيق الفلاتر الجديدة
                        }
                        print("sales name: $_selectedSalesFilter");
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (selectedTab == 0 && _selectedLeads.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ شيلنا الـ Checkbox بالكامل
                    const SizedBox(), // مكان فاضي عشان المسافات تبقى مظبوطة

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
                                      context
                                          .read<GetLeadsMarketerCubit>()
                                          .getLeadsByMarketer();
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
                                  final leadsList =
                                      context
                                          .read<GetLeadsMarketerCubit>()
                                          .leads;
                                  // نجيب ال lead المختار
                                  final selectedLead = leadsList.firstWhere(
                                    (lead) =>
                                        lead.id.toString() ==
                                        _selectedLeads.first,
                                    orElse:
                                        () =>
                                            LeadData(), // اسم الموديل عندك Lead مش LeadData
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
                                                selectedLead.notes ?? '',
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
                                              final leadsCubit =
                                                  context
                                                      .read<
                                                        GetLeadsMarketerCubit
                                                      >();
                                              // leadsCubit.resetPagination();
                                              leadsCubit.getLeadsByMarketer();
                                            },
                                          ),
                                        ),
                                  );
                                  if (result == true) {
                                    context
                                        .read<GetLeadsMarketerCubit>()
                                        .getLeadsByMarketer();
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
                          // 🟡 مسح باقي الفلاتر عند تغيير الـ tab
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedStageFilter = null;
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                        });
                        // 🟡 استدعي جلب البيانات الأصلية بعد تغيير الـ tab
                        if (widget.stageName != null &&
                            widget.stageName!.isNotEmpty) {
                          _applyCurrentFilters();
                        } else {
                          context
                              .read<GetLeadsMarketerCubit>()
                              .getLeadsByMarketer();
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
                          // 🟡 مسح باقي الفلاتر عند تغيير الـ tab
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedStageFilter = null;
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                        });
                        // 🟡 استدعي جلب بيانات سلة المهملات
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
                builder: (context, state) {
                  if (state is GetLeadsMarketerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetLeadsMarketerSuccess) {
                    final leads = state.leadsResponse.data;
                    print("🟢 Displaying leads count=${leads?.length}");

                    if (leads == null || leads.isEmpty) {
                      // 🟡 التأكد من أن leads ليست null
                      return const Center(child: Text('No leads found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _searchQuery = ''; // مسح البحث عند التحديث
                          _nameSearchController.clear();
                          // 🟡 مسح باقي الفلاتر عند التحديث
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                          _selectedStageFilter = widget.stageName;
                        });
                        final cubit = context.read<GetLeadsMarketerCubit>();
                        if (selectedTab == 0) {
                          await cubit.getLeadsByMarketer(
                            stageFilter:
                                _selectedStageFilter, // ✅ نحافظ على نفس الفلتر
                            duplicatesOnly: _showDuplicatesOnly,
                          );
                        } else {
                          context
                              .read<GetLeadsMarketerCubit>()
                              .getLeadsByMarketerInTrash();
                        }
                      },
                      child: ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          final leadassign = lead.assign;
                          final salesfcmtoken = lead.sales?.userlog?.fcmtokenn;
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
                              stageUpdatedDate = DateTime.parse(
                                leadstageupdated,
                              );
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
                            isOutdated =
                                difference >
                                1; // اعتبره قديم إذا مرّ أكثر من دقيقة
                            log("isOutdated: $isOutdated");
                          }
                          // Add other necessary imports from your project here
                          // (for cubits, constants, different screens, etc.)

                          // Assuming the context and all variables like 'lead', 'isOutdated', 'selectedTab', etc.
                          // from your new code are available.
                          return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _showCheckboxes = true;
                                _selectedLeads.add(
                                  lead.id!,
                                ); // أول كارت تعمل عليه Long Press بيتعلّم
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
                                  } else {
                                    _selectedLeads.add(lead.id!);
                                  }
                                });
                              } else {
                                final firstVersion =
                                    (lead.allVersions != null &&
                                            lead.allVersions!.isNotEmpty)
                                        ? lead.allVersions!.first
                                        : null;

                                // Navigation and refresh logic from your new code
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
                                                    lead.createdAt!,
                                                  )
                                                  : '',
                                          leadProject: lead.project?.name ?? '',
                                          leadLastComment:
                                              lead.lastcommentdate ?? '',
                                          leadcampaign:
                                              lead.campaign?.name ?? "campaign",
                                          leadNotes: lead.notes ?? "no notes",
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
                                              lead.secondphonenumber ??
                                              'no second phone number',
                                          laststageupdated:
                                              lead.stagedateupdated,
                                          stageId: lead.stage?.id,
                                          totalsubmissions:
                                              lead.totalSubmissions.toString(),
                                          leadversions: lead.allVersions,
                                          leadversionscampaign:
                                              firstVersion?.campaignName ??
                                              "No campaign",
                                          leadversionsproject:
                                              firstVersion?.projectName ??
                                              "No project",
                                          leadversionsdeveloper:
                                              firstVersion?.developerName ??
                                              "No developer",
                                          leadversionschannel:
                                              firstVersion?.channelName ??
                                              "No channel",
                                          leadversionscreationdate:
                                              firstVersion?.versionDate ??
                                              "No date",
                                          leadversionscommunicationway:
                                              firstVersion?.communicationWay ??
                                              "No communication way",
                                          leadStages: [lead.stage?.id],
                                          leadSalesName: lead.sales?.name ?? '',
                                        ),
                                  ),
                                );
                                // if (selectedTab == 0) {
                                //   context
                                //       .read<GetLeadsMarketerCubit>()
                                //       .getLeadsByMarketer();
                                // } else {
                                //   context
                                //       .read<GetLeadsMarketerCubit>()
                                //       .getLeadsByMarketerInTrash();
                                // }
                              }
                            },
                            child: Card(
                              color:
                                  _selectedLeads.contains(lead.id)
                                      ? (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors
                                              .grey[300] // أغمق شوية لو Light Mode
                                          : Colors
                                              .grey[800]) // أغمق شوية لو Dark Mode
                                      : (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.white
                                          : Colors.grey[900]),
                              margin: const EdgeInsets.symmetric(
                                // horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ---------- Row 1: Name and Status Icon ----------
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
                                          // ✅ الجزء الشمال (Checkbox + Stage + SD Date)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  if (_showCheckboxes &&
                                                      _selectedLeads.isNotEmpty)
                                                    Checkbox(
                                                      activeColor:
                                                          Constants.maincolor,
                                                      value: _selectedLeads
                                                          .contains(lead.id),
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          if (value == true) {
                                                            _selectedLeads.add(
                                                              lead.id!,
                                                            );
                                                            _selectedSalesIds
                                                                .add(
                                                                  lead
                                                                          .sales
                                                                          ?.id ??
                                                                      '',
                                                                );
                                                            _selectedLeadStagesIds
                                                                .add(
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
                                                                  lead
                                                                          .sales
                                                                          ?.id ??
                                                                      '',
                                                                );
                                                            _selectedLeadStagesIds
                                                                .remove(
                                                                  lead
                                                                          .stage
                                                                          ?.id ??
                                                                      '',
                                                                );
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  // 👇 نتحقق من الشرط الخاص باللون
                                                  Builder(
                                                    builder: (_) {
                                                      final bool isFinalStage =
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
                                                            Colors
                                                                .black; // ✅ اللون الأسود
                                                      } else {
                                                        stageColor =
                                                            isFinalStage
                                                                ? Constants
                                                                    .maincolor
                                                                : isOutdated
                                                                ? Colors.red
                                                                : Colors.green;
                                                      }
                                                      return Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                              vertical: 4.h,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: stageColor
                                                              .withOpacity(0.1),
                                                          border: Border.all(
                                                            color: stageColor,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20.r,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.circle,
                                                              color: stageColor,
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
                                                                fontSize: 13.sp,
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
                                                "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!) : "N/A"}",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.light
                                                          ? Colors.black87
                                                          : Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // ✅ الجزء اليمين (KSA | EVENT | Skyrise أو اسم المشروع)
                                          Expanded(
                                            child: Text(
                                              lead.project?.name ?? '',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    const Divider(height: 3, thickness: 1.5),
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12.h),

                                    // ---------- Row 2: Sales Person ----------
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
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 35.h),

                                    // ---------- Row 3: Stage and Total Submissions ----------
                                    // ---------- Row 3: Stage and Total Submissions ----------
                                    Column(
                                      children: [
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
                                              // 👈 الجزء الشمال (Sales name)
                                              Expanded(
                                                child: Text(
                                                  lead.sales?.name ?? "none",
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),

                                              // 👉 الجزء اليمين (الـ 3 أيقونات داخل خلفية)
                                              Row(
                                                children: [
                                                  // 📞 Phone Call
                                                  InkWell(
                                                    onTap: () {
                                                      final phone =
                                                          lead.phone ?? '';
                                                      final formattedPhone =
                                                          phone.startsWith('0')
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
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.maincolor,
                                                        shape: BoxShape.circle,
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
                                                                  ? lead.phone
                                                                  : lead
                                                                      .whatsappnumber)
                                                              ?.replaceAll(
                                                                RegExp(r'\D'),
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
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.maincolor,
                                                        shape: BoxShape.circle,
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
                                                          return Dialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: BlocProvider(
                                                              create:
                                                                  (
                                                                    _,
                                                                  ) => LeadCommentsCubit(
                                                                    GetAllLeadCommentsApiService(),
                                                                  )..fetchLeadComments(
                                                                    lead.id!,
                                                                  ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
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
                                                                      return const SizedBox(
                                                                        height:
                                                                            100,
                                                                        child: Center(
                                                                          child:
                                                                              CircularProgressIndicator(),
                                                                        ),
                                                                      );
                                                                    } else if (commentState
                                                                        is LeadCommentsError) {
                                                                      return SizedBox(
                                                                        height:
                                                                            100,
                                                                        child: Center(
                                                                          child: Text(
                                                                            "No comments available: ${commentState.message}",
                                                                          ),
                                                                        ),
                                                                      );
                                                                    } else if (commentState
                                                                        is LeadCommentsLoaded) {
                                                                      final commentsData =
                                                                          commentState
                                                                              .leadComments
                                                                              .data;
                                                                      if (commentsData ==
                                                                              null ||
                                                                          commentsData
                                                                              .isEmpty) {
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
                                                                                (
                                                                                  c,
                                                                                ) =>
                                                                                    (c.firstcomment?.text?.isNotEmpty ??
                                                                                        false) ||
                                                                                    (c.secondcomment?.text?.isNotEmpty ??
                                                                                        false),
                                                                              )
                                                                              .toList();

                                                                      final Comment?
                                                                      firstCommentEntry =
                                                                          validComments.isNotEmpty
                                                                              ? validComments.first
                                                                              : null;

                                                                      final String
                                                                      firstCommentText =
                                                                          firstCommentEntry
                                                                              ?.firstcomment
                                                                              ?.text ??
                                                                          'No comments available.';
                                                                      final String
                                                                      secondCommentText =
                                                                          firstCommentEntry
                                                                              ?.secondcomment
                                                                              ?.text ??
                                                                          'No action available.';

                                                                      return Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
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
                                                                      );
                                                                    } else {
                                                                      return const SizedBox(
                                                                        height:
                                                                            100,
                                                                        child: Text(
                                                                          "No comments",
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                ),
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
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.maincolor,
                                                        shape: BoxShape.circle,
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
                                        // ✅ CD Date (السطر اللي تحت)
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
                                                " ${lead.date != null ? formatDateTimeToDubai(lead.date!) : "N/A"}",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    // ---------- Row 3: Date ----------
                                    Container(
                                      width: double.infinity,
                                      height:
                                          22.h, // تم تقليل الارتفاع ليظهر البيضاوي بشكل صحيح
                                      decoration: BoxDecoration(
                                        color:
                                            (() {
                                              if (leadassign == false &&
                                                  lead.stage?.name != 'Fresh') {
                                                return Colors
                                                    .green
                                                    .shade200; // قرب للون اللي في الصورة التانية
                                              } else if (lead.stage?.name ==
                                                  'Fresh') {
                                                return Colors.grey.shade300;
                                              } else {
                                                return Constants.maincolor
                                                    .withOpacity(0.25);
                                              }
                                            })(),
                                        borderRadius: BorderRadius.circular(
                                          200.r,
                                        ), // رقم كبير علشان يكون fully rounded
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Builder(
                                            builder: (_) {
                                              String statusText = '';
                                              Color textColor =
                                                  Colors.grey.shade700;

                                              if (leadassign == false &&
                                                  lead.stage?.name != 'Fresh') {
                                                statusText = 'Approved';
                                                textColor =
                                                    Colors.green.shade800;
                                              } else if (lead.stage?.name ==
                                                  'Fresh') {
                                                statusText = 'Not Assigned';
                                                textColor =
                                                    Colors.grey.shade700;
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
                            ),
                          );
                        },
                      ),
                    );
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
        color:
            isDark
                ? Colors.white.withOpacity(0.10)
                : Colors.grey[100], // خلفية خفيفة شيك
        shape: BoxShape.circle, // دائري بالكامل 👌
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
