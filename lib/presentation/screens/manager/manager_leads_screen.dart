// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, library_private_types_in_public_api
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/campaign_api_service.dart';
import 'package:homewalkers_app/data/data_sources/communication_way_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/screens/manager/leads_details_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/manager/manager_dashboard_data_screen.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/manager/assign_lead_dialog_manager.dart';
import 'package:homewalkers_app/presentation/widgets/manager/manager_custom_filter_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/edit_lead_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManagerLeadsScreen extends StatefulWidget {
  final String? stageName;
  final bool showDuplicatesOnly;
  final bool shouldRefreshOnOpen;
  final bool? data;
  final String? salesId;
  const ManagerLeadsScreen({
    super.key,
    this.stageName,
    this.showDuplicatesOnly = false,
    this.shouldRefreshOnOpen = false,
    this.data,
    this.salesId,
  });

  @override
  State<ManagerLeadsScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<ManagerLeadsScreen> {
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  String? managername;
  String? managerid;
  bool isLoading = false;

  final String selectedSalesId = ''; // انت عارف ده من مكان تاني
  String? _selectedSalesFcmToken;
  bool _showCheckboxes = false; // عشان نتحكم في ظهور الـ Checkbox
  List<LeadData> selectedLeadsData = [];
  bool isSelectionMode = false;
  List<bool> selected = [];
  final Set<String> _selectedSalesIds = {};
  final Set<String> _selectedLeadStagesIds = {};
  final Set<String> _selectedLeads = {};
  Set<int> selectedLeadIds = {};
  late GetManagerLeadsCubit _cubit;
  final ScrollController _scrollController = ScrollController(); // ✅ جديد

  @override
  void initState() {
    super.initState();
    checkClearHistoryTime();
    checkIsClearHistory();
    init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit = context.read<GetManagerLeadsCubit>();
      _cubit.getManagerLeadsPagination(
        data: widget.data ?? false,
        stageIds: [widget.stageName ?? ''],
        ignoreDuplicate: widget.showDuplicatesOnly,
        salesIds: [widget.salesId ?? ''],
      );
    });

    // ✅ إضافة listener للـ scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ دالة الـ scroll listener
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // ✅ استخدم context.read هنا بردو
      context.read<GetManagerLeadsCubit>().loadMoreManagerLeads(
        data: widget.data ?? false,
      );
    }
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      managername = prefs.getString('name');
      managerid = prefs.getString('salesId');
    });
  }

  Future<void> checkClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final time = prefs.getString('clear_history_time');
    if (time != null) {
      setState(() {
        clearHistoryTimee = DateTime.tryParse(time);
      });
      debugPrint('آخر مرة تم فيها الضغط على Clear History: $time');
    }
  }

  Future<void> checkIsClearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final iscleared = prefs.getBool('clearHistory');
    if (mounted) {
      setState(() {
        isClearHistoryy = iscleared;
      });
    }
    debugPrint('Clear History: $iscleared');
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    bool isOutdated = false;

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
            InkWell(
              onTap: () async {
                if (_showCheckboxes && _selectedLeads.isNotEmpty) {
                  final result = await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(create: (_) => AssignleadCubit()),
                          BlocProvider(
                            create:
                                (_) => LeadCommentsCubit(
                                  GetAllLeadCommentsApiService(),
                                )..fetchLeadComments(
                                  _selectedLeads.toList()[0],
                                ),
                          ),
                          BlocProvider(
                            create:
                                (_) =>
                                    SalesCubit(GetAllSalesApiService())
                                      ..fetchAllSales(),
                          ),
                          BlocProvider(
                            create:
                                (_) =>
                                    StagesCubit(StagesApiService())
                                      ..fetchStages(),
                          ),
                        ],
                        child: AssignLeadDialogManager(
                          mainColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                          leadIds: _selectedLeads.toList(),
                          leadId: _selectedLeads.toList()[0],
                          fcmtoken: _selectedSalesFcmToken ?? '',
                          onAssignSuccess: () async {
                            setState(() {
                              selected.clear();
                              selectedLeadsData.clear();
                              isSelectionMode = false;
                            });
                            await _cubit.getManagerLeadsPagination(
                              data: widget.data ?? false,
                              stageIds: [widget.stageName ?? ''],
                              ignoreDuplicate: widget.showDuplicatesOnly,
                              salesIds: [widget.salesId ?? ''],
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Lead assigned successfully! ✅"),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                  if (result == true) {
                    context
                        .read<GetManagerLeadsCubit>()
                        .getManagerLeadsPagination(
                          data: widget.data ?? false,
                          stageIds: [widget.stageName ?? ''],
                          ignoreDuplicate: widget.showDuplicatesOnly,
                          salesIds: [widget.salesId ?? ''],
                        );
                    setState(() {
                      _showCheckboxes = false;
                      _selectedLeads.clear();
                      _selectedSalesIds.clear();
                      _selectedLeadStagesIds.clear();
                    });
                  }
                  log('Assign lead result: $result');
                }
              },
              child: _ActionIcon(
                icon: Image.asset(
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
              child: InkWell(
                onTap: () async {
                  final leadsList = context.read<GetManagerLeadsCubit>().leads;
                  // نجيب ال lead المختار
                  final selectedLead = leadsList.firstWhere(
                    (lead) => lead.id.toString() == _selectedLeads.first,
                    orElse:
                        () => LeadData(), // اسم الموديل عندك Lead مش LeadData
                  );
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
                                      StagesCubit(StagesApiService())
                                        ..fetchStages(),
                            ),
                            BlocProvider(
                              create:
                                  (_) => GetCommunicationWaysCubit(
                                    CommunicationWayApiService(),
                                  )..fetchCommunicationWays(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      ChannelCubit(GetChannelsApiService())
                                        ..fetchChannels(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      GetCampaignsCubit(CampaignApiService())
                                        ..fetchCampaigns(),
                            ),
                            BlocProvider(
                              create:
                                  (_) =>
                                      SalesCubit(GetAllSalesApiService())
                                        ..fetchAllSales(),
                            ),
                          ],
                          child: EditLeadDialog(
                            userId: selectedLead.id ?? '',
                            initialName: selectedLead.name ?? '',
                            initialStalesId: selectedLead.sales?.id ?? '',
                            initialEmail: selectedLead.email ?? '',
                            initialPhone: selectedLead.phone ?? '',
                            initialNotes: selectedLead.notes ?? '',
                            initialProjectId: selectedLead.project?.id,
                            initialStageId: selectedLead.stage?.id,
                            initialChannelId: selectedLead.chanel?.id,
                            initialCampaignId: selectedLead.campaign?.id,
                            initialCommunicationWayId:
                                selectedLead.communicationway?.id,
                            isCold: selectedLead.leedtype == "Cold",
                            onSuccess: () {
                              final leadsCubit =
                                  context.read<GetManagerLeadsCubit>();
                              // leadsCubit.resetPagination();
                              leadsCubit.getManagerLeadsPagination(
                                data: widget.data ?? false,
                                stageIds: [widget.stageName ?? ''],
                                ignoreDuplicate: widget.showDuplicatesOnly,
                                salesIds: [widget.salesId ?? ''],
                              );
                            },
                          ),
                        ),
                  );
                  if (result == true) {
                    context
                        .read<GetManagerLeadsCubit>()
                        .getManagerLeadsPagination(
                          data: widget.data ?? false,
                          stageIds: [widget.stageName ?? ''],
                          ignoreDuplicate: widget.showDuplicatesOnly,
                          salesIds: [widget.salesId ?? ''],
                        );
                  }
                },
                child: const _ActionIcon(icon: Icon(Icons.edit)),
              ),
            ),
          ],
        ),
      );
    }

    void makePhoneCall(String phoneNumber) async {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      } else {
        print('Could not launch $phoneUri');
      }
    }

    return BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
      builder: (context, state) {
        if (state is GetManagerDashboardSuccess && widget.stageName != null) {
          // نفلتر مرة واحدة فقط
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GetManagerLeadsCubit>().getManagerLeadsPagination(
              data: widget.data ?? false,
              stageIds: [widget.stageName ?? ''],
              ignoreDuplicate: widget.showDuplicatesOnly,
              salesIds: [widget.salesId ?? ''],
            );
          });
        }
        return Scaffold(
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            //   title: 'Leads',
            onBack: () {
              if (widget.data == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TabsScreenManager(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagerDashboardDataScreen(),
                  ),
                );
              }
            },
            extraActions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200.w,
                    child: TextField(
                      controller: nameController,
                      onChanged: (value) {
                        context
                            .read<GetManagerLeadsCubit>()
                            .getManagerLeadsPagination(
                              search: value.trim(),
                              data: widget.data ?? false,
                              stageIds: [widget.stageName ?? ''],
                              ignoreDuplicate: widget.showDuplicatesOnly,
                              salesIds: [widget.salesId ?? ''],
                            );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Color(0xff969696),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                //  height: 50.h,
                //width: 50.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1F2),
                  // border: Border.all(
                  //   color:
                  //       Theme.of(context).brightness == Brightness.light
                  //           ? Constants.maincolor
                  //           : Constants.mainDarkmodecolor,
                  // ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),
                  onPressed: () {
                    showFilterDialogManagerr(context, widget.data ?? false);
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              if (_showCheckboxes && _selectedLeads.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SafeArea(child: buildAssignButtons()),
                ),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state is GetManagerLeadsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetManagerCrmLeadsSuccess) {
                      final cubit = context.read<GetManagerLeadsCubit>();
                      final leads = cubit.allLeads;
                      if (leads.isEmpty) {
                        return const Center(child: Text('No leads found.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          final cubit = context.read<GetManagerLeadsCubit>();
                          // ✅ أول حاجة نرجع كل الداتا
                          await cubit.getManagerLeadsPagination(
                            data: widget.data ?? false,
                            stageIds: [widget.stageName ?? ''],
                            ignoreDuplicate: widget.showDuplicatesOnly,
                            salesIds: [widget.salesId ?? ''],
                          );
                          // ✅ بعدين نفلتر على نفس stageName زي BlocBuilder
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              leads.length +
                              (cubit.isFetchingMore
                                  ? 1
                                  : 0), // ✅ استخدم cubit مش _cubit
                          // ✅ زيادة 1 لو بنجلب
                          itemBuilder: (context, index) {
                            // ✅ عنصر التحميل في الآخر
                            if (index == leads.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final lead = leads[index];
                            final salesfcmtoken = lead.sales?.userlog?.fcmToken;
                            final leadassign = lead.assign;
                            print("assign of lead: ${lead.assign}");
                            final userlognamee = lead.sales?.userlog?.name;
                            final prefs = SharedPreferences.getInstance();
                            final fcmToken = prefs.then(
                              (prefs) => prefs.setString(
                                'fcm_token_sales',
                                salesfcmtoken ?? '',
                              ),
                            );
                            log("fcmToken of sales: $salesfcmtoken");
                            final leadstageupdated = lead.stagedateupdated;
                            final leadStagetype = lead.stage?.name ?? "";
                            // تحويل التاريخ من String إلى DateTime
                            DateTime? stageUpdatedDate;
                            if (leadstageupdated != null) {
                              try {
                                stageUpdatedDate = DateTime.parse(
                                  leadstageupdated,
                                );
                                log("stageUpdatedDate: $stageUpdatedDate");
                              } catch (_) {
                                stageUpdatedDate = null;
                              }
                            }
                            if (stageUpdatedDate != null) {
                              final now = DateTime.now().toUtc();
                              log("now: $now");
                              final difference =
                                  now.difference(stageUpdatedDate).inMinutes;
                              log("difference: $difference");
                              isOutdated =
                                  difference >
                                  1; // اعتبره قديم إذا مرّ أكثر من دقيقة
                              log("isOutdated: $isOutdated");
                            }
                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  _showCheckboxes = true;
                                  _selectedLeads.add(
                                    lead.id!,
                                  ); // أول كارت تعمل عليه Long Press بيتعلّم
                                  _selectedLeadStagesIds.add(
                                    lead.stage?.id ?? '',
                                  );
                                });
                              },
                              onTap: () async {
                                log("userlogmanagername: $userlognamee");
                                log("manager name: $managername");
                                log("leadassign: ${lead.assign}");
                                if (_showCheckboxes) {
                                  setState(() {
                                    if (_selectedLeads.contains(lead.id)) {
                                      _selectedLeads.remove(lead.id);
                                    } else {
                                      _selectedLeads.add(lead.id!);
                                    }
                                  });
                                }
                                final firstVersion =
                                    (lead.allVersions != null &&
                                            lead.allVersions!.isNotEmpty)
                                        ? lead.allVersions!.first
                                        : null;
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => BlocProvider(
                                          create:
                                              (_) => LeadCommentsCubit(
                                                GetAllLeadCommentsApiService(),
                                              ),
                                          child: LeadsDetailsScreenManager(
                                            leedId: lead.id!,
                                            leadName: lead.name ?? '',
                                            leadPhone: lead.phone ?? '',
                                            leadEmail: lead.email ?? '',
                                            leadStage: lead.stage?.name ?? '',
                                            leadStageId: lead.stage?.id ?? '',
                                            leadChannel:
                                                lead.chanel?.name ?? '',
                                            leadCreationDate:
                                                lead.createdAt != null
                                                    ? formatDateTimeToDubai(
                                                      lead.createdAt!,
                                                    )
                                                    : '',
                                            leadProject:
                                                lead.project?.name ?? '',
                                            leadLastComment:
                                                lead.lastcommentdate ?? '',
                                            leadcampaign:
                                                lead.campaign?.campainName ??
                                                "campaign",
                                            leaddeveloper:
                                                lead.project?.developer?.name ??
                                                "no developer",
                                            fcmtokenn: salesfcmtoken!,
                                            leadwhatsappnumber:
                                                lead.whatsappnumber,
                                            jobdescription:
                                                lead.jobdescription ??
                                                'no job description',
                                            secondphonenumber:
                                                lead.phonenumber2,
                                            laststageupdated: leadstageupdated,
                                            stageId: lead.stage?.id ?? '',
                                            sales: lead.sales?.name ?? '',
                                            leadLastDateAssigned:
                                                lead.lastdateassign,
                                          ),
                                        ),
                                  ),
                                );
                                context
                                    .read<GetManagerLeadsCubit>()
                                    .getManagerLeadsPagination(
                                      data: widget.data ?? false,
                                      stageIds: [widget.stageName ?? ''],
                                      ignoreDuplicate:
                                          widget.showDuplicatesOnly,
                                      salesIds: [widget.salesId ?? ''],
                                    );
                              },
                              child: Card(
                                color:
                                    _selectedLeads.contains(lead.id)
                                        ? (Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors
                                                .grey[300] // أغمق شوية لو Light Mode
                                            : Colors
                                                .grey[800]) // أغمق شوية لو Dark Mode
                                        : (Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.grey[900]),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ---------- Row 1: Name and Status Icon ----------
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // ✅ الجزء الشمال (Checkbox + Stage + SD Date)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    if (_showCheckboxes &&
                                                        _selectedLeads
                                                            .isNotEmpty)
                                                      Checkbox(
                                                        activeColor:
                                                            Constants.maincolor,
                                                        value: _selectedLeads
                                                            .contains(lead.id),
                                                        onChanged: (
                                                          bool? value,
                                                        ) {
                                                          setState(() {
                                                            if (value == true) {
                                                              _selectedLeads
                                                                  .add(
                                                                    lead.id!,
                                                                  );
                                                              _selectedSalesIds.add(
                                                                lead
                                                                        .sales
                                                                        ?.id ??
                                                                    '',
                                                              );
                                                              _selectedLeadStagesIds.add(
                                                                lead
                                                                        .stage
                                                                        ?.id ??
                                                                    '',
                                                              );
                                                            } else {
                                                              _selectedLeads
                                                                  .remove(
                                                                    lead.id,
                                                                  );
                                                              _selectedSalesIds
                                                                  .remove(
                                                                    lead.sales?.id ??
                                                                        '',
                                                                  );
                                                              _selectedLeadStagesIds
                                                                  .remove(
                                                                    lead.stage?.id ??
                                                                        '',
                                                                  );
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    // 👇 نتحقق من الشرط الخاص باللون
                                                    Builder(
                                                      builder: (_) {
                                                        final bool
                                                        isFinalStage =
                                                            stageUpdatedDate !=
                                                                null &&
                                                            (leadStagetype ==
                                                                    "Done Deal" ||
                                                                leadStagetype ==
                                                                    "Transfer" ||
                                                                leadStagetype ==
                                                                    "Fresh" ||
                                                                leadStagetype ==
                                                                    "Not Interested");
                                                        late final Color
                                                        stageColor;
                                                        if (leadStagetype ==
                                                            "Not Interested") {
                                                          stageColor =
                                                              Colors
                                                                  .black; // ✅ اللون الأسود
                                                        } else {
                                                          stageColor =
                                                              isFinalStage
                                                                  ? Constants
                                                                      .maincolor
                                                                  : isOutdated
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green;
                                                        }
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8.w,
                                                                vertical: 4.h,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: stageColor
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            border: Border.all(
                                                              color: stageColor,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20.r,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons.circle,
                                                                color:
                                                                    stageColor,
                                                                size: 10,
                                                              ),
                                                              SizedBox(
                                                                width: 6.w,
                                                              ),
                                                              Text(
                                                                lead
                                                                        .stage
                                                                        ?.name ??
                                                                    "No Stage",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      13.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      stageColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8.h),
                                                Text(
                                                  "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!) : "N/A"}",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.light
                                                            ? Colors.black87
                                                            : Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // ✅ الجزء اليمين (KSA | EVENT | Skyrise أو اسم المشروع)
                                            Expanded(
                                              child: Text(
                                                lead.project?.name ?? '',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      const Divider(height: 3, thickness: 1.5),
                                      SizedBox(height: 20.h),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                lead.name ?? "No Name",
                                                style: TextStyle(
                                                  fontSize: 19.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12.h),

                                      // ---------- Row 2: Sales Person ----------
                                      InkWell(
                                        onTap: () {
                                          final phone = lead.phone ?? '';
                                          final formattedPhone =
                                              phone.startsWith('0')
                                                  ? phone
                                                  : '+$phone';
                                          makePhoneCall(formattedPhone);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? Colors.grey
                                                        : Constants
                                                            .mainDarkmodecolor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  lead.phone ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 35.h),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.person_pin_outlined,
                                                  color:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.light
                                                          ? Colors.grey
                                                          : Constants
                                                              .mainDarkmodecolor,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8.w),
                                                // 👈 الجزء الشمال (Sales name)
                                                Expanded(
                                                  child: Text(
                                                    lead.sales?.name ?? "none",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),

                                                // 👉 الجزء اليمين (الـ 3 أيقونات داخل خلفية)
                                                Row(
                                                  children: [
                                                    // 📞 Phone Call
                                                    InkWell(
                                                      onTap: () {
                                                        final phone =
                                                            lead.phone ?? '';
                                                        final formattedPhone =
                                                            phone.startsWith(
                                                                  '0',
                                                                )
                                                                ? phone
                                                                : '+$phone';
                                                        makePhoneCall(
                                                          formattedPhone,
                                                        );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Constants
                                                                      .maincolor,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
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
                                                            (lead.phone?.isNotEmpty ==
                                                                        true
                                                                    ? lead.phone
                                                                    : lead
                                                                        .whatsappnumber)
                                                                ?.replaceAll(
                                                                  RegExp(r'\D'),
                                                                  '',
                                                                ) ??
                                                            '';
                                                        final formattedPhone =
                                                            rawPhone.startsWith(
                                                                  '0',
                                                                )
                                                                ? rawPhone
                                                                : '+$rawPhone';

                                                        final url =
                                                            "https://wa.me/$formattedPhone";
                                                        try {
                                                          await launchUrl(
                                                            Uri.parse(url),
                                                            mode:
                                                                LaunchMode
                                                                    .externalApplication,
                                                          );
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Could not open WhatsApp.",
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Constants
                                                                      .maincolor,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: const FaIcon(
                                                          FontAwesomeIcons
                                                              .whatsapp,
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
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: BlocProvider(
                                                                create:
                                                                    (
                                                                      _,
                                                                    ) => LeadCommentsCubit(
                                                                      GetAllLeadCommentsApiService(),
                                                                    )..fetchLeadComments(
                                                                      lead.id!,
                                                                    ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        16.0,
                                                                      ),
                                                                  child: BlocBuilder<
                                                                    LeadCommentsCubit,
                                                                    LeadCommentsState
                                                                  >(
                                                                    builder: (
                                                                      context,
                                                                      commentState,
                                                                    ) {
                                                                      if (commentState
                                                                          is LeadCommentsLoading) {
                                                                        return const CommentShimmer();
                                                                      } else if (commentState
                                                                          is LeadCommentsError) {
                                                                        return SizedBox(
                                                                          height:
                                                                              100,
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
                                                                        if (commentsData ==
                                                                                null ||
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
                                                                                  (
                                                                                    c,
                                                                                  ) =>
                                                                                      (c.firstcomment?.text?.isNotEmpty ??
                                                                                          false) ||
                                                                                      (c.secondcomment?.text?.isNotEmpty ??
                                                                                          false),
                                                                                )
                                                                                .toList();

                                                                        final Comment?
                                                                        firstCommentEntry =
                                                                            validComments.isNotEmpty
                                                                                ? validComments.first
                                                                                : null;

                                                                        final String
                                                                        firstCommentText =
                                                                            firstCommentEntry?.firstcomment?.text ??
                                                                            'No comments available.';
                                                                        final String
                                                                        secondCommentText =
                                                                            firstCommentEntry?.secondcomment?.text ??
                                                                            'No action available.';

                                                                        return Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const Text(
                                                                              "Last Comment",
                                                                              style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height:
                                                                                  5,
                                                                            ),
                                                                            Text(
                                                                              firstCommentText,
                                                                              maxLines:
                                                                                  2,
                                                                              overflow:
                                                                                  TextOverflow.ellipsis,
                                                                            ),
                                                                            const SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),
                                                                            const Text(
                                                                              "Action (Plan)",
                                                                              style: TextStyle(
                                                                                color:
                                                                                    Constants.maincolor,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height:
                                                                                  5,
                                                                            ),
                                                                            Text(
                                                                              secondCommentText,
                                                                              maxLines:
                                                                                  2,
                                                                              overflow:
                                                                                  TextOverflow.ellipsis,
                                                                            ),
                                                                          ],
                                                                        );
                                                                      } else {
                                                                        return const SizedBox(
                                                                          height:
                                                                              100,
                                                                          child: Text(
                                                                            "No comments",
                                                                          ),
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Constants
                                                                      .maincolor,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons
                                                              .chat_bubble_outline,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          // ✅ CD Date (السطر اللي تحت)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.light
                                                          ? Colors.grey
                                                          : Constants
                                                              .mainDarkmodecolor,
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (state is GetManagerLeadsFailure) {
                      return Center(child: Text(' ${state.message}'));
                    } else {
                      return const Center(child: Text('No leads found.'));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 8),
          Text("$title : ", style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
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
    )..repeat(); // No reverse — smoother loop

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

class _ActionIcon extends StatelessWidget {
  final Widget icon;
  const _ActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
      child: IconTheme(
        data: IconThemeData(
          size: 22,
          color: isDark ? Colors.white : Constants.maincolor,
        ),
        child: icon,
      ),
    );
  }
}

class CommentShimmer extends StatelessWidget {
  const CommentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 14, width: 120, color: Colors.white),
            const SizedBox(height: 10),
            Container(height: 12, width: double.infinity, color: Colors.white),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.white,
            ),
            const SizedBox(height: 15),
            Container(height: 14, width: 100, color: Colors.white),
            const SizedBox(height: 10),
            Container(height: 12, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
