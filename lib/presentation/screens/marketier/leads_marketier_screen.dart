// leads_marketier_screen.dart
// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, unused_field, use_super_parameters, unnecessary_null_comparison
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class LeadsMarketierScreen extends StatefulWidget {
  final String? stageName;
  final bool? showDuplicatesOnly;
  final bool shouldRefreshOnOpen;
  final bool? data;
  final bool? transferefromdata;
  final int? leadsCount; // ✅ أضف ده

  const LeadsMarketierScreen({
    super.key,
    this.stageName,
    this.showDuplicatesOnly = false,
    this.shouldRefreshOnOpen = true,
    this.data,
    this.transferefromdata,
    this.leadsCount, // ✅ أضف ده
  });

  @override
  State<LeadsMarketierScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<LeadsMarketierScreen> {
  int selectedTab = 0;
  String _searchQuery = '';
  late TextEditingController _nameSearchController;

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
  bool _isFetchingMore = false;

  List<String>? _selectedSalesIdsFilter;
  List<String>? _selectedDeveloperIdsFilter;
  List<String>? _selectedProjectIdsFilter;
  List<String>? _selectedChannelIdsFilter;
  List<String>? _selectedCampaignIdsFilter;
  List<String>? _selectedCommunicationWayIdsFilter;
  List<String>? _selectedStageIdsFilter;

  // UI variables
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  int _displayedLeadsCount = 0; // ✅ أضف ده

  @override
  void initState() {
    super.initState();
    _nameSearchController = TextEditingController();
    if (widget.stageName != null) {
      _selectedStageFilter = [widget.stageName!];
    }
    _showDuplicatesOnly = widget.showDuplicatesOnly!;
    log("stage name: $_selectedStageFilter");
    log("show duplicates only: $_showDuplicatesOnly");
    log("Data: ${widget.data}");
    log("Transfere From Data: ${widget.transferefromdata}");

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stage = widget.stageName;
      if (stage != null) {
        _selectedStageFilter = [stage];
      }
      if (widget.showDuplicatesOnly != null) {
        _showDuplicatesOnly = widget.showDuplicatesOnly!;
      }
      context.read<GetLeadsMarketerCubit>().stream.listen((state) {
        if (state is GetLeadsMarketerPaginationSuccess && mounted) {
          setState(() {
            _displayedLeadsCount =
                context.read<GetLeadsMarketerCubit>().totalLeads.toInt();
          });
        }
      });

      context.read<GetLeadsMarketerCubit>().fetchLeadsMarketerWithPagination(
        refresh: true,
        stageIds: stage != null ? [stage] : null,
        ignoreDuplicate: _showDuplicatesOnly == true ? true : false,
        data: widget.data,
        transferefromdata: widget.transferefromdata,
      );
    });
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  DateTime? _lastScrollLoadTime;

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final now = DateTime.now();
      if (_lastScrollLoadTime != null &&
          now.difference(_lastScrollLoadTime!).inMilliseconds < 500) {
        return;
      }

      final cubit = context.read<GetLeadsMarketerCubit>();
      if (!cubit.isLoadingMore && cubit.hasMoreData) {
        _lastScrollLoadTime = now;
        log("📜 Loading next page from scroll...");
        cubit.loadNextPage();
      }
    }
  }

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
    final bool isTabletDevice = () {
      final data = MediaQuery.of(context);
      final physicalSize = data.size;
      final diagonal = math.sqrt(
        math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
      );
      final inches = diagonal / (data.devicePixelRatio * 160);
      return inches >= 7.0;
    }();

    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: _isSearchVisible ? null : "Leads",
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
              // ✅ Animated Search Bar (Admin style)
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
                                Theme.of(context).brightness == Brightness.light
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
                            Icon(Icons.search, size: 20.sp, color: Colors.grey),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                autofocus: true,
                                onChanged: (value) {
                                  _searchDebounce?.cancel();
                                  _searchDebounce = Timer(
                                    const Duration(milliseconds: 500),
                                    () {
                                      setState(() {
                                        _searchQuery = value.trim();
                                        _nameSearchController.text =
                                            _searchQuery;
                                      });
                                      _applyCurrentFiltersWithPagination();
                                    },
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                    color: const Color(0xff969696),
                                    fontSize: (14 * tabletFontScale).sp,
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
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _nameSearchController.text = '';
                                  _isSearchVisible = false;
                                });
                                _searchFocusNode.unfocus();
                                _applyCurrentFiltersWithPagination();
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
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                        ),
              ),
              SizedBox(width: (10 * tabletWidthScale).w),
              // ✅ Filter Button (Admin style)
              Container(
                decoration: BoxDecoration(
                  // color: const Color(0xFFE8F1F2),
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
                        _searchController.text = _searchQuery;

                        _selectedCountryFilter = filters['country'] ?? [];
                        _selectedDeveloperFilter = filters['developer'] ?? [];
                        _selectedProjectFilter = filters['project'] ?? [];
                        _selectedStageFilter = filters['stage'] ?? [];
                        _selectedChannelFilter = filters['channel'] ?? [];
                        _selectedSalesFilter = filters['sales'] ?? [];
                        _selectedCommunicationWayFilter =
                            filters['communicationWay'] ?? [];
                        _selectedCampaignFilter = filters['campaign'] ?? [];

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
        padding: EdgeInsets.symmetric(
          horizontal: (16 * tabletWidthScale).w,
          vertical: (10 * tabletHeightScale).h,
        ),
        child: Column(
          children: [
            /// =========================
            /// TOP ACTION BAR (Admin Style)
            /// =========================
            if (selectedTab == 0 && _selectedLeads.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: (16 * tabletHeightScale).h),
                padding: EdgeInsets.symmetric(
                  horizontal: (16 * tabletWidthScale).w,
                  vertical: (14 * tabletHeightScale).h,
                ),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color(0xff1E1E1E),
                  borderRadius: BorderRadius.circular((18 * tabletScale).r),
                  border: Border.all(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade200
                            : Colors.grey.shade800,
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
                      width: (38 * tabletWidthScale).w,
                      height: (38 * tabletWidthScale).w,
                      decoration: BoxDecoration(
                        color: Constants.maincolor,
                        borderRadius: BorderRadius.circular(
                          (10 * tabletScale).r,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: (22 * tabletFontScale).sp,
                      ),
                    ),
                    SizedBox(width: (14 * tabletWidthScale).w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_selectedLeads.length} Leads",
                          style: TextStyle(
                            fontSize: (16 * tabletFontScale).sp,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                        Text(
                          "Selected",
                          style: TextStyle(
                            fontSize: (16 * tabletFontScale).sp,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: (15 * tabletWidthScale).w),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // =========================
                          // ASSIGN
                          // =========================
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
                                                : Constants.mainDarkmodecolor,
                                        leadIds: _selectedLeads.toList(),
                                        leadId: _selectedLeads.toList()[0],
                                        leadStages:
                                            _selectedLeadStagesIds.toList(),
                                        leadSalesId: _selectedSalesIds.toList(),
                                      ),
                                    );
                                  },
                                );
                                if (result == true) {
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.ios_share_outlined,
                                  color: Colors.grey.shade700,
                                  size: (25 * tabletFontScale).sp,
                                ),
                                SizedBox(height: (4 * tabletHeightScale).h),
                                Text(
                                  "ASSIGN",
                                  style: TextStyle(
                                    fontSize: (10 * tabletFontScale).sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: (50 * tabletHeightScale).h,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          // =========================
                          // EDIT
                          // =========================
                          InkWell(
                            onTap: () async {
                              final leadsList =
                                  context
                                      .read<GetLeadsMarketerCubit>()
                                      .leadsDatum;
                              final selectedLead = leadsList.firstWhere(
                                (lead) =>
                                    lead.id.toString() == _selectedLeads.first,
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
                                        initialNotes:
                                            selectedLead.jobdescription ?? '',
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
                                setState(() {
                                  _showCheckboxes = false;
                                  _selectedLeads.clear();
                                });
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: Colors.grey.shade700,
                                  size: (25 * tabletFontScale).sp,
                                ),
                                SizedBox(height: (4 * tabletHeightScale).h),
                                Text(
                                  "EDIT",
                                  style: TextStyle(
                                    fontSize: (10 * tabletFontScale).sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            /// =========================
            /// TABS + Create Lead Button
            /// =========================
            Container(
              padding: EdgeInsets.only(
                top: (4 * tabletHeightScale).h,
                bottom: (8 * tabletHeightScale).h,
              ),
              child: Row(
                children: [
                  /// MANAGE LEADS
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                          _searchQuery = '';
                          _nameSearchController.clear();
                          _searchController.clear();
                          _selectedCountryFilter = [];
                          _selectedDeveloperFilter = [];
                          _selectedProjectFilter = [];
                          _selectedStageFilter = [];
                          _selectedChannelFilter = [];
                          _selectedSalesFilter = [];
                          _selectedCommunicationWayFilter = [];
                          _selectedCampaignFilter = [];
                        });
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'All Leads',
                                style: TextStyle(
                                  fontSize: (16 * tabletFontScale).sp,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      selectedTab == 0
                                          ? Constants.maincolor
                                          : Colors.grey,
                                ),
                              ),

                              SizedBox(width: (8 * tabletWidthScale).w),

                              // ✅ Count Badge
                              BlocBuilder<
                                GetLeadsMarketerCubit,
                                GetLeadsMarketerState
                              >(
                                builder: (context, state) {
                                  final cubit =
                                      context.read<GetLeadsMarketerCubit>();
                                  final int count =
                                      _displayedLeadsCount > 0
                                          ? _displayedLeadsCount
                                          : context
                                              .read<GetLeadsMarketerCubit>()
                                              .totalLeads
                                              .toInt();

                                  if (count <= 0) {
                                    return const SizedBox.shrink();
                                  }

                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: (10 * tabletWidthScale).w,
                                      vertical: (4 * tabletHeightScale).h,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedTab == 0
                                              ? Constants.maincolor.withOpacity(
                                                0.12,
                                              )
                                              : Colors.grey.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(
                                        (20 * tabletScale).r,
                                      ),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: (13 * tabletFontScale).sp,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            selectedTab == 0
                                                ? Constants.maincolor
                                                : Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: (12 * tabletHeightScale).h),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: (3 * tabletHeightScale).h,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                              horizontal: (10 * tabletWidthScale).w,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedTab == 0
                                      ? Constants.maincolor
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                (20 * tabletScale).r,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: (8 * tabletWidthScale).w),

                  /// LEADS TRASH
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                          _searchQuery = '';
                          _nameSearchController.clear();
                          _searchController.clear();
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Leads Trash',
                                style: TextStyle(
                                  fontSize: (16 * tabletFontScale).sp,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      selectedTab == 1
                                          ? Constants.maincolor
                                          : Colors.grey,
                                ),
                              ),

                              SizedBox(width: (8 * tabletWidthScale).w),

                              // ✅ Trash Count Badge
                              BlocBuilder<
                                GetLeadsMarketerCubit,
                                GetLeadsMarketerState
                              >(
                                builder: (context, state) {
                                  final trashCount =
                                      context
                                          .read<GetLeadsMarketerCubit>()
                                          .totaltrashleads;

                                  if (trashCount > 0) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: (10 * tabletWidthScale).w,
                                        vertical: (4 * tabletHeightScale).h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            selectedTab == 1
                                                ? Constants.maincolor
                                                    .withOpacity(0.12)
                                                : Colors.grey.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(
                                          (20 * tabletScale).r,
                                        ),
                                      ),
                                      child: Text(
                                        '$trashCount',
                                        style: TextStyle(
                                          fontSize: (13 * tabletFontScale).sp,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              selectedTab == 1
                                                  ? Constants.maincolor
                                                  : Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: (12 * tabletHeightScale).h),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: (3 * tabletHeightScale).h,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                              horizontal: (10 * tabletWidthScale).w,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedTab == 1
                                      ? Constants.maincolor
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                (20 * tabletScale).r,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            /// =========================
            /// LEADS LIST
            /// =========================
            Expanded(
              child: BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
                buildWhen: (previous, current) {
                  if (current is GetLeadsMarketerPaginationLoading &&
                      current.isLoadingMore) {
                    return false;
                  }
                  return true;
                },
                builder: (context, state) {
                  if (state is GetLeadsMarketerPaginationLoading &&
                      !state.isLoadingMore) {
                    return const LeadsShimmer();
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
                          _searchController.clear();
                          _selectedCountryFilter = [];
                          _selectedDeveloperFilter = [];
                          _selectedProjectFilter = [];
                          _selectedChannelFilter = [];
                          _selectedSalesFilter = [];
                          _selectedCommunicationWayFilter = [];
                          _selectedCampaignFilter = [];
                          _selectedStageFilter = [];
                          _selectedSalesIdsFilter = null;
                          _selectedDeveloperIdsFilter = null;
                          _selectedProjectIdsFilter = null;
                          _selectedStageIdsFilter = null;
                          _selectedChannelIdsFilter = null;
                          _selectedCampaignIdsFilter = null;
                          _selectedCommunicationWayIdsFilter = null;
                          _startDate = null;
                          _endDate = null;
                          _lastStageUpdateStart = null;
                          _lastStageUpdateEnd = null;
                        });
                        final cubit = context.read<GetLeadsMarketerCubit>();
                        if (selectedTab == 0) {
                          await cubit.fetchLeadsMarketerWithPagination(
                            refresh: true,
                            ignoreDuplicate:
                                _showDuplicatesOnly == true ? true : null,
                            data: widget.data,
                            transferefromdata: widget.transferefromdata,
                            stageIds:
                                widget.stageName != null &&
                                        widget.stageName!.isNotEmpty
                                    ? [widget.stageName!]
                                    : null,
                          );
                        } else {
                          await cubit.getLeadsByMarketerInTrash();
                        }
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: leads.length + (cubit.hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= leads.length) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          bool isOutdated = false;
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

                          final bool isFinalStage =
                              stageUpdatedDate != null &&
                              (leadStagetype == "Done Deal" ||
                                  leadStagetype == "Pending" ||
                                  leadStagetype == "Transfer" ||
                                  leadStagetype == "Fresh" ||
                                  leadStagetype == "Not Interested");

                          final String statusText;
                          final Color statusBgColor;
                          final Color statusTextColor;
                          if (leadassign == false &&
                              lead.stage?.name != 'Fresh') {
                            statusText = 'Approved';
                            statusBgColor = Colors.green.shade200;
                            statusTextColor = Colors.green.shade800;
                          } else if (lead.stage?.name == 'Fresh') {
                            statusText = 'Not Assigned';
                            statusBgColor = Colors.grey.shade300;
                            statusTextColor = Colors.grey.shade700;
                          } else {
                            statusText = 'Assigned';
                            statusBgColor = Constants.maincolor.withOpacity(
                              0.25,
                            );
                            statusTextColor = Constants.maincolor;
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
                                          campaignlink:
                                              lead.campaign?.redirectLink ??
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
                                          salesFcmTokens:
                                              lead.sales?.userlog?.fcmTokens
                                                  ?.map((e) => e.token ?? '')
                                                  .where((t) => t.isNotEmpty)
                                                  .toList(),
                                        ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                vertical: (10 * tabletHeightScale).h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _selectedLeads.contains(lead.id)
                                        ? (Theme.of(context).brightness ==
                                                Brightness.light
                                            ? const Color(0xffF3F4F6)
                                            : const Color(0xff1F2937))
                                        : (Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : const Color(0xff111827)),
                                borderRadius: BorderRadius.circular(
                                  (22 * tabletScale).r,
                                ),
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
                                    /// LEFT COLOR BAR
                                    Container(
                                      width: (5 * tabletWidthScale).w,
                                      decoration: BoxDecoration(
                                        color:
                                            (() {
                                              if (leadStagetype == "Fresh") {
                                                return Constants.maincolor;
                                              } else if (leadStagetype ==
                                                      "Follow Up" &&
                                                  isOutdated) {
                                                return Colors.orangeAccent;
                                              } else if (leadStagetype ==
                                                      "Follow" &&
                                                  isOutdated) {
                                                return Colors.orangeAccent;
                                              } else if (leadStagetype ==
                                                      "No Stage" &&
                                                  isOutdated) {
                                                return Colors.orangeAccent;
                                              } else if (leadStagetype ==
                                                      "Follow After Meeting" &&
                                                  isOutdated) {
                                                return Colors.orangeAccent;
                                              } else if (leadStagetype ==
                                                      "No Answer" &&
                                                  isOutdated) {
                                                return Colors.orangeAccent;
                                              } else if (leadStagetype ==
                                                      "Meeting" &&
                                                  isOutdated) {
                                                return Colors.orangeAccent;
                                              } else if (leadStagetype ==
                                                      "Interested" &&
                                                  isOutdated) {
                                                return Colors.orangeAccent;
                                              } else if (leadStagetype ==
                                                      "Not Interested" ||
                                                  leadStagetype == "Transfer") {
                                                return Colors.black;
                                              } else {
                                                return Constants.maincolor;
                                              }
                                            })(),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                            (22 * tabletScale).r,
                                          ),
                                          bottomLeft: Radius.circular(
                                            (22 * tabletScale).r,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: (18 * tabletWidthScale).w,
                                          vertical: (18 * tabletHeightScale).h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// =========================
                                            /// TOP ROW
                                            /// =========================
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      if (_showCheckboxes &&
                                                          _selectedLeads
                                                              .isNotEmpty)
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                            right:
                                                                (8 * tabletWidthScale)
                                                                    .w,
                                                          ),
                                                          child: Checkbox(
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            activeColor:
                                                                Constants
                                                                    .maincolor,
                                                            value:
                                                                _selectedLeads
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
                                                                  _selectedSalesIds
                                                                      .add(
                                                                        lead.sales?.id ??
                                                                            '',
                                                                      );
                                                                  _selectedLeadStagesIds
                                                                      .add(
                                                                        lead.stage?.id ??
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
                                                                  if (_selectedLeads
                                                                      .isEmpty) {
                                                                    _showCheckboxes =
                                                                        false;
                                                                  }
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      Builder(
                                                        builder: (_) {
                                                          final Color
                                                          stageColor;
                                                          if (leadStagetype ==
                                                                  "Not Interested" ||
                                                              leadStagetype ==
                                                                  "Transfer") {
                                                            stageColor =
                                                                Colors.black;
                                                          } else {
                                                            stageColor =
                                                                isFinalStage
                                                                    ? Constants
                                                                        .maincolor
                                                                    : isOutdated
                                                                    ? const Color(
                                                                      0xffFEB300,
                                                                    )
                                                                    : Constants
                                                                        .maincolor;
                                                          }

                                                          return Flexible(
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(
                                                                horizontal:
                                                                    (18 *
                                                                            tabletWidthScale)
                                                                        .w,
                                                                vertical:
                                                                    (8 *
                                                                            tabletHeightScale)
                                                                        .h,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    (lead.stage?.name ==
                                                                                    "Follow Up" ||
                                                                                lead.stage?.name ==
                                                                                    "Follow After Meeting" ||
                                                                                lead.stage?.name ==
                                                                                    "Follow" ||
                                                                                lead.stage?.name ==
                                                                                    "Meeting" ||
                                                                                lead.stage?.name ==
                                                                                    "No Answer" ||
                                                                                lead.stage?.name ==
                                                                                    "No Stage" ||
                                                                                leadStagetype ==
                                                                                    "Interested") &&
                                                                            isOutdated
                                                                        ? stageColor
                                                                        : stageColor
                                                                            .withOpacity(
                                                                              0.15,
                                                                            ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      (10 *
                                                                              tabletScale)
                                                                          .r,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                ((lead.stage?.name ??
                                                                                "No Stage")
                                                                            .length >
                                                                        10)
                                                                    ? "${(lead.stage?.name ?? "No Stage").substring(0, 10).toUpperCase()}..."
                                                                    : (lead.stage?.name ??
                                                                            "No Stage")
                                                                        .toUpperCase(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      (10 *
                                                                              tabletFontScale)
                                                                          .sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  letterSpacing:
                                                                      1,
                                                                  color:
                                                                      (lead.stage?.name ==
                                                                                      "Follow Up" ||
                                                                                  lead.stage?.name ==
                                                                                      "Follow After Meeting" ||
                                                                                  lead.stage?.name ==
                                                                                      "Follow" ||
                                                                                  lead.stage?.name ==
                                                                                      "Meeting" ||
                                                                                  lead.stage?.name ==
                                                                                      "No Answer" ||
                                                                                  lead.stage?.name ==
                                                                                      "No Stage" ||
                                                                                  leadStagetype ==
                                                                                      "Interested") &&
                                                                              isOutdated
                                                                          ? const Color(
                                                                            0xff6A4800,
                                                                          )
                                                                          : stageColor,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      (10 * tabletWidthScale).w,
                                                ),
                                                Text(
                                                  lead.stagedateupdated != null
                                                      ? formatDateTimeToDubai(
                                                        lead.stagedateupdated!
                                                            .toIso8601String(),
                                                      )
                                                      : "N/A",
                                                  style: TextStyle(
                                                    fontSize:
                                                        (11 * tabletFontScale)
                                                            .sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height:
                                                  (12 * tabletHeightScale).h,
                                            ),

                                            /// NAME
                                            Text(
                                              lead.name ?? "No Name",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize:
                                                    (24 * tabletFontScale).sp,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? const Color(
                                                          0xff111827,
                                                        )
                                                        : Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: (4 * tabletHeightScale).h,
                                            ),

                                            /// PROJECT
                                            Text(
                                              (lead.project?.name ?? "")
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize:
                                                    (12 * tabletFontScale).sp,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                                color: Constants.maincolor,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  (15 * tabletHeightScale).h,
                                            ),

                                            /// SALESMAN + CREATED
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "SALESMAN",
                                                        style: TextStyle(
                                                          fontSize:
                                                              (10 * tabletFontScale)
                                                                  .sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 1.2,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade500,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            (6 * tabletHeightScale)
                                                                .h,
                                                      ),
                                                      Text(
                                                        lead.sales?.name ??
                                                            'N/A',
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              (16 * tabletFontScale)
                                                                  .sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      (20 * tabletWidthScale).w,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "CREATED",
                                                      style: TextStyle(
                                                        fontSize:
                                                            (10 * tabletFontScale)
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 1.2,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade500,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          (6 * tabletHeightScale)
                                                              .h,
                                                    ),
                                                    Text(
                                                      lead.date != null
                                                          ? formatDateTimeToDubai(
                                                            lead.date!
                                                                .toIso8601String(),
                                                          )
                                                          : "N/A",
                                                      style: TextStyle(
                                                        fontSize:
                                                            (12 * tabletFontScale)
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: (5 * tabletHeightScale).h,
                                            ),
                                            Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1,
                                            ),
                                            SizedBox(
                                              height: (5 * tabletHeightScale).h,
                                            ),

                                            /// PHONE + ACTIONS
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      final phone =
                                                          lead.phone ?? '';
                                                      String formatted;
                                                      if (phone.startsWith(
                                                        '+',
                                                      )) {
                                                        formatted = phone;
                                                      } else if (phone
                                                          .startsWith('0')) {
                                                        formatted = phone;
                                                      } else {
                                                        formatted = '+$phone';
                                                      }
                                                      makePhoneCall(formatted);
                                                    },
                                                    child: Text(
                                                      lead.phone ?? 'N/A',
                                                      style: TextStyle(
                                                        fontSize:
                                                            (16 * tabletFontScale)
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    /// PHONE
                                                    InkWell(
                                                      onTap: () {
                                                        final phone =
                                                            lead.phone ?? '';
                                                        String formatted;
                                                        if (phone.startsWith(
                                                          '+',
                                                        )) {
                                                          formatted = phone;
                                                        } else if (phone
                                                            .startsWith('0')) {
                                                          formatted = phone;
                                                        } else {
                                                          formatted = '+$phone';
                                                        }
                                                        makePhoneCall(
                                                          formatted,
                                                        );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            (40 * tabletScale)
                                                                .r,
                                                          ),
                                                      child: Container(
                                                        width:
                                                            (46 * tabletWidthScale)
                                                                .w,
                                                        height:
                                                            (46 * tabletWidthScale)
                                                                .w,
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .phone_in_talk_outlined,
                                                          color:
                                                              Constants
                                                                  .maincolor,
                                                          size:
                                                              (22 * tabletFontScale)
                                                                  .sp,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          (8 * tabletWidthScale)
                                                              .w,
                                                    ),

                                                    /// WHATSAPP
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
                                                            (40 * tabletScale)
                                                                .r,
                                                          ),
                                                      child: Container(
                                                        width:
                                                            (46 * tabletWidthScale)
                                                                .w,
                                                        height:
                                                            (46 * tabletWidthScale)
                                                                .w,
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xffDCFCE7,
                                                                  ),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: Center(
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .whatsapp,
                                                            color: Colors.green,
                                                            size:
                                                                (24 * tabletFontScale)
                                                                    .sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          (8 * tabletWidthScale)
                                                              .w,
                                                    ),

                                                    /// COMMENT ICON ✅
                                                    InkWell(
                                                      onTap: () {
                                                        final firstCommentText =
                                                            lead
                                                                        .lastComment
                                                                        ?.firstcomment
                                                                        ?.text
                                                                        ?.isNotEmpty ==
                                                                    true
                                                                ? lead
                                                                    .lastComment!
                                                                    .firstcomment!
                                                                    .text!
                                                                : 'No comments available.';
                                                        final secondCommentText =
                                                            lead
                                                                        .lastComment
                                                                        ?.secondcomment
                                                                        ?.text
                                                                        ?.isNotEmpty ==
                                                                    true
                                                                ? lead
                                                                    .lastComment!
                                                                    .secondcomment!
                                                                    .text!
                                                                : 'No action available.';

                                                        showDialog(
                                                          context: context,
                                                          builder:
                                                              (_) => Dialog(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        (16 *
                                                                                tabletScale)
                                                                            .r,
                                                                      ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        (18 *
                                                                                tabletScale)
                                                                            .r,
                                                                      ),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Last Comment",
                                                                        style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              (18 *
                                                                                      tabletFontScale)
                                                                                  .sp,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            (12 *
                                                                                    tabletHeightScale)
                                                                                .h,
                                                                      ),
                                                                      Text(
                                                                        firstCommentText,
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              (14 *
                                                                                      tabletFontScale)
                                                                                  .sp,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            (18 *
                                                                                    tabletHeightScale)
                                                                                .h,
                                                                      ),
                                                                      Text(
                                                                        "Action (Plan)",
                                                                        style: TextStyle(
                                                                          color:
                                                                              Constants.maincolor,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              (15 *
                                                                                      tabletFontScale)
                                                                                  .sp,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            (8 *
                                                                                    tabletHeightScale)
                                                                                .h,
                                                                      ),
                                                                      Text(
                                                                        secondCommentText,
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              (14 *
                                                                                      tabletFontScale)
                                                                                  .sp,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                        );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            (40 * tabletScale)
                                                                .r,
                                                          ),
                                                      child: Container(
                                                        width:
                                                            (46 * tabletWidthScale)
                                                                .w,
                                                        height:
                                                            (46 * tabletWidthScale)
                                                                .w,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Constants
                                                                  .maincolor
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .comment_outlined,
                                                          color:
                                                              Constants
                                                                  .maincolor,
                                                          size:
                                                              (22 * tabletFontScale)
                                                                  .sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // SizedBox(
                                            //   height:
                                            //       (10 * tabletHeightScale).h,
                                            // ),

                                            // /// COMMENT BOX
                                            // if (lead
                                            //             .lastComment
                                            //             ?.firstcomment
                                            //             ?.text
                                            //             ?.isNotEmpty ==
                                            //         true ||
                                            //     lead
                                            //             .lastComment
                                            //             ?.secondcomment
                                            //             ?.text
                                            //             ?.isNotEmpty ==
                                            //         true)
                                            //   InkWell(
                                            //     onTap: () {
                                            //       final String
                                            //       firstCommentText =
                                            //           lead
                                            //                       .lastComment
                                            //                       ?.firstcomment
                                            //                       ?.text
                                            //                       ?.isNotEmpty ==
                                            //                   true
                                            //               ? lead
                                            //                   .lastComment!
                                            //                   .firstcomment!
                                            //                   .text!
                                            //               : 'No comments available.';
                                            //       final String
                                            //       secondCommentText =
                                            //           lead
                                            //                       .lastComment
                                            //                       ?.secondcomment
                                            //                       ?.text
                                            //                       ?.isNotEmpty ==
                                            //                   true
                                            //               ? lead
                                            //                   .lastComment!
                                            //                   .secondcomment!
                                            //                   .text!
                                            //               : 'No action available.';
                                            //       showDialog(
                                            //         context: context,
                                            //         builder: (_) {
                                            //           return Dialog(
                                            //             shape: RoundedRectangleBorder(
                                            //               borderRadius:
                                            //                   BorderRadius.circular(
                                            //                     (16 * tabletScale)
                                            //                         .r,
                                            //                   ),
                                            //             ),
                                            //             child: Padding(
                                            //               padding: EdgeInsets.all(
                                            //                 (18 * tabletScale)
                                            //                     .r,
                                            //               ),
                                            //               child: Column(
                                            //                 mainAxisSize:
                                            //                     MainAxisSize
                                            //                         .min,
                                            //                 crossAxisAlignment:
                                            //                     CrossAxisAlignment
                                            //                         .start,
                                            //                 children: [
                                            //                   Text(
                                            //                     "Last Comment",
                                            //                     style: TextStyle(
                                            //                       fontWeight:
                                            //                           FontWeight
                                            //                               .w700,
                                            //                       fontSize:
                                            //                           (18 *
                                            //                                   tabletFontScale)
                                            //                               .sp,
                                            //                     ),
                                            //                   ),
                                            //                   SizedBox(
                                            //                     height:
                                            //                         (12 *
                                            //                                 tabletHeightScale)
                                            //                             .h,
                                            //                   ),
                                            //                   Text(
                                            //                     firstCommentText,
                                            //                     style: TextStyle(
                                            //                       fontSize:
                                            //                           (14 *
                                            //                                   tabletFontScale)
                                            //                               .sp,
                                            //                     ),
                                            //                   ),
                                            //                   SizedBox(
                                            //                     height:
                                            //                         (18 *
                                            //                                 tabletHeightScale)
                                            //                             .h,
                                            //                   ),
                                            //                   Text(
                                            //                     "Action (Plan)",
                                            //                     style: TextStyle(
                                            //                       color:
                                            //                           Constants
                                            //                               .maincolor,
                                            //                       fontWeight:
                                            //                           FontWeight
                                            //                               .w700,
                                            //                       fontSize:
                                            //                           (15 *
                                            //                                   tabletFontScale)
                                            //                               .sp,
                                            //                     ),
                                            //                   ),
                                            //                   SizedBox(
                                            //                     height:
                                            //                         (8 *
                                            //                                 tabletHeightScale)
                                            //                             .h,
                                            //                   ),
                                            //                   Text(
                                            //                     secondCommentText,
                                            //                     style: TextStyle(
                                            //                       fontSize:
                                            //                           (14 *
                                            //                                   tabletFontScale)
                                            //                               .sp,
                                            //                     ),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           );
                                            //         },
                                            //       );
                                            //     },
                                            //     child: Container(
                                            //       width: double.infinity,
                                            //       padding: EdgeInsets.symmetric(
                                            //         horizontal:
                                            //             (14 * tabletWidthScale)
                                            //                 .w,
                                            //         vertical:
                                            //             (14 * tabletHeightScale)
                                            //                 .h,
                                            //       ),
                                            //       decoration: BoxDecoration(
                                            //         color:
                                            //             Theme.of(
                                            //                       context,
                                            //                     ).brightness ==
                                            //                     Brightness.light
                                            //                 ? const Color(
                                            //                   0xffF3F4F6,
                                            //                 )
                                            //                 : Colors
                                            //                     .grey
                                            //                     .shade800,
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //               (14 * tabletScale).r,
                                            //             ),
                                            //       ),
                                            //       child: Text(
                                            //         lead
                                            //                     .lastComment
                                            //                     ?.firstcomment
                                            //                     ?.text
                                            //                     ?.isNotEmpty ==
                                            //                 true
                                            //             ? '"${lead.lastComment!.firstcomment!.text!}"'
                                            //             : lead
                                            //                     .lastComment
                                            //                     ?.secondcomment
                                            //                     ?.text
                                            //                     ?.isNotEmpty ==
                                            //                 true
                                            //             ? '"${lead.lastComment!.secondcomment!.text!}"'
                                            //             : '',
                                            //         maxLines: 3,
                                            //         overflow:
                                            //             TextOverflow.ellipsis,
                                            //         style: TextStyle(
                                            //           fontSize:
                                            //               (14 * tabletFontScale)
                                            //                   .sp,
                                            //           height: 1.6,
                                            //           color:
                                            //               Colors.grey.shade700,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
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
                      ),
                    );
                  } else if (state is GetLeadsMarketerPaginationFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('failed to load more leads:'),
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
                    return const LeadsShimmer();
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
