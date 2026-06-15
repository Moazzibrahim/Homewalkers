// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_local_variable, deprecated_member_use, use_build_context_synchronously, unused_field
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/meeting/get_meeting_comments.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_dashboard_leads_count.dart';
import 'package:homewalkers_app/data/models/stages_models.dart';
import 'package:homewalkers_app/data/models/teamleader_pagination_leads_model.dart';
import 'package:homewalkers_app/presentation/screens/Admin/meetingCommentsScreen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/leads_details_team_leader_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/teamleader_data_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/meeting/cubit/meetingcomments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/cubit/teamleader_dashboard_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/custom_assign_dialog_team_leader_widget.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/custom_filter_teamleader_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/edit_lead_sales_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamLeaderAssignScreen extends StatefulWidget {
  final String? stageName;
  final bool? transferfromdata;
  final bool? data;
  final String? salesName;
  final String? stageId;
  const TeamLeaderAssignScreen({
    super.key,
    this.stageName,
    this.transferfromdata,
    this.data,
    this.salesName,
    this.stageId,
  });

  @override
  _SalesAssignLeadsScreenState createState() => _SalesAssignLeadsScreenState();
}

class _SalesAssignLeadsScreenState extends State<TeamLeaderAssignScreen> {
  List<bool> selected = [];
  List<LeadDataPagination> _leads = [];
  LeadDataPagination? leadResponse;
  String? leadIdd;
  TextEditingController searchController = TextEditingController();
  String? salesfcmtoken;
  String? managerfcmtoken;
  String? teamleadname;
  String? teamleadid;
  bool isLoading = false;
  bool isSelectionMode = false;
  String? _selectedLeadId;
  LeadDataPagination? _selectedLead;
  List<LeadDataPagination> selectedLeadsData = [];
  late ScrollController _scrollController;
  bool _selectAll = false;
  int _selectedCount = 0;
  late ResponsiveSalesValues _responsive;
  Timer? _debounce;
  bool _isSearchVisible = false;
  final FocusNode _searchFocusNode = FocusNode();
  late GetLeadsTeamLeaderCubit _cubit;
  String? _currentFilterName;
  String? _currentFilterDeveloperId;
  String? _currentFilterProjectId;
  String? _currentFilterStageId;
  String? _currentFilterChannelId;
  String? _currentFilterSalesId;
  DateTime? _currentFilterCreationDateFrom;
  DateTime? _currentFilterCreationDateTo;
  DateTime? _currentFilterStageDateFrom;
  DateTime? _currentFilterStageDateTo;
  bool _isFetchingMore = false;

  // ✅ دالة لتحديث الفلاتر من الـ Dialog
  void _updateFilters({
    String? name,
    String? developerId,
    String? projectId,
    String? stageId,
    String? channelId,
    String? salesId,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
  }) {
    setState(() {
      _currentFilterName = name;
      _currentFilterDeveloperId = developerId;
      _currentFilterProjectId = projectId;
      _currentFilterStageId = stageId;
      _currentFilterChannelId = channelId;
      _currentFilterSalesId = salesId;
      _currentFilterCreationDateFrom = creationDateFrom;
      _currentFilterCreationDateTo = creationDateTo;
      _currentFilterStageDateFrom = stageDateFrom;
      _currentFilterStageDateTo = stageDateTo;
    });
  }

  // ✅ دالة لجلب الفلاتر الحالية كـ Map (اختياري)
  Map<String, dynamic> _getCurrentFilters() {
    return {
      if (_currentFilterName != null && _currentFilterName!.isNotEmpty)
        'name': _currentFilterName,
      if (_currentFilterDeveloperId != null &&
          _currentFilterDeveloperId!.isNotEmpty)
        'developerId': _currentFilterDeveloperId,
      if (_currentFilterProjectId != null &&
          _currentFilterProjectId!.isNotEmpty)
        'projectId': _currentFilterProjectId,
      if (_currentFilterStageId != null && _currentFilterStageId!.isNotEmpty)
        'stageId': _currentFilterStageId,
      if (_currentFilterChannelId != null &&
          _currentFilterChannelId!.isNotEmpty)
        'channelId': _currentFilterChannelId,
      if (_currentFilterSalesId != null && _currentFilterSalesId!.isNotEmpty)
        'salesId': _currentFilterSalesId,
      if (_currentFilterCreationDateFrom != null)
        'creationDateFrom': _currentFilterCreationDateFrom,
      if (_currentFilterCreationDateTo != null)
        'creationDateTo': _currentFilterCreationDateTo,
      if (_currentFilterStageDateFrom != null)
        'stageDateFrom': _currentFilterStageDateFrom,
      if (_currentFilterStageDateTo != null)
        'stageDateTo': _currentFilterStageDateTo,
    };
  }

  void _updateSelectedCount() {
    setState(() {
      _selectedCount = selected.where((isSelected) => isSelected).length;
      _selectAll = _selectedCount == _leads.length && _leads.isNotEmpty;
    });
  }

  void _toggleSelectAll(bool? value) {
    if (value == null) return;
    setState(() {
      _selectAll = value;
      for (int i = 0; i < selected.length; i++) {
        final lead = _leads[i];
        final bool hasDownloadIcon =
            (lead.assign == true && lead.sales?.userlog?.name == teamleadname);
        if (!hasDownloadIcon) {
          selected[i] = _selectAll;
          final leadIdStr = lead.id.toString();
          if (_selectAll) {
            if (!selectedLeadsData.any((l) => l.id.toString() == leadIdStr)) {
              selectedLeadsData.add(lead);
            }
          } else {
            selectedLeadsData.removeWhere((l) => l.id.toString() == leadIdStr);
          }
        }
      }
      isSelectionMode = selected.contains(true);
      _selectedCount = _selectAll ? selected.where((s) => s).length : 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    log("Stage Name in Assign Screen: ${widget.stageName}");
    log("data in Assign Screen: ${widget.data}");
    log("transferfromdata in Assign Screen: ${widget.transferfromdata}");

    _cubit = GetLeadsTeamLeaderCubit(GetLeadsService());
    searchController.clear();
    _loadLeads();
    context.read<SalesCubit>().fetchAllSales();
    _initUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedCount();
    });
  }

  Future<void> _initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      teamleadname = prefs.getString('name');
      teamleadid = prefs.getString('salesId');
    });
  }

  Future<void> _loadLeads() async {
    searchController.clear();
    await _cubit.fetchTeamLeaderLeadsWithPagination(
      data: widget.data,
      transferefromdata: widget.transferfromdata,
      stageId: widget.stageId,
      resetPagination: true,
      salesId: widget.salesName,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_cubit.hasMoreData && !_cubit.isFetchingMore && !_isFetchingMore) {
        setState(() => _isFetchingMore = true);
        _cubit
            .fetchTeamLeaderLeadsWithPagination(
              isLoadMore: true,
              limit: 10,
              data: widget.data,
              transferefromdata: widget.transferfromdata,
              stageId: widget.stageId,
              salesId: _currentFilterSalesId ?? widget.salesName,
              search:
                  searchController.text.isNotEmpty
                      ? searchController.text
                      : null,
            )
            .then((_) {
              if (mounted) setState(() => _isFetchingMore = false);
            });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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

  bool get isTablet {
    final data = MediaQuery.of(context);
    final physicalSize = data.size;
    final diagonal = math.sqrt(
      math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160);
    return inches >= 7.0;
  }

  @override
  Widget build(BuildContext context) {
    _responsive = ResponsiveSalesValues.fromContext(context);

    return BlocProvider.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
          final bool isTabletDevice = isTablet;
          final double tabletScale = isTabletDevice ? 0.85 : 1.0;
          final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
          final double tabletWidthScale = isTabletDevice ? 0.8 : 1.0;
          final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;

          return Scaffold(
            backgroundColor:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.backgroundlightmode
                    : Constants.backgroundDarkmode,
            appBar: CustomAppBar(
              title: _isSearchVisible ? null : "Leads",
              onBack: () {
                if (widget.transferfromdata == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeamLeaderTabsScreen(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BlocProvider(
                            create:
                                (context) => TeamleaderDashboardCubit(
                                  TeamleaderDashboardApiService(),
                                ),
                            child: const TeamleaderDataDashboardScreen(),
                          ),
                    ),
                  );
                }
              },
              extraActions: [
                BlocBuilder<GetLeadsTeamLeaderCubit, GetLeadsTeamLeaderState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ زر البحث المتغير
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
                                                    .read<
                                                      GetLeadsTeamLeaderCubit
                                                    >();
                                            _debounce?.cancel();
                                            _debounce = Timer(
                                              const Duration(milliseconds: 500),
                                              () {
                                                cubit
                                                    .fetchTeamLeaderLeadsWithPagination(
                                                      search: value.trim(),
                                                      stageId: widget.stageId,
                                                      data: widget.data,
                                                      transferefromdata:
                                                          widget
                                                              .transferfromdata,
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
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

                                          // إعادة تحميل البيانات بدون بحث
                                          final cubit =
                                              context
                                                  .read<
                                                    GetLeadsTeamLeaderCubit
                                                  >();
                                          cubit
                                              .fetchTeamLeaderLeadsWithPagination(
                                                search: null,
                                                data: widget.data,
                                                transferefromdata:
                                                    widget.transferfromdata,
                                                stageId:
                                                    _currentFilterStageId ??
                                                    widget.stageId, // ✅
                                                salesId:
                                                    _currentFilterSalesId ??
                                                    widget.salesName, // ✅
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
                        // ✅ زر الفلتر
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            // في build method داخل IconButton الفلتر
                            onPressed: () {
                              showFilterDialogTeamLeader(
                                context,
                                context.read<GetLeadsTeamLeaderCubit>(),
                                widget.data,
                                widget.transferfromdata,
                                (filters) {
                                  // ✅ استقبال الفلاتر من الـ Dialog
                                  _updateFilters(
                                    name: filters['name'],
                                    developerId: filters['developerId'],
                                    projectId: filters['projectId'],
                                    stageId: filters['stageId'],
                                    channelId: filters['channelId'],
                                    salesId: filters['salesId'],
                                    creationDateFrom:
                                        filters['creationDateFrom'],
                                    creationDateTo: filters['creationDateTo'],
                                    stageDateFrom: filters['stageDateFrom'],
                                    stageDateTo: filters['stageDateTo'],
                                  );
                                },
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
                // ── ACTION BAR (assign / edit / meeting) ──
                if (isSelectionMode) _buildActionBar(isTabletDevice),

                // ── SELECT ALL HEADER ──
                // if (_leads.isNotEmpty) _buildSelectAllHeader(isTabletDevice),

                // ── LEADS LIST ──
                Expanded(
                  child: BlocBuilder<
                    GetLeadsTeamLeaderCubit,
                    GetLeadsTeamLeaderState
                  >(
                    builder: (context, state) {
                      if (state is GetLeadsTeamLeaderPaginationLoading) {
                        return _buildShimmerLoading();
                      } else if (state is GetLeadsTeamLeaderPaginationSuccess) {
                        _leads =
                            _cubit
                                .paginatedLeads; // ← من الـ cubit مش من الـ state

                        // ✅ فقط extend الـ selected list لو اتضافت عناصر جديدة
                        while (selected.length < _leads.length) {
                          selected.add(false);
                        }

                        final int crossAxisCount = isTabletDevice ? 2 : 1;

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<GetLeadsTeamLeaderCubit>()
                                .fetchTeamLeaderLeadsWithPagination(
                                  data: widget.data,
                                  transferefromdata: widget.transferfromdata,
                                  stageId:
                                      _currentFilterStageId ??
                                      widget.stageId, // ✅
                                  salesId:
                                      _currentFilterSalesId ??
                                      widget.salesName, // ✅
                                  // ✅ مهم عشان يبدأ من الأول
                                );
                          },
                          color: Constants.maincolor,
                          child:
                              crossAxisCount == 1
                                  ? ListView.builder(
                                    controller: _scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          _responsive.cardMarginHorizontal.w,
                                      vertical:
                                          _responsive.cardMarginVertical.h,
                                    ),
                                    itemCount: _leads.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index >= _leads.length) {
                                        if (context
                                            .read<GetLeadsTeamLeaderCubit>()
                                            .hasMoreData) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20.h,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const CircularProgressIndicator(),
                                                  SizedBox(height: 8.h),
                                                  Text(
                                                    "Loading more leads...",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        } else if (_leads.isNotEmpty) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20.h,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "✓ All leads loaded (${_leads.length} total)",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      }

                                      final lead = _leads[index];
                                      return _buildLeadCard(
                                        lead: lead,
                                        index: index,
                                        parentContext: context,
                                      );
                                    },
                                  )
                                  : GridView.builder(
                                    padding: EdgeInsets.all(16.r),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: 0.85,
                                          crossAxisSpacing: 16.w,
                                          mainAxisSpacing: 16.h,
                                        ),
                                    itemCount:
                                        _leads.length +
                                        (_isFetchingMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _leads.length) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 20.h,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 18.w,
                                                height: 18.w,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Constants.maincolor),
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
                                      final lead = _leads[index];
                                      return _buildLeadCard(
                                        lead: lead,
                                        index: index,
                                        parentContext: context,
                                      );
                                    },
                                  ),
                        );
                      } else if (state is GetLeadsTeamLeaderPaginationError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Text(
                              state.message,
                              style: TextStyle(fontSize: 16.sp),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            "No leads found.",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SELECT ALL HEADER
  // ─────────────────────────────────────────────────────────────
  // Widget _buildSelectAllHeader(bool isTabletDevice) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(
  //       horizontal: _responsive.cardMarginHorizontal.w,
  //       vertical: 8.h,
  //     ),
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
  //     decoration: BoxDecoration(
  //       color:
  //           Theme.of(context).brightness == Brightness.light
  //               ? Colors.white
  //               : Colors.grey[900],
  //       borderRadius: BorderRadius.circular(12.r),
  //       border: Border.all(
  //         color:
  //             _selectAll ? Constants.maincolor : Colors.grey.withOpacity(0.3),
  //         width: 1.5.r,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Checkbox(
  //           value: _selectAll,
  //           onChanged: _leads.isEmpty ? null : _toggleSelectAll,
  //           activeColor: Constants.maincolor,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(5.r),
  //           ),
  //         ),
  //         SizedBox(width: 8.w),
  //         Expanded(
  //           child: Text(
  //             "Select All",
  //             style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //         Container(
  //           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  //           decoration: BoxDecoration(
  //             color: Constants.maincolor.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(20.r),
  //           ),
  //           child: Text(
  //             _selectedCount > 0 ? "$_selectedCount selected" : "0 selected",
  //             style: TextStyle(
  //               fontSize: 14.sp,
  //               fontWeight: FontWeight.w600,
  //               color: Constants.maincolor,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ─────────────────────────────────────────────────────────────
  // ACTION BAR  (same logic as buildAssignButtons, new design)
  // ─────────────────────────────────────────────────────────────
  Widget _buildActionBar(bool isTabletDevice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // إذا كانت الشيكات غير ظاهرة أو مفيش حاجة مختارة
    if (!isSelectionMode || selectedLeadsData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: 8.h,
        left: _responsive.cardMarginHorizontal.w,
        right: _responsive.cardMarginHorizontal.w,
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
                "${selectedLeadsData.length} ${selectedLeadsData.length == 1 ? 'Lead' : 'Leads'}",
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
                Container(height: 50.h, width: 1, color: Colors.grey.shade300),

                // =========================
                // ASSIGN
                // =========================
                InkWell(
                  onTap: () {
                    if (selectedLeadsData.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select at least one lead"),
                        ),
                      );
                      return;
                    }
                    _showAssignDialog(widget.data!, widget.transferfromdata!);
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
                Container(height: 50.h, width: 1, color: Colors.grey.shade300),

                // =========================
                // EDIT - يشتغل بس لو مختار 1
                // =========================
                InkWell(
                  onTap:
                      selectedLeadsData.length == 1
                          ? () async {
                            if (_selectedLead != null) {
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
                                              (_) => SalesCubit(
                                                GetAllSalesApiService(),
                                              )..fetchAllSales(),
                                        ),
                                      ],
                                      child: EditLeadSalesDialog(
                                        userId: _selectedLead!.id ?? '',
                                        initialName: _selectedLead!.name ?? '',
                                        initialPhone2:
                                            _selectedLead!.phonenumber2 ?? '',
                                        initialWhatsappNumber:
                                            _selectedLead!.whatsappnumber ?? '',
                                        initialNotes: '',
                                        initialProjectId:
                                            _selectedLead!.project?.id,
                                        salesID: _selectedLead!.sales?.id ?? '',
                                        onSuccess: () async {
                                          setState(() {
                                            selected.clear();
                                            selectedLeadsData.clear();
                                            _selectedLead = null;
                                            isSelectionMode = false;
                                          });
                                          await _cubit
                                              .fetchTeamLeaderLeadsWithPagination(
                                                data: widget.data,
                                                transferefromdata:
                                                    widget.transferfromdata,
                                                stageId: widget.stageId,
                                              );
                                          setState(() {});
                                        },
                                      ),
                                    ),
                              );
                              if (result == true) {
                                setState(() {
                                  selected.clear();
                                  selectedLeadsData.clear();
                                  _selectedLead = null;
                                  isSelectionMode = false;
                                });
                                await _cubit.fetchTeamLeaderLeadsWithPagination(
                                  data: widget.data,
                                  transferefromdata: widget.transferfromdata,
                                  stageId:
                                      _currentFilterStageId ?? widget.stageId,
                                  // ✅ البحث الحالي
                                  search:
                                      searchController.text.isNotEmpty
                                          ? searchController.text
                                          : null,
                                  // ✅ جميع الفلاتر المخزنة
                                  developerId: _currentFilterDeveloperId,
                                  projectId:
                                      _currentFilterProjectId, // استخدم stageId من الفلتر إذا وجد
                                  channelId: _currentFilterChannelId,
                                  salesId:
                                      _currentFilterSalesId ?? widget.salesName,
                                  creationDateFrom:
                                      _currentFilterCreationDateFrom,
                                  creationDateTo: _currentFilterCreationDateTo,
                                  stageDateFrom: _currentFilterStageDateFrom,
                                  stageDateTo: _currentFilterStageDateTo,
                                );
                                setState(() {});
                              }
                            }
                          }
                          : null,
                  child: Opacity(
                    opacity: selectedLeadsData.length == 1 ? 1.0 : 0.5,
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

                /// DIVIDER
                // Container(height: 50.h, width: 1, color: Colors.grey.shade300),

                // // =========================
                // // MEETING
                // // =========================
                // InkWell(
                //   onTap:
                //       selectedLeadsData.length == 1
                //           ? () {
                //             if (_selectedLead != null) {
                //               _showAddMeetingSheet(context, _selectedLead!.id!);
                //             }
                //           }
                //           : null,
                //   child: Opacity(
                //     opacity: selectedLeadsData.length == 1 ? 1.0 : 0.5,
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Icon(
                //           Icons.event_outlined,
                //           color: Colors.grey.shade700,
                //           size: 25.sp,
                //         ),
                //         SizedBox(height: 4.h),
                //         Text(
                //           "MEETING",
                //           style: TextStyle(
                //             fontSize: 10.sp,
                //             fontWeight: FontWeight.w700,
                //             color: Colors.grey.shade700,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHIMMER
  // ─────────────────────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: EdgeInsets.all(_responsive.horizontalPadding.w),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: _responsive.verticalPadding.h),
            height: _responsive.isTablet ? 180.h : 140.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LEAD CARD  (Sales-style design + TL logic)
  // ─────────────────────────────────────────────────────────────
  Widget _buildLeadCard({
    required LeadDataPagination lead,
    required int index,
    required BuildContext parentContext,
  }) {
    final String leadStagetype = lead.stage?.name ?? "";
    final String? leadstageupdated = lead.stagedateupdated;
    final bool assign = lead.assign ?? false;
    final String userlogteamleadername = lead.sales?.userlog?.name ?? '';

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

    // ── Left bar color (same logic as SalesLeadsScreen) ──
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
            leadStagetype == "No Answer" ||
            leadStagetype == "No Stage" ||
            leadStagetype == "Interested") &&
        isOutdated;

    final bool hasDownloadIcon =
        assign == true && userlogteamleadername == teamleadname;

    salesfcmtoken = lead.sales?.userlog?.fcmToken;
    leadIdd = lead.id.toString();
    managerfcmtoken = lead.sales?.manager?.fcmToken;

    return BlocProvider(
      create:
          (_) =>
              LeadCommentsCubit(GetAllLeadCommentsApiService())
                ..fetchNewComments(leadId: lead.id!, page: 1, limit: 10),
      child: InkWell(
        onLongPress: () {
          if (hasDownloadIcon) return;
          setState(() {
            selected[index] = true;
            isSelectionMode = selected.contains(true);
            _selectedLead = lead;
            final leadIdStr = lead.id.toString();
            if (!selectedLeadsData.any((l) => l.id.toString() == leadIdStr)) {
              selectedLeadsData.add(lead);
            }
          });
        },
        onTap: () async {
          final bool isPendingStage =
              (lead.stage?.name ?? '').toLowerCase() == 'pending';

          if (isSelectionMode) {
            if (hasDownloadIcon) return;
            setState(() {
              selected[index] = !selected[index];
              if (!selected.contains(true)) isSelectionMode = false;
              _updateSelectedCount();
              final leadIdStr = lead.id.toString();
              if (selected[index]) {
                if (!selectedLeadsData.any(
                  (l) => l.id.toString() == leadIdStr,
                )) {
                  selectedLeadsData.add(lead);
                }
              } else {
                selectedLeadsData.removeWhere(
                  (l) => l.id.toString() == leadIdStr,
                );
              }
            });
            return;
          }

          if (assign == false || isPendingStage) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider(
                      create:
                          (_) =>
                              LeadCommentsCubit(GetAllLeadCommentsApiService()),
                      child: LeadsDetailsTeamLeaderScreen(
                        leedId: lead.id.toString(),
                        leadName: lead.name ?? 'No Name',
                        leadPhone: lead.phone ?? 'No Phone',
                        leadEmail: lead.email ?? 'No Email',
                        leadStage: lead.stage?.name ?? 'No Stage',
                        leadStageId: lead.stage?.id.toString() ?? '',
                        leadChannel: lead.chanel?.name ?? 'No Channel',
                        leadSalesName: lead.sales?.name ?? 'No Sales',
                        leadCreationDate:
                            lead.createdAt != null
                                ? formatDateTimeToDubai(lead.createdAt!)
                                : '',
                        leadProject: lead.project?.name ?? 'No Project',
                        leadLastComment:
                            lead.lastcommentdate ?? 'No Last Comment',
                        leadcampaign:
                            lead.campaign?.campainName ?? 'No Campaign',
                        leadNotes: 'No Notes',
                        leaddeveloper:
                            lead.project?.developer?.name ?? 'No Developer',
                        userlogname: lead.sales?.userlog?.name ?? 'No User',
                        teamleadername:
                            lead.sales?.teamleader?.name ?? 'No Team Leader',
                        fcmtoken: salesfcmtoken ?? '',
                        managerfcmtoken: lead.sales?.manager?.fcmToken ?? '',
                        leadwhatsappnumber:
                            lead.whatsappnumber ?? lead.phone ?? '',
                        jobdescription:
                            lead.jobdescription ?? 'no job description',
                        secondphonenumber:
                            lead.phonenumber2 ?? 'no second phone number',
                        laststageupdated: leadstageupdated ?? '',
                        stageId: lead.stage?.id ?? 'No Stage ID',
                        leadLastDateAssigned: lead.lastdateassign ?? '',
                        isresetcreationdate: lead.resetcreationdate ?? false,
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
          } else if (assign == true && userlogteamleadername == teamleadname) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Attention", style: TextStyle(fontSize: 18.sp)),
                  content: Text(
                    "You must receive this lead first.",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (assign == true && userlogteamleadername != teamleadname) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider(
                      create:
                          (_) =>
                              LeadCommentsCubit(GetAllLeadCommentsApiService()),
                      child: LeadsDetailsTeamLeaderScreen(
                        leedId: lead.id.toString(),
                        leadName: lead.name ?? 'No Name',
                        leadPhone: lead.phone ?? 'No Phone',
                        leadEmail: lead.email ?? 'No Email',
                        leadStage: lead.stage?.name ?? 'No Stage',
                        leadStageId: lead.stage?.id.toString() ?? '',
                        leadChannel: lead.chanel?.name ?? 'No Channel',
                        leadSalesName: lead.sales?.name ?? 'No Sales',
                        leadCreationDate:
                            lead.createdAt != null
                                ? formatDateTimeToDubai(lead.createdAt!)
                                : '',
                        leadProject: lead.project?.name ?? 'No Project',
                        leadLastComment:
                            lead.lastcommentdate ?? 'No Last Comment',
                        leadcampaign:
                            lead.campaign?.campainName ?? 'No Campaign',
                        leadNotes: 'No Notes',
                        leaddeveloper:
                            lead.project?.developer?.name ?? 'No Developer',
                        userlogname: lead.sales?.userlog?.name ?? 'No User',
                        teamleadername:
                            lead.sales?.teamleader?.name ?? 'No Team Leader',
                        fcmtoken: salesfcmtoken ?? '',
                        managerfcmtoken: lead.sales?.manager?.fcmToken ?? '',
                        leadwhatsappnumber:
                            lead.whatsappnumber ?? lead.phone ?? '',
                        jobdescription:
                            lead.jobdescription ?? 'no job description',
                        secondphonenumber:
                            lead.phonenumber2 ?? 'no second phone number',
                        laststageupdated: leadstageupdated ?? '',
                        stageId: lead.stage?.id ?? 'No Stage ID',
                        leadLastDateAssigned: lead.lastdateassign ?? '',
                        isresetcreationdate: lead.resetcreationdate ?? false,
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
                      ),
                    ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color:
                selected[index]
                    ? Constants.maincolor.withOpacity(0.08)
                    : (Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : const Color(0xff111827)),
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
                                  if (isSelectionMode)
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: Checkbox(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        activeColor: Constants.maincolor,
                                        value: selected[index],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5.r,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          if (hasDownloadIcon) return;
                                          setState(() {
                                            selected[index] = val!;
                                            isSelectionMode = selected.contains(
                                              true,
                                            );
                                            _updateSelectedCount();
                                            _selectedLead = lead;
                                            final leadIdStr =
                                                lead.id.toString();
                                            if (val) {
                                              if (!selectedLeadsData.any(
                                                (l) =>
                                                    l.id.toString() ==
                                                    leadIdStr,
                                              )) {
                                                selectedLeadsData.add(lead);
                                              }
                                            } else {
                                              selectedLeadsData.removeWhere(
                                                (l) =>
                                                    l.id.toString() ==
                                                    leadIdStr,
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
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Text(
                                        ((lead.stage?.name ?? "No Stage")
                                                    .length >
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
                                  ? formatDateTimeToDubai(
                                    lead.stagedateupdated!,
                                  )
                                  : "N/A",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),

                        // DOT LOADING (if assigned to this TL)
                        if (hasDownloadIcon)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [DotLoading()],
                            ),
                          ),

                        SizedBox(height: 12.h),

                        // ── NAME + DOWNLOAD BUTTON ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                lead.name ?? "No Name",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? const Color(0xff111827)
                                          : Colors.white,
                                ),
                              ),
                            ),
                            if (hasDownloadIcon)
                              _buildDownloadButton(lead, parentContext),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        // ── PROJECT ──
                        Text(
                          (lead.project?.name ?? "").toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: const Color(0xff003178),
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
                                    lead.assigntype == true
                                        ? "team: ${lead.sales?.name ?? 'N/A'}"
                                        : lead.sales?.name ?? "None",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
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
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                // PHONE
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
                                // WHATSAPP
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

                                // 💬 COMMENT ICON
                                InkWell(
                                  onTap: () => _showCommentsDialog(lead),
                                  borderRadius: BorderRadius.circular(40.r),
                                  child: Container(
                                    width: 44.w,
                                    height: 44.w,
                                    decoration: BoxDecoration(
                                      color: Constants.maincolor.withOpacity(
                                        0.1,
                                      ),
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
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DOWNLOAD BUTTON  (same TL logic)
  // ─────────────────────────────────────────────────────────────
  Widget _buildDownloadButton(
    LeadDataPagination lead,
    BuildContext parentContext,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(40.r),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _cubit),
                BlocProvider(
                  create: (_) => EditLeadCubit(EditLeadApiService()),
                ),
              ],
              child: Builder(
                builder: (innerContext) {
                  bool isLoadingLocal = false;
                  return StatefulBuilder(
                    builder: (ctx, setS) {
                      return AlertDialog(
                        title: Text(
                          "Confirmation",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        content: Text(
                          "Are you sure to receive this lead?",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(ctx).brightness == Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            onPressed: () => Navigator.of(innerContext).pop(),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(ctx).brightness == Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            onPressed:
                                isLoadingLocal
                                    ? null
                                    : () async {
                                      setS(() => isLoadingLocal = true);
                                      try {
                                        await innerContext
                                            .read<EditLeadCubit>()
                                            .editLeadAssignvalue(
                                              userId: lead.id!,
                                              assign: false,
                                            );
                                        if (mounted) {
                                          Navigator.of(innerContext).pop();
                                          parentContext
                                              .read<GetLeadsTeamLeaderCubit>()
                                              .fetchTeamLeaderLeadsWithPagination(
                                                data: widget.data,
                                                transferefromdata:
                                                    widget.transferfromdata,
                                                stageId:
                                                    _currentFilterStageId ??
                                                    widget.stageId,
                                                // ✅ البحث الحالي
                                                search:
                                                    searchController
                                                            .text
                                                            .isNotEmpty
                                                        ? searchController.text
                                                        : null,
                                                // ✅ جميع الفلاتر المخزنة
                                                developerId:
                                                    _currentFilterDeveloperId,
                                                projectId:
                                                    _currentFilterProjectId, // استخدم stageId من الفلتر إذا وجد
                                                channelId:
                                                    _currentFilterChannelId,
                                                salesId:
                                                    _currentFilterSalesId ??
                                                    widget.salesName,
                                                creationDateFrom:
                                                    _currentFilterCreationDateFrom,
                                                creationDateTo:
                                                    _currentFilterCreationDateTo,
                                                stageDateFrom:
                                                    _currentFilterStageDateFrom,
                                                stageDateTo:
                                                    _currentFilterStageDateTo,
                                              );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setS(() => isLoadingLocal = false);
                                        }
                                      }
                                    },
                            child:
                                isLoadingLocal
                                    ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      "OK",
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
      child: CircleAvatar(
        radius: _responsive.avatarRadius.r,
        backgroundColor: Constants.maincolor.withOpacity(0.15),
        child: Icon(
          Icons.download,
          color: Constants.maincolor,
          size: _responsive.iconSizeLarge.sp,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // COMMENTS DIALOG
  // ─────────────────────────────────────────────────────────────
  void _showCommentsDialog(LeadDataPagination lead) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: _responsive.dialogHorizontalPadding.w,
            vertical: _responsive.dialogVerticalPadding.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: BlocProvider(
            create:
                (_) =>
                    LeadCommentsCubit(GetAllLeadCommentsApiService())
                      ..fetchNewComments(leadId: lead.id!, page: 1, limit: 10),
            child: Padding(
              padding: EdgeInsets.all(_responsive.cardPadding.w),
              child: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
                builder: (context, commentState) {
                  if (commentState is LeadCommentsLoading) {
                    return SizedBox(
                      height: _responsive.isTablet ? 300.h : 200.h,
                      child: Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: ListView.builder(
                            padding: EdgeInsets.all(_responsive.cardPadding.w),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: _responsive.verticalPadding.h,
                                ),
                                height: _responsive.isTablet ? 120.h : 80.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  } else if (commentState is LeadCommentsError) {
                    return SizedBox(
                      height: _responsive.isTablet ? 200.h : 150.h,
                      child: Center(
                        child: Text(
                          "No comments available",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                      ),
                    );
                  } else if (commentState is NewCommentsLoaded) {
                    final newCommentsData = commentState.newComments;
                    if (newCommentsData.comments == null ||
                        newCommentsData.comments!.isEmpty) {
                      return Text(
                        'No comments available.',
                        style: TextStyle(
                          fontSize: _responsive.fontSizeMedium.sp,
                        ),
                      );
                    }
                    final firstComment = newCommentsData.comments!.first;
                    final String firstCommentText =
                        firstComment.firstcomment?.text ??
                        "No comment available.";
                    final String secondCommentText =
                        firstComment.secondcomment?.text ??
                        'No action available.';
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Comment",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: _responsive.fontSizeLarge.sp,
                          ),
                        ),
                        SizedBox(height: _responsive.verticalPadding.h * 0.3),
                        Text(
                          firstCommentText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                        SizedBox(height: _responsive.verticalPadding.h),
                        Text(
                          "Action (Plan)",
                          style: TextStyle(
                            color: Constants.maincolor,
                            fontWeight: FontWeight.w600,
                            fontSize: _responsive.fontSizeLarge.sp,
                          ),
                        ),
                        SizedBox(height: _responsive.verticalPadding.h * 0.3),
                        Text(
                          secondCommentText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox(
                      height: _responsive.isTablet ? 200.h : 150.h,
                      child: Center(
                        child: Text(
                          "No comments",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
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
  }

  // ─────────────────────────────────────────────────────────────
  // ASSIGN DIALOG  (same TL logic unchanged)
  // ─────────────────────────────────────────────────────────────
  void _showAssignDialog(bool data, bool transferfromdata) async {
    final parentContext = context;
    final selectedIndices =
        selected
            .asMap()
            .entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one lead")),
      );
      return;
    }

    final selectedLeads = selectedIndices.map((i) => _leads[i]).toList();
    final selectedLeadStageIds =
        selectedLeads.map((lead) => lead.stage?.id?.toString() ?? "").toList();
    final lastStage =
        selectedLeadStageIds.isNotEmpty ? selectedLeadStageIds.last : "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => BlocProvider(
            create: (_) => SalesCubit(GetAllSalesApiService()),
            child: CustomAssignDialogTeamLeaderWidget(
              leadIds: selectedLeads.map((e) => e.id ?? 0).toList(),
              leadId: leadIdd,
              leadResponse: leadResponse,
              leadsStages: [lastStage],
              mainColor: Constants.maincolor,
              fcmyoken: salesfcmtoken!,
              managerfcm: managerfcmtoken,
              data: data,
              transferfromdata: transferfromdata,
              onAssignSuccess: () async {
                setState(() {
                  selected.clear();
                  selectedLeadsData.clear();
                  _selectedLead = null;
                  isSelectionMode = false;
                });
                await _cubit.fetchTeamLeaderLeadsWithPagination(
                  data: widget.data,
                  transferefromdata: widget.transferfromdata,
                  stageId: _currentFilterStageId ?? widget.stageId,
                  // ✅ البحث الحالي
                  search:
                      searchController.text.isNotEmpty
                          ? searchController.text
                          : null,
                  // ✅ جميع الفلاتر المخزنة
                  developerId: _currentFilterDeveloperId,
                  projectId:
                      _currentFilterProjectId, // استخدم stageId من الفلتر إذا وجد
                  channelId: _currentFilterChannelId,
                  salesId: _currentFilterSalesId ?? widget.salesName,
                  creationDateFrom: _currentFilterCreationDateFrom,
                  creationDateTo: _currentFilterCreationDateTo,
                  stageDateFrom: _currentFilterStageDateFrom,
                  stageDateTo: _currentFilterStageDateTo,
                );
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text("Lead assigned successfully! ✅"),
                  ),
                );
              },
            ),
          ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ADD MEETING SHEET  (unchanged from original)
  // ─────────────────────────────────────────────────────────────
  void _showAddMeetingSheet(BuildContext context, String leadId) {
    final commentController = TextEditingController();
    final salesDeveloperController = TextEditingController();
    DateTime? selectedDate;
    StageDatas? selectedStage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (context) {
            final cubit = StagesCubit(StagesApiService());
            cubit.fetchStages();
            return cubit;
          },
          child: MultiBlocListener(
            listeners: [
              BlocListener<GetLeadsCubit, GetLeadsState>(
                listener: (context, state) {
                  if (state is PostMeetingCommentSuccess) {
                    final parentContext = context;
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text("Meeting comment added successfully"),
                        ),
                      );
                      context
                          .read<GetLeadsCubit>()
                          .fetchSalesLeadsWithPagination(
                            data: widget.data,
                            transferefromdata: widget.transferfromdata,
                            stageId: widget.stageId,
                            resetPagination: true,
                          );
                    });
                  }
                },
              ),
            ],
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocBuilder<StagesCubit, StagesState>(
                          builder: (context, state) {
                            if (state is StagesLoading) {
                              return const CircularProgressIndicator();
                            }
                            if (state is StagesLoaded) {
                              final stages =
                                  state.stages
                                      .where(
                                        (s) =>
                                            s.name?.toLowerCase() == "eoi" ||
                                            s.name?.toLowerCase() ==
                                                "done deal" ||
                                            s.name?.toLowerCase() == "meeting",
                                      )
                                      .toList();
                              return DropdownButtonFormField<StageDatas>(
                                decoration: const InputDecoration(
                                  labelText: "Stage",
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedStage,
                                items:
                                    stages
                                        .map(
                                          (stage) => DropdownMenuItem(
                                            value: stage,
                                            child: Text(stage.name ?? ""),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() => selectedStage = value);
                                },
                              );
                            }
                            if (state is StagesError) {
                              return Text("Error: ${state.message}");
                            }
                            return const SizedBox();
                          },
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              selectedDate == null
                                  ? "Select Stage Date"
                                  : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year} "
                                      "${TimeOfDay.fromDateTime(selectedDate!).format(context)}",
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: salesDeveloperController,
                          decoration: const InputDecoration(
                            labelText: "Sales Developer Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<GetLeadsCubit, GetLeadsState>(
                          builder: (context, state) {
                            final isLoadingMeeting =
                                state is PostMeetingCommentLoading;
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Constants.maincolor,
                                    ),
                                    onPressed:
                                        isLoadingMeeting
                                            ? null
                                            : () {
                                              if (selectedStage == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please select a stage",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (selectedDate == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please select stage date",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (commentController
                                                  .text
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please enter a comment",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (salesDeveloperController
                                                  .text
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please enter Sales Developer Name",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              final dubaiDate = selectedDate!
                                                  .toUtc()
                                                  .add(
                                                    const Duration(hours: 4),
                                                  );
                                              context
                                                  .read<GetLeadsCubit>()
                                                  .postMeetingCommentWithStage(
                                                    leadId: leadId,
                                                    stageId: selectedStage!.id!,
                                                    comment:
                                                        commentController.text,
                                                    stageDate: dubaiDate,
                                                    salesdeveloperName:
                                                        salesDeveloperController
                                                            .text,
                                                    refreshAfterSuccess: true,
                                                  );
                                            },
                                    child:
                                        isLoadingMeeting
                                            ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Text(
                                              "Add Comment",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Constants.maincolor,
                                    ),
                                    onPressed: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final userId = prefs.getString('salesId');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => BlocProvider(
                                                create:
                                                    (
                                                      context,
                                                    ) => MeetingCommentsCubit(
                                                      MeetingCommentsApiService(),
                                                    ),
                                                child: MeetingCommentsScreen(
                                                  userId: userId,
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "All Comments",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
    } else {
      print('Could not launch $phoneUri');
    }
  }
}

// ─────────────────────────────────────────────────────────────
// DOT LOADING WIDGET  (same as SalesLeadsScreen)
// ─────────────────────────────────────────────────────────────
class DotLoading extends StatefulWidget {
  const DotLoading({super.key});

  @override
  _DotLoadingState createState() => _DotLoadingState();
}

class _DotLoadingState extends State<DotLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.5;
      return Tween<double>(begin: 0, end: 10).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end > 1.0 ? 1.0 : end,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSalesValues.fromContext(context);
    return SizedBox(
      height: responsive.iconSizeSmall.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding.w * 0.1,
            ),
            child: _buildDot(_animations[index]),
          );
        }),
      ),
    );
  }

  Widget _buildDot(Animation<double> animation) {
    final responsive = ResponsiveSalesValues.fromContext(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -animation.value),
          child: Container(
            width: responsive.iconSizeSmall * 0.3,
            height: responsive.iconSizeSmall * 0.3,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.grey
                      : Constants.mainDarkmodecolor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
