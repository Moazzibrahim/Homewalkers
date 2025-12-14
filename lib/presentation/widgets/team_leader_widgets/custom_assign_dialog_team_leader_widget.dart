// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_local_variable
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_sales_by_team_leader_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
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
  final LeadResponse? leadResponse;
  final List? leadIds;
  final String? leadId;
  final String fcmyoken;
  final String? managerfcm;
  final List? leadsStages;
  final Function? onAssignSuccess; // اضيفه في constructor

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
    savedIdassignedfrom = prefs.getString('teamLeaderIddspecific');
    log("message from shared preferences: $savedIdassignedfrom");
    setState(() {});
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

    // 🔥 إضافة اختيارات Stage هنا
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: double.maxFinite,
              height: 500, // حجم ثابت للديالوج
              child: Column(
                children: [
                  // TextField للبحث
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search Sales by Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          isSearching = val.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<
                      GetLeadsCountInTeamLeaderCubit,
                      GetLeadsCountInTeamLeaderState
                    >(
                      builder: (context, state) {
                        if (state is GetLeadsCountInTeamLeaderLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
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
                            return const Center(
                              child: Text("No sales available."),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            itemCount: filteredSales.length,
                            itemBuilder: (context, index) {
                              final sale = filteredSales[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sale.salesName ?? "Unnamed Sales",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Sales",
                                          style: TextStyle(
                                            color: widget.mainColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Checkbox(
                                      activeColor: widget.mainColor,
                                      value:
                                          selectedSales[sale.salesID] ?? false,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSales
                                              .clear(); // One select only
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
                          return Center(child: Text(state.message));
                        } else {
                          return const Center(
                            child: Text("No sales available for assignment."),
                          );
                        }
                      },
                    ),
                  ),
                  // Checkbox Clear History ثابت
                  CheckboxListTile(
                    title: const Text("Clear History"),
                    value: clearHistory,
                    onChanged: (newValue) {
                      setState(() {
                        clearHistory = newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: widget.mainColor,
                  ),

                  Column(
                    children: [
                      RadioListTile<String>(
                        value: 'as_fresh',
                        groupValue: selectedOption,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Assign as Fresh'),
                        onChanged: (value) {
                          setState(() => selectedOption = value!);
                        },
                      ),
                      RadioListTile<String>(
                        value: 'same',
                        groupValue: selectedOption,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Same Stage'),
                        onChanged: (value) {
                          setState(() => selectedOption = value!);
                        },
                      ),
                      RadioListTile<String>(
                        value: 'change',
                        groupValue: selectedOption,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Change Stage'),
                        onChanged: (value) {
                          setState(() => selectedOption = value!);
                        },
                      ),

                      // Dropdown يظهر فقط عند اختيار "Change Stage"
                      if (selectedOption == 'change' &&
                          stageState is StagesLoaded)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedStageId,
                            hint: const Text('Select Stage'),
                            items:
                                stageState.stages
                                    .where(
                                      (stage) =>
                                          stage.name?.toLowerCase() != "fresh",
                                    ) // ❌ hide Fresh
                                    .map((stage) {
                                      return DropdownMenuItem(
                                        value: stage.id.toString(),
                                        child: Text(stage.name ?? 'Unnamed'),
                                      );
                                    })
                                    .toList(),

                            onChanged: (value) {
                              setState(() => selectedStageId = value);
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // أزرار Apply و Cancel و Clear History ثابتة
                  BlocListener<AssignleadCubit, AssignState>(
                    listener: (context, state) async {
                      if (state is AssignSuccess) {
                        if (Navigator.canPop(dialogContext)) {
                          Navigator.pop(dialogContext, true);
                        }
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        if (widget.onAssignSuccess != null) {
                          widget.onAssignSuccess!();
                        }
                        final cubit = context.read<GetLeadsTeamLeaderCubit>();
                        await cubit.getLeadsByTeamLeader();
                        if (widget.leadsStages != null &&
                            widget.leadsStages!.isNotEmpty) {
                          cubit.filterLeadsByStage(
                            widget.leadsStages!.last.toString(),
                          );
                        }
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text("Lead assigned successfully! ✅"),
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
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (Navigator.canPop(dialogContext)) {
                                Navigator.pop(dialogContext);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: widget.mainColor),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: widget.mainColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          ElevatedButton(
                            onPressed:
                                selectedSalesId != null
                                    ? () async {
                                      // الكود الأصلي للـ Apply موجود عندك مسبقاً
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
                                        stageToSend =
                                            pendingStageId!; // Assign as fresh = رجع لل Pending
                                      } else if (selectedOption == 'change') {
                                        if (selectedStageId == null ||
                                            selectedStageId!.isEmpty) {
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
                                        stageToSend = selectedStageId!;
                                      } else {
                                        // same stage
                                        stageToSend =
                                            widget.leadsStages!.last.toString();
                                        if (widget.leadsStages!.last
                                                    .toString() ==
                                                transferStageId ||
                                            widget.leadsStages!.last
                                                    .toString() ==
                                                freshStageId) {
                                          stageToSend = pendingStageId!;
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: BlocBuilder<AssignleadCubit, AssignState>(
                              builder: (context, state) {
                                if (state is AssignLoading) {
                                  return const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
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
