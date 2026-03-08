// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_local_variable, deprecated_member_use, use_build_context_synchronously, unused_field
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:google_fonts/google_fonts.dart';
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
  // bool? leadassign; // <--- تم حذف هذا المتغير لأنه كان سبب المشكلة
  String? teamleadname;
  String? teamleadid;
  bool isLoading = false;
  bool isSelectionMode = false;
  String? _selectedLeadId;
  LeadDataPagination? _selectedLead; // لو حابب تخزن آخر ليد مختارة
  List<LeadDataPagination> selectedLeadsData = [];
  late ScrollController _scrollController;
  bool _selectAll = false; // متغير لتتبع حالة تحديد الكل
  int _selectedCount = 0; // عدد العناصر المختارة
  late ResponsiveSalesValues _responsive;
  Timer? _debounce;

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    //print("stage name: ${widget.stageName}");
    if (!mounted) return;
    setState(() {
      teamleadname = prefs.getString('name');
      teamleadid = prefs.getString('salesId');
    });
    // context.read<GetLeadsTeamLeaderCubit>().getLeadsByTeamLeader();
  }

  late GetLeadsTeamLeaderCubit _cubit;

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

      // تحديث كل الـ checkboxes
      for (int i = 0; i < selected.length; i++) {
        final lead = _leads[i];
        final bool hasDownloadIcon =
            (lead.assign == true && lead.sales?.userlog?.name == teamleadname);

        // لا نحدد الليدات التي لها أيقونة download
        if (!hasDownloadIcon) {
          selected[i] = _selectAll;

          // إضافة أو إزالة من selectedLeadsData
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

    // ✅ امسح الـ search controller
    searchController.clear(); // 👈 مهم جداً

    _loadLeads(); // ✅ دي بتعمل resetPagination: true

    context.read<SalesCubit>().fetchAllSales();

    // ✅ استبدل init() بالكود ده
    _initUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedCount();
    });
  }

  // ✅ دالة جديدة لتحميل بيانات المستخدم بدون تحميل الليدز تاني
  Future<void> _initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      teamleadname = prefs.getString('name');
      teamleadid = prefs.getString('salesId');
    });
  }

  Future<void> _loadLeads() async {
    // ✅ تأكد إن searchController فاضي
    searchController.clear();

    await _cubit.fetchTeamLeaderLeadsWithPagination(
      data: widget.data,
      transferefromdata: widget.transferfromdata,
      stageId: widget.stageId,
      resetPagination: true, // ✅ مهم جداً
      salesId: widget.salesName,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load more when user scrolls to 80% of the way
    if (currentScroll >= maxScroll * 0.8) {
      if (_cubit.hasMoreData && !_cubit.isFetchingMore) {
        log(
          "📜 Loading more data at scroll position: $currentScroll/$maxScroll",
        );
        _cubit.fetchTeamLeaderLeadsWithPagination(
          isLoadMore: true,
          limit: 10, // Adjust limit as needed
          data: widget.data,
          transferefromdata: widget.transferfromdata,
          stageId: widget.stageId,
          salesId: widget.salesName,
          search:
              searchController.text.isNotEmpty ? searchController.text : null,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    searchController.dispose(); // ✅ مهم جداً
    _debounce?.cancel();
    super.dispose();
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

  // ✅ دالة للكشف عن نوع الجهاز
  bool get isTablet {
    final data = MediaQuery.of(context);
    final physicalSize = data.size;
    final diagonal = math.sqrt(
      math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160); // تقريبي

    // ✅ أصغر تابلت هو iPad Mini 7.9 بوصة
    return inches >= 7.0;
  }

  // ✅ دالة للحصول على عامل التصغير للتابلت
  double get tabletFactor => isTablet ? 0.85 : 1.0;

  // ✅ دالة للخطوط المتجاوبة مع التابلت
  double responsiveFont(double size) => size.sp * (isTablet ? 0.9 : 1.0);

  // ✅ دالة للأبعاد المتجاوبة مع التابلت
  double responsiveW(double width) => width.w * (isTablet ? 0.8 : 1.0);
  double responsiveH(double height) => height.h * (isTablet ? 0.9 : 1.0);
  double responsiveR(double radius) => radius.r * (isTablet ? 0.85 : 1.0);
  @override
  Widget build(BuildContext context) {
    _responsive = ResponsiveSalesValues.fromContext(context);
    return BlocProvider.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
          // ✅ الكشف عن نوع الجهاز
          final bool isTabletDevice = () {
            final data = MediaQuery.of(context);
            final physicalSize = data.size;
            final diagonal = math.sqrt(
              math.pow(physicalSize.width, 2) +
                  math.pow(physicalSize.height, 2),
            );
            final inches = diagonal / (data.devicePixelRatio * 160);
            return inches >= 7.0;
          }();

          // ✅ عوامل التصغير للتابلت
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
              title: "Leads",
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
                      children: [
                        /// search
                        SizedBox(
                          width: (200 * tabletWidthScale).w,
                          height: (50 * tabletHeightScale).h,
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              final cubit =
                                  context.read<GetLeadsTeamLeaderCubit>();
                              _debounce?.cancel();
                              _debounce = Timer(
                                const Duration(milliseconds: 500),
                                () {
                                  cubit.fetchTeamLeaderLeadsWithPagination(
                                    search: value,
                                    stageId: widget.stageId,
                                    data: widget.data,
                                    transferefromdata: widget.transferfromdata,
                                  );
                                },
                              );
                            },
                            style: TextStyle(
                              fontSize: (14 * tabletFontScale).sp,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                fontSize: (14 * tabletFontScale).sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: (16 * tabletWidthScale).w,
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  (12 * tabletScale).r,
                                ),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.maincolor
                                          : Constants.mainDarkmodecolor,
                                  width: (1 * tabletScale).r,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  (12 * tabletScale).r,
                                ),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.maincolor
                                          : Constants.mainDarkmodecolor,
                                  width: (1.5 * tabletScale).r,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  (12 * tabletScale).r,
                                ),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.maincolor
                                          : Constants.mainDarkmodecolor,
                                  width: (1 * tabletScale).r,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: (10 * tabletWidthScale).w),

                        /// filter
                        Container(
                          height: (50 * tabletHeightScale).h,
                          width: (50 * tabletWidthScale).w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1F2),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                              width: (1 * tabletScale).r,
                            ),
                            borderRadius: BorderRadius.circular(
                              (8 * tabletScale).r,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              size: (24 * tabletFontScale).sp,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              showFilterDialogTeamLeader(
                                context,
                                context.read<GetLeadsTeamLeaderCubit>(),
                                widget.data,
                                widget.transferfromdata,
                              );
                            },
                          ),
                        ),

                        SizedBox(width: (10 * tabletWidthScale).w),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: EdgeInsets.all((8 * tabletScale).r),
                    child: buildAssignButtons(),
                  ),
                // BlocBuilder<GetLeadsTeamLeaderCubit, GetLeadsTeamLeaderState>(
                //   builder: (context, state) {
                //     return Padding(
                //       padding: EdgeInsets.all((8 * tabletScale).r),
                //       child: Column(
                //         children: [
                //           if (isSelectionMode) buildAssignButtons(),
                //           // SizedBox(height: (10 * tabletScale).h),
                //           // Row(
                //           //   children: [
                //           //     Expanded(
                //           //       child: TextField(
                //           //         controller: searchController,
                //           //         onChanged: (value) {
                //           //           final cubit =
                //           //               context
                //           //                   .read<GetLeadsTeamLeaderCubit>();

                //           //           cubit.fetchTeamLeaderLeadsWithPagination(
                //           //             search: value,
                //           //             stageId: widget.stageId,
                //           //             data: widget.data,
                //           //             transferefromdata:
                //           //                 widget.transferfromdata,
                //           //           );
                //           //         },
                //           //         style: TextStyle(
                //           //           fontSize: (14 * tabletFontScale).sp,
                //           //         ),
                //           //         decoration: InputDecoration(
                //           //           hintText: 'Search',
                //           //           hintStyle: TextStyle(
                //           //             fontSize: (14 * tabletFontScale).sp,
                //           //           ),
                //           //           contentPadding: EdgeInsets.symmetric(
                //           //             horizontal: (16 * tabletWidthScale).w,
                //           //             vertical: 0,
                //           //           ),
                //           //           border: OutlineInputBorder(
                //           //             borderRadius: BorderRadius.circular(
                //           //               (12 * tabletScale).r,
                //           //             ),
                //           //             borderSide: BorderSide(
                //           //               color:
                //           //                   Theme.of(context).brightness ==
                //           //                           Brightness.light
                //           //                       ? Constants.maincolor
                //           //                       : Constants.mainDarkmodecolor,
                //           //               width: (1 * tabletScale).r,
                //           //             ),
                //           //           ),
                //           //           focusedBorder: OutlineInputBorder(
                //           //             borderRadius: BorderRadius.circular(
                //           //               (12 * tabletScale).r,
                //           //             ),
                //           //             borderSide: BorderSide(
                //           //               color:
                //           //                   Theme.of(context).brightness ==
                //           //                           Brightness.light
                //           //                       ? Constants.maincolor
                //           //                       : Constants.mainDarkmodecolor,
                //           //               width: (1.5 * tabletScale).r,
                //           //             ),
                //           //           ),
                //           //           enabledBorder: OutlineInputBorder(
                //           //             borderRadius: BorderRadius.circular(
                //           //               (12 * tabletScale).r,
                //           //             ),
                //           //             borderSide: BorderSide(
                //           //               color:
                //           //                   Theme.of(context).brightness ==
                //           //                           Brightness.light
                //           //                       ? Constants.maincolor
                //           //                       : Constants.mainDarkmodecolor,
                //           //               width: (1 * tabletScale).r,
                //           //             ),
                //           //           ),
                //           //         ),
                //           //       ),
                //           //     ),
                //           //     SizedBox(width: (10 * tabletWidthScale).w),
                //           //     Container(
                //           //       height: (50 * tabletHeightScale).h,
                //           //       width: (50 * tabletWidthScale).w,
                //           //       decoration: BoxDecoration(
                //           //         color: const Color(0xFFE8F1F2),
                //           //         border: Border.all(
                //           //           color:
                //           //               Theme.of(context).brightness ==
                //           //                       Brightness.light
                //           //                   ? Constants.maincolor
                //           //                   : Constants.mainDarkmodecolor,
                //           //           width: (1 * tabletScale).r,
                //           //         ),
                //           //         borderRadius: BorderRadius.circular(
                //           //           (8 * tabletScale).r,
                //           //         ),
                //           //       ),
                //           //       child: IconButton(
                //           //         icon: Icon(
                //           //           Icons.filter_list,
                //           //           size: (24 * tabletFontScale).sp,
                //           //           color:
                //           //               Theme.of(context).brightness ==
                //           //                       Brightness.light
                //           //                   ? Constants.maincolor
                //           //                   : Constants.mainDarkmodecolor,
                //           //         ),
                //           //         padding: EdgeInsets.zero,
                //           //         constraints: const BoxConstraints(),
                //           //         onPressed: () {
                //           //           showFilterDialogTeamLeader(
                //           //             context,
                //           //             context.read<GetLeadsTeamLeaderCubit>(),
                //           //             widget.data,
                //           //             widget.transferfromdata,
                //           //           );
                //           //         },
                //           //       ),
                //           //     ),
                //           //     SizedBox(width: (10 * tabletWidthScale).w),
                //           //   ],
                //           // ),
                //         ],
                //       ),
                //     );
                //   },
                // ),
                // ... بعد الـ Column الأول
                Expanded(
                  child: Column(
                    children: [
                      // ✅ Header لتحديد الكل
                      if (_leads.isNotEmpty)
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: (16 * tabletWidthScale).w,
                            vertical: (8 * tabletHeightScale).h,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: (16 * tabletWidthScale).w,
                            vertical: (12 * tabletHeightScale).h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.grey[900],
                            borderRadius: BorderRadius.circular(
                              (12 * tabletScale).r,
                            ),
                            border: Border.all(
                              color:
                                  _selectAll
                                      ? Constants.maincolor
                                      : Colors.grey.withOpacity(0.3),
                              width: (1.5 * tabletScale).r,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _selectAll,
                                onChanged:
                                    _leads.isEmpty ? null : _toggleSelectAll,
                                activeColor: Constants.maincolor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    (5 * tabletScale).r,
                                  ),
                                ),
                              ),
                              SizedBox(width: (8 * tabletWidthScale).w),
                              Expanded(
                                child: Text(
                                  "Select All",
                                  style: TextStyle(
                                    fontSize: (16 * tabletFontScale).sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (12 * tabletWidthScale).w,
                                  vertical: (6 * tabletHeightScale).h,
                                ),
                                decoration: BoxDecoration(
                                  color: Constants.maincolor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    (20 * tabletScale).r,
                                  ),
                                ),
                                child: Text(
                                  _selectedCount > 0
                                      ? "$_selectedCount selected"
                                      : "0 selected",
                                  style: TextStyle(
                                    fontSize: (14 * tabletFontScale).sp,
                                    fontWeight: FontWeight.w600,
                                    color: Constants.maincolor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ✅ باقي الكود - الـ Expanded الثاني للـ BlocBuilder
                      Expanded(
                        child: BlocBuilder<
                          GetLeadsTeamLeaderCubit,
                          GetLeadsTeamLeaderState
                        >(
                          builder: (context, state) {
                            if (state is GetLeadsTeamLeaderPaginationLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: ListView.builder(
                                  padding: EdgeInsets.all((16 * tabletScale).r),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                        bottom: (16 * tabletHeightScale).h,
                                      ),
                                      height: (80 * tabletHeightScale).h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          (12 * tabletScale).r,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (state
                                is GetLeadsTeamLeaderPaginationSuccess) {
                              print('✅ Received ${_leads.length} leads total');
                              print(
                                '✅ hasMoreData from Cubit: ${context.read<GetLeadsTeamLeaderCubit>().hasMoreData}',
                              );
                              _leads = state.model.data ?? [];
                              if (selected.length != _leads.length) {
                                selected = List.generate(
                                  _leads.length,
                                  (index) => false,
                                );
                              }

                              // ✅ حساب عدد الأعمدة للتابلت (Grid View)
                              final int crossAxisCount = isTabletDevice ? 2 : 1;

                              return RefreshIndicator(
                                onRefresh: () async {
                                  final cubit =
                                      context.read<GetLeadsTeamLeaderCubit>();
                                  await cubit
                                      .fetchTeamLeaderLeadsWithPagination(
                                        data: widget.data,
                                        transferefromdata:
                                            widget.transferfromdata,
                                        stageId: widget.stageId,
                                      );
                                },
                                color: Constants.maincolor,
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Constants.backgroundDarkmode,
                                strokeWidth: (3 * tabletScale).r,
                                displacement: (40 * tabletHeightScale).h,
                                child:
                                    crossAxisCount == 1
                                        ? ListView.builder(
                                          controller: _scrollController,
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                (10 * tabletWidthScale).w,
                                            vertical: (2 * tabletHeightScale).h,
                                          ),
                                          itemCount:
                                              _leads.length +
                                              1, // +1 to account for the loading indicator
                                          itemBuilder: (context, index) {
                                            if (index >= _leads.length) {
                                              // Show loading indicator only if there's more data
                                              if (context
                                                  .read<
                                                    GetLeadsTeamLeaderCubit
                                                  >()
                                                  .hasMoreData) {
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        (20 * tabletHeightScale)
                                                            .h,
                                                  ),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const CircularProgressIndicator(),
                                                        SizedBox(
                                                          height:
                                                              (8 * tabletHeightScale)
                                                                  .h,
                                                        ),
                                                        Text(
                                                          "Loading more leads... (Page ${_cubit.currentPage})",
                                                          style: TextStyle(
                                                            fontSize:
                                                                (14 * tabletFontScale)
                                                                    .sp,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else if (_leads.isNotEmpty) {
                                                // Show end of list message
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        (20 * tabletHeightScale)
                                                            .h,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "✓ All leads loaded (${_leads.length} total)",
                                                      style: TextStyle(
                                                        fontSize:
                                                            (14 * tabletFontScale)
                                                                .sp,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            }
                                            // if (index >= _leads.length) {
                                            //   // ✅ عرض مؤشر التحميل فقط إذا كان هناك المزيد من البيانات للتحميل
                                            //   return context
                                            //           .read<
                                            //             GetLeadsTeamLeaderCubit
                                            //           >()
                                            //           .hasMoreData
                                            //       ? Padding(
                                            //         padding: EdgeInsets.symmetric(
                                            //           vertical:
                                            //               (12 * tabletHeightScale)
                                            //                   .h,
                                            //         ),
                                            //         child: const Center(
                                            //           child:
                                            //               CircularProgressIndicator(),
                                            //         ),
                                            //       )
                                            //       : const SizedBox(); // إذا لم تكن هناك بيانات أخرى، لا تظهر شيئًا
                                            // }
                                            final lead = _leads[index];
                                            print(
                                              "assign of lead: ${lead.assign}",
                                            );
                                            salesfcmtoken =
                                                lead.sales?.userlog?.fcmToken;
                                            final prefs =
                                                SharedPreferences.getInstance();
                                            final fcmToken = prefs.then(
                                              (prefs) => prefs.setString(
                                                'fcm_token_sales',
                                                salesfcmtoken ?? '',
                                              ),
                                            );
                                            log(
                                              "fcmToken of sales: $salesfcmtoken",
                                            );
                                            leadIdd = lead.id.toString();
                                            managerfcmtoken =
                                                lead.sales?.manager?.fcmToken;
                                            final leadstageupdated =
                                                lead.stagedateupdated;
                                            final leadStagetype =
                                                lead.stage?.name ?? "";
                                            DateTime? stageUpdatedDate;
                                            bool isOutdatedLocal = false;
                                            if (leadstageupdated != null) {
                                              try {
                                                stageUpdatedDate =
                                                    DateTime.parse(
                                                      leadstageupdated,
                                                    );
                                                log(
                                                  "stageUpdatedDate: $stageUpdatedDate",
                                                );
                                                log(
                                                  "stage type: $leadStagetype",
                                                );
                                              } catch (_) {
                                                stageUpdatedDate = null;
                                              }
                                            }
                                            if (stageUpdatedDate != null) {
                                              final now =
                                                  DateTime.now().toUtc();
                                              print("now: $now");
                                              final difference =
                                                  now
                                                      .difference(
                                                        stageUpdatedDate,
                                                      )
                                                      .inMinutes;
                                              print("difference: $difference");
                                              isOutdatedLocal = difference > 1;
                                              print(
                                                "isOutdated: $isOutdatedLocal",
                                              );
                                            }
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom:
                                                    (8 * tabletHeightScale).h,
                                              ),
                                              child: buildUserTile(
                                                parentContext: context,
                                                name: lead.name ?? 'No Name',
                                                status:
                                                    lead.stage?.name ??
                                                    'No Status',
                                                index: index,
                                                id: lead.id.toString(),
                                                leadsalesName:
                                                    lead.sales?.name ??
                                                    'No Sales',
                                                phone: lead.phone ?? 'No Phone',
                                                email: lead.email ?? 'No Email',
                                                stage:
                                                    lead.stage?.name ??
                                                    'No Stage',
                                                stageid:
                                                    lead.stage?.id.toString() ??
                                                    'No Stage ID',
                                                channel:
                                                    lead.chanel?.name ??
                                                    'No Channel',
                                                creationdate:
                                                    lead.createdAt != null
                                                        ? formatDateTimeToDubai(
                                                          lead.createdAt!,
                                                        )
                                                        : '',
                                                project:
                                                    lead.project?.name ??
                                                    'No Project',
                                                lastcomment:
                                                    lead.lastcommentdate ??
                                                    'No Last Comment',
                                                leadcampaign:
                                                    lead
                                                        .campaign
                                                        ?.campainName ??
                                                    'No Campaign',
                                                leadNotes: 'No Notes',
                                                leaddeveloper:
                                                    lead
                                                        .project
                                                        ?.developer
                                                        ?.name ??
                                                    'No Developer',
                                                userlogname:
                                                    lead.sales?.userlog?.name ??
                                                    'No User',
                                                teamleadername:
                                                    lead
                                                        .sales
                                                        ?.teamleader
                                                        ?.name ??
                                                    'No Team Leader',
                                                salesName:
                                                    lead.sales?.name ??
                                                    'No Sales',
                                                lead: lead,
                                                stageUpdatedDate:
                                                    stageUpdatedDate,
                                                leadStagetype: leadStagetype,
                                                isOutdated: isOutdatedLocal,
                                                fcmtoken: salesfcmtoken ?? '',
                                                managerFcmtoken:
                                                    lead
                                                        .sales
                                                        ?.manager
                                                        ?.fcmToken ??
                                                    '',
                                                assign: lead.assign ?? false,
                                                userlogteamleadername:
                                                    lead.sales?.userlog?.name ??
                                                    'No Userlog Team Leader',
                                                leadwhatsappnumber:
                                                    lead.whatsappnumber ??
                                                    lead.phone ??
                                                    '',
                                                jobdescription:
                                                    lead.jobdescription ??
                                                    'no job description',
                                                secondphonenumber:
                                                    lead.phonenumber2 ??
                                                    'no second phone number',
                                                laststageupdated:
                                                    leadstageupdated!,
                                                stageId:
                                                    lead.stage?.id ??
                                                    'No Stage ID',
                                                leadLastDateAssigned:
                                                    lead.lastdateassign ?? '',
                                                resetCreationDate:
                                                    lead.resetcreationdate ??
                                                    false,
                                              ),
                                            );
                                          },
                                        )
                                        : GridView.builder(
                                          padding: EdgeInsets.all(
                                            (16 * tabletScale).r,
                                          ),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                childAspectRatio: 0.85,
                                                crossAxisSpacing:
                                                    (16 * tabletWidthScale).w,
                                                mainAxisSpacing:
                                                    (16 * tabletHeightScale).h,
                                              ),
                                          itemCount: _leads.length,
                                          itemBuilder: (context, index) {
                                            final lead = _leads[index];
                                            // ✅ نفس الكود لكن مع تعديل الفهرس
                                            salesfcmtoken =
                                                lead.sales?.userlog?.fcmToken;
                                            final prefs =
                                                SharedPreferences.getInstance();
                                            final fcmToken = prefs.then(
                                              (prefs) => prefs.setString(
                                                'fcm_token_sales',
                                                salesfcmtoken ?? '',
                                              ),
                                            );
                                            leadIdd = lead.id.toString();
                                            managerfcmtoken =
                                                lead.sales?.manager?.fcmToken;
                                            final leadstageupdated =
                                                lead.stagedateupdated;
                                            final leadStagetype =
                                                lead.stage?.name ?? "";
                                            DateTime? stageUpdatedDate;
                                            bool isOutdatedLocal = false;
                                            if (leadstageupdated != null) {
                                              try {
                                                stageUpdatedDate =
                                                    DateTime.parse(
                                                      leadstageupdated,
                                                    );
                                              } catch (_) {
                                                stageUpdatedDate = null;
                                              }
                                            }
                                            if (stageUpdatedDate != null) {
                                              final now =
                                                  DateTime.now().toUtc();
                                              final difference =
                                                  now
                                                      .difference(
                                                        stageUpdatedDate,
                                                      )
                                                      .inMinutes;
                                              isOutdatedLocal = difference > 1;
                                            }
                                            return buildUserTile(
                                              parentContext: context,
                                              name: lead.name ?? 'No Name',
                                              status:
                                                  lead.stage?.name ??
                                                  'No Status',
                                              index: index,
                                              id: lead.id.toString(),
                                              leadsalesName:
                                                  lead.sales?.name ??
                                                  'No Sales',
                                              phone: lead.phone ?? 'No Phone',
                                              email: lead.email ?? 'No Email',
                                              stage:
                                                  lead.stage?.name ??
                                                  'No Stage',
                                              stageid:
                                                  lead.stage?.id.toString() ??
                                                  'No Stage ID',
                                              channel:
                                                  lead.chanel?.name ??
                                                  'No Channel',
                                              creationdate:
                                                  lead.createdAt != null
                                                      ? formatDateTimeToDubai(
                                                        lead.createdAt!,
                                                      )
                                                      : '',
                                              project:
                                                  lead.project?.name ??
                                                  'No Project',
                                              lastcomment:
                                                  lead.lastcommentdate ??
                                                  'No Last Comment',
                                              leadcampaign:
                                                  lead.campaign?.campainName ??
                                                  'No Campaign',
                                              leadNotes: 'No Notes',
                                              leaddeveloper:
                                                  lead
                                                      .project
                                                      ?.developer
                                                      ?.name ??
                                                  'No Developer',
                                              userlogname:
                                                  lead.sales?.userlog?.name ??
                                                  'No User',
                                              teamleadername:
                                                  lead
                                                      .sales
                                                      ?.teamleader
                                                      ?.name ??
                                                  'No Team Leader',
                                              salesName:
                                                  lead.sales?.name ??
                                                  'No Sales',
                                              lead: lead,
                                              stageUpdatedDate:
                                                  stageUpdatedDate,
                                              leadStagetype: leadStagetype,
                                              isOutdated: isOutdatedLocal,
                                              fcmtoken: salesfcmtoken ?? '',
                                              managerFcmtoken:
                                                  lead
                                                      .sales
                                                      ?.manager
                                                      ?.fcmToken ??
                                                  '',
                                              assign: lead.assign ?? false,
                                              userlogteamleadername:
                                                  lead.sales?.userlog?.name ??
                                                  'No Userlog Team Leader',
                                              leadwhatsappnumber:
                                                  lead.whatsappnumber ??
                                                  lead.phone ??
                                                  '',
                                              jobdescription:
                                                  lead.jobdescription ??
                                                  'no job description',
                                              secondphonenumber:
                                                  lead.phonenumber2 ??
                                                  'no second phone number',
                                              laststageupdated:
                                                  leadstageupdated!,
                                              stageId:
                                                  lead.stage?.id ??
                                                  'No Stage ID',
                                              leadLastDateAssigned:
                                                  lead.lastdateassign ?? '',
                                              resetCreationDate:
                                                  lead.resetcreationdate ??
                                                  false,
                                            );
                                          },
                                        ),
                              );
                            } else if (state
                                is GetLeadsTeamLeaderPaginationError) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all((16 * tabletScale).r),
                                  child: Text(
                                    " ${state.message}",
                                    style: TextStyle(
                                      fontSize: (16 * tabletFontScale).sp,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black87
                                              : Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all((16 * tabletScale).r),
                                  child: Text(
                                    "No leads found.",
                                    style: TextStyle(
                                      fontSize: (16 * tabletFontScale).sp,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black87
                                              : Colors.white70,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

    /// ✅ هات آخر Stage مسجل لل Leads المختارة
    final lastStage =
        selectedLeadStageIds.isNotEmpty ? selectedLeadStageIds.last : "";

    /// ✅ افتح الديالوج النهائي مباشرة
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
                  stageId: widget.stageId,
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

  void _showAddMeetingSheet(BuildContext context, String leadId) {
    final commentController = TextEditingController();
    final salesDeveloperController =
        TextEditingController(); // 🔹 حقل Sales Developer Name
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
                    final parentContext =
                        context; // أفضل طريقة: تمرر الـ context الأساسي للـ Scaffold عند فتح الـ BottomSheet
                    Navigator.pop(context); // تقفل الـ BottomSheet أولاً
                    // بعد الإغلاق، نستخدم parent context للـ Snackbar
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text("Meeting comment added successfully"),
                        ),
                      );
                      final cubit = context.read<GetLeadsCubit>();
                      cubit.fetchSalesLeadsWithPagination(
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
                        /// 🔹 Stage Dropdown
                        BlocBuilder<StagesCubit, StagesState>(
                          builder: (context, state) {
                            if (state is StagesLoading) {
                              return const CircularProgressIndicator();
                            }

                            if (state is StagesLoaded) {
                              // فلتر على الثلاث مراحل المطلوبة فقط
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

                        /// 🔹 Stage Date + Time
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

                        /// 🔹 Comment
                        TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 Sales Developer Name
                        TextField(
                          controller: salesDeveloperController,
                          decoration: const InputDecoration(
                            labelText: "Sales Developer Name",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 Buttons
                        BlocBuilder<GetLeadsCubit, GetLeadsState>(
                          builder: (context, state) {
                            final isLoading =
                                state is PostMeetingCommentLoading;

                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Constants.maincolor,
                                    ),
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () {
                                              // ✅ تحقق من الحقول المطلوبة
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

                                              // تحويل التاريخ لتوقيت دبي
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
                                      // هنا هتحدد وجهة All Comments بعدين
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

  Widget buildAssignButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
      decoration: BoxDecoration(
        color: isDark ? Constants.mainDarkmodecolor : Constants.maincolor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /// 🔹 Assign Button
          _buildCircleButton(
            child: Image.asset(
              "assets/images/right.png",
              width: 22,
              height: 22,
              color: Constants.maincolor,
            ),
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
          ),

          /// 🔹 Edit Button
          _buildCircleButton(
            child: Icon(Icons.edit, color: Constants.maincolor, size: 22),
            onTap: () async {
              if (_selectedLead != null) {
                final result = await showDialog(
                  context: context,
                  builder:
                      (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => EditLeadCubit(EditLeadApiService()),
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
                                    SalesCubit(GetAllSalesApiService())
                                      ..fetchAllSales(),
                          ),
                        ],
                        child: EditLeadSalesDialog(
                          userId: _selectedLead!.id ?? '',
                          initialName: _selectedLead!.name ?? '',
                          initialPhone2: _selectedLead!.phonenumber2 ?? '',
                          initialWhatsappNumber:
                              _selectedLead!.whatsappnumber ?? '',
                          initialNotes: '',
                          initialProjectId: _selectedLead!.project?.id,
                          salesID: _selectedLead!.sales?.id ?? '',
                          onSuccess: () async {
                            setState(() {
                              selected.clear();
                              selectedLeadsData.clear();
                              _selectedLead = null;
                              isSelectionMode = false;
                            });

                            await _cubit.fetchTeamLeaderLeadsWithPagination(
                              data: widget.data,
                              transferefromdata: widget.transferfromdata,
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
                    stageId: widget.stageId,
                  );

                  setState(() {});
                }
              }
            },
          ),

          /// 🔹 Add Meeting Button
          _buildCircleButton(
            child: Icon(Icons.event, color: Constants.maincolor, size: 22),
            onTap: () {
              if (_selectedLead != null) {
                _showAddMeetingSheet(context, _selectedLead!.id!);
              }
            },
          ),
        ],
      ),
    );
  }

  /// ✅ Circle Button Widget موحد لكل الأزرار
  Widget _buildCircleButton({
    required Widget child,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, // 👈 نفس المقاس للجميع
        height: 48,
        alignment: Alignment.center,
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
        child: child,
      ),
    );
  }

  Widget buildUserTile({
    required String name,
    required BuildContext parentContext,
    required String status,
    required int index,
    required String id,
    required String leadsalesName,
    required String phone,
    required String email,
    required String stage,
    required String stageid,
    required String channel,
    required String creationdate,
    required String project,
    required String lastcomment,
    required String leadcampaign,
    required String leadNotes,
    required String leaddeveloper,
    required String userlogname,
    required String teamleadername,
    required String salesName,
    required dynamic lead,
    DateTime? stageUpdatedDate,
    required String leadStagetype,
    required bool isOutdated,
    required String fcmtoken,
    required String managerFcmtoken,
    required bool assign,
    required String userlogteamleadername,
    required String leadwhatsappnumber,
    required String jobdescription,
    required String secondphonenumber,
    required String laststageupdated,
    required String stageId,
    required String leadLastDateAssigned,
    required bool resetCreationDate,
  }) {
    // ✅ كشف نوع الجهاز داخل الويدجت
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

    return InkWell(
      onTap: () async {
        final bool hasDownloadIcon =
            assign == true && userlogteamleadername == teamleadname;
        final bool isPendingStage = stage.toLowerCase() == 'pending';

        if (isSelectionMode) {
          if (hasDownloadIcon) return;
          setState(() {
            selected[index] = !selected[index];

            if (!selected.contains(true)) {
              isSelectionMode = false;
            }
          });
          return;
        }
        log("userlogteamleadername: $userlogteamleadername");
        log("teamleadname: $teamleadname");
        log("leadassign: $assign");
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
                      leedId: id,
                      leadName: name,
                      leadPhone: phone,
                      leadEmail: email,
                      leadStage: stage,
                      leadStageId: stageid,
                      leadChannel: channel,
                      leadSalesName: leadsalesName,
                      leadCreationDate: creationdate,
                      leadProject: project,
                      leadLastComment: lastcomment,
                      leadcampaign: leadcampaign,
                      leadNotes: leadNotes,
                      leaddeveloper: leaddeveloper,
                      userlogname: userlogname,
                      teamleadername: teamleadername,
                      fcmtoken: fcmtoken,
                      managerfcmtoken: managerFcmtoken,
                      leadwhatsappnumber: leadwhatsappnumber,
                      jobdescription: jobdescription,
                      secondphonenumber: secondphonenumber,
                      laststageupdated: laststageupdated,
                      stageId: stageId,
                      leadLastDateAssigned: leadLastDateAssigned,
                      isresetcreationdate: resetCreationDate,
                    ),
                  ),
            ),
          );
        } else if (assign == true && userlogteamleadername == teamleadname) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Attention",
                  style: TextStyle(fontSize: (18 * tabletFontScale).sp),
                ),
                content: Text(
                  "You must receive this lead first.",
                  style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      padding: EdgeInsets.symmetric(
                        horizontal: (16 * tabletWidthScale).w,
                        vertical: (8 * tabletHeightScale).h,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (14 * tabletFontScale).sp,
                      ),
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
                      leedId: id,
                      leadName: name,
                      leadPhone: phone,
                      leadEmail: email,
                      leadStage: stage,
                      leadStageId: stageid,
                      leadChannel: channel,
                      leadSalesName: leadsalesName,
                      leadCreationDate: creationdate,
                      leadProject: project,
                      leadLastComment: lastcomment,
                      leadcampaign: leadcampaign,
                      leadNotes: leadNotes,
                      leaddeveloper: leaddeveloper,
                      userlogname: userlogname,
                      teamleadername: teamleadername,
                      fcmtoken: fcmtoken,
                      managerfcmtoken: managerFcmtoken,
                      leadwhatsappnumber: leadwhatsappnumber,
                      jobdescription: jobdescription,
                      secondphonenumber: secondphonenumber,
                      laststageupdated: laststageupdated,
                      stageId: stageId,
                      leadLastDateAssigned: leadLastDateAssigned,
                      isresetcreationdate: resetCreationDate,
                    ),
                  ),
            ),
          );
        }
      },
      onLongPress: () {
        final bool hasDownloadIcon =
            assign == true && userlogteamleadername == teamleadname;
        if (hasDownloadIcon) return;
        setState(() {
          selected[index] = true;
          isSelectionMode = selected.contains(true);
          _selectedLead = lead;

          final leadIdStr = lead.id.toString();

          if (selected[index] = true) {
            if (!selectedLeadsData.any((l) => l.id.toString() == leadIdStr)) {
              selectedLeadsData.add(lead);
            }
          } else {
            selectedLeadsData.removeWhere((l) => l.id.toString() == leadIdStr);
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: (4 * tabletHeightScale).h,
          horizontal: (2 * tabletWidthScale).w,
        ),
        padding: EdgeInsets.all((16 * tabletScale).r),
        decoration: BoxDecoration(
          color:
              selected[index]
                  ? Colors.grey.withOpacity(0.3)
                  : (Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.grey[900]),
          borderRadius: BorderRadius.circular((15 * tabletScale).r),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.black.withOpacity(0.5),
              spreadRadius: (2 * tabletScale).r,
              blurRadius: (5 * tabletScale).r,
              offset: Offset(0, (3 * tabletHeightScale).h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isTabletDevice ? 8 : 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (_) {
                              final bool isFinalStage =
                                  stageUpdatedDate != null &&
                                  (leadStagetype == "Done Deal" ||
                                      leadStagetype == "Transfer" ||
                                      leadStagetype == "Fresh" ||
                                      leadStagetype == "Not Interested");

                              final Color stageColor =
                                  isFinalStage
                                      ? Constants.maincolor
                                      : isOutdated
                                      ? Colors.red
                                      : Colors.green;

                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (10 * tabletWidthScale).w,
                                  vertical: (5 * tabletHeightScale).h,
                                ),
                                decoration: BoxDecoration(
                                  color: stageColor.withOpacity(0.1),
                                  border: Border.all(
                                    color: stageColor,
                                    width: (1 * tabletScale).r,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    (20 * tabletScale).r,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: stageColor,
                                      size: (10 * tabletFontScale).sp,
                                    ),
                                    SizedBox(width: (6 * tabletWidthScale).w),
                                    Flexible(
                                      child: Text(
                                        lead.stage?.name ?? "Unknown",
                                        style: TextStyle(
                                          fontSize: (13 * tabletFontScale).sp,
                                          fontWeight: FontWeight.bold,
                                          color: stageColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: (8 * tabletHeightScale).h),
                          Padding(
                            padding: EdgeInsets.only(
                              left: (4 * tabletWidthScale).w,
                            ),
                            child: Text(
                              "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!) : "N/A"}",
                              style: TextStyle(
                                fontSize: (12 * tabletFontScale).sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black87
                                        : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (assign == true && userlogteamleadername == teamleadname)
                      Padding(
                        padding: EdgeInsets.only(
                          right: (8 * tabletWidthScale).w,
                        ),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value:
                                          context
                                              .read<GetLeadsTeamLeaderCubit>(),
                                    ),
                                    BlocProvider(
                                      create:
                                          (_) => EditLeadCubit(
                                            EditLeadApiService(),
                                          ),
                                    ),
                                  ],
                                  child: Builder(
                                    builder: (innerContext) {
                                      bool isLoading = false;

                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: Text(
                                              "Confirmation",
                                              style: TextStyle(
                                                fontSize:
                                                    (18 * tabletFontScale).sp,
                                              ),
                                            ),
                                            content: Text(
                                              "Are you sure to receive this lead?",
                                              style: TextStyle(
                                                fontSize:
                                                    (14 * tabletFontScale).sp,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.light
                                                          ? Constants.maincolor
                                                          : Constants
                                                              .mainDarkmodecolor,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        (16 * tabletWidthScale)
                                                            .w,
                                                    vertical:
                                                        (8 * tabletHeightScale)
                                                            .h,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(
                                                    innerContext,
                                                  ).pop();
                                                },
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        (14 * tabletFontScale)
                                                            .sp,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.light
                                                          ? Constants.maincolor
                                                          : Constants
                                                              .mainDarkmodecolor,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        (16 * tabletWidthScale)
                                                            .w,
                                                    vertical:
                                                        (8 * tabletHeightScale)
                                                            .h,
                                                  ),
                                                ),
                                                onPressed:
                                                    isLoading
                                                        ? null
                                                        : () async {
                                                          setState(() {
                                                            isLoading = true;
                                                          });
                                                          try {
                                                            await innerContext
                                                                .read<
                                                                  EditLeadCubit
                                                                >()
                                                                .editLeadAssignvalue(
                                                                  userId:
                                                                      lead.id!,
                                                                  assign: false,
                                                                );
                                                            if (mounted) {
                                                              Navigator.of(
                                                                innerContext,
                                                              ).pop();
                                                              parentContext
                                                                  .read<
                                                                    GetLeadsTeamLeaderCubit
                                                                  >()
                                                                  .fetchTeamLeaderLeadsWithPagination(
                                                                    data:
                                                                        widget
                                                                            .data,
                                                                    transferefromdata:
                                                                        widget
                                                                            .transferfromdata,
                                                                    stageId:
                                                                        widget
                                                                            .stageId,
                                                                  );
                                                            }
                                                          } finally {
                                                            if (mounted) {
                                                              setState(() {
                                                                isLoading =
                                                                    false;
                                                              });
                                                            }
                                                          }
                                                        },
                                                child:
                                                    isLoading
                                                        ? SizedBox(
                                                          height:
                                                              (20 * tabletHeightScale)
                                                                  .h,
                                                          width:
                                                              (20 * tabletWidthScale)
                                                                  .w,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth:
                                                                (2 * tabletScale)
                                                                    .r,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                        : Text(
                                                          "OK",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                (14 * tabletFontScale)
                                                                    .sp,
                                                          ),
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
                            radius: (18 * tabletScale).r,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey
                                    : Constants.mainDarkmodecolor,
                            child: Icon(
                              Icons.download,
                              color: Colors.white,
                              size: (20 * tabletFontScale).sp,
                            ),
                          ),
                        ),
                      ),
                    Checkbox(
                      value: selected[index],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          (5 * tabletScale).r,
                        ),
                      ),
                      activeColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) {
                        final bool hasDownloadIcon =
                            assign == true &&
                            userlogteamleadername == teamleadname;

                        if (hasDownloadIcon) return;

                        setState(() {
                          selected[index] = val!;
                          isSelectionMode = selected.contains(true);
                          _updateSelectedCount();
                          _selectedLead = lead;
                          final leadIdStr = lead.id.toString();

                          if (val) {
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
                      },
                    ),
                  ],
                ),
                SizedBox(height: (5 * tabletHeightScale).h),
                if (assign == true && userlogteamleadername == teamleadname)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: (20 * tabletHeightScale).h,
                        width: (44 * tabletWidthScale).w,
                        child: const DotLoading(),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: (12 * tabletHeightScale).h),
            Divider(thickness: (1.5 * tabletScale).h),
            SizedBox(height: (20 * tabletHeightScale).h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: isTabletDevice ? 7 : 6,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: (19 * tabletFontScale).sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: isTabletDevice ? 5 : 4,
                  child: Text(
                    lead.project?.name ?? "N/A",
                    style: TextStyle(
                      fontSize: (12 * tabletFontScale).sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: (12 * tabletHeightScale).h),
            InkWell(
              onTap: () {
                final formattedPhone =
                    phone.startsWith('0') ? phone : '+$phone';
                makePhoneCall(formattedPhone);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.grey
                            : Constants.mainDarkmodecolor,
                    size: (18 * tabletFontScale).sp,
                  ),
                  SizedBox(width: (8 * tabletWidthScale).w),
                  Expanded(
                    child: Text(
                      phone,
                      style: TextStyle(
                        fontSize: (13 * tabletFontScale).sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: (35 * tabletHeightScale).h),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_pin_outlined,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.grey
                              : Constants.mainDarkmodecolor,
                      size: (20 * tabletFontScale).sp,
                    ),
                    SizedBox(width: (8 * tabletWidthScale).w),
                    Expanded(
                      flex: isTabletDevice ? 6 : 5,
                      child: Text(
                        lead.assigntype == true
                            ? "team: ${lead.sales?.name}"
                            : lead.sales?.name ?? 'N/A',
                        style: TextStyle(
                          fontSize: (16 * tabletFontScale).sp,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Flexible(
                      flex: isTabletDevice ? 5 : 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              final phone = lead.phone ?? '';
                              final formattedPhone =
                                  phone.startsWith('0') ? phone : '+$phone';
                              makePhoneCall(formattedPhone);
                            },
                            borderRadius: BorderRadius.circular(
                              (30 * tabletScale).r,
                            ),
                            child: Container(
                              padding: EdgeInsets.all((8 * tabletScale).r),
                              margin: EdgeInsets.symmetric(
                                horizontal: (4 * tabletWidthScale).w,
                              ),
                              decoration: BoxDecoration(
                                color: Constants.maincolor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.phone,
                                color: Colors.white,
                                size: (18 * tabletFontScale).sp,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final rawPhone =
                                  (lead.phone?.isNotEmpty == true
                                          ? lead.phone
                                          : lead.whatsappnumber)
                                      ?.replaceAll(RegExp(r'\D'), '') ??
                                  '';
                              final formattedPhone =
                                  rawPhone.startsWith('0')
                                      ? rawPhone
                                      : '+$rawPhone';
                              final url = "https://wa.me/$formattedPhone";
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
                            borderRadius: BorderRadius.circular(
                              (30 * tabletScale).r,
                            ),
                            child: Container(
                              padding: EdgeInsets.all((8 * tabletScale).r),
                              margin: EdgeInsets.symmetric(
                                horizontal: (4 * tabletWidthScale).w,
                              ),
                              decoration: BoxDecoration(
                                color: Constants.maincolor,
                                shape: BoxShape.circle,
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.white,
                                size: (18 * tabletFontScale).sp,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        (12 * tabletScale).r,
                                      ),
                                    ),
                                    child: BlocProvider(
                                      create:
                                          (_) => LeadCommentsCubit(
                                            GetAllLeadCommentsApiService(),
                                          )..fetchNewComments(
                                            leadId: lead.id!,
                                            page: 1,
                                            limit: 10,
                                          ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          (16 * tabletScale).r,
                                        ),
                                        child: BlocBuilder<
                                          LeadCommentsCubit,
                                          LeadCommentsState
                                        >(
                                          builder: (context, commentState) {
                                            if (commentState
                                                is LeadCommentsLoading) {
                                              return SizedBox(
                                                height:
                                                    (100 * tabletHeightScale).h,
                                                child: Center(
                                                  child: Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.all(
                                                        (16 * tabletScale).r,
                                                      ),
                                                      itemCount: 6,
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        return Container(
                                                          margin: EdgeInsets.only(
                                                            bottom:
                                                                (16 *
                                                                        tabletHeightScale)
                                                                    .h,
                                                          ),
                                                          height:
                                                              (80 * tabletHeightScale)
                                                                  .h,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  (12 *
                                                                          tabletScale)
                                                                      .r,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else if (commentState
                                                is LeadCommentsError) {
                                              return SizedBox(
                                                height:
                                                    (100 * tabletHeightScale).h,
                                                child: Center(
                                                  child: Text(
                                                    "No comments available",
                                                    style: TextStyle(
                                                      fontSize:
                                                          (14 * tabletFontScale)
                                                              .sp,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else if (commentState
                                                is NewCommentsLoaded) {
                                              final newCommentsData =
                                                  commentState.newComments;

                                              if (newCommentsData.comments ==
                                                      null ||
                                                  newCommentsData
                                                      .comments!
                                                      .isEmpty) {
                                                return Text(
                                                  'No comments available.',
                                                  style: TextStyle(
                                                    fontSize:
                                                        (14 * tabletFontScale)
                                                            .sp,
                                                  ),
                                                );
                                              }

                                              final firstComment =
                                                  newCommentsData
                                                      .comments!
                                                      .first;

                                              final String firstCommentText =
                                                  firstComment
                                                      .firstcomment
                                                      ?.text ??
                                                  "No comment available.";

                                              final String secondCommentText =
                                                  firstComment
                                                      .secondcomment
                                                      ?.text ??
                                                  'No action available.';

                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Last Comment",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          (15 * tabletFontScale)
                                                              .sp,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        (5 * tabletHeightScale)
                                                            .h,
                                                  ),
                                                  Text(
                                                    firstCommentText,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          (13 * tabletFontScale)
                                                              .sp,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        (10 * tabletHeightScale)
                                                            .h,
                                                  ),
                                                  Text(
                                                    "Action (Plan)",
                                                    style: TextStyle(
                                                      color:
                                                          Constants.maincolor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          (15 * tabletFontScale)
                                                              .sp,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        (5 * tabletHeightScale)
                                                            .h,
                                                  ),
                                                  Text(
                                                    secondCommentText,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          (13 * tabletFontScale)
                                                              .sp,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return SizedBox(
                                                height:
                                                    (100 * tabletHeightScale).h,
                                                child: Center(
                                                  child: Text(
                                                    "No comments",
                                                    style: TextStyle(
                                                      fontSize:
                                                          (14 * tabletFontScale)
                                                              .sp,
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
                            },
                            borderRadius: BorderRadius.circular(
                              (30 * tabletScale).r,
                            ),
                            child: Container(
                              padding: EdgeInsets.all((7 * tabletScale).r),
                              margin: EdgeInsets.symmetric(
                                horizontal: (2 * tabletWidthScale).w,
                              ),
                              decoration: BoxDecoration(
                                color: Constants.maincolor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: (18 * tabletFontScale).sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (4 * tabletHeightScale).h),
                if (resetCreationDate == false)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.date_range,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.grey
                                : Constants.mainDarkmodecolor,
                        size: (20 * tabletFontScale).sp,
                      ),
                      SizedBox(width: (6 * tabletWidthScale).w),
                      Flexible(
                        child: Text(
                          " ${lead.date != null ? formatDateTimeToDubai(lead.date!) : "N/A"}",
                          style: TextStyle(
                            fontSize: (12 * tabletFontScale).sp,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getStatusIcon(String status) {
    switch (status) {
      case 'Follow Up':
      case 'Follow After Meeting':
      case 'Follow':
        return Icon(
          Icons.mark_email_unread_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Meeting':
        return Icon(
          Icons.chat_bubble_outline,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Done Deal':
        return Icon(
          Icons.check_box_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Interested':
        return Icon(
          FontAwesomeIcons.check,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Not Interested':
        return Icon(
          FontAwesomeIcons.timesCircle,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Fresh':
        return Icon(
          Icons.new_releases,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Transfer':
        return Icon(
          Icons.no_transfer,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'EOI':
        return Icon(
          Icons.event_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Reservation':
        return Icon(
          Icons.task,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'assigned':
        return Icon(
          Icons.check,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'delivered':
        return Icon(
          Icons.done_all,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      default:
        return const Icon(Icons.info_outline, color: Colors.grey);
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
}

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
    // ✅ كشف نوع الجهاز داخل الـ build
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
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;

    return SizedBox(
      height: (20 * tabletHeightScale).h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: (3 * tabletWidthScale).w),
            child: _buildDot(_animations[index], isTabletDevice, tabletScale),
          );
        }),
      ),
    );
  }

  Widget _buildDot(
    Animation<double> animation,
    bool isTabletDevice,
    double tabletScale,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -(animation.value * (isTabletDevice ? 0.85 : 1.0))),
          child: Container(
            width: (8 * tabletScale).r,
            height: (8 * tabletScale).r,
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
