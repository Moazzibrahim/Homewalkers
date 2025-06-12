// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignLeadDialogManager extends StatefulWidget {
  final Color mainColor;
  final LeadResponse? leadResponse;
  final List? leadIds;
  final String? leadId;

  const AssignLeadDialogManager({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
  });

  @override
  State<AssignLeadDialogManager> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<AssignLeadDialogManager> {
  String? selectedSalesId;
  Map<String, bool> selectedSales = {};

  // 1. إضافة متغير الحالة للـ Checkbox
  bool clearHistory = false;

  Future<void> saveClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    await prefs.setString('clear_history_time', now.toIso8601String());
    log('Clear history time saved: $now');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AssignleadCubit()),
        BlocProvider(
          create:
              (_) =>
                  LeadCommentsCubit(GetAllLeadCommentsApiService())
                    ..fetchLeadComments(widget.leadId!),
        ),
      ],
      child: Builder(
        builder: (dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
                      builder: (context, state) {
                        if (state is GetManagerLeadsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is GetManagerLeadsSuccess &&
                            state.leads.data != null) {
                          final uniqueSalesMap = <String, LeadData>{};
                          for (var sale in state.leads.data!) {
                            final user = sale.sales?.userlog;
                            if (user != null &&
                                (user.role == "Sales" ||
                                    user.role == "Team Leader")) {
                              uniqueSalesMap[sale.sales!.id!] = sale;
                            }
                          }
                          final salesOnly = uniqueSalesMap.values.toList();
                          if (salesOnly.isEmpty) {
                            return const Text(
                              "No sales or team leaders available.",
                            );
                          }
                          return Column(
                            children:
                                salesOnly.map((sale) {
                                  final userId = sale.sales!.id!;
                                  return ListTile(
                                    title: Text(
                                      sale.sales?.userlog?.name ??
                                          "Unnamed Sales",
                                    ),
                                    subtitle: Text(
                                      "${sale.sales?.userlog?.role}",
                                      style: TextStyle(color: widget.mainColor),
                                    ),
                                    trailing: Checkbox(
                                      activeColor: widget.mainColor,
                                      value: selectedSales[userId] ?? false,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSales.clear();
                                          selectedSales[userId] = val ?? false;
                                          selectedSalesId =
                                              val == true ? userId : null;
                                          log(
                                            "selectedSalesId: $selectedSalesId",
                                          );
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                          );
                        } else if (state is GetManagerLeadsFailure) {
                          return Text(state.message);
                        } else {
                          return const Text(
                            "No sales available for assignment.",
                          );
                        }
                      },
                    ),

                    // 2. إضافة واجهة المستخدم للـ Checkbox هنا
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
                    const SizedBox(height: 16),
                    BlocListener<AssignleadCubit, AssignState>(
                      listener: (context, state) {
                        if (state is AssignSuccess) {
                          Navigator.pop(dialogContext, true);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text("Lead assigned successfully! ✅"),
                            ),
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
                              Navigator.pop(dialogContext);
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
                                // 3. يمكنك الآن استخدام قيمة clearHistory
                                log("Clear History value: $clearHistory");
                                log("lead id: ${widget.leadId}");
                                if (clearHistory) {
                                  await saveClearHistoryTime(); // حفظ الوقت في حالة تفعيل clearHistory
                                }
                                final lastDateAssign =
                                    DateTime.now().toUtc().toIso8601String();
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
                                assignCubit.assignLeadFromManager(
                                  leadIds: leadIds,
                                  lastDateAssign: lastDateAssign,
                                  dateAssigned:
                                      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                  salesId: selectedSalesId!,
                                  isClearhistory: clearHistory,
                                  // يمكنك إضافة clearHistory هنا إذا كانت الدالة تدعمها
                                );
                                cubit.apiService.fetchLeadAssigned(
                                  widget.leadId!,
                                );
                              } else {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
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
            ),
          );
        },
      ),
    );
  }
}
