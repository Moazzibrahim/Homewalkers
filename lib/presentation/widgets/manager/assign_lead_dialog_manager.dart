// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print, deprecated_member_use
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/models/leads_model.dart' hide Sales;
import 'package:homewalkers_app/data/models/manager_new/manager_dashboard_pagination_model.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
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
  final Function? onAssignSuccess;

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
  String? selectedFcmToken;

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dubaiTime = DateTime.now().toUtc().add(const Duration(hours: 4));
    await prefs.setString('clear_history_time', dubaiTime.toIso8601String());
    log('Clear history time saved (Dubai): $dubaiTime');
  }

  // 🟢 دالة جديدة لتحميل بيانات المدير إذا لم تكن موجودة
  Future<void> _ensureDashboardDataLoaded() async {
    final managerCubit = context.read<GetManagerLeadsCubit>();

    // إذا كانت البيانات غير موجودة، قم بتحميلها
    if (managerCubit.dashboardDataS == null) {
      log("📊 Loading manager dashboard data from dialog...");
      await managerCubit.getManagerDashboardCounts();
    }
  }

  // 🟢 دالة للبحث عن الـ sales.id المناسب للـ Team Leader
  String? _getSalesIdForTeamLeader(TeamLeader teamLeader) {
    if (teamLeader.teamLeaderInfo == null) return null;

    final teamLeaderEmail = teamLeader.teamLeaderInfo!.email;

    // البحث في قائمة الـ sales عن مندوب له نفس email الـ Team Leader
    for (var sale in teamLeader.sales ?? []) {
      if (sale.userlog?.email == teamLeaderEmail) {
        return sale.id; // 🟢 نرجع الـ sales.id
      }
    }

    // إذا لم نجد، نرجع null (يعني هذا الـ Team Leader ليس له حساب مندوب)
    return null;
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
      ],
      child: Builder(
        builder: (dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
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

                  // 🔹 قائمة Sales و Team Leaders من GetManagerLeadsCubit
                  Expanded(
                    child: FutureBuilder(
                      future: _ensureDashboardDataLoaded(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return BlocBuilder<
                          GetManagerLeadsCubit,
                          GetManagerLeadsState
                        >(
                          builder: (context, state) {
                            final managerCubit =
                                context.read<GetManagerLeadsCubit>();
                            final dashboardData = managerCubit.dashboardDataS;

                            if (state is GetManagerLeadsLoading &&
                                dashboardData == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state is GetManagerLeadsFailure &&
                                dashboardData == null) {
                              return Center(
                                child: Text(
                                  "Failed to load data: ${state.message}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (dashboardData != null &&
                                dashboardData.data != null) {
                              // 🟢 قائمة لعرض المستخدمين (كل عنصر يحتوي على الاسم والدور والمعرّف الذي سنستخدمه للتعيين)
                              final List<Map<String, dynamic>> displayUsers =
                                  [];

                              // 1. إضافة المندوبين المباشرين للمدير (Direct Manager Sales)
                              final directSales =
                                  dashboardData.data!.directManagerSales ?? [];
                              for (var sale in directSales) {
                                if (sale.id != null) {
                                  displayUsers.add({
                                    'displayId':
                                        sale.id, // 🟢 نستخدم sales.id للتعيين
                                    'name': sale.userlog?.name ?? 'Unnamed',
                                    'role': sale.userlog?.role ?? 'Sales',
                                    'email': sale.userlog?.email,
                                    'fcmtoken': sale.userlog?.fcmToken,
                                    'originalId': sale.id,
                                  });
                                  for (var u in displayUsers) {
                                    log(
                                      "USER: ${u['name']}  TOKEN: ${u['fcmtoken']}",
                                    );
                                  }
                                }
                              }

                              // 2. إضافة الـ Team Leaders (مع البحث عن الـ sales.id المناسب)
                              final teamLeaders =
                                  dashboardData.data!.teamLeaders ?? [];
                              for (var teamLeader in teamLeaders) {
                                if (teamLeader.teamLeaderInfo != null) {
                                  // 🟢 البحث عن الـ sales.id المناسب لهذا الـ Team Leader
                                  final salesIdForTeamLeader =
                                      _getSalesIdForTeamLeader(teamLeader);

                                  // إذا وجدنا sales.id، نضيف الـ Team Leader للقائمة
                                  if (salesIdForTeamLeader != null) {
                                    displayUsers.add({
                                      'displayId':
                                          salesIdForTeamLeader, // 🟢 نستخدم sales.id للتعيين
                                      'name':
                                          teamLeader.teamLeaderInfo!.name ??
                                          'Unnamed',
                                      'role': 'Team Leader (Sales)',
                                      'email': teamLeader.teamLeaderInfo!.email,
                                      'originalId':
                                          teamLeader.teamLeaderInfo!.id,
                                      'fcmtoken':
                                          teamLeader.teamLeaderInfo?.fcmToken,
                                      'salesId': salesIdForTeamLeader,
                                    });
                                  }
                                  for (var u in displayUsers) {
                                    log(
                                      "USER: ${u['name']}  TOKEN: ${u['fcmtoken']}",
                                    );
                                  }
                                }

                                // إضافة المندوبين العاديين تحت هذا الـ Team Leader
                                final salesUnderTeamLeader =
                                    teamLeader.sales ?? [];
                                for (var sale in salesUnderTeamLeader) {
                                  if (sale.id != null) {
                                    displayUsers.add({
                                      'displayId':
                                          sale.id, // 🟢 نستخدم sales.id للتعيين
                                      'name': sale.userlog?.name ?? 'Unnamed',
                                      'role': sale.userlog?.role ?? 'Sales',
                                      'email': sale.userlog?.email,
                                      'fcmtoken': sale.userlog?.fcmToken,
                                      'originalId': sale.id,
                                    });
                                  }
                                  for (var u in displayUsers) {
                                    log(
                                      "USER: ${u['name']}  TOKEN: ${u['fcmtoken']}",
                                    );
                                  }
                                }
                              }

                              // 🟢 إزالة التكرار بناءً على displayId
                              final uniqueUsersMap =
                                  <String, Map<String, dynamic>>{};
                              for (var user in displayUsers) {
                                final displayId = user['displayId'] as String;
                                if (!uniqueUsersMap.containsKey(displayId)) {
                                  uniqueUsersMap[displayId] = user;
                                }
                              }
                              List<Map<String, dynamic>> usersList =
                                  uniqueUsersMap.values.toList();

                              // 🟢 فلترة البحث
                              if (searchQuery.isNotEmpty) {
                                usersList =
                                    usersList
                                        .where(
                                          (user) => (user['name'] as String)
                                              .toLowerCase()
                                              .contains(searchQuery),
                                        )
                                        .toList();
                              }

                              if (usersList.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No sales or team leaders available.",
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: usersList.length,
                                itemBuilder: (context, index) {
                                  final user = usersList[index];
                                  final displayId = user['displayId'] as String;
                                  final name = user['name'] as String;
                                  final role = user['role'] as String;

                                  return ListTile(
                                    title: Text(name),
                                    subtitle: Text(
                                      role,
                                      style: TextStyle(color: widget.mainColor),
                                    ),
                                    trailing: Checkbox(
                                      activeColor: widget.mainColor,
                                      value: selectedSales[displayId] ?? false,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSales.clear();
                                          selectedSales[displayId] =
                                              val ?? false;
                                          selectedSalesId =
                                              val == true ? displayId : null;
                                          selectedFcmToken =
                                              val == true
                                                  ? user['fcmtoken']
                                                  : null;
                                          log(
                                            "Selected FCM TOKEN: $selectedFcmToken",
                                          );
                                          if (val == true) {
                                            log(
                                              "📤 Selected user for assignment:",
                                            );
                                            log("   - Name: $name");
                                            log("   - Role: $role");
                                            log(
                                              "   - Display ID (will be sent): $displayId",
                                            );
                                            if (user.containsKey(
                                              'originalId',
                                            )) {
                                              log(
                                                "   - Original ID: ${user['originalId']}",
                                              );
                                            }
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "No data available for assignment.",
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<GetManagerLeadsCubit>()
                                            .getManagerDashboardCounts();
                                      },
                                      child: const Text("Retry"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
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

                  // 🔹 خيارات الـ Stage
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
                        await cubit.getManagerLeadsPagination();

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
                              fcmtokennnn: selectedFcmToken ?? "",
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

                              log(
                                "📤 Assigning lead to sales ID: $selectedSalesId",
                              );

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
