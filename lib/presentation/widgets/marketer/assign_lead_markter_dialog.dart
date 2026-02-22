// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print
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
  State<AssignLeadMarkterDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<AssignLeadMarkterDialog> {
  String? selectedSalesId;
  Map<String, bool> selectedSales = {};
  String? selectedSalesFcmToken;

  bool clearHistory = false;

  final TextEditingController searchController = TextEditingController();
  List<SalesData> filteredSales = [];
  final Set<String> _selectedLeadStagesIds = {};
  String selectedOption = 'same';
  String? selectedStageId;
  String? selectedstagename;
  bool isTeamLeaderAssign = false; // assigntype
  bool resetCreationDate = false;

  // ✅ عوامل التصغير responsive
  late bool isTabletDevice;
  late double tabletScale;
  late double tabletFontScale;
  late double tabletWidthScale;
  late double tabletHeightScale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ حساب عوامل التصغير بناءً على حجم الشاشة
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

  Future<void> saveClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();

    // توقيت دبي +4
    final dubaiTime = DateTime.now().toUtc().add(const Duration(hours: 4));

    await prefs.setString('clear_history_time', dubaiTime.toIso8601String());

    log('Clear history time saved (Dubai): $dubaiTime');
  }

  @override
  Widget build(BuildContext context) {
    final stagesCubit = context.read<StagesCubit>();
    if (stagesCubit.state is! StagesLoaded) {
      stagesCubit.fetchStages();
    }
    final stageState = stagesCubit.state;

    return Builder(
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((16 * tabletScale).r),
          ),
          child: Padding(
            padding: EdgeInsets.all((16 * tabletScale).r),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ===== Assign As =====
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Assign As",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.mainColor,
                        fontSize: (16 * tabletFontScale).sp,
                      ),
                    ),
                  ),

                  RadioListTile<bool>(
                    value: false,
                    groupValue: isTeamLeaderAssign,
                    title: Text(
                      "Salesman",
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setState(() {
                        isTeamLeaderAssign = val!;
                        filteredSales.clear();
                        selectedSales.clear();
                        selectedSalesId = null;
                      });
                    },
                  ),

                  RadioListTile<bool>(
                    value: true,
                    groupValue: isTeamLeaderAssign,
                    title: Text(
                      "Team Leader",
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setState(() {
                        isTeamLeaderAssign = val!;
                        filteredSales.clear();
                        selectedSales.clear();
                        selectedSalesId = null;
                      });
                    },
                  ),

                  BlocBuilder<SalesCubit, SalesState>(
                    builder: (context, state) {
                      if (state is SalesLoading) {
                        return Center(
                          child: SizedBox(
                            height: (40 * tabletHeightScale).h,
                            width: (40 * tabletWidthScale).w,
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is SalesLoaded) {
                        final uniqueSalesMap = <String, SalesData>{};

                        for (var sale in state.salesData.data!) {
                          final user = sale.userlog;

                          if (isTeamLeaderAssign) {
                            if (user!.role == "Team Leader") {
                              uniqueSalesMap[sale.id!] = sale;
                            }
                          } else {
                            if (user!.role == "Sales" ||
                                user.role == "Team Leader" ||
                                user.role == "Manager") {
                              uniqueSalesMap[sale.id!] = sale;
                            }
                          }
                        }

                        List<SalesData> salesOnly =
                            uniqueSalesMap.values.toList();

                        salesOnly.sort((a, b) {
                          if (a.name?.toLowerCase() == "no sales") return -1;
                          if (b.name?.toLowerCase() == "no sales") return 1;
                          return a.name!.compareTo(b.name!);
                        });

                        if (filteredSales.isEmpty) {
                          filteredSales = List.from(salesOnly);
                        }

                        return StatefulBuilder(
                          builder: (context, setStateSB) {
                            void filterSales(String query) {
                              setStateSB(() {
                                filteredSales =
                                    salesOnly
                                        .where(
                                          (s) => s.name!.toLowerCase().contains(
                                            query.toLowerCase(),
                                          ),
                                        )
                                        .toList();
                              });
                            }

                            return Column(
                              children: [
                                TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    labelText: "Filter by name",
                                    labelStyle: TextStyle(
                                      fontSize: (14 * tabletFontScale).sp,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: (20 * tabletFontScale).sp,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        (12 * tabletScale).r,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: (12 * tabletWidthScale).w,
                                      vertical: (16 * tabletHeightScale).h,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: (14 * tabletFontScale).sp,
                                  ),
                                  onChanged: filterSales,
                                ),

                                SizedBox(height: (8 * tabletHeightScale).h),

                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Results: ${filteredSales.length}",
                                    style: TextStyle(
                                      color: widget.mainColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: (14 * tabletFontScale).sp,
                                    ),
                                  ),
                                ),

                                SizedBox(height: (8 * tabletHeightScale).h),

                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: (350 * tabletHeightScale).h,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: filteredSales.length,
                                    itemBuilder: (context, index) {
                                      final sale = filteredSales[index];
                                      final userId = sale.id;
                                      return ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: (8 * tabletWidthScale).w,
                                          vertical: (4 * tabletHeightScale).h,
                                        ),
                                        title: Text(
                                          isTeamLeaderAssign
                                              ? 'Team: ${sale.name}'
                                              : sale.name!,
                                          style: TextStyle(
                                            fontSize: (16 * tabletFontScale).sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          sale.userlog!.role!,
                                          style: TextStyle(
                                            color: widget.mainColor,
                                            fontSize: (14 * tabletFontScale).sp,
                                          ),
                                        ),
                                        trailing: Checkbox(
                                          activeColor: widget.mainColor,
                                          value: selectedSales[userId] ?? false,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          onChanged: (val) {
                                            setState(() {
                                              selectedSales.clear();
                                              selectedSales[userId!] =
                                                  val ?? false;
                                              selectedSalesId =
                                                  val == true ? userId : null;
                                              selectedSalesFcmToken =
                                                  val == true
                                                      ? sale.userlog?.fcmtoken
                                                      : null;
                                            });
                                            setStateSB(() {});
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (state is SalesError) {
                        return Text(
                          state.message,
                          style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                        );
                      } else {
                        return Text(
                          "No sales available for assignment.",
                          style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                        );
                      }
                    },
                  ),

                  CheckboxListTile(
                    title: Text(
                      "Clear History",
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    ),
                    value: clearHistory,
                    onChanged: (newValue) {
                      setState(() => clearHistory = newValue ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: widget.mainColor,
                  ),

                  CheckboxListTile(
                    title: Text(
                      "Reset Creation Date",
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    ),
                    value: resetCreationDate,
                    onChanged: (val) {
                      setState(() => resetCreationDate = val ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: widget.mainColor,
                  ),

                  RadioListTile<String>(
                    value: 'same',
                    groupValue: selectedOption,
                    title: Text(
                      'Same Stage',
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        (value) => setState(() => selectedOption = value!),
                  ),

                  RadioListTile<String>(
                    value: 'change',
                    groupValue: selectedOption,
                    title: Text(
                      'Change Stage',
                      style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        (value) => setState(() => selectedOption = value!),
                  ),

                  if (selectedOption == 'change' && stageState is StagesLoaded)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: (8 * tabletWidthScale).w,
                        vertical: (4 * tabletHeightScale).h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(
                          (8 * tabletScale).r,
                        ),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedStageId,
                        hint: Text(
                          'Select Stage',
                          style: TextStyle(fontSize: (14 * tabletFontScale).sp),
                        ),
                        underline: const SizedBox(),
                        items:
                            stageState.stages
                                .where(
                                  (stage) =>
                                      stage.name?.toLowerCase() != 'fresh',
                                )
                                .map((stage) {
                                  final displayName =
                                      stage.name?.toLowerCase() == 'no stage'
                                          ? 'Fresh'
                                          : stage.name ?? 'Unnamed';
                                  return DropdownMenuItem<String>(
                                    value: stage.id.toString(),
                                    child: Text(
                                      displayName,
                                      style: TextStyle(
                                        fontSize: (14 * tabletFontScale).sp,
                                      ),
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
                    ),

                  SizedBox(height: (12 * tabletHeightScale).h),

                  BlocListener<AssignleadCubit, AssignState>(
                    listener: (dialogContext, state) async {
                      if (state is AssignSuccess) {
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(true);
                        }

                        try {
                          final parentContext = context;
                          if (parentContext.mounted) {
                            parentContext
                                .read<GetAllUsersCubit>()
                                .resetPagination();
                            parentContext
                                .read<GetAllUsersCubit>()
                                .fetchAllUsers(
                                  reset: true,
                                  stageFilter: widget.leadStage,
                                );
                          }
                        } catch (_) {}

                        if (selectedSalesFcmToken != null) {
                          dialogContext
                              .read<NotificationCubit>()
                              .sendNotificationToToken(
                                title: "Lead",
                                body: "New Lead assigned to you ✅",
                                fcmtokennnn: selectedSalesFcmToken!,
                              );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Lead assigned successfully! ✅",
                              style: TextStyle(
                                fontSize: (14 * tabletFontScale).sp,
                              ),
                            ),
                          ),
                        );
                      } else if (state is AssignFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
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
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            selectedSalesId == null
                                ? null
                                : () async {
                                  final leadIds =
                                      widget.leadIds != null
                                          ? List<String>.from(widget.leadIds!)
                                          : [widget.leadId!];
                                  if (clearHistory) {
                                    await saveClearHistoryTime();
                                  }
                                  final assignCubit =
                                      dialogContext.read<AssignleadCubit>();
                                  final leadCommentsCubit =
                                      dialogContext.read<LeadCommentsCubit>();

                                  String? stageToSend;
                                  if (_selectedLeadStagesIds.isNotEmpty) {
                                    stageToSend = _selectedLeadStagesIds.last;
                                  }

                                  await assignCubit.assignLeadFromMarkter(
                                    leadIds: leadIds,
                                    lastDateAssign:
                                        DateTime.now()
                                            .toUtc()
                                            .toIso8601String(),
                                    dateAssigned:
                                        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                    salesId: selectedSalesId!,
                                    isClearhistory: clearHistory,
                                    stage:
                                        stageToSend ==
                                                "68d110bbad5a0732ad44e5cf"
                                            ? ""
                                            : stageToSend,
                                    assigntype: isTeamLeaderAssign,
                                    resetcreationdate: resetCreationDate,
                                  );

                                  await leadCommentsCubit.apiService
                                      .fetchLeadAssigned(widget.leadId!);
                                },
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
                          builder: (dialogContext, state) {
                            if (state is AssignLoading) {
                              return SizedBox(
                                height: (20 * tabletFontScale).h,
                                width: (20 * tabletFontScale).w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
