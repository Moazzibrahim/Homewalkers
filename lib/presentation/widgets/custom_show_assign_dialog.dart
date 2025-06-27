// ignore_for_file: non_constant_identifier_names
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:homewalkers_app/presentation/viewModels/get_all_sales/get_all_sales_cubit.dart';

class AssignDialog extends StatefulWidget {
  final Color mainColor;
  final LeadResponse?
  leadResponse; // Contains potential assignees (e.g., sales team members)
  final List? leadIds;
  final String? leadId;
  final String? fcmtoken; // Optional: if you want to pass a specific lead ID

  const AssignDialog({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
    this.fcmtoken,
  });

  @override
  State<AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<AssignDialog> {
  bool isTeamLeaderChecked =
      false; // Simplified for the single team leader checkbox
  LeadData? _LeadData; // To store the found team leader data
  String? teamLeaderId;

  @override
  void initState() {
    super.initState();
    _initialize();
    print('fcmtoken: ${widget.fcmtoken}');
  }

  void _initialize() async {
    final salesCubit = BlocProvider.of<SalesCubit>(context);
    salesCubit.fetchSales();

    final prefs = await SharedPreferences.getInstance();
    final userlogId = prefs.getString('teamLeaderId') ?? '';
    salesCubit.salesRepository.fetchSalesData(userlogId);

    teamLeaderId = prefs.getString('saved_id');

    final leads = widget.leadResponse?.data ?? [];
    try {
      _LeadData = leads.firstWhere((leadData) => leadData.id != null);
      if (_LeadData != null) {}
    } catch (e) {
      _LeadData = null;
      log("No team leader found or error: $e");
    }
    // تحديث واجهة المستخدم بعد جلب البيانات
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This BlocProvider creates a new AssignleadCubit instance each time
    // the AssignDialog is built. Its lifecycle is tied to the dialog.
    return BlocProvider(
      create: (context) => AssignleadCubit(),
      child: Builder(
        // Use Builder to get a context that has access to AssignleadCubit
        builder: (dialogContext) {
          // This context can access AssignleadCubit
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
                    // Display Team Leader information if found
                    if (_LeadData != null)
                      ListTile(
                        title: Text(
                          _LeadData!.sales!.teamleader!.name ??
                              "Team Leader Name N/A",
                        ),
                        subtitle: Text(
                          "Team Leader",
                          style: TextStyle(color: widget.mainColor),
                        ),
                        trailing: Checkbox(
                          activeColor: widget.mainColor,
                          value: isTeamLeaderChecked,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              isTeamLeaderChecked = val ?? false;
                            });
                          },
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("No Team Leader available for assignment."),
                      ),
                    const SizedBox(height: 16),
                    // Listen to cubit states for side effects (navigation, snackbars)
                    BlocListener<AssignleadCubit, AssignState>(
                      listener: (context, state) {
                        // context here is dialogContext
                        if (state is AssignSuccess) {
                          Navigator.pop(
                            dialogContext,
                            true,
                          ); // Pop dialog and indicate success
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
                              log(
                                "Team Leader ID: $teamLeaderId",
                              ); // Use dialogContext
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
                            onPressed: () {
                              if (isTeamLeaderChecked && _LeadData != null) {
                                // ✅ اطبع كل الـ lead IDs
                                final leadIds =
                                    widget.leadIds != null
                                        ? List<String>.from(widget.leadIds!)
                                        : [widget.leadId!];
                                log("Selected Lead IDs: $leadIds");
                                log("Team Leader ID: $teamLeaderId");
                                final String lastDateAssign =
                                    DateTime.now().toUtc().toIso8601String();
                                // Call the cubit method using the context from BlocProvider
                                BlocProvider.of<AssignleadCubit>(
                                  dialogContext,
                                ).assignUserAndLead(
                                  leadIds: leadIds,
                                  lastDateAssign: lastDateAssign,
                                  dateAssigned:
                                      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                  teamleadersId: teamLeaderId!,
                                );
                                  context.read<NotificationCubit>().sendNotificationToToken(
                                      // 👈 هنعرف دي تحت
                                      title: "Lead",
                                      body: "Lead assigned successfully ✅",
                                      fcmtokennnn: widget.fcmtoken!,
                                    );
                              } else {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  // Use dialogContext
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
                            // Show loading indicator on the button while assigning
                            child: BlocBuilder<AssignleadCubit, AssignState>(
                              builder: (context, state) {
                                // context here is dialogContext
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
