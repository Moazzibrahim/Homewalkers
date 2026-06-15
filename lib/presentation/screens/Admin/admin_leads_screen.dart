// leads_marketier_screen.dart
// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, unused_field, use_super_parameters, unnecessary_null_comparison
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
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
import 'package:homewalkers_app/presentation/screens/Admin/admin_data_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_lead_details.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
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

class _ChangeLeadToDataDialog extends StatelessWidget {
  final List<String> leadIds;
  final VoidCallback onSuccess;

  const _ChangeLeadToDataDialog({
    required this.leadIds,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditLeadCubit, EditLeadState>(
      listener: (context, state) {
        if (state is EditLeadSuccess) {
          Navigator.pop(context);
          onSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Leads transferred to data center successfully"),
            ),
          );
        }

        if (state is EditLeadFailure) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("failed to change lead to data center")),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is EditLeadLoading;

        return AlertDialog(
          title: const Text('Transfer Leads'),
          content: Text(
            'Are you sure you want to transfer ${leadIds.length} lead(s) to the Data Center?',
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.mainlightmodecolor,
              ),
              onPressed:
                  isLoading
                      ? null
                      : () {
                        log('leadIds: $leadIds');
                        context.read<EditLeadCubit>().changeLeadToData(
                          leadIds: leadIds,
                        );
                      },
              child:
                  isLoading
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ],
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
  final bool? data;
  final bool? transferefromdata;
  final int? leadsCount;
  final List<String>? salesIdss;
  final bool showNavBar; // ← أضف ده

  const AdminLeadsScreen({
    super.key,
    this.stageName,
    this.showDuplicatesOnly,
    this.shouldRefreshOnOpen = true,
    this.stageId,
    this.data,
    this.transferefromdata,
    this.leadsCount,
    this.salesIdss,
    this.showNavBar = true,
  });

  @override
  State<AdminLeadsScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<AdminLeadsScreen> {
  int selectedTab = 0; // 0: Manage Leads, 1: Leads Trash
  String _searchQuery = '';
  late TextEditingController _nameSearchController;

  // ✅ تعديل المتغيرات لتصبح Lists
  String? _selectedCountryFilter;
  String? _selectedStageNameFilter;
  List<String> _selectedDeveloperFilter = []; // 👈 تغيير
  List<String> _selectedProjectFilter = []; // 👈 تغيير
  List<String> _selectedStageFilter = []; // 👈 تغيير
  List<String> _selectedChannelFilter = []; // 👈 تغيير
  List<String> _selectedSalesFilter = []; // 👈 تغيير
  List<String> _selectedCommunicationWayFilter = []; // 👈 تغيير
  List<String> _selectedCampaignFilter = []; // 👈 تغيير

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
  final bool _didInitialFetch = false;
  Timer? _searchDebounce;
  late Future<void> _initialFetch;
  late AllLeadsCubitWithPagination _cubit;
  int _currentPage = 1;
  bool _isFetchingMoreTrash = false;
  bool _hasMoreTrashData = true;
  int _currentTrashPage = 1;
  final ScrollController _trashScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _nameSearchController = TextEditingController();

    // ✅ تعديل: تحويل stageId الفردي إلى List
    if (widget.stageId != null && widget.stageId!.isNotEmpty) {
      _selectedStageFilter = [widget.stageId!];
    }

    _showDuplicatesOnly = widget.showDuplicatesOnly ?? false;
    log("stage id: $_selectedStageFilter");
    log("stage name: ${widget.stageName}");
    log("show duplicates only: $_showDuplicatesOnly");

    // ✅ إعداد الـ Scroll Listener
    _setupScrollListener();
    _trashScrollController.addListener(() {
      if (_trashScrollController.position.pixels >=
          _trashScrollController.position.maxScrollExtent - 200) {
        if (!_isFetchingMoreTrash && _hasMoreTrashData) {
          setState(() => _isFetchingMoreTrash = true);
          _currentTrashPage++;
          context
              .read<AllLeadsCubitWithPagination>()
              .fetchLeadsInTrash(
                page: _currentTrashPage,
                search: _searchQuery.isNotEmpty ? _searchQuery : null,
              )
              .then((_) {
                if (mounted) {
                  final cubit = context.read<AllLeadsCubitWithPagination>();
                  setState(() {
                    _isFetchingMoreTrash = false;
                    // لو الداتا الجديدة أقل من 10 معناها خلصت
                    _hasMoreTrashData =
                        cubit.trashLeads.length < cubit.totaltrashleads;
                  });
                }
              });
        }
      }
    });

    _cubit = context.read<AllLeadsCubitWithPagination>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitial();
    });
  }

  void _fetchInitial() {
    _hasMoreData = true;
    _currentPage = 1;

    // ✅ جيب الـ trash count الأول قبل أي حاجة
    _cubit.fetchTrashCountOnly().then((_) {
      // بعد ما العدد اتجيب، emit الـ state الحالية عشان الـ UI يتحدث
      if (mounted) setState(() {});
    });

    _cubit.fetchLeads(
      page: _currentPage,
      limit: 10,
      stageIds: _selectedStageFilter.isNotEmpty ? _selectedStageFilter : null,
      duplicates: _showDuplicatesOnly,
      ignoreDuplicate: _showDuplicatesOnly,
      data: widget.data,
      transferefromdata: widget.transferefromdata,
      salesIds:
          widget.salesIdss != null && widget.salesIdss!.isNotEmpty
              ? widget.salesIdss
              : null,
    );
  }

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
            _selectedDeveloperFilter.isNotEmpty || // 👈 تعديل
            _selectedProjectFilter.isNotEmpty || // 👈 تعديل
            _selectedChannelFilter.isNotEmpty || // 👈 تعديل
            _selectedSalesFilter.isNotEmpty || // 👈 تعديل
            _selectedCommunicationWayFilter.isNotEmpty || // 👈 تعديل
            _selectedCampaignFilter.isNotEmpty || // 👈 تعديل
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
          stageIds:
              _selectedStageFilter.isNotEmpty
                  ? _selectedStageFilter
                  : null, // 👈 تعديل
          developerIds:
              _selectedDeveloperFilter.isNotEmpty
                  ? _selectedDeveloperFilter
                  : null, // 👈 تعديل
          projectIds:
              _selectedProjectFilter.isNotEmpty
                  ? _selectedProjectFilter
                  : null, // 👈 تعديل
          channelIds:
              _selectedChannelFilter.isNotEmpty
                  ? _selectedChannelFilter
                  : null, // 👈 تعديل
          salesIds:
              _selectedSalesFilter.isNotEmpty
                  ? _selectedSalesFilter
                  : (widget.salesIdss != null && widget.salesIdss!.isNotEmpty)
                  ? widget.salesIdss
                  : null,
          communicationWayIds:
              _selectedCommunicationWayFilter.isNotEmpty
                  ? _selectedCommunicationWayFilter
                  : null, // 👈 تعديل
          campaignIds:
              _selectedCampaignFilter.isNotEmpty
                  ? _selectedCampaignFilter
                  : null, // 👈 تعديل
          addedByIds:
              _addedByFilter != null ? [_addedByFilter!] : null, // 👈 تعديل
          assignedFromIds:
              _assignedFromFilter != null
                  ? [_assignedFromFilter!]
                  : null, // 👈 تعديل
          assignedToIds:
              _assignedToFilter != null
                  ? [_assignedToFilter!]
                  : null, // 👈 تعديل
          creationDateFrom: _startDateFilter,
          creationDateTo: _endDateFilter,
          lastStageUpdateFrom: _lastStageUpdateStartFilter,
          lastStageUpdateTo: _lastStageUpdateEndFilter,
          lastCommentDateFrom: _lastCommentDateStartFilter,
          lastCommentDateTo: _lastCommentDateEndFilter,
          duplicates: _showDuplicatesOnly,
          data: widget.data,
          transferefromdata: widget.transferefromdata,
        )
        .whenComplete(() {
          _isFetchingMore = false;
        });
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    _scrollController.dispose();
    _trashScrollController.dispose();
    super.dispose();
  }

  void _applyCurrentFilters() {
    _currentPage = 1;
    _hasMoreData = true;

    _cubit.fetchLeads(
      page: _currentPage,
      limit: 10,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      stageIds:
          _selectedStageFilter.isNotEmpty
              ? _selectedStageFilter
              : (widget.stageId != null && widget.stageId!.isNotEmpty)
              ? [widget.stageId!]
              : null, // 👈 تعديل
      developerIds:
          _selectedDeveloperFilter.isNotEmpty
              ? _selectedDeveloperFilter
              : null, // 👈 تعديل
      projectIds:
          _selectedProjectFilter.isNotEmpty
              ? _selectedProjectFilter
              : null, // 👈 تعديل
      channelIds:
          _selectedChannelFilter.isNotEmpty
              ? _selectedChannelFilter
              : null, // 👈 تعديل
      salesIds:
          _selectedSalesFilter.isNotEmpty
              ? _selectedSalesFilter
              : (widget.salesIdss != null && widget.salesIdss!.isNotEmpty)
              ? widget.salesIdss
              : null,
      communicationWayIds:
          _selectedCommunicationWayFilter.isNotEmpty
              ? _selectedCommunicationWayFilter
              : null, // 👈 تعديل
      campaignIds:
          _selectedCampaignFilter.isNotEmpty
              ? _selectedCampaignFilter
              : null, // 👈 تعديل
      addedByIds: _addedByFilter != null ? [_addedByFilter!] : null, // 👈 تعديل
      assignedFromIds:
          _assignedFromFilter != null
              ? [_assignedFromFilter!]
              : null, // 👈 تعديل
      assignedToIds:
          _assignedToFilter != null ? [_assignedToFilter!] : null, // 👈 تعديل
      creationDateFrom: _startDateFilter,
      creationDateTo: _endDateFilter,
      lastStageUpdateFrom: _lastStageUpdateStartFilter,
      lastStageUpdateTo: _lastStageUpdateEndFilter,
      lastCommentDateFrom: _lastCommentDateStartFilter,
      lastCommentDateTo: _lastCommentDateEndFilter,
      duplicates: _showDuplicatesOnly,
      ignoreDuplicate: _showDuplicatesOnly,
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

  // أضف هذه المتغيرات في بداية الـ State
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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

    // ✅ عوامل التصغير حسب الجهاز
    final double tabletScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    bool isOutdated = false;

    return Scaffold(
      bottomNavigationBar:
          widget.showNavBar
              ? SharedAdminNavBar(currentIndex: 1)
              : null, // ← لو جاي من tabs مش هيظهر

      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title:
            _isSearchVisible
                ? null // إذا كان البحث ظاهراً، لا نريد عرض النص
                : "Leads",
        onBack: () {
          if (widget.transferefromdata == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminTabsScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDataDashboardScreen(),
              ),
            );
          }
        },
        extraActions: [
          Row(
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
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.mainlightmodecolor
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
                                      _searchQuery = value.trim();
                                      if (selectedTab == 0) {
                                        _applyCurrentFilters();
                                      } else {
                                        _currentPage = 1;
                                        context
                                            .read<AllLeadsCubitWithPagination>()
                                            .fetchLeadsInTrash(
                                              page: 1,
                                              search:
                                                  _searchQuery.isNotEmpty
                                                      ? _searchQuery
                                                      : null,
                                            );
                                      }
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
                                _searchQuery = '';
                                setState(() {
                                  _isSearchVisible = false;
                                });
                                _searchFocusNode.unfocus(); // يقفل الكيبورد

                                if (selectedTab == 0) {
                                  _applyCurrentFilters();
                                } else {
                                  _currentPage = 1;
                                  context
                                      .read<AllLeadsCubitWithPagination>()
                                      .fetchLeadsInTrash(page: 1, search: null);
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Icon(
                                  Icons.clear,
                                  size: 18.sp,
                                  color: Colors.black,
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
                                    ? Constants.mainlightmodecolor
                                    : Constants.mainDarkmodecolor,
                          ),
                        ),
              ),
              SizedBox(width: (10 * tabletWidthScale).w),
              // ✅ زر الفلتر (كما هو دون تغيير)
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.mainlightmodecolor
                          : Constants.mainDarkmodecolor,
                ),
                onPressed: () async {
                  if (selectedTab == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Filtering is not available for the trash.",
                          style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                        ),
                      ),
                    );
                    return;
                  }
                  final Map<String, dynamic>? filters =
                      await showDialog<Map<String, dynamic>>(
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
                            child: FilterDialog(
                              initialDeveloperIds: null,
                              initialProjectIds: null,
                              initialStageIds: null,
                              initialChannelIds: null,
                              initialSalesIds: null,
                              initialCommunicationWayIds: null,
                              initialCampaignIds: null,
                              initialSearchName: null,
                              initialAddedBy: null,
                              initialAssignedFrom: null,
                              initialAssignedTo: null,
                              initialStartDate: null,
                              initialEndDate: null,
                              initialLastStageUpdateStart: null,
                              initialLastStageUpdateEnd: null,
                              initialLastCommentDateStart: null,
                              initialLastCommentDateEnd: null,
                              initialOldStageStartDate: null,
                              initialOldStageEndDate: null,
                            ),
                          );
                        },
                      );
                  if (filters != null) {
                    setState(() {
                      _searchQuery = filters['name'] ?? _searchQuery;
                      _searchController.text = _searchQuery;
                      _selectedCountryFilter = filters['country'];
                      _selectedDeveloperFilter = List<String>.from(
                        filters['developerIds'] ?? [],
                      );
                      _selectedProjectFilter = List<String>.from(
                        filters['projectIds'] ?? [],
                      );
                      _selectedStageFilter = List<String>.from(
                        filters['stageIds'] ?? [],
                      );
                      _selectedChannelFilter = List<String>.from(
                        filters['channelIds'] ?? [],
                      );
                      _selectedSalesFilter = List<String>.from(
                        filters['salesIds'] ?? [],
                      );
                      _selectedCommunicationWayFilter = List<String>.from(
                        filters['communicationWayIds'] ?? [],
                      );
                      _selectedCampaignFilter = List<String>.from(
                        filters['campaignIds'] ?? [],
                      );
                      _addedByFilter = filters['addedBy'];
                      _assignedFromFilter = filters['assignedFrom'];
                      _assignedToFilter = filters['assignedTo'];
                      _startDateFilter = filters['startDate'];
                      _endDateFilter = filters['endDate'];
                      _lastStageUpdateStartFilter =
                          filters['lastStageUpdateStart'];
                      _lastStageUpdateEndFilter = filters['lastStageUpdateEnd'];
                      _lastCommentDateStartFilter =
                          filters['lastCommentDateStart'];
                      _lastCommentDateEndFilter = filters['lastCommentDateEnd'];
                      _oldStageNameFilter = filters['oldStageName'];
                      _oldStageDateStartFilter = filters['oldStageDateStart'];
                      _oldStageDateEndFilter = filters['oldStageDateEnd'];
                    });
                    _applyCurrentFilters();
                  }
                },
              ),
            ],
          ),
        ],
      ),
      // باقي الـ body
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (16 * tabletWidthScale).w,
          vertical: (10 * tabletHeightScale).h,
        ),
        child: Column(
          children: [
            /// =========================
            /// TOP ACTION BAR
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
                        color: Constants.mainlightmodecolor,
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

                    /// SELECTED TEXT
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
                          // EXPORT / ASSIGN
                          // =========================
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
                                                ? Constants.mainlightmodecolor
                                                : Constants.mainDarkmodecolor,
                                        leadIds: _selectedLeads.toList(),
                                        leadId: _selectedLeads.toList()[0],
                                        leadStages:
                                            _selectedLeadStagesIds.toList(),
                                        leadSalesId: _selectedSalesIds.toList(),
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

                          /// DIVIDER
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
                                      .read<AllLeadsCubitWithPagination>()
                                      .leads;

                              final selectedLead = leadsList.firstWhere(
                                (lead) =>
                                    lead.id.toString() == _selectedLeads.first,
                                orElse: () => LeadDataWithPagination(),
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
                                        userId: selectedLead.id.toString(),
                                        initialName: selectedLead.name ?? '',
                                        initialEmail: selectedLead.email ?? '',
                                        initialPhone: selectedLead.phone ?? '',
                                        initialProjectId:
                                            selectedLead.project?.id
                                                ?.toString(),
                                        initialStageId:
                                            selectedLead.stage?.id?.toString(),
                                        initialChannelId:
                                            selectedLead.chanel?.id?.toString(),
                                        initialCampaignId:
                                            selectedLead.campaign?.id
                                                ?.toString(),
                                        initialCommunicationWayId:
                                            selectedLead.communicationway?.id
                                                ?.toString(),
                                        isCold: selectedLead.leedtype == "Cold",
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

                                          leadsCubit.fetchLeads(
                                            stageIds:
                                                _selectedStageFilter.isNotEmpty
                                                    ? _selectedStageFilter
                                                    : null,
                                            duplicates: _showDuplicatesOnly,
                                            ignoreDuplicate:
                                                _showDuplicatesOnly,
                                            data: widget.data,
                                            transferefromdata:
                                                widget.transferefromdata,
                                            salesIds:
                                                widget.salesIdss != null &&
                                                        widget
                                                            .salesIdss!
                                                            .isNotEmpty
                                                    ? widget.salesIdss
                                                    : null,
                                          );
                                        },
                                      ),
                                    ),
                              );

                              if (result == true) {
                                context
                                    .read<AllLeadsCubitWithPagination>()
                                    .fetchLeads(
                                      stageIds:
                                          _selectedStageFilter.isNotEmpty
                                              ? _selectedStageFilter
                                              : null,
                                      duplicates: _showDuplicatesOnly,
                                      ignoreDuplicate: _showDuplicatesOnly,
                                      data: widget.data,
                                      transferefromdata:
                                          widget.transferefromdata,
                                      salesIds:
                                          widget.salesIdss != null &&
                                                  widget.salesIdss!.isNotEmpty
                                              ? widget.salesIdss
                                              : null,
                                    );

                                _showCheckboxes = false;
                                _selectedLeads.clear();
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

                          /// DIVIDER
                          Container(
                            height: (50 * tabletHeightScale).h,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),

                          // =========================
                          // STATUS
                          // =========================
                          if (widget.transferefromdata == true)
                            InkWell(
                              onTap: () {
                                if (_selectedLeads.isEmpty) return;

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) {
                                    return BlocProvider(
                                      create:
                                          (_) => EditLeadCubit(
                                            EditLeadApiService(),
                                          ),
                                      child: _ChangeLeadToDataDialog(
                                        leadIds: _selectedLeads.toList(),
                                        onSuccess: () {
                                          context
                                              .read<
                                                AllLeadsCubitWithPagination
                                              >()
                                              .fetchLeads(
                                                stageIds:
                                                    _selectedStageFilter
                                                            .isNotEmpty
                                                        ? _selectedStageFilter
                                                        : null,
                                                duplicates: _showDuplicatesOnly,
                                                ignoreDuplicate:
                                                    _showDuplicatesOnly,
                                                data: widget.data,
                                                transferefromdata:
                                                    widget.transferefromdata,
                                                salesIds:
                                                    widget.salesIdss != null &&
                                                            widget
                                                                .salesIdss!
                                                                .isNotEmpty
                                                        ? widget.salesIdss
                                                        : null,
                                              );

                                          setState(() {
                                            _showCheckboxes = false;
                                            _selectedLeads.clear();
                                          });
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.grey.shade700,
                                    size: (25 * tabletFontScale).sp,
                                  ),
                                  SizedBox(height: (4 * tabletHeightScale).h),
                                  Text(
                                    "Switch",
                                    style: TextStyle(
                                      fontSize: (10 * tabletFontScale).sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          /// DIVIDER
                          Container(
                            height: (50 * tabletHeightScale).h,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),

                          // =========================
                          // DELETE
                          // =========================
                          InkWell(
                            onTap: () async {
                              final leadsList =
                                  context
                                      .read<AllLeadsCubitWithPagination>()
                                      .leads;

                              final selectedLead = leadsList.firstWhere(
                                (lead) =>
                                    lead.id.toString() == _selectedLeads.first,
                                orElse: () => LeadDataWithPagination(),
                              );

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return BlocProvider(
                                    create:
                                        (_) =>
                                            EditLeadCubit(EditLeadApiService()),
                                    child: AlertDialog(
                                      title: Text(
                                        "Delete Lead",
                                        style: TextStyle(
                                          fontSize: (18 * tabletFontScale).sp,
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete this lead?",
                                        style: TextStyle(
                                          fontSize: (14 * tabletFontScale).sp,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize:
                                                  (14 * tabletFontScale).sp,
                                            ),
                                          ),
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
                                                SnackBar(
                                                  content: Text(
                                                    "Failed to delete the lead. Please try again.",
                                                    style: TextStyle(
                                                      fontSize:
                                                          (14 * tabletFontScale)
                                                              .sp,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.red,
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
                                                        _showCheckboxes = false;

                                                        _selectedLeads.clear();

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
                                                      ? SizedBox(
                                                        height:
                                                            (18 * tabletFontScale)
                                                                .h,
                                                        width:
                                                            (18 * tabletFontScale)
                                                                .w,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth:
                                                              (2 * tabletScale)
                                                                  .w,
                                                        ),
                                                      )
                                                      : Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize:
                                                              (14 * tabletFontScale)
                                                                  .sp,
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
                                    context.read<AllLeadsCubitWithPagination>();

                                cubit.fetchLeads(
                                  stageIds:
                                      _selectedStageFilter.isNotEmpty
                                          ? _selectedStageFilter
                                          : null,
                                  duplicates: _showDuplicatesOnly,
                                  ignoreDuplicate: _showDuplicatesOnly,
                                  data: widget.data,
                                  transferefromdata: widget.transferefromdata,
                                  salesIds:
                                      widget.salesIdss != null &&
                                              widget.salesIdss!.isNotEmpty
                                          ? widget.salesIdss
                                          : null,
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey.shade700,
                                  size: (25 * tabletFontScale).sp,
                                ),
                                SizedBox(height: (4 * tabletHeightScale).h),
                                Text(
                                  "DELETE",
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
            /// TABS
            /// =========================
            Container(
              padding: EdgeInsets.only(
                top: (4 * tabletHeightScale).h,
                bottom: (8 * tabletHeightScale).h,
              ),
              child: Row(
                children: [
                  /// ALL LEADS
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                          _searchQuery = '';
                          _nameSearchController.clear();
                          _selectedCountryFilter = null;
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
                          _applyCurrentFilters();
                        } else {
                          context
                              .read<AllLeadsCubitWithPagination>()
                              .fetchLeads(
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
                                          ? Constants.mainlightmodecolor
                                          : Colors.grey,
                                ),
                              ),

                              SizedBox(width: (8 * tabletWidthScale).w),

                              // ✅ هنا التعديل
                              BlocBuilder<
                                AllLeadsCubitWithPagination,
                                AllLeadsState
                              >(
                                builder: (context, state) {
                                  // ✅ بس اعرض بعد ما الـ fetch يخلص
                                  if (state is! AllLeadsLoaded &&
                                      state is! AllLeadsError) {
                                    return const SizedBox.shrink();
                                  }

                                  final cubit =
                                      context
                                          .read<AllLeadsCubitWithPagination>();

                                  // ✅ لو loaded → خد totalLeads من الـ cubit مباشرة (بيكون 0 لو مفيش نتايج)
                                  // ✅ لو error → عرض 0
                                  final count =
                                      state is AllLeadsLoaded
                                          ? cubit.totalLeads
                                          : 0;

                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: (10 * tabletWidthScale).w,
                                      vertical: (4 * tabletHeightScale).h,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedTab == 0
                                              ? Constants.mainlightmodecolor
                                                  .withOpacity(0.12)
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
                                                ? Constants.mainlightmodecolor
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
                                      ? Constants.mainlightmodecolor
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
                          _currentTrashPage = 1; // ← أضف
                          _hasMoreTrashData = true; // ← أضف
                          _isFetchingMoreTrash = false; // ← أضف
                        });

                        context
                            .read<AllLeadsCubitWithPagination>()
                            .fetchLeadsInTrash();
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
                                          ? Constants.mainlightmodecolor
                                          : Colors.grey,
                                ),
                              ),

                              SizedBox(width: (8 * tabletWidthScale).w),

                              // ✅ هنا كمان للـ Trash
                              BlocBuilder<
                                AllLeadsCubitWithPagination,
                                AllLeadsState
                              >(
                                builder: (context, state) {
                                  final trashCount =
                                      context
                                          .read<AllLeadsCubitWithPagination>()
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
                                                ? Constants.mainlightmodecolor
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
                                                  ? Constants.mainlightmodecolor
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
                                      ? Constants.mainlightmodecolor
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
                    final cubit =
                        context.read<AllLeadsCubitWithPagination>(); // ← أضف
                    final trashLeads =
                        cubit.trashLeads; // ← استخدم trashLeads من الـ cubit
                    if (trashLeads.isEmpty) {
                      return const Center(child: Text('Leads trash is empty.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _currentTrashPage = 1;
                          _hasMoreTrashData = true;
                          _isFetchingMoreTrash = false;
                        });
                        //   context.read<GetAllUsersCubit>().fetchLeadsInTrash();
                        context
                            .read<AllLeadsCubitWithPagination>()
                            .fetchLeadsInTrash(
                              search:
                                  _searchQuery.isNotEmpty ? _searchQuery : null,
                            );
                      },
                      child: ListView.builder(
                        controller: _trashScrollController, // ← أضف
                        itemCount:
                            trashLeads.length + (_isFetchingMoreTrash ? 1 : 0),
                        // ← عدّل
                        itemBuilder: (context, index) {
                          if (index == trashLeads.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Constants.mainlightmodecolor,
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
                          final lead = trashLeads[index];
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
                          _selectedDeveloperFilter = [];
                          _selectedProjectFilter = [];
                          _selectedChannelFilter = [];
                          _selectedSalesFilter = [];
                          _selectedCommunicationWayFilter = [];
                          _selectedCampaignFilter = [];
                          // ✅ خليك دايمًا ماسك الـ stage اللي دخل بيها المستخدم
                          _selectedStageFilter =
                              widget.stageId != null &&
                                      widget.stageId!.isNotEmpty
                                  ? [widget.stageId!]
                                  : []; // ✅ رجّع الـ stageId الأصلي
                        });

                        if (selectedTab == 0) {
                          //  cubit.resetPagination();

                          log("⏳ Refreshing with stage: $_selectedStageFilter");

                          await cubit
                              .fetchLeads(
                                stageIds:
                                    _selectedStageFilter.isNotEmpty
                                        ? _selectedStageFilter
                                        : null,
                                duplicates: _showDuplicatesOnly,
                                ignoreDuplicate: _showDuplicatesOnly,
                                data: widget.data,
                                transferefromdata: widget.transferefromdata,
                              )
                              .then((_) {
                                log("✅ Leads fetched successfully");
                                // ✅ بعد ما الداتا ترجع، فعّل الفلاتر (stage وغيره)
                                if (_showDuplicatesOnly) {
                                  cubit.fetchLeads(
                                    duplicates: true,
                                    ignoreDuplicate: true,
                                    data: widget.data,
                                    transferefromdata: widget.transferefromdata,
                                  );
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
                                          lastcommentFirst:
                                              lead.lastComment?.firstcomment,
                                          lastcommentNext:
                                              lead.lastComment?.secondcomment,
                                          linkCampaign:
                                              lead.campaign?.redirectLink,
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
                                Container(
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
                                                  if (leadStagetype ==
                                                      "Fresh") {
                                                    return Constants
                                                        .mainlightmodecolor;
                                                  } else if (leadStagetype ==
                                                          "Follow Up" &&
                                                      isOutdated) {
                                                    return Colors.orangeAccent;
                                                  } else if (leadStagetype ==
                                                          "Follow" &&
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
                                                          "No Stage" &&
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
                                                      leadStagetype ==
                                                          "Transfer") {
                                                    return Colors.black;
                                                  } else {
                                                    return Constants
                                                        .mainlightmodecolor;
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
                                              horizontal:
                                                  (18 * tabletWidthScale).w,
                                              vertical:
                                                  (18 * tabletHeightScale).h,
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
                                                              padding:
                                                                  EdgeInsets.only(
                                                                    right:
                                                                        (8 *
                                                                                tabletWidthScale)
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
                                                                        .mainlightmodecolor,
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
                                                                        lead.sales?.id ??
                                                                            '',
                                                                      );

                                                                      _selectedLeadStagesIds.add(
                                                                        lead.stage?.id ??
                                                                            '',
                                                                      );
                                                                    } else {
                                                                      _selectedLeads
                                                                          .remove(
                                                                            lead.id,
                                                                          );

                                                                      _selectedSalesIds.remove(
                                                                        lead.sales?.id ??
                                                                            '',
                                                                      );

                                                                      _selectedLeadStagesIds.remove(
                                                                        lead.stage?.id ??
                                                                            '',
                                                                      );

                                                                      _showCheckboxes =
                                                                          false;
                                                                    }
                                                                  });
                                                                },
                                                              ),
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
                                                                          "Fresh" ||
                                                                      leadStagetype ==
                                                                          "EOI" ||
                                                                      leadStagetype ==
                                                                          "Cancel Meeting" ||
                                                                      leadStagetype ==
                                                                          "Pending");

                                                              late final Color
                                                              stageColor;

                                                              if (leadStagetype ==
                                                                      "Not Interested" ||
                                                                  leadStagetype ==
                                                                      "Transfer") {
                                                                stageColor =
                                                                    Colors
                                                                        .black;
                                                              } else {
                                                                stageColor =
                                                                    isFinalStage
                                                                        ? Constants
                                                                            .mainlightmodecolor
                                                                        : isOutdated
                                                                        ? const Color(
                                                                          0xffFEB300,
                                                                        )
                                                                        : Constants
                                                                            .mainlightmodecolor;
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
                                                                            : stageColor.withOpacity(
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
                                                          (10 * tabletWidthScale)
                                                              .w,
                                                    ),

                                                    Text(
                                                      lead.stagedateupdated !=
                                                              null
                                                          ? formatDateTimeToDubai(
                                                            lead.stagedateupdated!
                                                                .toString(),
                                                          )
                                                          : "N/A",
                                                      style: TextStyle(
                                                        fontSize:
                                                            (11 * tabletFontScale)
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(
                                                  height:
                                                      (12 * tabletHeightScale)
                                                          .h,
                                                ),

                                                /// =========================
                                                /// NAME
                                                /// =========================
                                                Text(
                                                  lead.name ?? "No Name",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize:
                                                        (24 * tabletFontScale)
                                                            .sp,
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
                                                  height:
                                                      (4 * tabletHeightScale).h,
                                                ),

                                                /// PROJECT
                                                Text(
                                                  (lead.project?.name ?? "")
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize:
                                                        (12 * tabletFontScale)
                                                            .sp,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1,
                                                    color: Color(0xff003178),
                                                  ),
                                                ),

                                                SizedBox(
                                                  height:
                                                      (15 * tabletHeightScale)
                                                          .h,
                                                ),

                                                /// =========================
                                                /// SALESMAN + CREATED
                                                /// =========================
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
                                                                  (10 *
                                                                          tabletFontScale)
                                                                      .sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              letterSpacing:
                                                                  1.2,
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
                                                            lead.assigntype ==
                                                                    true
                                                                ? "team: ${lead.sales?.name}"
                                                                : lead
                                                                        .sales
                                                                        ?.name ??
                                                                    'N/A',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  (16 *
                                                                          tabletFontScale)
                                                                      .sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      width:
                                                          (20 * tabletWidthScale)
                                                              .w,
                                                    ),

                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
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
                                                                    .toString(),
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
                                                  height:
                                                      (5 * tabletHeightScale).h,
                                                ),

                                                Divider(
                                                  color: Colors.grey.shade300,
                                                  thickness: 1,
                                                ),

                                                SizedBox(
                                                  height:
                                                      (5 * tabletHeightScale).h,
                                                ),

                                                /// =========================
                                                /// PHONE + ACTIONS
                                                /// =========================
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
                                                            // إذا كان الرقم يبدأ بـ + بالفعل، استخدمه كما هو
                                                            formatted = phone;
                                                          } else if (phone
                                                              .startsWith(
                                                                '0',
                                                              )) {
                                                            // إذا كان يبدأ بـ 0، استخدمه كما هو
                                                            formatted = phone;
                                                          } else {
                                                            // إذا لم يبدأ بـ 0 أو +، أضف +
                                                            formatted =
                                                                '+$phone';
                                                          }
                                                          makePhoneCall(
                                                            formatted,
                                                          );
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
                                                                lead.phone ??
                                                                '';
                                                            String formatted;
                                                            if (phone
                                                                .startsWith(
                                                                  '+',
                                                                )) {
                                                              // إذا كان الرقم يبدأ بـ + بالفعل، استخدمه كما هو
                                                              formatted = phone;
                                                            } else if (phone
                                                                .startsWith(
                                                                  '0',
                                                                )) {
                                                              // إذا كان يبدأ بـ 0، استخدمه كما هو
                                                              formatted = phone;
                                                            } else {
                                                              // إذا لم يبدأ بـ 0 أو +، أضف +
                                                              formatted =
                                                                  '+$phone';
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
                                                            decoration: BoxDecoration(
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
                                                                      .mainlightmodecolor,
                                                              size:
                                                                  (22 *
                                                                          tabletFontScale)
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
                                                            decoration: BoxDecoration(
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
                                                                color:
                                                                    Colors
                                                                        .green,
                                                                size:
                                                                    (24 *
                                                                            tabletFontScale)
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

                                                        /// COMMENT ICON ✅ أضف ده
                                                        InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) {
                                                                final lastComment =
                                                                    lead.lastComment;
                                                                final firstCommentText =
                                                                    lastComment
                                                                        ?.firstcomment
                                                                        ?.text ??
                                                                    'No comments available.';
                                                                final secondCommentText =
                                                                    lastComment
                                                                        ?.secondcomment
                                                                        ?.text ??
                                                                    'No action available.';

                                                                return Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          (16 *
                                                                                  tabletScale)
                                                                              .r,
                                                                        ),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(
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
                                                                                Constants.mainlightmodecolor,
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
                                                                );
                                                              },
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
                                                            decoration: BoxDecoration(
                                                              color: Constants
                                                                  .mainlightmodecolor
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
                                                                      .mainlightmodecolor,
                                                              size:
                                                                  (22 *
                                                                          tabletFontScale)
                                                                      .sp,
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
          color: isDark ? Colors.white : Constants.mainlightmodecolor,
        ),
        child: icon,
      ),
    );
  }
}
