// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignLeadDialogManager extends StatefulWidget {
  final Color mainColor;
  final LeadResponse? leadResponse;
  final List? leadIds;
  final String? leadId;
  final String fcmtoken;
  final Function? onAssignSuccess; // اضيفه في constructor

  const AssignLeadDialogManager({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
    required this.fcmtoken,
    this.onAssignSuccess,
  });

  @override
  State<AssignLeadDialogManager> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<AssignLeadDialogManager> {
  String? selectedSalesId;
  Map<String, bool> selectedSales = {};
  bool clearHistory = false;
  String? managerId;

  // 1️⃣ بحث
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;
  String selectedOption = 'same';
  String? selectedStageId;
  Future<void> _loadManagerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      managerId = prefs.getString("managerIdspecific");
    });
    print("managerId: $managerId");
  }

  @override
  void initState() {
    super.initState();
    _loadManagerId();
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
        BlocProvider(create: (_) => AssignleadCubit()),
        BlocProvider(
          create:
              (_) =>
                  LeadCommentsCubit(GetAllLeadCommentsApiService())
                    ..fetchLeadComments(widget.leadId!),
        ),
        BlocProvider(
          create: (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
        ),
      ],
      child: Builder(
        builder: (dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 500,
              ), // يحدد ارتفاع ثابت للـ dialog
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🔹 حقل البحث
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search Sales by name",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 🔹 قائمة Sales
                  Expanded(
                    child: BlocBuilder<SalesCubit, SalesState>(
                      builder: (context, state) {
                        if (state is SalesLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is SalesLoaded &&
                            state.salesData.data != null) {
                          final uniqueSalesMap = <String, SalesData>{};
                          for (var sale in state.salesData.data!) {
                            final salesManagerId = sale.manager?.id?.toString();
                            final user = sale.userlog;
                            if (user != null &&
                                salesManagerId == managerId &&
                                (user.role == "Sales" ||
                                    user.role == "Team Leader")) {
                              uniqueSalesMap[sale.id!] = sale;
                            }
                          }
                          List<SalesData> salesOnly =
                              uniqueSalesMap.values.toList();

                          // 🔹 فلترة البحث
                          if (searchQuery.isNotEmpty) {
                            salesOnly =
                                salesOnly
                                    .where(
                                      (s) => (s.userlog?.name ?? "")
                                          .toLowerCase()
                                          .contains(searchQuery),
                                    )
                                    .toList();
                          }

                          if (salesOnly.isEmpty) {
                            return const Center(
                              child: Text(
                                "No sales or team leaders available.",
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: salesOnly.length,
                            itemBuilder: (context, index) {
                              final sale = salesOnly[index];
                              final userId = sale.id!;
                              return ListTile(
                                title: Text(
                                  sale.userlog?.name ?? "Unnamed Sales",
                                ),
                                subtitle: Text(
                                  sale.userlog?.role ?? "",
                                  style: TextStyle(color: widget.mainColor),
                                ),
                                trailing: Checkbox(
                                  activeColor: widget.mainColor,
                                  value: selectedSales[userId] ?? false,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedSales.clear();
                                      selectedSales[userId] = val ?? false;
                                      selectedSalesId =
                                          val == true ? userId : null;
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        } else if (state is SalesError) {
                          return Center(child: Text(state.message));
                        } else {
                          return const Center(
                            child: Text("No sales available for assignment."),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 🔹 Clear History checkbox
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

                  const SizedBox(height: 8),
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
                                stageState.stages.map((stage) {
                                  return DropdownMenuItem(
                                    value: stage.id.toString(),
                                    child: Text(stage.name ?? 'Unnamed'),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() => selectedStageId = value);
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 🔹 Buttons: Cancel & Apply
                  BlocListener<AssignleadCubit, AssignState>(
                    listener: (context, state) async {
                      if (state is AssignSuccess) {
                        if (Navigator.canPop(dialogContext)) {
                          Navigator.pop(dialogContext, true);
                        }
                        if (widget.onAssignSuccess != null) {
                          widget.onAssignSuccess!();
                        }
                        final cubit = context.read<GetManagerLeadsCubit>();
                        await cubit.getLeadsByManager();

                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text("Lead assigned successfully! ✅"),
                          ),
                        );

                        context
                            .read<NotificationCubit>()
                            .sendNotificationToToken(
                              title: "Lead",
                              body: "New Lead assigned successfully ✅",
                              fcmtokennnn: widget.fcmtoken,
                            );
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
                          onPressed: () async {
                            if (selectedSalesId != null) {
                              final leadIds =
                                  widget.leadIds != null
                                      ? List<String>.from(widget.leadIds!)
                                      : [widget.leadId!];

                              if (clearHistory) {
                                await saveClearHistoryTime();
                              }

                              final assignCubit =
                                  BlocProvider.of<AssignleadCubit>(
                                    dialogContext,
                                    listen: false,
                                  );

                              assignCubit.assignLeadFromManager(
                                leadIds: leadIds,
                                lastDateAssign:
                                    DateTime.now().toUtc().toIso8601String(),
                                dateAssigned:
                                    "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                salesId: selectedSalesId!,
                                isClearhistory: clearHistory,
                              );
                            } else {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select the Team Leader or Sales to assign. ⚠️",
                                  ),
                                ),
                              );
                            }
                          },
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
