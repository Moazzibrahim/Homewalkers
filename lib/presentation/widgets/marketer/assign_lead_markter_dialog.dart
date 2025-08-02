// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignLeadMarkterDialog extends StatefulWidget {
  final Color mainColor;
  final LeadResponse? leadResponse;
  final List? leadIds;
  final String? leadId;
  final String? leadStage;

  const AssignLeadMarkterDialog({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
    this.leadStage,
  });

  @override
  State<AssignLeadMarkterDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<AssignLeadMarkterDialog> {
  String? selectedSalesId;
  Map<String, bool> selectedSales = {};
  String? selectedSalesFcmToken;

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<SalesCubit, SalesState>(
                      builder: (context, state) {
                        if (state is SalesLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is SalesLoaded) {
                          final uniqueSalesMap = <String, SalesData>{};
                          for (var sale in state.salesData.data!) {
                            final user = sale.userlog;
                            if ((user!.role == "Sales" ||
                                user.role == "Team Leader" ||
                                user.role == "Manager")) {
                              uniqueSalesMap[sale.id!] = sale;
                            }
                          }
                          final salesOnly = uniqueSalesMap.values.toList();
                          if (salesOnly.isEmpty) {
                            return const Text(
                              "No sales or team leaders or managers available.",
                            );
                          }
                          return Column(
                            children:
                                salesOnly.map((sale) {
                                  final userId = sale.id;
                                  return ListTile(
                                    title: Text(sale.name!),
                                    subtitle: Text(
                                      sale.userlog!.role!,
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
                                          selectedSales[userId!] = val ?? false;
                                          selectedSalesId =
                                              val == true ? userId : null;
                                          selectedSalesFcmToken =
                                              val == true
                                                  ? sale.userlog?.fcmtoken
                                                  : null;
                                          log(
                                            "selectedSalesId: $selectedSalesId",
                                          );
                                          log(
                                            "selectedSalesFcmToken: $selectedSalesFcmToken",
                                          );
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                          );
                        } else if (state is SalesError) {
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
                          if (context.mounted) {
                            // اغلق آخر Dialog
                            Navigator.of(context).pop();
                            // اغلق الـ Dialog اللي قبله
                            Navigator.of(context).pop();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
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
                                assignCubit.assignLeadFromMarkter(
                                  leadIds: leadIds,
                                  lastDateAssign: lastDateAssign,
                                  dateAssigned:
                                      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                  salesId: selectedSalesId!,
                                  isClearhistory: clearHistory,
                                  stage:
                                      widget
                                          .leadStage, // إذا كان stage غير فارغ، أرسله
                                  // يمكنك إضافة clearHistory هنا إذا كانت الدالة تدعمها
                                );
                                context
                                    .read<NotificationCubit>()
                                    .sendNotificationToToken(
                                      // 👈 هنعرف دي تحت
                                      title: "Lead",
                                      body: "New Lead assigned to you ✅",
                                      fcmtokennnn: selectedSalesFcmToken!,
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
