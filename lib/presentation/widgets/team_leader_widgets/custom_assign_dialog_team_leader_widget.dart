// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_local_variable
import 'dart:developer';
import 'dart:math' as math; // ✅ للكشف عن التابلت
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_sales_by_team_leader_api_service.dart';
import 'package:homewalkers_app/data/models/teamleader_pagination_leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_sales_team_leader_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAssignDialogTeamLeaderWidget extends StatefulWidget {
  final Color mainColor;
  final LeadDataPagination? leadResponse;
  final List? leadIds;
  final String? leadId;
  final String fcmyoken;
  final String? managerfcm;
  final List? leadsStages;
  final Function? onAssignSuccess;
  final bool? data;
  final bool? transferfromdata;

  const CustomAssignDialogTeamLeaderWidget({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
    required this.fcmyoken,
    this.managerfcm,
    this.leadsStages,
    this.onAssignSuccess,
    this.data,
    this.transferfromdata,
  });

  @override
  State<CustomAssignDialogTeamLeaderWidget> createState() =>
      _AssignDialogState();
}

class _AssignDialogState extends State<CustomAssignDialogTeamLeaderWidget> {
  bool isTeamLeaderChecked = false;
  String? savedIdassignedfrom;
  String? selectedSalesId;
  Map<String, bool> selectedSales = {};
  bool clearHistory = false;

  late SalesTeamCubit _salesTeamCubit;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String selectedOption = 'same';
  String? selectedStageId;

  @override
  void initState() {
    super.initState();
    _salesTeamCubit = SalesTeamCubit(GetSalesTeamLeaderApiService());
    _salesTeamCubit.fetchSalesTeam();
    _initialize();
    print("fcm token: ${widget.fcmyoken}");
  }

  @override
  void dispose() {
    _salesTeamCubit.close();
    searchController.dispose();
    super.dispose();
  }

  void _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    savedIdassignedfrom = prefs.getString('salesId');
    log("message from shared preferences: $savedIdassignedfrom");
    setState(() {});
  }

  Future<void> saveClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dubaiTime = DateTime.now().toUtc().add(const Duration(hours: 4));
    await prefs.setString('clear_history_time', dubaiTime.toIso8601String());
    log('Clear history time saved (Dubai): $dubaiTime');
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
    final double tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    final double tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    final double tabletHeightScale = isTabletDevice ? 0.9 : 1.0;

    final stagesCubit = context.read<StagesCubit>();

    if (stagesCubit.state is! StagesLoaded) {
      stagesCubit.fetchStages();
    }
    final stageState = stagesCubit.state;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AssignleadCubit()),
        BlocProvider(
          create:
              (_) =>
                  LeadCommentsCubit(GetAllLeadCommentsApiService())
                    ..fetchLeadComments(widget.leadId!),
        ),
        BlocProvider(
          create:
              (context) =>
                  GetLeadsCountInTeamLeaderCubit(GetLeadsCountApiService())
                    ..fetchLeadsCount(),
        ),
      ],
      child: Builder(
        builder: (dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((16 * tabletScale).r),
            ),
            child: Container(
              width:
                  isTabletDevice
                      ? MediaQuery.of(context).size.width * 0.7
                      : double.maxFinite,
              height: isTabletDevice ? 600.h : 500.h,
              constraints: BoxConstraints(
                maxWidth: isTabletDevice ? 700.w : double.infinity,
                maxHeight: isTabletDevice ? 700.h : 600.h,
              ),
              child: Column(
                children: [
                  // 🔍 TextField للبحث - متجاوب بالكامل
                  Padding(
                    padding: EdgeInsets.all((8 * tabletScale).r),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          size: (20 * tabletFontScale).sp,
                        ),
                        hintText: 'Search Sales by Name',
                        hintStyle: TextStyle(
                          fontSize: (14 * tabletFontScale).sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: (16 * tabletWidthScale).w,
                          vertical: (12 * tabletHeightScale).h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            (8 * tabletScale).r,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          isSearching = val.isNotEmpty;
                        });
                      },
                    ),
                  ),

                  // 📋 Expanded ListView - متجاوب بالكامل
                  Expanded(
                    child: BlocBuilder<
                      GetLeadsCountInTeamLeaderCubit,
                      GetLeadsCountInTeamLeaderState
                    >(
                      builder: (context, state) {
                        if (state is GetLeadsCountInTeamLeaderLoading) {
                          return Center(
                            child: SizedBox(
                              height: (40 * tabletHeightScale).h,
                              width: (40 * tabletWidthScale).w,
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is GetLeadsCountInTeamLeaderLoaded) {
                          final salesList = state.data.data ?? [];
                          final filteredSales =
                              isSearching
                                  ? salesList
                                      .where(
                                        (sale) =>
                                            sale.salesName != null
                                                ? sale.salesName!
                                                    .toLowerCase()
                                                    .contains(
                                                      searchController.text
                                                          .toLowerCase(),
                                                    )
                                                : false,
                                      )
                                      .toList()
                                  : salesList;

                          if (filteredSales.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all((16 * tabletScale).r),
                                child: Text(
                                  "No sales available.",
                                  style: TextStyle(
                                    fontSize: (16 * tabletFontScale).sp,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: (12 * tabletWidthScale).w,
                              vertical: (6 * tabletHeightScale).h,
                            ),
                            itemCount: filteredSales.length,
                            itemBuilder: (context, index) {
                              final sale = filteredSales[index];

                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: (10 * tabletHeightScale).h,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: (12 * tabletWidthScale).w,
                                  vertical: (12 * tabletHeightScale).h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(
                                    (12 * tabletScale).r,
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: (1 * tabletScale).r,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: isTabletDevice ? 8 : 7,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sale.salesName ?? "Unnamed Sales",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  (15 * tabletFontScale).sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(
                                            height: (4 * tabletHeightScale).h,
                                          ),
                                          Text(
                                            "Sales",
                                            style: TextStyle(
                                              color: widget.mainColor,
                                              fontSize:
                                                  (12 * tabletFontScale).sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      activeColor: widget.mainColor,
                                      value:
                                          selectedSales[sale.salesID] ?? false,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSales.clear();
                                          selectedSales[sale.salesID!] =
                                              val ?? false;
                                          selectedSalesId =
                                              val == true
                                                  ? sale.salesID.toString()
                                                  : null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (state is GetLeadsCountInTeamLeaderError) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all((16 * tabletScale).r),
                              child: Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: (16 * tabletFontScale).sp,
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
                                "No sales available for assignment.",
                                style: TextStyle(
                                  fontSize: (16 * tabletFontScale).sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // ✅ Checkbox Clear History - متجاوب
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (8 * tabletWidthScale).w,
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        "Clear History",
                        style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                      ),
                      value: clearHistory,
                      onChanged: (newValue) {
                        setState(() {
                          clearHistory = newValue ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: widget.mainColor,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  // 📻 Radio Options - متجاوبة
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (8 * tabletWidthScale).w,
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'as_fresh',
                          groupValue: selectedOption,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            'Assign as Fresh',
                            style: TextStyle(
                              fontSize: (14 * tabletFontScale).sp,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => selectedOption = value!);
                          },
                        ),
                        RadioListTile<String>(
                          value: 'same',
                          groupValue: selectedOption,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            'Same Stage',
                            style: TextStyle(
                              fontSize: (14 * tabletFontScale).sp,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => selectedOption = value!);
                          },
                        ),
                        RadioListTile<String>(
                          value: 'change',
                          groupValue: selectedOption,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            'Change Stage',
                            style: TextStyle(
                              fontSize: (14 * tabletFontScale).sp,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => selectedOption = value!);
                          },
                        ),
                      ],
                    ),
                  ),

                  // 🔻 Dropdown يظهر فقط عند اختيار "Change Stage" - متجاوب
                  if (selectedOption == 'change' && stageState is StagesLoaded)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (16 * tabletWidthScale).w,
                        vertical: (8 * tabletHeightScale).h,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: (12 * tabletWidthScale).w,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: (1 * tabletScale).r,
                          ),
                          borderRadius: BorderRadius.circular(
                            (8 * tabletScale).r,
                          ),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedStageId,
                          hint: Text(
                            'Select Stage',
                            style: TextStyle(
                              fontSize: (14 * tabletFontScale).sp,
                            ),
                          ),
                          underline: const SizedBox(),
                          iconSize: (24 * tabletFontScale).sp,
                          items:
                              stageState.stages
                                  .where(
                                    (stage) =>
                                        stage.name?.toLowerCase() != "fresh",
                                  )
                                  .map((stage) {
                                    return DropdownMenuItem(
                                      value: stage.id.toString(),
                                      child: Text(
                                        stage.name ?? 'Unnamed',
                                        style: TextStyle(
                                          fontSize: (14 * tabletFontScale).sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  })
                                  .toList(),
                          onChanged: (value) {
                            setState(() => selectedStageId = value);
                          },
                        ),
                      ),
                    ),

                  SizedBox(height: (8 * tabletHeightScale).h),

                  // 🔘 أزرار Apply و Cancel - متجاوبة بالكامل
                  BlocListener<AssignleadCubit, AssignState>(
                    listener: (context, state) async {
                      if (state is AssignSuccess) {
                        if (Navigator.canPop(dialogContext)) {
                          Navigator.pop(dialogContext, true);
                        }
                        if (widget.onAssignSuccess != null) {
                          widget.onAssignSuccess!();
                        }
                        final cubit = context.read<GetLeadsTeamLeaderCubit>();
                        await cubit.fetchTeamLeaderLeadsWithPagination(
                          data: widget.data,
                          transferefromdata: widget.transferfromdata,
                        );
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Lead assigned successfully! ✅",
                              style: TextStyle(
                                fontSize: (14 * tabletFontScale).sp,
                              ),
                            ),
                          ),
                        );
                        context
                            .read<NotificationCubit>()
                            .sendNotificationToToken(
                              title: "Lead",
                              body: "Lead assigned successfully ✅",
                              fcmtokennnn: widget.fcmyoken,
                            );
                        if (widget.managerfcm != null) {
                          context
                              .read<NotificationCubit>()
                              .sendNotificationToToken(
                                title: "Lead",
                                body: "Lead assigned successfully ✅",
                                fcmtokennnn: widget.managerfcm!,
                              );
                        }
                      } else if (state is AssignFailure) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Failed to assign lead: ${state.error} ❌",
                              style: TextStyle(
                                fontSize: (14 * tabletFontScale).sp,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: (16 * tabletWidthScale).w,
                        right: (16 * tabletWidthScale).w,
                        bottom: (16 * tabletHeightScale).h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ❌ Cancel Button
                          ElevatedButton(
                            onPressed: () {
                              if (Navigator.canPop(dialogContext)) {
                                Navigator.pop(dialogContext);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: (16 * tabletWidthScale).w,
                                vertical: (12 * tabletHeightScale).h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  (10 * tabletScale).r,
                                ),
                                side: BorderSide(
                                  color: widget.mainColor,
                                  width: (1 * tabletScale).r,
                                ),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: widget.mainColor,
                                fontWeight: FontWeight.w600,
                                fontSize: (14 * tabletFontScale).sp,
                              ),
                            ),
                          ),

                          // ✅ Apply Button
                          ElevatedButton(
                            onPressed:
                                selectedSalesId != null
                                    ? () async {
                                      final leadIds =
                                          widget.leadIds != null
                                              ? List<String>.from(
                                                widget.leadIds!,
                                              )
                                              : [widget.leadId!];

                                      log("Selected Lead IDs: $leadIds");
                                      log("Clear History value: $clearHistory");

                                      if (clearHistory) {
                                        await saveClearHistoryTime();
                                      }

                                      final String lastDateAssign =
                                          DateTime.now()
                                              .toUtc()
                                              .toIso8601String();

                                      final assignCubit =
                                          BlocProvider.of<AssignleadCubit>(
                                            dialogContext,
                                            listen: false,
                                          );

                                      final cubit =
                                          BlocProvider.of<LeadCommentsCubit>(
                                            dialogContext,
                                            listen: false,
                                          );
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final freshStageId = prefs.getString(
                                        'fresh_stage_id',
                                      );
                                      final transferStageId = prefs.getString(
                                        "transfer_stage_id",
                                      );
                                      final pendingStageId = prefs.getString(
                                        'pending_stage_id',
                                      );
                                      final stageIds =
                                          widget.leadsStages
                                              ?.map(
                                                (stage) =>
                                                    stage is Map
                                                        ? stage["_id"]
                                                            ?.toString()
                                                        : stage.toString(),
                                              )
                                              .where(
                                                (id) =>
                                                    id != null && id.isNotEmpty,
                                              )
                                              .toList() ??
                                          [];
                                      String stageToSend = '';

                                      if (selectedOption == 'as_fresh') {
                                        stageToSend = pendingStageId!;
                                      } else if (selectedOption == 'change') {
                                        if (selectedStageId == null ||
                                            selectedStageId!.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Please select a stage",
                                                style: TextStyle(
                                                  fontSize:
                                                      (14 * tabletFontScale).sp,
                                                ),
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        stageToSend = selectedStageId!;
                                      } else {
                                        // ✅ Same Stage - مع التحقق من وجود leadsStages
                                        if (widget.leadsStages != null &&
                                            widget.leadsStages!.isNotEmpty) {
                                          stageToSend =
                                              widget.leadsStages!.last
                                                  .toString();

                                          // التحقق من حالة transfer أو fresh
                                          if (stageToSend == transferStageId ||
                                              stageToSend == freshStageId) {
                                            stageToSend = pendingStageId!;
                                          }
                                        } else {
                                          // ✅ قيمة افتراضية إذا كان leadsStages فارغاً أو null
                                          stageToSend = pendingStageId!;
                                          log(
                                            "⚠️ leadsStages is null or empty, using pendingStageId as default",
                                          );

                                          // يمكنك إظهار رسالة للمستخدم إذا أردت
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "No stage available, using default stage",
                                                style: TextStyle(
                                                  fontSize:
                                                      (14 * tabletFontScale).sp,
                                                ),
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                      assignCubit.assignUserAndLeadTeamLeader(
                                        leadIds: leadIds,
                                        lastDateAssign: lastDateAssign,
                                        dateAssigned:
                                            "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                        teamleadersId: savedIdassignedfrom!,
                                        salesId: selectedSalesId!,
                                        clearhistory: clearHistory,
                                        stageId: stageToSend,
                                      );
                                      cubit.apiService.fetchLeadAssigned(
                                        widget.leadId!,
                                      );
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.mainColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: (16 * tabletWidthScale).w,
                                vertical: (12 * tabletHeightScale).h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  (12 * tabletScale).r,
                                ),
                              ),
                            ),
                            child: BlocBuilder<AssignleadCubit, AssignState>(
                              builder: (context, state) {
                                if (state is AssignLoading) {
                                  return SizedBox(
                                    height: (20 * tabletHeightScale).h,
                                    width: (20 * tabletWidthScale).w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  );
                                }
                                return Text(
                                  "Apply",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: (14 * tabletFontScale).sp,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
