// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, library_private_types_in_public_api, unused_field
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_filter_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/edit_lead_sales_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SalesLeadsScreen extends StatefulWidget {
  final String? stageName;
  const SalesLeadsScreen({super.key, this.stageName});

  @override
  State<SalesLeadsScreen> createState() => _SalesLeadsScreenState();
}

class _SalesLeadsScreenState extends State<SalesLeadsScreen> {
  bool _showCheckboxes = false; // هل تظهر checkboxes على الـ cards
  String? _selectedLeadId;
  LeadData? _selectedLead;
  // late ScrollController _scrollController;
  final int _currentPage = 1;
  final bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // _scrollController =
    //     ScrollController()..addListener(() {
    //       if (_scrollController.position.pixels >=
    //           _scrollController.position.maxScrollExtent - 200) {
    //         _loadMore();
    //       }
    //     });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1) تحميل كل الداتا
      await _initializeData();

      // 2) بعد ما كل حاجة تخلص نطبق الفلترة مرة واحدة فقط
      if (widget.stageName != null) {
        context.read<GetLeadsCubit>().filterLeadsByStageName(widget.stageName!);
      }
    });
  }

  Future<void> _initializeData() async {
    final cubit = context.read<GetLeadsCubit>();

    // تحميل الصفحة الأولى
    await cubit.fetchLeads();

    // تحميل مبيعات
    context.read<SalesCubit>().fetchAllSales();
  }

  // void _loadMore() async {
  //   if (_isLoadingMore) return;

  //   _isLoadingMore = true;
  //   await context.read<GetLeadsCubit>().fetchLeads(loadMore: true);
  //   _isLoadingMore = false;
  // }

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

    void makePhoneCall(String phoneNumber) async {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      } else {
        print('Could not launch $phoneUri');
      }
    }

    return BlocBuilder<GetLeadsCubit, GetLeadsState>(
      builder: (context, state) {
        // if (state is GetLeadsSuccess && widget.stageName != null) {
        //   // نفلتر مرة واحدة فقط
        //   context.read<GetLeadsCubit>().filterLeadsByStageName(
        //     widget.stageName!,
        //     useAllLeads: true,
        //   );
        // }
        return Scaffold(
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            title: 'Leads',
            onBack: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SalesTabsScreen()),
              );
            },
          ),
          body: Column(
            children: [
              // Search & filter
              Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Constants.backgroundDarkmode,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        onChanged: (value) {
                          final cubit = context.read<GetLeadsCubit>();
                          cubit.filterLeads(
                            query: value.trim(), // استخدم allLeads لو جاهزة
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: GoogleFonts.montserrat(
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
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
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
                    const SizedBox(width: 10),
                    Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1F2),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
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
                          showFilterDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Create Lead Button
              Row(
                children: [
                  // زر Edit يظهر فقط لما _showCheckboxes true
                  if (_showCheckboxes)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          log("_selectedLead ID: ${_selectedLead?.id}");
                          if (_selectedLead != null) {
                            final result = await showDialog(
                              context: context,
                              builder:
                                  (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create:
                                            (_) => EditLeadCubit(
                                              EditLeadApiService(),
                                            ),
                                      ),
                                      BlocProvider(
                                        create:
                                            (_) => ProjectsCubit(
                                              ProjectsApiService(),
                                            )..fetchProjects(),
                                      ),
                                      BlocProvider(
                                        create:
                                            (_) => SalesCubit(
                                              GetAllSalesApiService(),
                                            )..fetchAllSales(),
                                      ),
                                    ],
                                    child: EditLeadSalesDialog(
                                      userId: _selectedLead!.id ?? '',
                                      initialName: _selectedLead!.name ?? '',
                                      initialPhone2:
                                          _selectedLead!.secondphonenumber ??
                                          '',
                                      initialWhatsappNumber:
                                          _selectedLead!.whatsappnumber ?? '',
                                      initialNotes: _selectedLead!.notes ?? '',
                                      initialProjectId:
                                          _selectedLead!.project?.id,
                                      salesID: _selectedLead!.sales?.id ?? '',
                                      onSuccess: () {
                                        context
                                            .read<GetLeadsCubit>()
                                            .fetchLeads();
                                      },
                                    ),
                                  ),
                            );

                            if (result == true) {
                              context.read<GetLeadsCubit>().fetchLeads();
                            }
                          }
                        },

                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  // زر Create Lead
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateLeadScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Create Lead',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Leads List Based on State
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state is GetLeadsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetLeadsSuccess) {
                      final leads = state.assignedModel.data;
                      if (leads!.isEmpty) {
                        return const Center(child: Text('No leads found.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          final cubit = context.read<GetLeadsCubit>();
                          // 1) تحميل أول صفحة
                          await cubit.fetchLeads();
                          // 3) تطبيق الفلترة زي initState تماماً
                          if (widget.stageName != null &&
                              widget.stageName!.isNotEmpty) {
                            cubit.filterLeadsByStageName(widget.stageName!);
                          }
                        },

                        child: ListView.builder(
                          //   controller: _scrollController, // ← إضافة مهمة
                          itemCount: leads.length,
                          itemBuilder: (context, index) {
                            final lead = leads[index];
                            final salesfcmtoken =
                                lead.sales?.teamleader?.fcmtokenn;
                            final leadassign = lead.assign;
                            log("lead assign value: $leadassign");
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
                              isOutdated =
                                  difference >
                                  1; // اعتبره قديم إذا مرّ أكثر من دقيقة
                              print("isOutdated: $isOutdated");
                            }
                            return InkWell(
                              onLongPress: () {
                                setState(() {
                                  _showCheckboxes = true;
                                  _selectedLead =
                                      lead; // خزن الـ lead اللي اتضغط عليه
                                  _selectedLeadId =
                                      lead.id; // لو محتاج بس الـ id
                                });
                              },

                              onTap: () async {
                                if (leadassign == false) {
                                  // Navigate to details screen
                                  final updatedStageName = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => BlocProvider(
                                            create:
                                                (_) => LeadCommentsCubit(
                                                  GetAllLeadCommentsApiService(),
                                                ),
                                            child: SalesLeadsDetailsScreen(
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
                                                  lead.campaign?.name ??
                                                  "campaign",
                                              leadNotes:
                                                  lead.notes ?? "no notes",
                                              leaddeveloper:
                                                  lead
                                                      .project
                                                      ?.developer
                                                      ?.name ??
                                                  "no developer",
                                              fcmtoken: salesfcmtoken,
                                              managerfcmtoken:
                                                  lead
                                                      .sales
                                                      ?.manager
                                                      ?.fcmtokenn,
                                              teamleaderfcmtoken:
                                                  lead
                                                      .sales
                                                      ?.teamleader
                                                      ?.fcmtokenn,
                                              leadwhatsappnumber:
                                                  lead.whatsappnumber ??
                                                  'no whatsapp number',
                                              jobdescription:
                                                  lead.jobdescription ??
                                                  'no job description',
                                              secondphonenumber:
                                                  lead.secondphonenumber ??
                                                  'no second phone number',
                                              laststageupdated:
                                                  lead.stagedateupdated,
                                              stageId: lead.stage?.id,
                                            ),
                                          ),
                                    ),
                                  );
                                  final cubit = context.read<GetLeadsCubit>();

                                  // 1) إعادة تحميل البيانات بالكامل أولاً
                                  await cubit.fetchLeads();

                                  // 2) تطبيق الفلترة لو stageName موجودة وغير فاضية
                                  if (widget.stageName != null &&
                                      widget.stageName!.isNotEmpty) {
                                    cubit.filterLeadsByStageName(
                                      widget.stageName!,
                                    );
                                  }
                                  // context.read<GetLeadsCubit>().fetchLeads(
                                  //   showLoading: false,
                                  // );
                                } else {
                                  // Show popup alert
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Attention"),
                                        content: Text(
                                          "You must receive this lead first.",
                                        ),
                                        actions: [
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
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: Text(
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
                                }
                              },
                              child: Card(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.grey[900],
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
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
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// 🟦 الجزء الخاص بالستيج والتاريخ
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Builder(
                                                    builder: (_) {
                                                      final bool isFinalStage =
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

                                                      final Color stageColor =
                                                          isFinalStage
                                                              ? Constants
                                                                  .maincolor
                                                              : isOutdated
                                                              ? Colors.red
                                                              : Colors.green;

                                                      return Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 10.w,
                                                              vertical: 5.h,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: stageColor
                                                              .withOpacity(0.1),
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
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.circle,
                                                              color: stageColor,
                                                              size: 10,
                                                            ),
                                                            SizedBox(
                                                              width: 6.w,
                                                            ),
                                                            Text(
                                                              lead
                                                                      .stage
                                                                      ?.name ??
                                                                  "Unknown",
                                                              style: GoogleFonts.montserrat(
                                                                fontSize: 13.sp,
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
                                                  SizedBox(height: 8.h),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 4.w,
                                                    ),
                                                    child: Text(
                                                      "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!) : "N/A"}",
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Theme.of(
                                                                      context,
                                                                    ).brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors.black87
                                                                : Colors
                                                                    .white70,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (_showCheckboxes)
                                                Checkbox(
                                                  value:
                                                      _selectedLeadId ==
                                                      lead.id,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (val == true) {
                                                        _selectedLeadId =
                                                            lead.id; // اختار lead واحد فقط
                                                      } else {
                                                        _selectedLeadId = null;
                                                        _showCheckboxes =
                                                            false; // اختفى إذا لم يتبقى أي اختيار
                                                      }
                                                    });
                                                  },
                                                ),
                                              // SizedBox(width: 10.w),
                                              /// 🟨 زرار التحميل
                                              if (leadassign == true)
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider(
                                                              create:
                                                                  (
                                                                    _,
                                                                  ) => EditLeadCubit(
                                                                    EditLeadApiService(),
                                                                  ),
                                                            ),
                                                          ],
                                                          child: Builder(
                                                            builder: (
                                                              innerContext,
                                                            ) {
                                                              bool isLoading =
                                                                  false;
                                                              return StatefulBuilder(
                                                                builder: (
                                                                  context,
                                                                  setState,
                                                                ) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                      "Confirmation",
                                                                    ),
                                                                    content:
                                                                        const Text(
                                                                          "Are you sure to receive this lead?",
                                                                        ),
                                                                    actions: [
                                                                      TextButton(
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor:
                                                                              Constants.maincolor,
                                                                        ),
                                                                        onPressed:
                                                                            () => Navigator.pop(
                                                                              context,
                                                                            ),
                                                                        child: const Text(
                                                                          "Cancel",
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor:
                                                                              Constants.maincolor,
                                                                        ),
                                                                        onPressed:
                                                                            isLoading
                                                                                ? null
                                                                                : () async {
                                                                                  setState(
                                                                                    () =>
                                                                                        isLoading =
                                                                                            true,
                                                                                  );

                                                                                  try {
                                                                                    await innerContext
                                                                                        .read<
                                                                                          EditLeadCubit
                                                                                        >()
                                                                                        .editLeadAssignvalue(
                                                                                          userId:
                                                                                              lead.id!,
                                                                                          assign:
                                                                                              false,
                                                                                        );

                                                                                    if (!context.mounted) return;

                                                                                    Navigator.pop(
                                                                                      innerContext,
                                                                                    );

                                                                                    final cubit =
                                                                                        innerContext
                                                                                            .read<
                                                                                              GetLeadsCubit
                                                                                            >();

                                                                                    // 1) إعادة تحميل البيانات بالكامل أولاً
                                                                                    await cubit.fetchLeads();

                                                                                    // 2) تطبيق الفلترة لو stageName موجودة وغير فاضية
                                                                                    if (widget.stageName !=
                                                                                            null &&
                                                                                        widget.stageName!.isNotEmpty) {
                                                                                      cubit.filterLeadsByStageName(
                                                                                        widget.stageName!,
                                                                                      );
                                                                                    }
                                                                                  } finally {
                                                                                    if (context.mounted) {
                                                                                      setState(
                                                                                        () =>
                                                                                            isLoading =
                                                                                                false,
                                                                                      );
                                                                                    }
                                                                                  }
                                                                                },
                                                                        child:
                                                                            isLoading
                                                                                ? const SizedBox(
                                                                                  height:
                                                                                      20,
                                                                                  width:
                                                                                      20,
                                                                                  child: CircularProgressIndicator(
                                                                                    strokeWidth:
                                                                                        2,
                                                                                    color:
                                                                                        Colors.white,
                                                                                  ),
                                                                                )
                                                                                : const Text(
                                                                                  "OK",
                                                                                  style: TextStyle(
                                                                                    color:
                                                                                        Colors.white,
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
                                                    radius: 20,
                                                    backgroundColor: Constants
                                                        .maincolor
                                                        .withOpacity(0.15),
                                                    child: Icon(
                                                      Icons.download,
                                                      color:
                                                          Constants.maincolor,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 5.h),
                                          if (leadassign == true)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [DotLoading()],
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      const Divider(thickness: 1.5),
                                      SizedBox(height: 20.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lead.name ?? "No Name",
                                              style: GoogleFonts.montserrat(
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
                                      // ---------- Row 2: phone | Person ----------
                                      InkWell(
                                        onTap: () {
                                          final phone = lead.phone ?? '';
                                          final formattedPhone =
                                              phone.startsWith('0')
                                                  ? phone
                                                  : '+$phone';
                                          makePhoneCall(formattedPhone);
                                        },
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
                                      SizedBox(height: 35.h),
                                      // ---------- Row 2: Sales Person ----------
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
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
                                                          phone.startsWith('0')
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
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.maincolor,
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
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.maincolor,
                                                        shape: BoxShape.circle,
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
                                                                      return const SizedBox(
                                                                        height:
                                                                            100,
                                                                        child: Center(
                                                                          child:
                                                                              CircularProgressIndicator(),
                                                                        ),
                                                                      );
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
                                                                          commentState
                                                                              .leadComments
                                                                              .data;
                                                                      if (commentsData ==
                                                                              null ||
                                                                          commentsData
                                                                              .isEmpty) {
                                                                        return const Text(
                                                                          'No comments available.',
                                                                        );
                                                                      }

                                                                      final commentsList =
                                                                          commentsData
                                                                              .first
                                                                              .comments ??
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
                                                                          firstCommentEntry
                                                                              ?.firstcomment
                                                                              ?.text ??
                                                                          'No comments available.';
                                                                      final String
                                                                      secondCommentText =
                                                                          firstCommentEntry
                                                                              ?.secondcomment
                                                                              ?.text ??
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
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.maincolor,
                                                        shape: BoxShape.circle,
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
                                          SizedBox(height: 4.h),
                                          // ✅ CD Date (السطر اللي تحت)
                                          Row(
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
                    } else if (state is GetLeadsError) {
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
