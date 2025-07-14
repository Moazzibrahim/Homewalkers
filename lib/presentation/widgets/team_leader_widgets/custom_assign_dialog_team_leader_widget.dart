// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
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
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_count_in_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_sales_team_leader_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAssignDialogTeamLeaderWidget extends StatefulWidget {
  final Color mainColor;
  final LeadResponse? leadResponse;
  final List? leadIds;
  final String? leadId;
  final String fcmyoken;
  final String? managerfcm;

  const CustomAssignDialogTeamLeaderWidget({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
    required this.fcmyoken,
    this.managerfcm,
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

  // 1. إضافة متغير الحالة للـ Checkbox الجديد
  bool clearHistory = false;

  late SalesTeamCubit _salesTeamCubit;

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<
                      GetLeadsCountInTeamLeaderCubit,
                      GetLeadsCountInTeamLeaderState
                    >(
                      builder: (context, state) {
                        if (state is GetLeadsCountInTeamLeaderLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is GetLeadsCountInTeamLeaderLoaded) {
                          final salesList = state.data.data;
                          if (salesList!.isEmpty) {
                            return const Text("No sales available.");
                          }
                          return Column(
                            children:
                                salesList.map((sale) {
                                  return ListTile(
                                    title: Text(
                                      sale.salesName ?? "Unnamed Sales",
                                    ),
                                    subtitle: Text(
                                      "Sales",
                                      style: TextStyle(color: widget.mainColor),
                                    ),
                                    trailing: Checkbox(
                                      activeColor: widget.mainColor,
                                      value:
                                          selectedSales[sale.salesID] ?? false,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
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
                                  );
                                }).toList(),
                          );
                        } else if (state is GetLeadsCountInTeamLeaderError) {
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
                      controlAffinity:
                          ListTileControlAffinity
                              .leading, // لوضع الصندوق على اليسار
                      contentPadding:
                          EdgeInsets.zero, // لإزالة الحواف الافتراضية
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
                                log("Selected Lead IDs: $leadIds");
                                // 3. يمكنك الآن استخدام قيمة clearHistory عند الإرسال
                                log("Clear History value: $clearHistory");
                                if (clearHistory) {
                                  await saveClearHistoryTime(); // حفظ الوقت في حالة تفعيل clearHistory
                                }
                                final String lastDateAssign =
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
                                assignCubit.assignUserAndLeadTeamLeader(
                                  leadIds: leadIds,
                                  lastDateAssign: lastDateAssign,
                                  dateAssigned:
                                      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                  teamleadersId: savedIdassignedfrom!,
                                  salesId: selectedSalesId!,
                                  clearhistory: clearHistory,
                                  // يمكنك إضافة clearHistory هنا إذا كانت الدالة تدعمها
                                );
                                context.read<NotificationCubit>().sendNotificationToToken(
                                      // 👈 هنعرف دي تحت
                                      title: "Lead",
                                      body: "Lead assigned successfully ✅",
                                      fcmtokennnn: widget.fcmyoken,
                                    );
                                    context.read<NotificationCubit>().sendNotificationToToken(
                                      // 👈 هنعرف دي تحت
                                      title: "Lead",
                                      body: "Lead assigned successfully ✅",
                                      fcmtokennnn: widget.managerfcm!,
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
                                      "Please select the Team Leader to assign. ⚠️",
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
