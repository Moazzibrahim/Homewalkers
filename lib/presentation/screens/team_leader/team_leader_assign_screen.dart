// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_local_variable
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/leads_details_team_leader_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/custom_assign_dialog_team_leader_widget.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/custom_filter_teamleader_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // isOutdated is a state variable and should be managed per lead, not globally.
  // We will calculate it inside the buildUserTile or pass it from itemBuilder.

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = GetLeadsTeamLeaderCubit(GetLeadsService());
        cubit.getLeadsByTeamLeader().then((_) {
          if (widget.stageName != null && widget.stageName!.isNotEmpty) {
            cubit.filterLeadsByStage(widget.stageName!);
          }
        });
        return cubit;
      },
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
                    builder: (context) => TeamLeaderTabsScreen(),
                  ),
                );
              },
            ),
            body: Column(
              children: [
                BlocBuilder<GetLeadsTeamLeaderCubit, GetLeadsTeamLeaderState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                context
                                    .read<GetLeadsTeamLeaderCubit>()
                                    .filterLeadsByName(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search',
                                contentPadding: EdgeInsets.symmetric(
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
                          SizedBox(width: 10),
                          GestureDetector(
                            onTapDown:
                                (details) => _showAssignMenu(
                                  context,
                                  details.globalPosition,
                                ),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.maincolor
                                          : Constants.mainDarkmodecolor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.more_vert,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                              ),
                            ),
                          ),
                        ],
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
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetLeadsTeamLeaderSuccess) {
                        _leads = state.leadsData.data ?? [];

                        // تأكد من مزامنة selected مع طول البيانات
                        if (selected.length != _leads.length) {
                          selected = List.generate(
                            _leads.length,
                            (index) => false,
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<GetLeadsTeamLeaderCubit>()
                                .getLeadsByTeamLeader();
                          },
                          child: ListView.builder(
                            itemCount: _leads.length,
                            itemBuilder: (context, index) {
                              final lead = _leads[index];
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
                              final leadstageupdated = lead.stagedateupdated;
                              final leadStagetype = lead.stage?.name ?? "";
                              DateTime? stageUpdatedDate;
                              bool isOutdatedLocal =
                                  false; // Local variable for each lead

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
                                isOutdatedLocal =
                                    difference >
                                    1; // اعتبره قديم إذا مرّ أكثر من دقيقة
                                print("isOutdated: $isOutdatedLocal");
                              }
                              return buildUserTile(
                                name: lead.name ?? 'No Name',
                                status: lead.stage?.name ?? 'No Status',
                                index: index,
                                id: lead.id.toString(),
                                phone: lead.phone ?? 'No Phone',
                                email: lead.email ?? 'No Email',
                                stage: lead.stage?.name ?? 'No Stage',
                                stageid:
                                    lead.stage?.id.toString() ?? 'No Stage ID',
                                channel: lead.chanel?.name ?? 'No Channel',
                                creationdate:
                                    lead.createdAt != null
                                        ? formatDateTime(lead.createdAt!)
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
                                stageUpdatedDate:
                                    stageUpdatedDate, // Pass the DateTime object
                                leadStagetype:
                                    leadStagetype, // Pass the stage type string
                                isOutdated: isOutdatedLocal,
                                fcmtoken:
                                    salesfcmtoken!, // Pass the calculated boolean
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
    final selectedIndices =
        selected
            .asMap()
            .entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" please select at least one lead")),
      );
      return;
    }

    final selectedLeads = selectedIndices.map((i) => _leads[i]).toList();
    log(
      "Selected Leads: ${selectedLeads.map((e) => 'ID: ${e.id}, Name: ${e.name}').join(', ')}",
    );

    await showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<GetLeadsTeamLeaderCubit, GetLeadsTeamLeaderState>(
          builder: (context, state) {
            if (state is GetLeadsTeamLeaderLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GetLeadsTeamLeaderSuccess) {
              leadResponse = state.leadsData;
            } else if (state is GetLeadsTeamLeaderError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              return SizedBox.shrink();
            }
            return BlocProvider(
              create: (_) => SalesCubit(GetAllSalesApiService()),
              child: CustomAssignDialogTeamLeaderWidget(
                leadIds: selectedLeads.map((e) => e.id ?? 0).toList(),
                leadId: leadIdd,
                leadResponse: leadResponse,
                mainColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
                fcmyoken: salesfcmtoken!,
              ),
            );
          },
        );
      },
    );
  }

  void _showAssignMenu(BuildContext context, Offset position) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'assign',
          child: Text('Assign Leads'),
          onTap: () => Future.delayed(Duration.zero, () => _showAssignDialog()),
        ),
      ],
    );
  }

  Widget buildUserTile({
    required String name,
    required String status,
    required int index,
    required String id,
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
    DateTime? stageUpdatedDate, // Add this parameter
    required String leadStagetype, // Add this parameter
    required bool isOutdated,
    required String fcmtoken, // Add this parameter
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.grey[800],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black87
                            : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Moved the logic for the outdated icon here and used the passed parameters
              (stageUpdatedDate != null &&
                      (leadStagetype == "Done Deal" ||
                          leadStagetype == "Transfer" ||
                          leadStagetype == "Fresh" ||
                          leadStagetype == "Not Interested"))
                  ? const SizedBox()
                  : Icon(
                    isOutdated ? Icons.close : Icons.check_circle,
                    color: isOutdated ? Colors.red : Colors.green,
                    size: 24,
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
                  setState(() {
                    selected[index] = val!;
                  });
                },
              ),
            ],
          ),
          const Divider(height: 16, thickness: 1),
          _buildInfoRow(
            context,
            Icons.category,
            'stage',
            status,
            valueColor:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          ),
          _buildInfoRow(context, Icons.person, 'Sales', salesName),
          InkWell(
            onTap: () {
              makePhoneCall(phone);
            },
            child: _buildInfoRow(
              context,
              Icons.phone,
              'Phone',
              phone,
              valueColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Constants.maincolor
                      : Constants.mainDarkmodecolor,
              isUnderlined: true,
            ),
          ),
          _buildInfoRow(context, Icons.email, 'Email', email),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => LeadsDetailsTeamLeaderScreen(
                          leedId: id,
                          leadName: name,
                          leadPhone: phone,
                          leadEmail: email,
                          leadStage: stage,
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
                        ),
                  ),
                );
              },
              child: Text(
                'View More',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isUnderlined = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Constants.maincolor
                    : Constants.mainDarkmodecolor,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.black87
                      : Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    valueColor ??
                    (Theme.of(context).brightness == Brightness.light
                        ? Colors.black54
                        : Colors.white54),
                decoration: isUnderlined ? TextDecoration.underline : null,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
}
