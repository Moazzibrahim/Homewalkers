// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      ),
                    ),
                  ),
                  RadioListTile<bool>(
                    value: false,
                    groupValue: isTeamLeaderAssign,
                    title: const Text("Salesman"),
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
                    title: const Text("Team Leader"),
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
                        return const Center(child: CircularProgressIndicator());
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
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: filterSales,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Results: ${filteredSales.length}",
                                    style: TextStyle(
                                      color: widget.mainColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 350,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: filteredSales.length,
                                    itemBuilder: (context, index) {
                                      final sale = filteredSales[index];
                                      final userId = sale.id;
                                      return ListTile(
                                        title: Text(
                                          isTeamLeaderAssign
                                              ? 'Team: ${sale.name}'
                                              : sale.name!,
                                        ),

                                        subtitle: Text(
                                          sale.userlog!.role!,
                                          style: TextStyle(
                                            color: widget.mainColor,
                                          ),
                                        ),
                                        trailing: Checkbox(
                                          activeColor: widget.mainColor,
                                          value: selectedSales[userId] ?? false,
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
                        return Text(state.message);
                      } else {
                        return const Text("No sales available for assignment.");
                      }
                    },
                  ),

                  CheckboxListTile(
                    title: const Text("Clear History"),
                    value: clearHistory,
                    onChanged: (newValue) {
                      setState(() => clearHistory = newValue ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: widget.mainColor,
                  ),

                  CheckboxListTile(
                    title: const Text("Reset Creation Date"),
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
                    title: const Text('Same Stage'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        (value) => setState(() => selectedOption = value!),
                  ),

                  RadioListTile<String>(
                    value: 'change',
                    groupValue: selectedOption,
                    title: const Text('Change Stage'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        (value) => setState(() => selectedOption = value!),
                  ),

                  if (selectedOption == 'change' && stageState is StagesLoaded)
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedStageId,
                      hint: const Text('Select Stage'),
                      items:
                          stageState.stages
                              .where(
                                (stage) => stage.name?.toLowerCase() != 'fresh',
                              )
                              .map((stage) {
                                final displayName =
                                    stage.name?.toLowerCase() == 'no stage'
                                        ? 'Fresh'
                                        : stage.name ?? 'Unnamed';
                                return DropdownMenuItem<String>(
                                  value: stage.id.toString(),
                                  child: Text(displayName),
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

                  const SizedBox(height: 12),

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
                          const SnackBar(
                            content: Text("Lead assigned successfully! ✅"),
                          ),
                        );
                      } else if (state is AssignFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Failed to assign lead: ${state.error} ❌",
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: BlocBuilder<AssignleadCubit, AssignState>(
                          builder: (dialogContext, state) {
                            if (state is AssignLoading) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            return const Text(
                              "Apply",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
