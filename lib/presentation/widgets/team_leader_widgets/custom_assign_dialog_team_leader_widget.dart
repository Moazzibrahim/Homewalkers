// ignore_for_file: non_constant_identifier_names
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_sales_by_team_leader_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_sales_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_sales_team_leader_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAssignDialogTeamLeaderWidget extends StatefulWidget {
  final Color mainColor;
  final LeadResponse? leadResponse;
  final List? leadIds;
  final String? leadId;

  const CustomAssignDialogTeamLeaderWidget({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
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

  late SalesTeamCubit _salesTeamCubit;

  @override
  void initState() {
    super.initState();
    _salesTeamCubit = SalesTeamCubit(GetSalesTeamLeaderApiService());
    _salesTeamCubit.fetchSalesTeam(); // استدعاء بعد التأكد من أنه مفتوح
    _initialize();
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AssignleadCubit()),
        BlocProvider(
          create:
              (context) =>
                  SalesTeamCubit(GetSalesTeamLeaderApiService())
                    ..fetchSalesTeam(),
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
                    // ✅ عرض بيانات السيلز إذا متاحة
                    BlocBuilder<SalesTeamCubit, SalesTeamState>(
                      builder: (context, state) {
                        if (state is SalesTeamLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is SalesTeamLoaded &&
                            state.salesTeam.data != null) {
                          final salesOnly =
                              state.salesTeam.data!
                                  .where(
                                    (sale) => sale.userlog?.role == "Sales",
                                  )
                                  .toList();
                          if (salesOnly.isEmpty) {
                            return const Text("No sales available.");
                          }
                          return Column(
                            children:
                                salesOnly.map((sale) {
                                  return ListTile(
                                    title: Text(sale.name ?? "Unnamed Sales"),
                                    subtitle: Text(
                                      "Sales",
                                      style: TextStyle(color: widget.mainColor),
                                    ),
                                    trailing: Checkbox(
                                      activeColor: widget.mainColor,
                                      value: selectedSales[sale.id] ?? false,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSales
                                              .clear(); // للسماح باختيار واحد فقط
                                          selectedSales[sale.id!] =
                                              val ?? false;
                                          selectedSalesId =
                                              val == true
                                                  ? sale.id.toString()
                                                  : null;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                          );
                        } else if (state is SalesTeamError) {
                          return Text(state.error);
                        } else {
                          return const Text(
                            "No sales available for assignment.",
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // ✅ الاستماع لحالة التعيين
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
                            onPressed: () {
                              if (selectedSalesId != null) {
                                final leadIds =
                                    widget.leadIds != null
                                        ? List<String>.from(widget.leadIds!)
                                        : [widget.leadId!];

                                log("Selected Lead IDs: $leadIds");

                                final String lastDateAssign =
                                    DateTime.now().toUtc().toIso8601String();

                                BlocProvider.of<AssignleadCubit>(
                                  dialogContext,
                                ).assignUserAndLeadTeamLeader(
                                  leadIds: leadIds,
                                  lastDateAssign: lastDateAssign,
                                  dateAssigned:
                                      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                  teamleadersId: savedIdassignedfrom!,
                                  salesId: selectedSalesId!,
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
