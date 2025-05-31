// ignore_for_file: library_private_types_in_public_api
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/team_leader_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_leads_team_leader_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_show_assign_dialog.dart';

class TeamLeaderAssignScreen extends StatefulWidget {
  const TeamLeaderAssignScreen({super.key});

  @override
  _SalesAssignLeadsScreenState createState() => _SalesAssignLeadsScreenState();
}

class _SalesAssignLeadsScreenState extends State<TeamLeaderAssignScreen> {
  List<bool> selected = [];
  List<LeadData> _leads = [];
  LeadResponse? leadResponse;
  String? leadIdd;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              GetLeadsTeamLeaderCubit(GetLeadsService())
                ..getLeadsByTeamLeader(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Assign",
          onBack: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TeamLeaderTabsScreen()),
            );
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTapDown:
                        (details) =>
                            _showAssignMenu(context, details.globalPosition),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  BlocBuilder<GetLeadsTeamLeaderCubit, GetLeadsTeamLeaderState>(
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
                              lead.name ?? 'No Name',
                              lead.stage?.name ?? 'No Status',
                              index,
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
      builder:
          (context) => BlocBuilder<GetLeadsCubit, GetLeadsState>(
            builder: (context, state) {
              if (state is GetLeadsLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is GetLeadsSuccess) {
                leadResponse = state.assignedModel;
              } else if (state is GetLeadsError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                return SizedBox.shrink();
              }
              return BlocProvider(
                create: (_) => SalesCubit(GetAllSalesApiService()),
                child: AssignDialog(
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
          ),
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

  Widget buildUserTile(String name, String status, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  status,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: selected[index],
            shape: ContinuousRectangleBorder(),
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
    );
  }
}
