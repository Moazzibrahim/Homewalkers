// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_local_variable, deprecated_member_use, use_build_context_synchronously, unused_field
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/leads_details_team_leader_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/custom_assign_dialog_team_leader_widget.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/custom_filter_teamleader_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/edit_lead_sales_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamLeaderAssignScreen extends StatefulWidget {
  final String? stageName;
  const TeamLeaderAssignScreen({super.key, this.stageName});

  @override
  _SalesAssignLeadsScreenState createState() => _SalesAssignLeadsScreenState();
}

class _SalesAssignLeadsScreenState extends State<TeamLeaderAssignScreen> {
  List<bool> selected = [];
  List<LeadData> _leads = [];
  LeadResponse? leadResponse;
  String? leadIdd;
  TextEditingController searchController = TextEditingController();
  String? salesfcmtoken;
  String? managerfcmtoken;
  // bool? leadassign; // <--- تم حذف هذا المتغير لأنه كان سبب المشكلة
  String? teamleadname;
  String? teamleadid;
  bool isLoading = false;
  bool isSelectionMode = false;
  String? _selectedLeadId;
  LeadData? _selectedLead; // لو حابب تخزن آخر ليد مختارة
  List<LeadData> selectedLeadsData = [];

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    //print("stage name: ${widget.stageName}");
    if (!mounted) return;
    setState(() {
      teamleadname = prefs.getString('name');
      teamleadid = prefs.getString('salesId');
    });
    // context.read<GetLeadsTeamLeaderCubit>().getLeadsByTeamLeader();
  }

  late GetLeadsTeamLeaderCubit _cubit;

  @override
  void initState() {
    super.initState();

    log("Stage Name in Assign Screen: ${widget.stageName}");

    _cubit = GetLeadsTeamLeaderCubit(GetLeadsService());

    _loadLeads();

    context.read<SalesCubit>().fetchAllSales();
    init();
  }

  Future<void> _loadLeads() async {
    await _cubit.getLeadsByTeamLeader();

    if (widget.stageName == null || widget.stageName!.isEmpty) return;

    if (widget.stageName == "Team Leader Pending") {
      log("Filtering Team Leader Pending");
      _cubit.filterPendingLeadsForLoggedSales();
    } else {
      log("Filtering by stage: ${widget.stageName}");
      _cubit.filterLeadsByStage(widget.stageName!);
    }
  }

  String formatDateTimeToDubai(String dateStr) {
    try {
      // Parse and ensure UTC base
      final utcTime = DateTime.parse(dateStr).toUtc();

      // Convert to Dubai timezone (UTC+4)
      final dubaiTime = utcTime.add(const Duration(hours: 4));

      // Format the output
      final day = dubaiTime.day.toString().padLeft(2, '0');
      final month = dubaiTime.month.toString().padLeft(2, '0');
      final year = dubaiTime.year;

      // Convert to 12-hour format with AM/PM
      int hour = dubaiTime.hour;
      final minute = dubaiTime.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$day/$month/$year - ${hour.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (e) {
      return dateStr; // fallback في حال كان التاريخ مش صحيح
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.backgroundlightmode
                    : Constants.backgroundDarkmode,
            appBar: CustomAppBar(
              title: "Assign",
              onBack: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeamLeaderTabsScreen(),
                  ),
                );
              },
            ),
            body: Column(
              children: [
                BlocBuilder<GetLeadsTeamLeaderCubit, GetLeadsTeamLeaderState>(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Constants.backgroundDarkmode,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            if (isSelectionMode) buildAssignButtons(),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (value) {
                                      final cubit =
                                          context
                                              .read<GetLeadsTeamLeaderCubit>();

                                      if (widget.stageName != null &&
                                          widget.stageName!.isNotEmpty) {
                                        // 🟢 Search داخل stageName فقط
                                        cubit.filterLeadsByStageAndQuery(
                                          widget.stageName!,
                                          value,
                                        );
                                      } else {
                                        // 🟢 Search على كل الداتا
                                        cubit.filterLeadsTeamLeader(
                                          query: value,
                                        );
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 0,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  height: 50.h,
                                  width: 50.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F1F2),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.filter_list,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                    onPressed: () {
                                      showFilterDialogTeamLeader(
                                        context,
                                        context.read<GetLeadsTeamLeaderCubit>(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<
                    GetLeadsTeamLeaderCubit,
                    GetLeadsTeamLeaderState
                  >(
                    builder: (context, state) {
                      if (state is GetLeadsTeamLeaderLoading) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (state is GetLeadsTeamLeaderSuccess) {
                        _leads = state.leadsData.data ?? [];
                        if (selected.length != _leads.length) {
                          selected = List.generate(
                            _leads.length,
                            (index) => false,
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            final cubit =
                                context.read<GetLeadsTeamLeaderCubit>();
                            await cubit
                                .getLeadsByTeamLeader(); // جلب كل البيانات أولاً

                            // لو فيه stageName محدد، اعمل فلتر بعد الـ fetch
                            if (widget.stageName != null &&
                                widget.stageName!.isNotEmpty) {
                              cubit.filterLeadsByStage(widget.stageName!);
                            }
                          },
                          child: ListView.builder(
                            itemCount: _leads.length,
                            itemBuilder: (context, index) {
                              final lead = _leads[index];
                              // leadassign = lead.assign; // <--- تم حذف هذا السطر
                              print("assign of lead: ${lead.assign}");
                              salesfcmtoken = lead.sales?.userlog?.fcmtokenn;
                              final prefs = SharedPreferences.getInstance();
                              final fcmToken = prefs.then(
                                (prefs) => prefs.setString(
                                  'fcm_token_sales',
                                  salesfcmtoken ?? '',
                                ),
                              );
                              log("fcmToken of sales: $salesfcmtoken");
                              leadIdd = lead.id.toString();
                              managerfcmtoken = lead.sales?.manager?.fcmtokenn;
                              final leadstageupdated = lead.stagedateupdated;
                              final leadStagetype = lead.stage?.name ?? "";
                              DateTime? stageUpdatedDate;
                              bool isOutdatedLocal = false;
                              if (leadstageupdated != null) {
                                try {
                                  stageUpdatedDate = DateTime.parse(
                                    leadstageupdated,
                                  );
                                  log("stageUpdatedDate: $stageUpdatedDate");
                                  log("stage type: $leadStagetype");
                                } catch (_) {
                                  stageUpdatedDate = null;
                                }
                              }
                              if (stageUpdatedDate != null) {
                                final now = DateTime.now().toUtc();
                                print("now: $now");
                                final difference =
                                    now.difference(stageUpdatedDate).inMinutes;
                                print("difference: $difference");
                                isOutdatedLocal = difference > 1;
                                print("isOutdated: $isOutdatedLocal");
                              }
                              return buildUserTile(
                                parentContext: context,
                                name: lead.name ?? 'No Name',
                                status: lead.stage?.name ?? 'No Status',
                                index: index,
                                id: lead.id.toString(),
                                leadsalesName: lead.sales?.name ?? 'No Sales',
                                phone: lead.phone ?? 'No Phone',
                                email: lead.email ?? 'No Email',
                                stage: lead.stage?.name ?? 'No Stage',
                                stageid:
                                    lead.stage?.id.toString() ?? 'No Stage ID',
                                channel: lead.chanel?.name ?? 'No Channel',
                                creationdate:
                                    lead.createdAt != null
                                        ? formatDateTimeToDubai(lead.createdAt!)
                                        : '',
                                project: lead.project?.name ?? 'No Project',
                                lastcomment:
                                    lead.lastcommentdate ?? 'No Last Comment',
                                leadcampaign:
                                    lead.campaign?.campaoignType ??
                                    'No Campaign',
                                leadNotes: lead.notes ?? 'No Notes',
                                leaddeveloper:
                                    lead.project?.developer?.name ??
                                    'No Developer',
                                userlogname:
                                    lead.sales?.userlog?.name ?? 'No User',
                                teamleadername:
                                    lead.sales?.teamleader?.name ??
                                    'No Team Leader',
                                salesName: lead.sales?.name ?? 'No Sales',
                                lead: lead,
                                stageUpdatedDate: stageUpdatedDate,
                                leadStagetype: leadStagetype,
                                isOutdated: isOutdatedLocal,
                                fcmtoken:
                                    salesfcmtoken ?? '', // استخدام قيمة آمنة
                                managerFcmtoken:
                                    lead.sales?.manager?.fcmtokenn ?? '',
                                //  <--- التعديل الرئيسي: تمرير القيمة مباشرة من المصدر
                                assign: lead.assign ?? false,
                                userlogteamleadername:
                                    lead.sales?.userlog?.name ??
                                    'No Userlog Team Leader',
                                leadwhatsappnumber:
                                    lead.whatsappnumber ?? lead.phone ?? '',
                                jobdescription:
                                    lead.jobdescription ?? 'no job description',
                                secondphonenumber:
                                    lead.secondphonenumber ??
                                    'no second phone number',
                                laststageupdated: leadstageupdated!,
                                stageId: lead.stage?.id ?? 'No Stage ID',
                                leadLastDateAssigned: lead.lastdateassign ?? '',
                                resetCreationDate:
                                    lead.resetcreationdate ?? false,
                              );
                            },
                          ),
                        );
                      } else if (state is GetLeadsTeamLeaderError) {
                        return Center(child: Text(" ${state.message}"));
                      } else {
                        return const Center(child: Text("لا توجد بيانات"));
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAssignDialog() async {
    final parentContext = context;

    final selectedIndices =
        selected
            .asMap()
            .entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one lead")),
      );
      return;
    }

    final selectedLeads = selectedIndices.map((i) => _leads[i]).toList();
    final selectedLeadStageIds =
        selectedLeads.map((lead) => lead.stage?.id?.toString() ?? "").toList();

    /// ✅ هات آخر Stage مسجل لل Leads المختارة
    final lastStage =
        selectedLeadStageIds.isNotEmpty ? selectedLeadStageIds.last : "";

    /// ✅ افتح الديالوج النهائي مباشرة
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => BlocProvider(
            create: (_) => SalesCubit(GetAllSalesApiService()),
            child: CustomAssignDialogTeamLeaderWidget(
              leadIds: selectedLeads.map((e) => e.id ?? 0).toList(),
              leadId: leadIdd,
              leadResponse: leadResponse,
              leadsStages: [lastStage],
              mainColor: Constants.maincolor,
              fcmyoken: salesfcmtoken!,
              managerfcm: managerfcmtoken,
              onAssignSuccess: () async {
                setState(() {
                  selected.clear();
                  selectedLeadsData.clear();
                  _selectedLead = null;
                  isSelectionMode = false;
                });

                await _cubit.getLeadsByTeamLeader();
                if (widget.stageName != null && widget.stageName!.isNotEmpty) {
                  _cubit.filterLeadsByStage(widget.stageName!);
                }

                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text("Lead assigned successfully! ✅"),
                  ),
                );
              },
            ),
          ),
    );
  }

  Widget buildAssignButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Constants.maincolor
                : Constants.mainDarkmodecolor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // زر Assign
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.grey[100], // خلفية خفيفة شيك
              shape: BoxShape.circle, // دائري بالكامل 👌
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (selectedLeadsData.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select at least one lead"),
                    ),
                  );
                  return;
                }
                _showAssignDialog(); // نفس كود الـ assign الحالي
              },
              child: Image.asset(
                "assets/images/right.png",
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                color: Constants.maincolor,
              ),
            ),
          ),
          // الزر الثاني (ممكن تضيف له الوظيفة بعدين)
          Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.grey[100], // خلفية خفيفة شيك
              shape: BoxShape.circle, // دائري بالكامل 👌
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: Constants.maincolor),
              onPressed: () async {
                if (_selectedLead != null) {
                  final result = await showDialog(
                    context: context,
                    builder:
                        (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create:
                                  (_) => EditLeadCubit(EditLeadApiService()),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      ProjectsCubit(ProjectsApiService())
                                        ..fetchProjects(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      SalesCubit(GetAllSalesApiService())
                                        ..fetchAllSales(),
                            ),
                          ],
                          child: EditLeadSalesDialog(
                            userId: _selectedLead!.id ?? '',
                            initialName: _selectedLead!.name ?? '',
                            initialPhone2:
                                _selectedLead!.secondphonenumber ?? '',
                            initialWhatsappNumber:
                                _selectedLead!.whatsappnumber ?? '',
                            initialNotes: _selectedLead!.notes ?? '',
                            initialProjectId: _selectedLead!.project?.id,
                            salesID: _selectedLead!.sales?.id ?? '',
                            onSuccess: () async {
                              // ✅ تصفية الاختيارات القديمة
                              setState(() {
                                selected.clear();
                                selectedLeadsData.clear();
                                _selectedLead = null;
                                isSelectionMode = false;
                              });

                              // ✅ جلب البيانات الجديدة
                              await _cubit.getLeadsByTeamLeader();

                              // ✅ لو فيه stage محدد، اعمل فلترة بعد الجلب
                              if (widget.stageName != null &&
                                  widget.stageName!.isNotEmpty) {
                                _cubit.filterLeadsByStage(widget.stageName!);
                              }

                              // تحديث الـ UI
                              setState(() {});
                            },
                          ),
                        ),
                  );

                  if (result == true) {
                    // نفس الشيء لو الديالوج رجع true
                    setState(() {
                      selected.clear();
                      selectedLeadsData.clear();
                      _selectedLead = null;
                      isSelectionMode = false;
                    });
                    await _cubit.getLeadsByTeamLeader();
                    if (widget.stageName != null &&
                        widget.stageName!.isNotEmpty) {
                      _cubit.filterLeadsByStage(widget.stageName!);
                    }
                    setState(() {});
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserTile({
    required String name,
    required BuildContext parentContext,
    required String status,
    required int index,
    required String id,
    required String leadsalesName,
    required String phone,
    required String email,
    required String stage,
    required String stageid,
    required String channel,
    required String creationdate,
    required String project,
    required String lastcomment,
    required String leadcampaign,
    required String leadNotes,
    required String leaddeveloper,
    required String userlogname,
    required String teamleadername,
    required String salesName,
    required dynamic lead,
    DateTime? stageUpdatedDate,
    required String leadStagetype,
    required bool isOutdated,
    required String fcmtoken,
    required String managerFcmtoken,
    required bool
    assign, //  <--- الآن هذا المتغير يستقبل القيمة الصحيحة لكل عنصر
    required String userlogteamleadername,
    required String leadwhatsappnumber,
    required String jobdescription,
    required String secondphonenumber,
    required String laststageupdated,
    required String stageId,
    required String leadLastDateAssigned,
    required bool resetCreationDate,
  }) {
    return InkWell(
      onTap: () async {
        final bool hasDownloadIcon =
            assign == true && userlogteamleadername == teamleadname;
        if (isSelectionMode) {
          if (hasDownloadIcon) return; // منع الاختيار للكارت اللي عنده Download
          setState(() {
            selected[index] = !selected[index];

            if (!selected.contains(true)) {
              isSelectionMode = false;
            }
          });
          return;
        }
        log("userlogteamleadername: $userlogteamleadername");
        log("teamleadname: $teamleadname");
        // <--- استخدام المتغير الصحيح 'assign' بدلاً من 'leadassign'
        log("leadassign: $assign");
        if (assign == false) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider(
                    create:
                        (_) =>
                            LeadCommentsCubit(GetAllLeadCommentsApiService()),
                    child: LeadsDetailsTeamLeaderScreen(
                      leedId: id,
                      leadName: name,
                      leadPhone: phone,
                      leadEmail: email,
                      leadStage: stage,
                      leadSalesName: leadsalesName,
                      leadStageId: stageid,
                      leadChannel: channel,
                      leadCreationDate: creationdate,
                      leadProject: project,
                      leadLastComment: lastcomment,
                      leadcampaign: leadcampaign,
                      leadNotes: leadNotes,
                      leaddeveloper: leaddeveloper,
                      userlogname: userlogname,
                      teamleadername: teamleadername,
                      fcmtoken: fcmtoken,
                      managerfcmtoken: managerFcmtoken,
                      leadwhatsappnumber: leadwhatsappnumber,
                      jobdescription: jobdescription,
                      secondphonenumber: secondphonenumber,
                      laststageupdated: laststageupdated,
                      stageId: stageId,
                      leadLastDateAssigned: leadLastDateAssigned,
                      isresetcreationdate: resetCreationDate,
                    ),
                  ),
            ),
          );
        } else if (assign == true && userlogteamleadername == teamleadname) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Attention"),
                content: const Text("You must receive this lead first."),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        } else if (assign == true && userlogteamleadername != teamleadname) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider(
                    create:
                        (_) =>
                            LeadCommentsCubit(GetAllLeadCommentsApiService()),
                    child: LeadsDetailsTeamLeaderScreen(
                      leedId: id,
                      leadName: name,
                      leadPhone: phone,
                      leadEmail: email,
                      leadStage: stage,
                      leadStageId: stageid,
                      leadChannel: channel,
                      leadSalesName: leadsalesName,
                      leadCreationDate: creationdate,
                      leadProject: project,
                      leadLastComment: lastcomment,
                      leadcampaign: leadcampaign,
                      leadNotes: leadNotes,
                      leaddeveloper: leaddeveloper,
                      userlogname: userlogname,
                      teamleadername: teamleadername,
                      fcmtoken: fcmtoken,
                      managerfcmtoken: managerFcmtoken,
                      leadwhatsappnumber: leadwhatsappnumber,
                      jobdescription: jobdescription,
                      secondphonenumber: secondphonenumber,
                      laststageupdated: laststageupdated,
                      stageId: stageId,
                      leadLastDateAssigned: leadLastDateAssigned,
                      isresetcreationdate: resetCreationDate,
                    ),
                  ),
            ),
          );
        }
      },
      onLongPress: () {
        final bool hasDownloadIcon =
            assign == true && userlogteamleadername == teamleadname;
        if (hasDownloadIcon) return; // منع Long Press للكارت اللي عنده Download
        setState(() {
          isSelectionMode = true;
          selected[index] = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selected[index]
                  ? Colors.grey.withOpacity(0.3) // لون الكارت المحدد
                  : (Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.grey[900]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (_) {
                            final bool isFinalStage =
                                stageUpdatedDate != null &&
                                (leadStagetype == "Done Deal" ||
                                    leadStagetype == "Transfer" ||
                                    leadStagetype == "Fresh" ||
                                    leadStagetype == "Not Interested");

                            final Color stageColor =
                                isFinalStage
                                    ? Constants.maincolor
                                    : isOutdated
                                    ? Colors.red
                                    : Colors.green;

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: stageColor.withOpacity(0.1),
                                border: Border.all(color: stageColor),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: stageColor,
                                    size: 10,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    lead.stage?.name ?? "Unknown",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: stageColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Text(
                            "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!) : "N/A"}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black87
                                      : Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (assign == true && userlogteamleadername == teamleadname)
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return MultiBlocProvider(
                                providers: [
                                  // ✅ استخدم value علشان يورّث الكابت الأساسي مش يعمل واحد جديد
                                  BlocProvider.value(
                                    value:
                                        context.read<GetLeadsTeamLeaderCubit>(),
                                  ),
                                  BlocProvider(
                                    create:
                                        (_) =>
                                            EditLeadCubit(EditLeadApiService()),
                                  ),
                                ],
                                child: Builder(
                                  builder: (innerContext) {
                                    bool isLoading = false;

                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: const Text("Confirmation"),
                                          content: const Text(
                                            "Are you sure to receive this lead?",
                                          ),
                                          actions: [
                                            // ❌ Cancel button
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? Constants.maincolor
                                                        : Constants
                                                            .mainDarkmodecolor,
                                              ),
                                              onPressed: () {
                                                Navigator.of(
                                                  innerContext,
                                                ).pop(); // Close dialog
                                              },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            // ✅ OK button with loading state
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? Constants.maincolor
                                                        : Constants
                                                            .mainDarkmodecolor,
                                              ),
                                              onPressed:
                                                  isLoading
                                                      ? null
                                                      : () async {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        try {
                                                          await innerContext
                                                              .read<
                                                                EditLeadCubit
                                                              >()
                                                              .editLeadAssignvalue(
                                                                userId:
                                                                    lead.id!,
                                                                assign: false,
                                                              );
                                                          if (mounted) {
                                                            Navigator.of(
                                                              innerContext,
                                                            ).pop(); // اغلاق الديالوج
                                                            // ✅ استخدم context الصحيح المرتبط بالصفحة الرئيسية
                                                            parentContext
                                                                .read<
                                                                  GetLeadsTeamLeaderCubit
                                                                >()
                                                                .refreshLeads(
                                                                  stageName:
                                                                      widget
                                                                          .stageName,
                                                                );
                                                          }
                                                        } finally {
                                                          if (mounted) {
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          }
                                                        }
                                                      },
                                              child:
                                                  isLoading
                                                      ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                      : const Text(
                                                        "OK",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey
                                  : Constants.mainDarkmodecolor,
                          child: const Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    Checkbox(
                      value: selected[index],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      activeColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      onChanged: (val) {
                        final bool hasDownloadIcon =
                            assign == true &&
                            userlogteamleadername == teamleadname;

                        if (hasDownloadIcon) return; // منع تعديل ليدات معينة

                        setState(() {
                          selected[index] = val!;
                          isSelectionMode = selected.contains(
                            true,
                          ); // تظهر Container لو في اختيار
                          _selectedLead = lead;

                          // استخدام id للتحقق والإضافة/الإزالة
                          final leadIdStr = lead.id.toString();

                          if (val) {
                            // إضافة إذا مش موجود
                            if (!selectedLeadsData.any(
                              (l) => l.id.toString() == leadIdStr,
                            )) {
                              selectedLeadsData.add(lead);
                            }
                          } else {
                            // إزالة الليد المحدد
                            selectedLeadsData.removeWhere(
                              (l) => l.id.toString() == leadIdStr,
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                if (assign == true && userlogteamleadername == teamleadname)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [DotLoading()],
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(thickness: 1.5),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  lead.project?.name ?? "N/A",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: () {
                final formattedPhone =
                    phone.startsWith('0') ? phone : '+$phone';
                makePhoneCall(formattedPhone);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.grey
                            : Constants.mainDarkmodecolor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 35.h),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_pin_outlined,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.grey
                              : Constants.mainDarkmodecolor,
                      size: 20,
                    ),
                    SizedBox(width: 8.w),
                    // 👈 الجزء الشمال (Sales name)
                    Expanded(
                      child: Text(
                        lead.assigntype == true
                            ? "team: ${lead.sales?.name}"
                            : lead.sales?.name ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 👉 الجزء اليمين (الـ 3 أيقونات داخل خلفية)
                    Row(
                      children: [
                        // 📞 Phone Call
                        InkWell(
                          onTap: () {
                            final phone = lead.phone ?? '';
                            final formattedPhone =
                                phone.startsWith('0') ? phone : '+$phone';
                            makePhoneCall(formattedPhone);
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Constants.maincolor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                        // 💬 WhatsApp
                        InkWell(
                          onTap: () async {
                            final rawPhone =
                                (lead.phone?.isNotEmpty == true
                                        ? lead.phone
                                        : lead.whatsappnumber)
                                    ?.replaceAll(RegExp(r'\D'), '') ??
                                '';
                            final formattedPhone =
                                rawPhone.startsWith('0')
                                    ? rawPhone
                                    : '+$rawPhone';
                            final url = "https://wa.me/$formattedPhone";
                            try {
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Could not open WhatsApp."),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Constants.maincolor,
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                        // 🗨️ Last Comment
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: BlocProvider(
                                    create:
                                        (_) => LeadCommentsCubit(
                                          GetAllLeadCommentsApiService(),
                                        )..fetchLeadComments(lead.id!),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: BlocBuilder<
                                        LeadCommentsCubit,
                                        LeadCommentsState
                                      >(
                                        builder: (context, commentState) {
                                          if (commentState
                                              is LeadCommentsLoading) {
                                            return SizedBox(
                                              height: 100,
                                              child: Center(
                                                child: Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: ListView.builder(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    itemCount: 6,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 16,
                                                            ),
                                                        height: 80,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else if (commentState
                                              is LeadCommentsError) {
                                            return SizedBox(
                                              height: 100,
                                              child: Center(
                                                child: Text(
                                                  "No comments available: ${commentState.message}",
                                                ),
                                              ),
                                            );
                                          } else if (commentState
                                              is LeadCommentsLoaded) {
                                            final commentsData =
                                                commentState.leadComments.data;
                                            if (commentsData == null ||
                                                commentsData.isEmpty) {
                                              return const Text(
                                                'No comments available.',
                                              );
                                            }

                                            final commentsList =
                                                commentsData.first.comments ??
                                                [];
                                            final validComments =
                                                commentsList
                                                    .where(
                                                      (c) =>
                                                          (c
                                                                  .firstcomment
                                                                  ?.text
                                                                  ?.isNotEmpty ??
                                                              false) ||
                                                          (c
                                                                  .secondcomment
                                                                  ?.text
                                                                  ?.isNotEmpty ??
                                                              false),
                                                    )
                                                    .toList();

                                            final Comment? firstCommentEntry =
                                                validComments.isNotEmpty
                                                    ? validComments.first
                                                    : null;

                                            final String firstCommentText =
                                                firstCommentEntry
                                                    ?.firstcomment
                                                    ?.text ??
                                                'No comments available.';
                                            final String secondCommentText =
                                                firstCommentEntry
                                                    ?.secondcomment
                                                    ?.text ??
                                                'No action available.';

                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Last Comment",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  firstCommentText,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 10),
                                                const Text(
                                                  "Action (Plan)",
                                                  style: TextStyle(
                                                    color: Constants.maincolor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  secondCommentText,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            );
                                          } else {
                                            return const SizedBox(
                                              height: 100,
                                              child: Text("No comments"),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Constants.maincolor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // ✅ CD Date (السطر اللي تحت)
                if (resetCreationDate == false)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.date_range,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.grey
                                : Constants.mainDarkmodecolor,
                        size: 20,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        " ${lead.date != null ? formatDateTimeToDubai(lead.date!) : "N/A"}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getStatusIcon(String status) {
    switch (status) {
      case 'Follow Up':
      case 'Follow After Meeting':
      case 'Follow':
        return Icon(
          Icons.mark_email_unread_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Meeting':
        return Icon(
          Icons.chat_bubble_outline,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Done Deal':
        return Icon(
          Icons.check_box_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Interested':
        return Icon(
          FontAwesomeIcons.check,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Not Interested':
        return Icon(
          FontAwesomeIcons.timesCircle,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Fresh':
        return Icon(
          Icons.new_releases,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Transfer':
        return Icon(
          Icons.no_transfer,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'EOI':
        return Icon(
          Icons.event_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'Reservation':
        return Icon(
          Icons.task,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'assigned':
        return Icon(
          Icons.check,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      case 'delivered':
        return Icon(
          Icons.done_all,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Constants.mainDarkmodecolor,
        );
      default:
        return const Icon(Icons.info_outline, color: Colors.grey);
    }
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
    } else {
      print('Could not launch $phoneUri');
    }
  }
}

class DotLoading extends StatefulWidget {
  const DotLoading({super.key});

  @override
  _DotLoadingState createState() => _DotLoadingState();
}

class _DotLoadingState extends State<DotLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.5;
      return Tween<double>(begin: 0, end: 10).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end > 1.0 ? 1.0 : end,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildDot(_animations[index]),
          );
        }),
      ),
    );
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -animation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.grey
                      : Constants.mainDarkmodecolor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
