// ignore_for_file: library_private_types_in_public_api, avoid_print
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
                        return ListView.builder(
                          itemCount: _leads.length,
                          itemBuilder: (context, index) {
                            final lead = _leads[index];
                            leadIdd = lead.id.toString();
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
                              lead: lead,
                              leadcampaign:
                                  lead.campaign?.campaoignType ?? 'No Campaign',
                              leadNotes: lead.notes ?? 'No Notes',
                              leaddeveloper:
                                  lead.project?.developer?.name ??
                                  'No Developer',
                              userlogname:
                                  lead.sales?.userlog?.name ?? 'No User',
                              teamleadername:
                                  lead.sales?.teamleader?.name ??
                                  'No Team Leader',
                              salesName:
                                  lead.sales?.userlog?.name ?? 'No Sales',
                            );
                          },
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
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "sales : $salesName",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    makePhoneCall(phone);
                  },
                  child: Text(
                    phone,
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: selected[index],
            shape: const ContinuousRectangleBorder(),
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
          InkWell(
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
                      ),
                ),
              );
            },
            child: Text(
              'View More',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
                decoration: TextDecoration.underline,
              ),
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
