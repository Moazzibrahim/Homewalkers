// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, library_private_types_in_public_api
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/presentation/screens/manager/leads_details_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/manager/tabs_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/manager/manager_custom_filter_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManagerLeadsScreen extends StatefulWidget {
  final String? stageName;
  const ManagerLeadsScreen({super.key, this.stageName});

  @override
  State<ManagerLeadsScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<ManagerLeadsScreen> {
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  String? managername;
  String? managerid;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkClearHistoryTime();
    checkIsClearHistory();
    init();
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
    String formatDateTime(String dateStr) {
      try {
        final dateTime = DateTime.parse(dateStr);
        final day = dateTime.day.toString().padLeft(2, '0');
        final month = dateTime.month.toString().padLeft(2, '0');
        final year = dateTime.year;
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return '$day/$month/$year - $hour:$minute';
      } catch (e) {
        return dateStr; // fallback في حال كان التاريخ مش صحيح
      }
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

    return BlocBuilder<GetManagerLeadsCubit, GetManagerLeadsState>(
      builder: (context, state) {
        if (state is GetManagerLeadsSuccess && widget.stageName != null) {
          // نفلتر مرة واحدة فقط
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GetManagerLeadsCubit>().filterLeadsByStageInManager(
              widget.stageName!,
            );
          });
        }
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
                MaterialPageRoute(builder: (context) => TabsScreenManager()),
              );
            },
          ),
          body: Column(
            children: [
              // Search & filter
              Container(
                decoration: BoxDecoration(
                  // color:
                  //     Theme.of(context).brightness == Brightness.light
                  //         ? Colors.white
                  //         : Constants.backgroundDarkmode,
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
                          context
                              .read<GetManagerLeadsCubit>()
                              .filterLeadsManager(query: value.trim());
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
                          showFilterDialogManager(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Create Lead Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
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
              // Leads List Based on State
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state is GetManagerLeadsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetManagerLeadsSuccess) {
                      final leads = state.leads.data;
                      if (leads!.isEmpty) {
                        return const Center(child: Text('No leads found.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<GetManagerLeadsCubit>()
                              .getLeadsByManager();
                        },
                        child: ListView.builder(
                          itemCount: leads.length,
                          itemBuilder: (context, index) {
                            final lead = leads[index];
                            final salesfcmtoken =
                                lead.sales?.userlog?.fcmtokenn;
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
                            return InkWell(
                              onTap: () async {
                                log("userlogmanagername: $userlognamee");
                                log("manager name: $managername");
                                log("leadassign: ${lead.assign}");
                                if (lead.assign == false) {
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
                                                      ? formatDateTime(
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
                                              fcmtokenn: salesfcmtoken!,
                                              leadwhatsappnumber:
                                                  lead.whatsappnumber,
                                              jobdescription:
                                                  lead.jobdescription ??
                                                  'no job description',
                                              secondphonenumber:
                                                  lead.secondphonenumber,
                                            ),
                                          ),
                                    ),
                                  );
                                  context
                                      .read<GetManagerLeadsCubit>()
                                      .getLeadsByManager();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text("Attention"),
                                          content: const Text(
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
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: const Text(
                                                "OK",
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lead.name ?? "No Name",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (lead.assign == true &&
                                              userlognamee == managername)
                                            InkWell(
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
                                                                content: const Text(
                                                                  "Are you sure to receive this lead?",
                                                                ),
                                                                actions: [
                                                                  // Cancel button
                                                                  TextButton(
                                                                    style: TextButton.styleFrom(
                                                                      backgroundColor:
                                                                          Theme.of(context).brightness ==
                                                                                  Brightness.light
                                                                              ? Constants.maincolor
                                                                              : Constants.mainDarkmodecolor,
                                                                    ),
                                                                    onPressed:
                                                                        () =>
                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop(),
                                                                    child: const Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  // OK button
                                                                  TextButton(
                                                                    style: TextButton.styleFrom(
                                                                      backgroundColor:
                                                                          Theme.of(context).brightness ==
                                                                                  Brightness.light
                                                                              ? Constants.maincolor
                                                                              : Constants.mainDarkmodecolor,
                                                                    ),
                                                                    onPressed:
                                                                        isLoading
                                                                            ? null
                                                                            : () async {
                                                                              setState(
                                                                                () {
                                                                                  isLoading =
                                                                                      true;
                                                                                },
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

                                                                                if (context.mounted) {
                                                                                  Navigator.of(
                                                                                    innerContext,
                                                                                  ).pop(); // Close dialog
                                                                                  innerContext
                                                                                      .read<
                                                                                        GetManagerLeadsCubit
                                                                                      >()
                                                                                      .getLeadsByManager(); // Refresh data
                                                                                }
                                                                              } finally {
                                                                                if (context.mounted) {
                                                                                  setState(
                                                                                    () {
                                                                                      isLoading =
                                                                                          false;
                                                                                    },
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
                                                radius: 18,
                                                backgroundColor:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? Colors.grey
                                                        : Constants
                                                            .mainDarkmodecolor,
                                                child: const Icon(
                                                  Icons.download,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          (stageUpdatedDate != null &&
                                                  (leadStagetype ==
                                                          "Done Deal" ||
                                                      leadStagetype ==
                                                          "Transfer" ||
                                                      leadStagetype ==
                                                          "Fresh" ||
                                                      leadStagetype ==
                                                          "Not Interested"))
                                              ? const SizedBox()
                                              : Icon(
                                                isOutdated
                                                    ? Icons.cancel
                                                    : Icons.check_circle,
                                                color:
                                                    isOutdated
                                                        ? Colors.red
                                                        : Colors.green,
                                                size: 24,
                                              ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),

                                      // ---------- Row 2: Sales Person ----------
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_pin_outlined,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.grey
                                                    : Constants
                                                        .mainDarkmodecolor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              lead.sales?.name ?? "No Sales",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.date_range,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            lead.createdAt != null
                                                ? formatDateTime(
                                                  lead.createdAt!,
                                                )
                                                : "N/A",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      // ---------- Row 4: WhatsApp and Phone Call ----------
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                final phone = lead
                                                    .whatsappnumber
                                                    ?.replaceAll(
                                                      RegExp(r'\D'),
                                                      '',
                                                    );
                                                final url =
                                                    "https://wa.me/$phone";
                                                if (await canLaunchUrl(
                                                  Uri.parse(url),
                                                )) {
                                                  await launchUrl(
                                                    Uri.parse(url),
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                } else {
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
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.whatsapp,
                                                    color:
                                                        Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.light
                                                            ? Colors.grey
                                                            : Constants
                                                                .mainDarkmodecolor,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    lead
                                                                .whatsappnumber
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? lead.whatsappnumber!
                                                        : 'no whatsapp number',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap:
                                                  () => makePhoneCall(
                                                    lead.phone ?? '',
                                                  ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
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
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    lead.phone ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              getStatusIcon(
                                                lead.stage?.name ?? "",
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                lead.stage?.name ?? "none",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.light
                                                          ? Constants.maincolor
                                                          : Constants
                                                              .mainDarkmodecolor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                ),
                                                onPressed: () {
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
                                                                state,
                                                              ) {
                                                                if (state
                                                                    is LeadCommentsLoading) {
                                                                  return const SizedBox(
                                                                    height: 100,
                                                                    child: Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                  );
                                                                } else if (state
                                                                    is LeadCommentsError) {
                                                                  return SizedBox(
                                                                    height: 100,
                                                                    child: Center(
                                                                      child: Text(
                                                                        "No comments available.",
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if (state
                                                                    is LeadCommentsLoaded) {
                                                                  final data =
                                                                      state
                                                                          .leadComments
                                                                          .data;
                                                                  if (data ==
                                                                          null ||
                                                                      data.isEmpty) {
                                                                    return const Text(
                                                                      'No comments available.',
                                                                    );
                                                                  }
                                                                  final firstItem =
                                                                      data.first;
                                                                  final firstComment =
                                                                      firstItem
                                                                          .comments
                                                                          ?.first;
                                                                  final firstcommentdate =
                                                                      DateTime.tryParse(
                                                                        firstComment?.firstcomment?.date.toString() ??
                                                                            "",
                                                                      )?.toUtc();
                                                                  final secondcommentdate =
                                                                      DateTime.tryParse(
                                                                        firstComment?.secondcomment?.date.toString() ??
                                                                            "",
                                                                      )?.toUtc();
                                                                  final isFirstValid =
                                                                      isClearHistoryy !=
                                                                          true ||
                                                                      (firstcommentdate !=
                                                                              null &&
                                                                          firstcommentdate.isAfter(
                                                                            clearHistoryTimee!,
                                                                          ));
                                                                  final isSecondValid =
                                                                      isClearHistoryy !=
                                                                          true ||
                                                                      (secondcommentdate !=
                                                                              null &&
                                                                          secondcommentdate.isAfter(
                                                                            clearHistoryTimee!,
                                                                          ));
                                                                  if ((isFirstValid &&
                                                                      firstComment
                                                                              ?.firstcomment
                                                                              ?.text !=
                                                                          null)) {
                                                                    return Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Text(
                                                                          "Last Comment",
                                                                          style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10.h,
                                                                        ),
                                                                        const Text(
                                                                          "Comment",
                                                                          style: TextStyle(
                                                                            color:
                                                                                Constants.maincolor,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5.h,
                                                                        ),
                                                                        Text(
                                                                          firstComment?.firstcomment?.text ??
                                                                              'No comment available.',
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10.h,
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
                                                                          firstComment?.secondcomment?.text ??
                                                                              'No comment available.',
                                                                        ),
                                                                      ],
                                                                    );
                                                                  } else {
                                                                    return const SizedBox(
                                                                      child: Text(
                                                                        "no comments",
                                                                      ),
                                                                    );
                                                                  }
                                                                } else {
                                                                  return const SizedBox(
                                                                    height: 100,
                                                                    child: Text(
                                                                      "no comments",
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
                                                icon: const Icon(
                                                  Icons.chat_bubble_outline,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                label: const Text(
                                                  "Last Comment",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.date_range_outlined,
                                              color: Colors.grey,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              lead.lastStageDateUpdated != null
                                                  ? formatDateTime(
                                                    lead.lastStageDateUpdated!,
                                                  )
                                                  : "N/A",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ---------- Row 6: View More Link ----------
                                      SizedBox(height: 8.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (lead.assign == true) ...[
                                            const DotLoading(),
                                            const Spacer(),
                                          ],
                                          if (lead.assign == true &&
                                              userlognamee == managername) ...[
                                            DotLoading(),
                                            Spacer(),
                                            const SizedBox(width: 10),
                                          ],
                                          InkWell(
                                            onTap: () async {
                                              log(
                                                "userlogmanagername: $userlognamee",
                                              );
                                              log("manager name: $managername");
                                              log("leadassign: ${lead.assign}");
                                              if (lead.assign == false) {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) => BlocProvider(
                                                          create:
                                                              (
                                                                _,
                                                              ) => LeadCommentsCubit(
                                                                GetAllLeadCommentsApiService(),
                                                              ),
                                                          child: LeadsDetailsScreenManager(
                                                            leedId: lead.id!,
                                                            leadName:
                                                                lead.name ?? '',
                                                            leadPhone:
                                                                lead.phone ??
                                                                '',
                                                            leadEmail:
                                                                lead.email ??
                                                                '',
                                                            leadStage:
                                                                lead
                                                                    .stage
                                                                    ?.name ??
                                                                '',
                                                            leadStageId:
                                                                lead
                                                                    .stage
                                                                    ?.id ??
                                                                '',
                                                            leadChannel:
                                                                lead
                                                                    .chanel
                                                                    ?.name ??
                                                                '',
                                                            leadCreationDate:
                                                                lead.createdAt !=
                                                                        null
                                                                    ? formatDateTime(
                                                                      lead.createdAt!,
                                                                    )
                                                                    : '',
                                                            leadProject:
                                                                lead
                                                                    .project
                                                                    ?.name ??
                                                                '',
                                                            leadLastComment:
                                                                lead.lastcommentdate ??
                                                                '',
                                                            leadcampaign:
                                                                lead
                                                                    .campaign
                                                                    ?.name ??
                                                                "campaign",
                                                            leadNotes:
                                                                lead.notes ??
                                                                "no notes",
                                                            leaddeveloper:
                                                                lead
                                                                    .project
                                                                    ?.developer
                                                                    ?.name ??
                                                                "no developer",
                                                            fcmtokenn:
                                                                salesfcmtoken!,
                                                            leadwhatsappnumber:
                                                                lead.whatsappnumber,
                                                            jobdescription:
                                                                lead.jobdescription ??
                                                                'no job description',
                                                            secondphonenumber:
                                                                lead.secondphonenumber,
                                                          ),
                                                        ),
                                                  ),
                                                );
                                                context
                                                    .read<
                                                      GetManagerLeadsCubit
                                                    >()
                                                    .getLeadsByManager();
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => AlertDialog(
                                                        title: const Text(
                                                          "Attention",
                                                        ),
                                                        content: const Text(
                                                          "You must receive this lead first.",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              backgroundColor:
                                                                  Theme.of(
                                                                            context,
                                                                          ).brightness ==
                                                                          Brightness
                                                                              .light
                                                                      ? Constants
                                                                          .maincolor
                                                                      : Constants
                                                                          .mainDarkmodecolor,
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(),
                                                            child: const Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              'View More',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? Colors.grey
                                                        : Colors.white,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
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
