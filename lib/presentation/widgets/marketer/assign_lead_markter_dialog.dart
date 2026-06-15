// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print, deprecated_member_use
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/stages_models.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignLeadMarkterDialog extends StatefulWidget {
  final Color mainColor;
  final LeadResponse? leadResponse;
  final List? leadIds;
  final String? leadId;
  final String? leadStage;
  final List? leadSalesId;
  final List? leadStages;

  const AssignLeadMarkterDialog({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
    this.leadStage,
    this.leadSalesId,
    this.leadStages,
  });

  @override
  State<AssignLeadMarkterDialog> createState() =>
      _AssignLeadMarkterDialogState();
}

class _AssignLeadMarkterDialogState extends State<AssignLeadMarkterDialog> {
  // ─── original logic state ──────────────────────────────────────
  String? selectedSalesId;
  Map<String, bool> selectedSales = {};
  String? selectedSalesFcmToken;
  bool clearHistory = false;
  final TextEditingController searchController = TextEditingController();
  final Set<String> _selectedLeadStagesIds = {};
  String selectedOption = 'same';
  String? selectedStageId;
  String? selectedstagename;
  bool isTeamLeaderAssign = false;
  bool resetCreationDate = false;

  // ─── NEW: single source of truth for the list ─────────────────
  // salesOnly   = full filtered-by-role list (rebuilt on BlocBuilder)
  // displayList = what's shown (sliced or searched)
  List<SalesData> _salesOnly = [];
  List<SalesData> _displayList = [];
  bool _searchActive = false;
  List<String> selectedSalesFcmTokens = []; // ✅ أضف ده

  // ─── responsive ───────────────────────────────────────────────
  late bool isTabletDevice;
  late double tabletScale;
  late double tabletFontScale;
  late double tabletWidthScale;
  late double tabletHeightScale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = MediaQuery.of(context);
    final physicalSize = data.size;
    final diagonal = math.sqrt(
      math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160);
    isTabletDevice = inches >= 7.0;
    tabletScale = isTabletDevice ? 0.85 : 1.0;
    tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ─── rebuild _salesOnly from the loaded state ─────────────────
  void _rebuildSalesOnly(List<SalesData> allSales) {
    final uniqueSalesMap = <String, SalesData>{};
    for (var sale in allSales) {
      final user = sale.userlog;
      if (user != null) {
        if (isTeamLeaderAssign) {
          // وضع Team Leader
          if (user.role == "Team Leader") {
            uniqueSalesMap[sale.id!] = sale;
          }
        } else {
          // بعد
          if ((user.role == "Sales" || user.role == "Manager") &&
              !(sale.name?.toLowerCase().startsWith("default") ?? false)) {
            uniqueSalesMap[sale.id!] = sale;
          }
        }
      }
    }
    _salesOnly = uniqueSalesMap.values.toList();

    // Only sort if list is not empty
    if (_salesOnly.isNotEmpty) {
      _salesOnly.sort((a, b) {
        // Handle null names safely
        final nameA = a.name?.toLowerCase() ?? '';
        final nameB = b.name?.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });
    }

    _applySearch(searchController.text, notify: false);
  }

  // ─── apply current search query to _salesOnly → _displayList ──
  void _applySearch(String query, {bool notify = true}) {
    _searchActive = query.isNotEmpty;

    // استخدم ?. بدل ! عشان تتجنب null error
    final matched =
        query.isEmpty
            ? List<SalesData>.from(_salesOnly)
            : _salesOnly
                .where(
                  (s) =>
                      s.name?.toLowerCase().contains(query.toLowerCase()) ??
                      false,
                )
                .toList();

    // لو في بحث: اعرض كل النتايج، لو مش في بحث: اعرض أول 8 بس
    _displayList = matched;
    if (notify) setState(() {});
  }

  Future<void> saveClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dubaiTime = DateTime.now().toUtc().add(const Duration(hours: 4));
    await prefs.setString('clear_history_time', dubaiTime.toIso8601String());
    log('Clear history time saved (Dubai): $dubaiTime');
  }

  Widget _buildAvatar(String name) {
    final trimmed = name.trim();

    // Guard: إذا الاسم فاضي خالص
    if (trimmed.isEmpty) {
      return CircleAvatar(
        radius: 20.r,
        backgroundColor: widget.mainColor.withOpacity(0.12),
        child: Text(
          '?',
          style: TextStyle(
            color: widget.mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      );
    }

    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    final initials =
        parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
            : parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();

    return CircleAvatar(
      radius: 20.r,
      backgroundColor: widget.mainColor.withOpacity(0.12),
      child: Text(
        initials,
        style: TextStyle(
          color: widget.mainColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final stagesCubit = context.read<StagesCubit>();
    if (stagesCubit.state is! StagesLoaded) stagesCubit.fetchStages();
    final stageState = stagesCubit.state;
    final Color primary = widget.mainColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Assign Lead',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocListener<AssignleadCubit, AssignState>(
        listener: (ctx, state) async {
          if (state is AssignSuccess) {
            Navigator.of(ctx).pop(true);
            try {
              if (context.mounted) {
                context.read<GetAllUsersCubit>().resetPagination();
                context.read<GetAllUsersCubit>().fetchAllUsers(
                  reset: true,
                  stageFilter: widget.leadStage,
                );
              }
            } catch (_) {}
            if (selectedSalesFcmTokens.isNotEmpty) {
              ctx.read<NotificationCubit>().sendNotificationToTokens(
                title: "Lead",
                body:
                    "New Lead assigned to ${_displayList.firstWhere((s) => s.id == selectedSalesId, orElse: () => SalesData()).name ?? 'you'} ✅",
                fcmTokens: selectedSalesFcmTokens,
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Lead assigned successfully! ✅",
                  style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                ),
              ),
            );
          } else if (state is AssignFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to assign lead: ${state.error} ❌",
                  style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Assign As ──────────────────────────────
                    _sectionLabel('ASSIGN AS'),
                    SizedBox(height: 8.h),
                    _buildSegmentedControl(primary),
                    SizedBox(height: 16.h),

                    // ── Sales list (driven purely by outer state) ─
                    // Fix the BlocConsumer builder section (around line 237)
                    BlocConsumer<SalesCubit, SalesState>(
                      buildWhen:
                          (prev, curr) =>
                              curr is SalesLoaded ||
                              curr is SalesLoading ||
                              curr is SalesError,
                      listenWhen: (prev, curr) => curr is SalesLoaded,
                      listener: (ctx, state) {
                        if (state is SalesLoaded) {
                          final data = state.salesData.data ?? [];
                          if (data.isNotEmpty) {
                            _rebuildSalesOnly(data);
                          } else {
                            _salesOnly = [];
                            _displayList = [];
                            setState(() {});
                          }
                        }
                      },
                      builder: (context, state) {
                        if (state is SalesLoading) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.h),
                              child: CircularProgressIndicator(color: primary),
                            ),
                          );
                        }
                        if (state is SalesError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: TextStyle(
                                fontSize: (14 * tabletFontScale).sp,
                              ),
                            ),
                          );
                        }
                        if (state is SalesLoaded) {
                          final data = state.salesData.data ?? [];
                          if (_salesOnly.isEmpty && data.isNotEmpty) {
                            _rebuildSalesOnly(data);
                          }
                        }

                        if (_salesOnly.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.h),
                              child: Text(
                                "No sales available for assignment.",
                                style: TextStyle(
                                  fontSize: (14 * tabletFontScale).sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final totalCount =
                            _searchActive
                                ? _displayList.length
                                : _salesOnly.length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search
                            _buildSearchField(primary),
                            SizedBox(height: 10.h),

                            // Results count
                            _sectionLabel('AVAILABLE RESULTS ($totalCount)'),
                            SizedBox(height: 8.h),

                            // Clear history card
                            _buildClearHistoryCard(primary),
                            SizedBox(height: 8.h),

                            // Sales tiles - safe check
                            Container(
                              height: 300.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: ListView.builder(
                                  padding: EdgeInsets.all(8.r),
                                  itemCount: _displayList.length,
                                  itemBuilder: (context, index) {
                                    final sale = _displayList[index];
                                    final userId = sale.id!;
                                    final isSelected =
                                        selectedSales[userId] ?? false;
                                    return _buildSalesTile(
                                      sale: sale,
                                      userId: userId,
                                      isSelected: isSelected,
                                      primary: primary,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSales.clear();
                                          selectedSales[userId] = val ?? false;
                                          selectedSalesId =
                                              val == true ? userId : null;
                                          selectedSalesFcmToken =
                                              val == true
                                                  ? sale.userlog?.fcmtoken
                                                  : null;
                                          if (val == true) {
                                            final tokens =
                                                sale.userlog?.fcmTokens
                                                    ?.map((e) => e.token ?? '')
                                                    .where((t) => t.isNotEmpty)
                                                    .toList() ??
                                                [];
                                            selectedSalesFcmTokens =
                                                tokens.isNotEmpty
                                                    ? tokens
                                                    : (selectedSalesFcmToken !=
                                                            null
                                                        ? [
                                                          selectedSalesFcmToken!,
                                                        ]
                                                        : []);
                                          } else {
                                            selectedSalesFcmTokens = [];
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    // ── Advanced Settings ──────────────────────
                    _sectionLabel('ADVANCED SETTINGS'),
                    SizedBox(height: 8.h),
                    _buildToggleTile(
                      primary: primary,
                      label: 'Reset Creation Date',
                      value: resetCreationDate,
                      onChanged:
                          (val) =>
                              setState(() => resetCreationDate = val ?? false),
                    ),

                    SizedBox(height: 16.h),

                    // ── Stage Change ───────────────────────────
                    _sectionLabel('STAGE CHANGE'),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _stageChip(
                          label: 'Keep Same Stage',
                          selected: selectedOption == 'same',
                          primary: primary,
                          onTap: () => setState(() => selectedOption = 'same'),
                        ),
                        SizedBox(width: 8.w),
                        _stageChip(
                          label: 'Change Stage',
                          selected: selectedOption == 'change',
                          primary: primary,
                          onTap:
                              () => setState(() => selectedOption = 'change'),
                        ),
                      ],
                    ),
                    if (selectedOption == 'change' &&
                        stageState is StagesLoaded) ...[
                      SizedBox(height: 10.h),
                      _buildStageDropdown(stageState, primary),
                    ],

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // ── Sticky Apply button ────────────────────────────
            _buildApplyButton(primary),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WIDGET HELPERS
  // ─────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      color: widget.mainColor,
      letterSpacing: 0.8,
    ),
  );

  Widget _buildSegmentedControl(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _segmentTab(
            label: 'Salesman',
            icon: Icons.person_outline_rounded,
            selected: !isTeamLeaderAssign,
            primary: primary,
            onTap:
                () => setState(() {
                  isTeamLeaderAssign = false;
                  selectedSales.clear();
                  selectedSalesId = null;
                  searchController.clear();
                  _searchActive = false;
                  _salesOnly.clear();
                  _displayList.clear();
                  // BlocConsumer listener will rebuild via listenWhen=SalesLoaded
                  // but data is already loaded, so rebuild manually:
                  final salesState = context.read<SalesCubit>().state;
                  if (salesState is SalesLoaded) {
                    final data = salesState.salesData.data ?? [];
                    if (data.isNotEmpty) _rebuildSalesOnly(data);
                  }
                }),
          ),
          _segmentTab(
            label: 'Team Leader',
            icon: Icons.group_outlined,
            selected: isTeamLeaderAssign,
            primary: primary,
            onTap:
                () => setState(() {
                  isTeamLeaderAssign = true;
                  selectedSales.clear();
                  selectedSalesId = null;
                  searchController.clear();
                  _searchActive = false;
                  _salesOnly.clear();
                  _displayList.clear();
                  final salesState = context.read<SalesCubit>().state;
                  if (salesState is SalesLoaded) {
                    _rebuildSalesOnly(salesState.salesData.data!);
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _segmentTab({
    required String label,
    required IconData icon,
    required bool selected,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(4.r),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border:
                selected
                    ? Border.all(color: primary, width: 1.5)
                    : Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? primary : Colors.grey.shade400,
                size: 22.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: selected ? primary : Colors.grey.shade500,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (q) => _applySearch(q),
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Filter by name',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildClearHistoryCard(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.history_rounded, color: primary, size: 18.sp),
        ),
        title: Text(
          'Clear assignment history',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Wipes previous lead records',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
        trailing: Switch(
          value: clearHistory,
          onChanged: (val) => setState(() => clearHistory = val),
          activeColor: primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildSalesTile({
    required SalesData sale,
    required String userId,
    required bool isSelected,
    required Color primary,
    required void Function(bool?) onChanged,
  }) {
    final roleLower = sale.userlog?.role?.toLowerCase() ?? '';
    final isTeamLeader = roleLower == 'team leader';
    final roleColor =
        isTeamLeader ? Colors.orange.shade700 : Colors.grey.shade500;

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: isSelected ? primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border:
            isSelected
                ? Border.all(color: primary.withOpacity(0.3))
                : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: _buildAvatar(
          isTeamLeaderAssign ? 'Team ${sale.name}' : sale.name ?? '?',
        ),
        title: Text(
          isTeamLeaderAssign ? 'Team: ${sale.name}' : sale.name ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          sale.userlog?.role?.toUpperCase() ?? '',
          style: TextStyle(
            color: roleColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        trailing: Checkbox(
          activeColor: primary,
          value: isSelected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required Color primary,
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _stageChip({
    required String label,
    required bool selected,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: selected ? primary : Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? primary : Colors.grey.shade600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildStageDropdown(StagesLoaded stageState, Color primary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedStageId,
        hint: Text(
          'Select Stage',
          style: TextStyle(
            fontSize: (14 * tabletFontScale).sp,
            color: Colors.grey.shade500,
          ),
        ),
        underline: const SizedBox(),
        items:
            stageState.stages
                .where((stage) => stage.name?.toLowerCase() != 'fresh')
                .map((stage) {
                  final displayName =
                      stage.name?.toLowerCase() == 'no stage'
                          ? 'Fresh'
                          : stage.name ?? 'Unnamed';
                  return DropdownMenuItem<String>(
                    value: stage.id.toString(),
                    child: Text(
                      displayName,
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    ),
                  );
                })
                .toList(),
        onChanged: (value) {
          final selectedStage = stageState.stages.firstWhere(
            (stage) => stage.id.toString() == value,
            orElse: () => StageDatas(),
          );
          setState(() {
            selectedStageId = value;
            _selectedLeadStagesIds.add(selectedStageId!);
            selectedstagename =
                selectedStage.name?.toLowerCase() == 'no stage'
                    ? 'Fresh'
                    : selectedStage.name;
          });
        },
      ),
    );
  }

  Widget _buildApplyButton(Color primary) {
    return BlocBuilder<AssignleadCubit, AssignState>(
      builder: (ctx, state) {
        final isLoading = state is AssignLoading;
        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            16.w,
            12.h,
            16.w,
            MediaQuery.of(context).padding.bottom + 12.h,
          ),
          child: ElevatedButton(
            onPressed:
                (selectedSalesId == null || isLoading)
                    ? null
                    : () async {
                      final leadIds =
                          widget.leadIds != null
                              ? List<String>.from(widget.leadIds!)
                              : [widget.leadId!];
                      if (clearHistory) await saveClearHistoryTime();

                      final assignCubit = ctx.read<AssignleadCubit>();
                      final leadCommentsCubit = ctx.read<LeadCommentsCubit>();

                      String? stageToSend;
                      if (_selectedLeadStagesIds.isNotEmpty) {
                        stageToSend = _selectedLeadStagesIds.last;
                      }

                      await assignCubit.assignLeadFromMarkter(
                        leadIds: leadIds,
                        lastDateAssign:
                            DateTime.now().toUtc().toIso8601String(),
                        dateAssigned:
                            "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                        salesId: selectedSalesId!,
                        isClearhistory: clearHistory,
                        stage:
                            stageToSend == "68d110bbad5a0732ad44e5cf"
                                ? ""
                                : stageToSend,
                        assigntype: isTeamLeaderAssign,
                        resetcreationdate: resetCreationDate,
                      );

                      await leadCommentsCubit.apiService.fetchLeadAssigned(
                        widget.leadId!,
                      );
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child:
                isLoading
                    ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      'APPLY CHANGES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        letterSpacing: 1.0,
                      ),
                    ),
          ),
        );
      },
    );
  }
}
