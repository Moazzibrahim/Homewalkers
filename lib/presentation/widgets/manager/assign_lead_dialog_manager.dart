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
  final List? leadsStages; // ✅ جديد

  const AssignLeadDialogManager({
    super.key,
    required this.mainColor,
    this.leadResponse,
    this.leadId,
    this.leadIds,
    required this.fcmtoken,
    this.onAssignSuccess,
    this.leadsStages, // ✅ جديد
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
  List<String> selectedFcmTokens = []; // ✅ أضف ده

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

  // ── UI helper بحت: بيرجع initials للاسم عشان الـ avatar (مفيش أي تأثير على اللوجيك) ──
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  TextStyle get _sectionLabelStyle => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.1,
    color: Colors.grey.shade500,
  );

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
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 640, maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── HEADER ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                    decoration: BoxDecoration(
                      color: widget.mainColor.withOpacity(0.06),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: widget.mainColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ASSIGN LEAD",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: widget.mainColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Choose a sales or team leader",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (Navigator.canPop(dialogContext)) {
                              Navigator.pop(dialogContext);
                            }
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── BODY (SCROLLABLE) ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 حقل البحث
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "Search Sales by name",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey.shade500,
                                  size: 21,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 18),
                          Text(
                            "SELECT SALES / TEAM LEADER",
                            style: _sectionLabelStyle,
                          ),
                          const SizedBox(height: 10),

                          // 🔹 قائمة Sales و Team Leaders من GetManagerLeadsCubit
                          SizedBox(
                            height: 260,
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
                                    final dashboardData =
                                        managerCubit.dashboardDataS;

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
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      );
                                    }

                                    if (dashboardData != null &&
                                        dashboardData.data != null) {
                                      // 🟢 قائمة لعرض المستخدمين (كل عنصر يحتوي على الاسم والدور والمعرّف الذي سنستخدمه للتعيين)
                                      final List<Map<String, dynamic>>
                                      displayUsers = [];

                                      // 1. إضافة المندوبين المباشرين للمدير (Direct Manager Sales)
                                      final directSales =
                                          dashboardData
                                              .data!
                                              .directManagerSales ??
                                          [];
                                      for (var sale in directSales) {
                                        if (sale.id != null) {
                                          displayUsers.add({
                                            'displayId':
                                                sale.id, // 🟢 نستخدم sales.id للتعيين
                                            'name':
                                                sale.userlog?.name ?? 'Unnamed',
                                            'role':
                                                sale.userlog?.role ?? 'Sales',
                                            'email': sale.userlog?.email,
                                            'fcmtoken': sale.userlog?.fcmToken,
                                            'fcmTokens':
                                                sale
                                                    .userlog
                                                    ?.fcmTokens // ✅ أضف ده
                                                    ?.map((e) => e.token ?? '')
                                                    .where((t) => t.isNotEmpty)
                                                    .toList() ??
                                                [],
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
                                              _getSalesIdForTeamLeader(
                                                teamLeader,
                                              );

                                          // إذا وجدنا sales.id، نضيف الـ Team Leader للقائمة
                                          if (salesIdForTeamLeader != null) {
                                            displayUsers.add({
                                              'displayId':
                                                  salesIdForTeamLeader, // 🟢 نستخدم sales.id للتعيين
                                              'name':
                                                  teamLeader
                                                      .teamLeaderInfo!
                                                      .name ??
                                                  'Unnamed',
                                              'role': 'Team Leader (Sales)',
                                              'email':
                                                  teamLeader
                                                      .teamLeaderInfo!
                                                      .email,
                                              'originalId':
                                                  teamLeader.teamLeaderInfo!.id,
                                              'fcmtoken':
                                                  teamLeader
                                                      .teamLeaderInfo
                                                      ?.fcmToken,
                                              'fcmTokens':
                                                  teamLeader
                                                      .teamLeaderInfo
                                                      ?.fcmTokens // ✅ أضف ده
                                                      ?.map(
                                                        (e) => e.token ?? '',
                                                      )
                                                      .where(
                                                        (t) => t.isNotEmpty,
                                                      )
                                                      .toList() ??
                                                  [],
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
                                              'name':
                                                  sale.userlog?.name ??
                                                  'Unnamed',
                                              'role':
                                                  sale.userlog?.role ?? 'Sales',
                                              'email': sale.userlog?.email,
                                              'fcmtoken':
                                                  sale.userlog?.fcmToken,
                                              'fcmTokens':
                                                  sale
                                                      .userlog
                                                      ?.fcmTokens // ✅ أضف ده
                                                      ?.map(
                                                        (e) => e.token ?? '',
                                                      )
                                                      .where(
                                                        (t) => t.isNotEmpty,
                                                      )
                                                      .toList() ??
                                                  [],
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
                                        final displayId =
                                            user['displayId'] as String;
                                        if (!uniqueUsersMap.containsKey(
                                          displayId,
                                        )) {
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
                                                  (user) => (user['name']
                                                          as String)
                                                      .toLowerCase()
                                                      .contains(searchQuery),
                                                )
                                                .toList();
                                      }

                                      if (usersList.isEmpty) {
                                        return Center(
                                          child: Text(
                                            "No sales or team leaders available.",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: usersList.length,
                                        itemBuilder: (context, index) {
                                          final user = usersList[index];
                                          final displayId =
                                              user['displayId'] as String;
                                          final name = user['name'] as String;
                                          final role = user['role'] as String;
                                          final isItemSelected =
                                              selectedSales[displayId] ?? false;

                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isItemSelected
                                                      ? widget.mainColor
                                                          .withOpacity(0.08)
                                                      : Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color:
                                                    isItemSelected
                                                        ? widget.mainColor
                                                        : Colors.grey.shade200,
                                                width: isItemSelected ? 1.4 : 1,
                                              ),
                                            ),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 2,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              leading: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: widget
                                                    .mainColor
                                                    .withOpacity(0.15),
                                                child: Text(
                                                  _getInitials(name),
                                                  style: TextStyle(
                                                    color: widget.mainColor,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: widget.mainColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    role,
                                                    style: TextStyle(
                                                      color: widget.mainColor,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              trailing: Checkbox(
                                                activeColor: widget.mainColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                value:
                                                    selectedSales[displayId] ??
                                                    false,
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedSales.clear();
                                                    selectedSales[displayId] =
                                                        val ?? false;
                                                    selectedSalesId =
                                                        val == true
                                                            ? displayId
                                                            : null;
                                                    selectedFcmToken =
                                                        val == true
                                                            ? user['fcmtoken']
                                                            : null;

                                                    // ✅ اجمع الـ fcmTokens
                                                    if (val == true) {
                                                      final tokensList =
                                                          (user['fcmTokens']
                                                                  as List<
                                                                    dynamic
                                                                  >?)
                                                              ?.map(
                                                                (e) =>
                                                                    e.toString(),
                                                              )
                                                              .where(
                                                                (t) =>
                                                                    t.isNotEmpty,
                                                              )
                                                              .toList() ??
                                                          [];

                                                      selectedFcmTokens =
                                                          tokensList.isNotEmpty
                                                              ? tokensList
                                                              : (selectedFcmToken !=
                                                                      null
                                                                  ? [
                                                                    selectedFcmToken!,
                                                                  ]
                                                                  : []);
                                                    } else {
                                                      selectedFcmTokens = [];
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "No data available for assignment.",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                context
                                                    .read<
                                                      GetManagerLeadsCubit
                                                    >()
                                                    .getManagerDashboardCounts();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    widget.mainColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                "Retry",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
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

                          const SizedBox(height: 18),
                          Text("OPTIONS", style: _sectionLabelStyle),
                          const SizedBox(height: 8),

                          // 🔹 Clear History checkbox (نفس اللوجيك بشكل جديد)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: CheckboxListTile(
                              title: const Text(
                                "Clear History",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              value: clearHistory,
                              onChanged: (newValue) {
                                setState(() {
                                  clearHistory = newValue ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              activeColor: widget.mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          Text("STAGE OPTION", style: _sectionLabelStyle),
                          const SizedBox(height: 8),

                          // 🔹 خيارات الـ Stage (نفس اللوجيك بشكل جديد)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  value: 'as_fresh',
                                  groupValue: selectedOption,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  activeColor: widget.mainColor,
                                  title: const Text(
                                    'Assign as Fresh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() => selectedOption = value!);
                                  },
                                ),
                                Divider(height: 1, color: Colors.grey.shade200),
                                RadioListTile<String>(
                                  value: 'same',
                                  groupValue: selectedOption,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  activeColor: widget.mainColor,
                                  title: const Text(
                                    'Same Stage',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() => selectedOption = value!);
                                  },
                                ),
                                Divider(height: 1, color: Colors.grey.shade200),
                                RadioListTile<String>(
                                  value: 'change',
                                  groupValue: selectedOption,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  activeColor: widget.mainColor,
                                  title: const Text(
                                    'Change Stage',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() => selectedOption = value!);
                                  },
                                ),

                                // Dropdown يظهر فقط عند اختيار "Change Stage"
                                if (selectedOption == 'change' &&
                                    stageState is StagesLoaded)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      0,
                                      12,
                                      12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: selectedStageId,
                                          hint: const Text('Select Stage'),
                                          items:
                                              stageState.stages.map((stage) {
                                                return DropdownMenuItem(
                                                  value: stage.id.toString(),
                                                  child: Text(
                                                    stage.name ?? 'Unnamed',
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (value) {
                                            setState(
                                              () => selectedStageId = value,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── FOOTER: Cancel & Apply ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: BlocListener<AssignleadCubit, AssignState>(
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

                          if (selectedFcmTokens.isNotEmpty) {
                            context
                                .read<NotificationCubit>()
                                .sendNotificationToTokens(
                                  title: "Lead",
                                  body: "New Lead assigned successfully ✅",
                                  fcmTokens: selectedFcmTokens,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                if (Navigator.canPop(dialogContext)) {
                                  Navigator.pop(dialogContext);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: widget.mainColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: widget.mainColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (selectedSalesId != null) {
                                  final leadIds =
                                      widget.leadIds != null
                                          ? List<String>.from(widget.leadIds!)
                                          : [widget.leadId!];

                                  if (clearHistory) {
                                    await saveClearHistoryTime();
                                  }
                                          final prefs = await SharedPreferences.getInstance();
        final freshStageId = prefs.getString('fresh_stage_id');
        final transferStageId = prefs.getString('transfer_stage_id');
        final pendingStageId = prefs.getString('pending_stage_id');
        String stageToSend = '';
        if (selectedOption == 'as_fresh') {
          stageToSend = pendingStageId!;
        } else if (selectedOption == 'change') {
          if (selectedStageId == null || selectedStageId!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select a stage")),
            );
            return;
          }
          stageToSend = selectedStageId!;
        } else {
          // ✅ Same Stage - مع التحقق من وجود leadsStages
          if (widget.leadsStages != null && widget.leadsStages!.isNotEmpty) {
            stageToSend = widget.leadsStages!.last.toString();

            if (stageToSend == transferStageId || stageToSend == freshStageId) {
              stageToSend = pendingStageId!;
            }
          } else {
            stageToSend = pendingStageId!;
            log("⚠️ leadsStages is null or empty, using pendingStageId as default");

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No stage available, using default stage"),
                duration: Duration(seconds: 2),
              ),
            );
          }
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
                                        DateTime.now()
                                            .toUtc()
                                            .toIso8601String(),
                                    dateAssigned:
                                        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                    salesId: selectedSalesId!,
                                    isClearhistory: clearHistory,
                                     stageId: stageToSend, // ✅ جديد
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: widget.mainColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
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
