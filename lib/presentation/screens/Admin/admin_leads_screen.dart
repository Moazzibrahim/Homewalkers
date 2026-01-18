// leads_marketier_screen.dart
// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, unused_field, use_super_parameters, unnecessary_null_comparison
import 'dart:async';
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
import 'package:homewalkers_app/data/models/leadsAdminModelWithPagination.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_lead_details.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_state.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
//import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/assign_lead_markter_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/edit_lead_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/filter_leads_dialog.dart'; // تأكد أن المسار صحيح
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LeadsShimmer extends StatelessWidget {
  const LeadsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AdminLeadsScreen extends StatefulWidget {
  final String? stageName;
  final bool? showDuplicatesOnly;
  final bool shouldRefreshOnOpen;
  final String? stageId;

  const AdminLeadsScreen({
    super.key,
    this.stageName,
    this.showDuplicatesOnly,
    this.shouldRefreshOnOpen = true,
    this.stageId,
  });

  @override
  State<AdminLeadsScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<AdminLeadsScreen> {
  int selectedTab = 0; // 0: Manage Leads, 1: Leads Trash
  String _searchQuery = '';
  late TextEditingController _nameSearchController;
  String? _selectedCountryFilter;
  String? _selectedStageNameFilter;
  String? _selectedDeveloperFilter;
  String? _selectedProjectFilter;
  String? _selectedStageFilter;
  String? _selectedChannelFilter;
  String? _selectedSalesFilter;
  String? _selectedCommunicationWayFilter;
  String? _selectedCampaignFilter;
  String? _addedByFilter;
  String? _assignedFromFilter;
  String? _assignedToFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  DateTime? _lastStageUpdateStartFilter;
  DateTime? _lastStageUpdateEndFilter;
  DateTime? _lastCommentDateStartFilter;
  DateTime? _lastCommentDateEndFilter;
  String? _oldStageNameFilter;
  DateTime? _oldStageDateStartFilter;
  DateTime? _oldStageDateEndFilter;
  late bool _showDuplicatesOnly;
  final bool _isSelectAll = false;
  final Set<String> _selectedLeads = {};
  final Set<String> _selectedSalesIds = {};
  final Set<String> _selectedLeadStagesIds = {};
  final String selectedSalesId = ''; // انت عارف ده من مكان تاني
  String? _selectedSalesFcmToken;
  bool _showCheckboxes = false; // عشان نتحكم في ظهور الـ Checkbox
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false; // 👈 متغير داخلي يمنع التكرار
  bool _hasMoreData = true; // ✅ نعرف إذا كان فيه بيانات زيادة
  bool _didInitialFetch = false;
  Timer? _searchDebounce;
  late Future<void> _initialFetch;
  late AllLeadsCubitWithPagination _cubit;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();

    _nameSearchController = TextEditingController();
    _selectedStageFilter = widget.stageId;
    _showDuplicatesOnly = widget.showDuplicatesOnly ?? false;
    log("stage id: $_selectedStageFilter");
    log("stage name: ${widget.stageName}");
    log("show duplicates only: $_showDuplicatesOnly");

    // ✅ إعداد الـ Scroll Listener
    _setupScrollListener();

    // 🔹 استماع لكل state من الكيوبت
    //  final cubit = context.read<GetAllUsersCubit>();
    // cubit.stream.listen((state) {
    //   log("📦 Cubit State changed: ${state.toString()}");
    // });
    _cubit = context.read<AllLeadsCubitWithPagination>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _handleInitialFetch();
      _fetchInitial();
    });
  }

  void _fetchInitial() {
    _hasMoreData = true;
    _currentPage = 1;
    _cubit.fetchLeads(
      page: _currentPage,
      limit: 10,
      stageId: _selectedStageFilter,
      duplicates: _showDuplicatesOnly,
      ignoreDuplicate: _showDuplicatesOnly,
    );
  }

  // void _handleInitialFetch() {
  //   if (_didInitialFetch) return;
  //   _didInitialFetch = true;

  //   final cubit = context.read<GetAllUsersCubit>();
  //   log("🚀 Initial fetch triggered");
  //   cubit.fetchAllUsers(
  //     reset: true,
  //     stageFilter:
  //         (_selectedStageFilter != null && _selectedStageFilter!.isNotEmpty)
  //             ? _selectedStageFilter
  //             : null,
  //     duplicatesOnly: _showDuplicatesOnly,
  //   );
  // }

  // ✅ دالة إعداد الـ Scroll Listener
  void _setupScrollListener() {
    _scrollController.addListener(() {
      // ✅ تحقق إذا وصلنا لنهاية السكرول
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // ❌ لو فيه فلترة → امنع تحميل المزيد
        if (_searchQuery.isNotEmpty ||
            _selectedCountryFilter != null ||
            _selectedStageNameFilter != null ||
            _selectedDeveloperFilter != null ||
            _selectedProjectFilter != null ||
            _selectedChannelFilter != null ||
            _selectedSalesFilter != null ||
            _selectedCommunicationWayFilter != null ||
            _selectedCampaignFilter != null ||
            _addedByFilter != null ||
            _assignedFromFilter != null ||
            _assignedToFilter != null ||
            _startDateFilter != null ||
            _endDateFilter != null ||
            _lastStageUpdateStartFilter != null ||
            _lastStageUpdateEndFilter != null ||
            _oldStageNameFilter != null) {
          return;
        }

        _loadMoreData();
      }
    });
  }

  void _loadMoreData() {
    if (_isFetchingMore || !_hasMoreData) return;
    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++;

    _cubit
        .fetchLeads(
          page: _currentPage,
          limit: 10,
          ignoreDuplicate: _showDuplicatesOnly,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          stageId: _selectedStageFilter,
          developerId: _selectedDeveloperFilter,
          projectId: _selectedProjectFilter,
          channelId: _selectedChannelFilter,
          salesId: _selectedSalesFilter,
          communicationWayId: _selectedCommunicationWayFilter,
          campaignId: _selectedCampaignFilter,
          addedById: _addedByFilter,
          assignedFromId: _assignedFromFilter,
          assignedToId: _assignedToFilter,
          creationDateFrom: _startDateFilter,
          creationDateTo: _endDateFilter,
          lastStageUpdateFrom: _lastStageUpdateStartFilter,
          lastStageUpdateTo: _lastStageUpdateEndFilter,
          lastCommentDateFrom: _lastCommentDateStartFilter,
          lastCommentDateTo: _lastCommentDateEndFilter,
          duplicates: _showDuplicatesOnly,
        )
        .whenComplete(() {
          _isFetchingMore = false;
        });
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void _applyCurrentFilters() {
  //   final cubit = context.read<GetAllUsersCubit>();

  //   // لو لسه بيحمل أو الداتا فاضية — متعملش فلترة
  //   if (cubit.state is GetAllUsersLoading ||
  //       cubit.originalLeadsResponse?.data == null ||
  //       cubit.originalLeadsResponse!.data!.isEmpty) {
  //     log("⏳ لسه البيانات مجتش، مش هنعمل فلترة دلوقتي");
  //     return;
  //   }

  //   if (selectedTab == 1) return;

  //   // لو مفيش سيرش ولا أي فلتر
  //   if (_searchQuery.isEmpty &&
  //       _selectedCountryFilter == null &&
  //       _selectedDeveloperFilter == null &&
  //       _selectedProjectFilter == null &&
  //       _selectedStageNameFilter == null &&
  //       _selectedChannelFilter == null &&
  //       _selectedSalesFilter == null &&
  //       _selectedCommunicationWayFilter == null &&
  //       _selectedCampaignFilter == null &&
  //       _addedByFilter == null &&
  //       _assignedFromFilter == null &&
  //       _assignedToFilter == null &&
  //       _startDateFilter == null &&
  //       _endDateFilter == null &&
  //       _lastStageUpdateStartFilter == null &&
  //       _lastStageUpdateEndFilter == null &&
  //       _oldStageNameFilter == null) {
  //     _hasMoreData = true; // ✅ مهم عشان يسمح بالتحميل التالي
  //     _isFetchingMore = false; // ✅ مهم عشان يسمح للـ Scroll Loader بالعمل

  //     // ✅ رجع كل الـ leads من الكيوبت
  //     cubit.fetchAllUsers(
  //       reset: true,
  //       stageFilter:
  //           (_selectedStageFilter != null && _selectedStageFilter!.isNotEmpty)
  //               ? _selectedStageFilter
  //               : null, // ممكن تحافظ على stage لو عايز
  //       duplicatesOnly: _showDuplicatesOnly,
  //     );
  //     return;
  //   }

  //   // لو فيه سيرش أو فلتر، طبق الفلترة
  //   cubit.filterLeadsAdmin(
  //     query: _searchQuery,
  //     country: _selectedCountryFilter,
  //     developer: _selectedDeveloperFilter,
  //     project: _selectedProjectFilter,
  //     stage: _selectedStageNameFilter,
  //     channel: _selectedChannelFilter,
  //     sales: _selectedSalesFilter,
  //     communicationWay: _selectedCommunicationWayFilter,
  //     campaign: _selectedCampaignFilter,
  //     addedBy: _addedByFilter,
  //     assignedFrom: _assignedFromFilter,
  //     assignedTo: _assignedToFilter,
  //     startDate: _startDateFilter,
  //     endDate: _endDateFilter,
  //     lastStageUpdateStart: _lastStageUpdateStartFilter,
  //     lastStageUpdateEnd: _lastStageUpdateEndFilter,
  //     lastCommentDateStart: _lastCommentDateStartFilter,
  //     lastCommentDateEnd: _lastCommentDateEndFilter,
  //     oldStageName: _oldStageNameFilter,
  //     oldStageDateStart: _oldStageDateStartFilter,
  //     oldStageDateEnd: _oldStageDateEndFilter,
  //   );
  //   setState(() {
  //     _hasMoreData = false; // وقف اللود مور
  //     _isFetchingMore = false;
  //   });
  // }

  void _applyCurrentFilters() {
    _currentPage = 1;
    _hasMoreData = true;

    _cubit.fetchLeads(
      page: _currentPage,
      limit: 10,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      stageId: _selectedStageFilter,
      developerId: _selectedDeveloperFilter,
      projectId: _selectedProjectFilter,
      channelId: _selectedChannelFilter,
      salesId: _selectedSalesFilter,
      communicationWayId: _selectedCommunicationWayFilter,
      campaignId: _selectedCampaignFilter,
      addedById: _addedByFilter,
      assignedFromId: _assignedFromFilter,
      assignedToId: _assignedToFilter,
      creationDateFrom: _startDateFilter,
      creationDateTo: _endDateFilter,
      lastStageUpdateFrom: _lastStageUpdateStartFilter,
      lastStageUpdateTo: _lastStageUpdateEndFilter,
      lastCommentDateFrom: _lastCommentDateStartFilter,
      lastCommentDateTo: _lastCommentDateEndFilter,
      duplicates: _showDuplicatesOnly,
      ignoreDuplicate: _showDuplicatesOnly,
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
    bool isOutdated = false;
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: 'Leads',
        onBack: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminTabsScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                // color:
                //     Theme.of(context).brightness == Brightness.light
                //         ? Colors.white
                //         : Constants.backgroundDarkmode,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameSearchController,
                      onChanged: (value) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            _searchQuery = value.trim();
                            _applyCurrentFilters();
                          },
                        );
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
                        if (selectedTab == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Filtering is not available for the trash.",
                              ),
                            ),
                          );
                          return;
                        }
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
                              child: FilterDialog(
                                initialCountry: _selectedCountryFilter,
                                initialDeveloper: _selectedDeveloperFilter,
                                initialProject: _selectedProjectFilter,
                                initialStage: _selectedStageNameFilter,
                                initialChannel: _selectedChannelFilter,
                                initialSales: _selectedSalesFilter,
                                initialCommunicationWay:
                                    _selectedCommunicationWayFilter,
                                initialCampaign: _selectedCampaignFilter,
                                initialSearchName: _nameSearchController.text,
                              ),
                            );
                          },
                        );
                        if (filters != null) {
                          setState(() {
                            _searchQuery = filters['name'] ?? _searchQuery;
                            _nameSearchController.text = _searchQuery;
                            _selectedCountryFilter = filters['country'];
                            _selectedDeveloperFilter = filters['developerId'];
                            _selectedProjectFilter = filters['projectId'];
                            _selectedStageNameFilter = filters['stageId'];
                            _selectedChannelFilter = filters['channelId'];
                            _selectedSalesFilter = filters['salesId'];
                            _selectedCommunicationWayFilter =
                                filters['communicationWayId'];
                            _selectedCampaignFilter = filters['campaignId'];

                            _addedByFilter = filters['addedBy'];
                            _assignedFromFilter = filters['assignedFrom'];
                            _assignedToFilter = filters['assignedTo'];
                            _startDateFilter = filters['startDate'];
                            _endDateFilter = filters['endDate'];
                            _lastStageUpdateStartFilter =
                                filters['lastStageUpdateStart'];
                            _lastStageUpdateEndFilter =
                                filters['lastStageUpdateEnd'];
                            _lastCommentDateStartFilter =
                                filters['lastCommentDateStart'];
                            _lastCommentDateEndFilter =
                                filters['lastCommentDateEnd'];
                            // ✅✅ أضف هذا الجزء هنا لحل المشكلة ✅✅
                            _oldStageNameFilter = filters['oldStageName'];
                            _oldStageDateStartFilter =
                                filters['oldStageDateStart'];
                            _oldStageDateEndFilter = filters['oldStageDateEnd'];
                          });
                          _applyCurrentFilters();
                        }
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
                                    final String? selectedStageIddd =
                                        _selectedLeadStagesIds.isNotEmpty
                                            ? _selectedLeadStagesIds.first
                                            : null;

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
                                            leadStage: selectedStageIddd,
                                          ),
                                        );
                                      },
                                    );

                                    if (result == true) {
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
                                          .read<AllLeadsCubitWithPagination>()
                                          .leads;

                                  // نجيب ال lead المختار
                                  final selectedLead = leadsList.firstWhere(
                                    (lead) =>
                                        lead.id.toString() ==
                                        _selectedLeads.first,
                                    orElse:
                                        () =>
                                            LeadDataWithPagination(), // اسم الموديل عندك Lead مش LeadData
                                  );
                                  print('_selectedLeads: $_selectedLeads');
                                  print('found lead: $selectedLead');

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
                                            userId: selectedLead.id.toString(),
                                            initialName:
                                                selectedLead.name ?? '',
                                            initialEmail:
                                                selectedLead.email ?? '',
                                            initialPhone:
                                                selectedLead.phone ?? '',
                                            // initialNotes:
                                            //     selectedLead. ?? '',
                                            initialProjectId:
                                                selectedLead.project?.id
                                                    ?.toString(),
                                            initialStageId:
                                                selectedLead.stage?.id
                                                    ?.toString(),
                                            initialChannelId:
                                                selectedLead.chanel?.id
                                                    ?.toString(),
                                            initialCampaignId:
                                                selectedLead.campaign?.id
                                                    ?.toString(),
                                            initialCommunicationWayId:
                                                selectedLead
                                                    .communicationway
                                                    ?.id
                                                    ?.toString(),
                                            isCold:
                                                selectedLead.leedtype == "Cold",

                                            onSuccess: () {
                                              setState(() {
                                                _showCheckboxes = false;
                                                _selectedLeads.clear();
                                              });

                                              final leadsCubit =
                                                  context
                                                      .read<
                                                        AllLeadsCubitWithPagination
                                                      >();
                                              //   leadsCubit.resetPagination();
                                              leadsCubit.fetchLeads(
                                                stageId: widget.stageId,
                                                duplicates: _showDuplicatesOnly,
                                                ignoreDuplicate: _showDuplicatesOnly,
                                              );
                                            },
                                          ),
                                        ),
                                  );
                                  if (result == true) {
                                    context
                                        .read<AllLeadsCubitWithPagination>()
                                        .fetchLeads(
                                          stageId: widget.stageId,
                                          duplicates: _showDuplicatesOnly,
                                          ignoreDuplicate: _showDuplicatesOnly,
                                        );
                                    _showCheckboxes = false;
                                    _selectedLeads.clear();
                                  }
                                },
                                child: const _ActionIcon(
                                  icon: Icon(Icons.edit),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final leadsList =
                                      context
                                          .read<AllLeadsCubitWithPagination>()
                                          .leads;

                                  final selectedLead = leadsList.firstWhere(
                                    (lead) =>
                                        lead.id.toString() ==
                                        _selectedLeads.first,
                                    orElse: () => LeadDataWithPagination(),
                                  );

                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return BlocProvider(
                                        create:
                                            (_) => EditLeadCubit(
                                              EditLeadApiService(),
                                            ),
                                        child: AlertDialog(
                                          title: const Text("Delete Lead"),
                                          content: const Text(
                                            "Are you sure you want to delete this lead?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            BlocConsumer<
                                              EditLeadCubit,
                                              EditLeadState
                                            >(
                                              listener: (context, state) {
                                                if (state is EditLeadSuccess) {
                                                  Navigator.pop(context, true);
                                                }
                                                if (state is EditLeadFailure) {
                                                  Navigator.pop(context, false);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Failed to delete the lead. Please try again.",
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              builder: (context, state) {
                                                return TextButton(
                                                  onPressed:
                                                      state is EditLeadLoading
                                                          ? null
                                                          : () {
                                                            _showCheckboxes =
                                                                false;
                                                            _selectedLeads
                                                                .clear();
                                                            context
                                                                .read<
                                                                  EditLeadCubit
                                                                >()
                                                                .editLead(
                                                                  userId:
                                                                      selectedLead
                                                                          .id ??
                                                                      '',
                                                                  isLeadActivte:
                                                                      false,
                                                                );
                                                            setState(() {
                                                              _showCheckboxes =
                                                                  false;
                                                              _selectedLeads
                                                                  .clear();
                                                            });
                                                          },
                                                  child:
                                                      state is EditLeadLoading
                                                          ? const SizedBox(
                                                            height: 18,
                                                            width: 18,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          )
                                                          : const Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    final cubit =
                                        context
                                            .read<
                                              AllLeadsCubitWithPagination
                                            >();
                                    //  cubit.resetPagination();
                                    cubit.fetchLeads(
                                      stageId: widget.stageId,
                                      duplicates: _showDuplicatesOnly,
                                      ignoreDuplicate: _showDuplicatesOnly,
                                    );
                                  }
                                },
                                child: const _ActionIcon(
                                  icon: Icon(Icons.delete),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                          _searchQuery = '';
                          _nameSearchController.clear();
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedStageFilter =
                              widget
                                  .stageName; // أرجع stage لو كانت جاية من فوق
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                        });

                        if (widget.stageName != null &&
                            widget.stageName!.isNotEmpty) {
                          _applyCurrentFilters(); // لو جاية من الـ Widget نفذ فلترة
                        } else {
                          context
                              .read<AllLeadsCubitWithPagination>()
                              .fetchLeads(); // غير كده هات الكل
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
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                          _searchQuery = '';
                          _nameSearchController.clear();
                        });
                        context
                            .read<AllLeadsCubitWithPagination>()
                            .fetchLeadsInTrash();
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
            Expanded(
              child: //BlocBuilder<GetAllUsersCubit, GetAllUsersState>(
                  BlocBuilder<AllLeadsCubitWithPagination, AllLeadsState>(
                builder: (context, state) {
                  // الشرط الأول: عرض مؤشر التحميل إذا كانت أي من الحالتين loading
                  // if (state is GetAllUsersLoading ||
                  //     state is GetLeadsInTrashLoading) {
                  if (state is AllLeadsLoading && _currentPage == 1) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  // الشرط الثاني: عرض بيانات سلة المهملات فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 1
                  // else if (state is GetLeadsInTrashSuccess &&
                  //     selectedTab == 1) {
                  else if (state is AllLeadsTrashLoaded && selectedTab == 1) {
                    final leads = state.leadsData.data;
                    if (leads == null || leads.isEmpty) {
                      return const Center(child: Text('Leads trash is empty.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        //   context.read<GetAllUsersCubit>().fetchLeadsInTrash();
                        context
                            .read<AllLeadsCubitWithPagination>()
                            .fetchLeadsInTrash();
                      },
                      child: ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          return Card(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.grey[900],
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(lead.name ?? "No Name"),
                              subtitle: Text(
                                "Phone: ${lead.phone ?? 'N/A'}\nEmail: ${lead.email ?? 'N/A'}\nStage: ${lead.stage?.name ?? 'N/A'}\nSales: ${lead.sales?.name ?? 'N/A'}",
                              ),
                              leading: Icon(
                                Icons.delete_forever,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  // الشرط الثالث: عرض خطأ سلة المهملات فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 1
                  else if (state is AllLeadsTrashError && selectedTab == 1) {
                    return Center(child: Text(state.message));
                  }
                  // الشرط الرابع: عرض قائمة الـ Leads الرئيسية فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 0
                  else if (state is AllLeadsLoaded && selectedTab == 0) {
                    final cubit = context.read<AllLeadsCubitWithPagination>();
                    final leads = cubit.leads;
                    if (leads == null || leads.isEmpty) {
                      return const Center(child: Text('No leads found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        final cubit =
                            context.read<AllLeadsCubitWithPagination>();

                        setState(() {
                          _searchQuery = '';
                          _nameSearchController.clear();
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                          // ✅ خليك دايمًا ماسك الـ stage اللي دخل بيها المستخدم
                          _selectedStageFilter = widget.stageId;
                        });

                        if (selectedTab == 0) {
                          //  cubit.resetPagination();

                          log("⏳ Refreshing with stage: $_selectedStageFilter");

                          await cubit
                              .fetchLeads(
                                stageId:
                                    (_selectedStageFilter != null &&
                                            _selectedStageFilter!.isNotEmpty)
                                        ? _selectedStageFilter
                                        : null,
                                duplicates: _showDuplicatesOnly,
                                ignoreDuplicate: _showDuplicatesOnly,
                              )
                              .then((_) {
                                log("✅ Leads fetched successfully");
                                // ✅ بعد ما الداتا ترجع، فعّل الفلاتر (stage وغيره)
                                if (_showDuplicatesOnly) {
                                  cubit.fetchLeads(duplicates: true,ignoreDuplicate: true,);
                                } else {}
                              });
                        } else {
                          // context.read<GetAllUsersCubit>().fetchLeadsInTrash();
                          cubit.fetchLeadsInTrash();
                        }
                      },

                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            leads.length +
                            ((_isFetchingMore || _hasMoreData) ? 1 : 0),

                        // ✅ خليها length + 1
                        itemBuilder: (context, index) {
                          if (index == leads.length) {
                            // العنصر الأخير → Loading
                            return _isFetchingMore
                                ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                                : const SizedBox(); // لو مش بيتم تحميل → فاضي
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
                          DateTime? stageUpdatedDate;
                          if (leadstageupdated != null) {
                            try {
                              stageUpdatedDate = DateTime.parse(
                                leadstageupdated.toString(),
                              );
                              log("stageUpdatedDate: $stageUpdatedDate");
                            } catch (_) {
                              stageUpdatedDate = null;
                            }
                          }
                          if (stageUpdatedDate != null) {
                            final now = DateTime.now().toUtc();
                            final difference =
                                now.difference(stageUpdatedDate).inMinutes;
                            isOutdated = difference > 1;
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
                            onTap: () {
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
                                final lastVersion =
                                    (lead.allVersions != null &&
                                            lead.allVersions!.isNotEmpty)
                                        ? lead.allVersions!.last
                                        : null;
                                final currentScrollOffset =
                                    _scrollController.offset;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => AdminLeadDetails(
                                          leedId: lead.id!,
                                          leadName: lead.name ?? '',
                                          leadPhone: lead.phone ?? '',
                                          leadEmail: lead.email ?? '',
                                          leadStage: lead.stage?.name ?? '',
                                          leadStageId: lead.stage?.id ?? '',
                                          leadSalesName: lead.sales?.name ?? '',
                                          leadChannel: lead.chanel?.name ?? '',
                                          leadCreationDate:
                                              lead.createdAt != null
                                                  ? formatDateTimeToDubai(
                                                    lead.createdAt!.toString(),
                                                  )
                                                  : '',
                                          leadProject: lead.project?.name ?? '',
                                          leadLastComment:
                                              lead.lastcommentdate.toString(),
                                          leadcampaign:
                                              lead.campaign?.CampainName ??
                                              "campaign",
                                          leadNotes: "no notes",
                                          leaddeveloper:
                                              lead.project?.developer?.name ??
                                              "no developer",
                                          salesfcmToken: salesfcmtoken,
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
                                              lead.stagedateupdated.toString(),
                                          stageId: lead.stage?.id,
                                          totalsubmissions:
                                              lead.totalSubmissions.toString(),
                                          leadversions: lead.allVersions,
                                          leadversionscampaign:
                                              firstVersion
                                                  ?.campaign
                                                  ?.CampainName ??
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
                                                  .toString() ??
                                              "No date",
                                          leadversionscommunicationway:
                                              firstVersion
                                                  ?.communicationway
                                                  ?.name ??
                                              "No communication way",
                                          leadStages: [lead.stage?.id],
                                          cashbackmoney: lead.cashbackmoney,
                                          cashbackratio: lead.cashbackratio,
                                          commissionmoney: lead.commissionmoney,
                                          commissionratio: lead.commissionratio,
                                          unitPrice: lead.unit_price,
                                          unitnumber: lead.unitnumber,
                                          lastcommentFirst: lead.lastComment?.firstcomment,
                                          lastcommentNext: lead.lastComment?.secondcomment,
                                        ),
                                  ),
                                ).then((_) {
                                  _scrollController.animateTo(
                                    currentScrollOffset,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              }
                            },
                            child: Column(
                              children: [
                                Card(
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
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      // 👇 نتحقق من الشرط الخاص باللون
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
                                                                Colors
                                                                    .black; // ✅ اللون الأسود
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
                                                    "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!.toString()) : "N/A"}",
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
                                              // ✅ الجزء اليمين (KSA | EVENT | Skyrise أو اسم المشروع)
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
                                        // ---------- Row 2: phone | Person ----------
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
                                        // ---------- Row 3: Sales Name, CD Date, and Action Icons ----------
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
                                                  // 👈 الجزء الشمال (Sales name)
                                                  Expanded(
                                                    child: Text(
                                                      lead.assigntype == true
                                                          ? "team: ${lead.sales?.name}"
                                                          : lead.sales?.name ??
                                                              'N/A',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
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
        final lastComment = lead.lastComment;
        final firstCommentText =
            lastComment?.firstcomment?.text ?? 'No comments available.';
        final secondCommentText =
            lastComment?.secondcomment?.text ?? 'No action available.';

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Last Comment",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(firstCommentText), // كل النص يظهر بالكامل
                  const SizedBox(height: 10),
                  const Text(
                    "Action (Plan)",
                    style: TextStyle(
                      color: Constants.maincolor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(secondCommentText), // كل النص يظهر بالكامل
                ],
              ),
            ),
          ),
        );
      },
    );
  },
  borderRadius: BorderRadius.circular(30),
  child: Container(
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: Constants.maincolor,
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.chat_bubble_outline,
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
                                                    " ${lead.date != null ? formatDateTimeToDubai(lead.date!.toString()) : "N/A"}",
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
                                        SizedBox(height: 20.h),
                                        Container(
                                          width: double.infinity,
                                          height:
                                              22.h, // تم تقليل الارتفاع ليظهر البيضاوي بشكل صحيح
                                          decoration: BoxDecoration(
                                            color:
                                                (() {
                                                  if (leadassign == false &&
                                                      lead.stage?.name !=
                                                          'Fresh') {
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
                                                      lead.stage?.name !=
                                                          'Fresh') {
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
                                                    textColor =
                                                        Constants.maincolor;
                                                  }
                                                  return Text(
                                                    statusText,
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
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
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                  // الشرط الخامس: عرض خطأ الـ Leads الرئيسية فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 0
                  else if (state is AllLeadsError && selectedTab == 0) {
                    return Center(child: Text(' No leads found'));
                  }
                  // الحالة الافتراضية: إذا لم تتطابق أي من الشروط السابقة
                  // (مثلاً الحالة هي GetLeadsInTrashSuccess والتبويب هو 0)
                  // نعرض مؤشر تحميل لأننا ننتظر الحالة الصحيحة
                  else {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      ),
                    );
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

class DotLoading extends StatefulWidget {
  const DotLoading({Key? key}) : super(key: key);

  @override
  State<DotLoading> createState() => _DotLoadingState();
}

class _DotLoadingState extends State<DotLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // ينور ويطفي باستمرار
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.green, // اللون الأخضر
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
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
