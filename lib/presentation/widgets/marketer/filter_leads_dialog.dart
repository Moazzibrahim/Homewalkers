// filter_leads_dialog.dart

// ignore_for_file: avoid_print, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';

class FilterDialog extends StatefulWidget {
  final String? initialCountry;
  final String? initialDeveloper;
  final String? initialProject;
  final String? initialStage;
  final String? initialChannel;
  final String? initialSales;
  final String? initialCommunicationWay;
  final String? initialCampaign;
  final String? initialSearchName;

  const FilterDialog({
    super.key,
    this.initialCountry,
    this.initialDeveloper,
    this.initialProject,
    this.initialStage,
    this.initialChannel,
    this.initialSales,
    this.initialCommunicationWay,
    this.initialCampaign,
    this.initialSearchName,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _nameController;

  String? _selectedCountry;
  String? _selectedDeveloperId;
  String? _selectedDeveloperName;
  String? _selectedProjectId;
  String? _selectedProjectName;
  String? _selectedStageId;
  String? _selectedStageName;
  String? _selectedChannelId;
  String? _selectedChannelName;
  String? _selectedCommunicationWayId;
  String? _selectedCommunicationWayName;
  String? _selectedCampaignId;
  String? _selectedCampaignName;
  String? _selectedSalesId;
  String? _selectedSalesName;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;
  DateTime? _lastCommentDateStart;
  DateTime? _lastCommentDateEnd;
  DateTime? _oldStageStartDate;
  DateTime? _oldStageEndDate;

  String? _selectedAddedBy;
  String? _selectedAssignedFrom;
  String? _selectedAssignedTo;
  String? _selectedOldStage;
  String? _selectedAddedById;
  String? _selectedAssignedFromId;
  String? _selectedAssignedToId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialSearchName);
    _selectedCountry = widget.initialCountry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget buildDateField(
    String label,
    DateTime? value,
    Function(DateTime) onDatePicked,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onDatePicked(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(143, 146, 146, 1),
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffE1E1E1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          child: Text(
            value != null ? "${value.toLocal()}".split(' ')[0] : label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? const Color(0xff080719)
                      : const Color(0xffFFFFFF),
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: "Search Name, Email, or Phone",
                controller: _nameController,
              ),
              const SizedBox(height: 12),

              // Sales Dropdown
              BlocBuilder<SalesCubit, SalesState>(
                builder: (context, state) {
                  if (state is SalesLoaded) {
                    final filteredSales =
                        state.salesData.data?.where((sales) {
                          final role = sales.userlog?.role?.toLowerCase();
                          return role == 'sales' ||
                              role == 'team leader' ||
                              role == 'manager';
                        }).toList() ??
                        [];
                    return CustomDropdownField(
                      hint: "Choose Sales",
                      items: filteredSales.map((e) => e.name ?? '').toList(),
                      value: _selectedSalesName,
                      onChanged: (name) {
                        final sales = filteredSales.firstWhere(
                          (e) => e.name == name,
                        );
                        setState(() {
                          _selectedSalesName = name;
                          _selectedSalesId = sales.id;
                        });
                      },
                    );
                  } else if (state is SalesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SalesError) {
                    return Text("Error: ${state.message}");
                  }
                  return const SizedBox();
                },
              ),

              const SizedBox(height: 12),
              // Developers Dropdown
              BlocBuilder<DevelopersCubit, DevelopersState>(
                builder: (context, state) {
                  if (state is DeveloperLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is DeveloperSuccess) {
                    final items =
                        state.developersModel.data
                            .map((dev) => dev.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose Developer",
                      items: items,
                      value: _selectedDeveloperName,
                      onChanged: (name) {
                        final dev = state.developersModel.data.firstWhere(
                          (e) => e.name == name,
                        );
                        setState(() {
                          _selectedDeveloperName = name;
                          _selectedDeveloperId = dev.id;
                        });
                      },
                    );
                  } else if (state is DeveloperError) {
                    return Text(
                      "Error: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 12),

              // Channels Dropdown
              BlocBuilder<ChannelCubit, ChannelState>(
                builder: (context, state) {
                  if (state is ChannelLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is ChannelLoaded) {
                    final items =
                        state.channelResponse.data
                            .map((dev) => dev.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose channel",
                      items: items,
                      value: _selectedChannelName,
                      onChanged: (name) {
                        final channel = state.channelResponse.data.firstWhere(
                          (e) => e.name == name,
                        );
                        setState(() {
                          _selectedChannelName = name;
                          _selectedChannelId = channel.id;
                        });
                      },
                    );
                  } else if (state is ChannelError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 12),
              // Projects Dropdown
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is ProjectsSuccess) {
                    final items =
                        state.projectsModel.data!
                            .map((project) => project.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose Project",
                      items: items,
                      value: _selectedProjectName,
                      onChanged: (name) {
                        final project = state.projectsModel.data!.firstWhere(
                          (e) => e.name == name,
                        );
                        setState(() {
                          _selectedProjectName = name;
                          _selectedProjectId = project.id;
                        });
                      },
                    );
                  } else if (state is ProjectsError) {
                    return Text(
                      "Error: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 12),
              // Campaigns Dropdown
              BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
                builder: (context, state) {
                  if (state is GetCampaignsLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is GetCampaignsSuccess) {
                    final items =
                        state.campaigns.data!
                            .map((campaign) => campaign.campainName)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose Campaign",
                      items: items,
                      value: _selectedCampaignName,
                      onChanged: (name) {
                        final campaign = state.campaigns.data!.firstWhere(
                          (e) => e.campainName == name,
                        );
                        setState(() {
                          _selectedCampaignName = name;
                          _selectedCampaignId = campaign.id;
                        });
                      },
                    );
                  } else if (state is GetCampaignsFailure) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 12),
              // Communication Ways Dropdown
              BlocBuilder<GetCommunicationWaysCubit, GetCommunicationWaysState>(
                builder: (context, state) {
                  if (state is GetCommunicationWaysLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is GetCommunicationWaysLoaded) {
                    final items =
                        state.response.data!.map((way) => way.name).toList();
                    return CustomDropdownField(
                      hint: "Choose communication way",
                      items: items,
                      value: _selectedCommunicationWayName,
                      onChanged: (name) {
                        final way = state.response.data!.firstWhere(
                          (e) => e.name == name,
                        );
                        setState(() {
                          _selectedCommunicationWayName = name;
                          _selectedCommunicationWayId = way.id;
                        });
                      },
                    );
                  } else if (state is GetCommunicationWaysError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 12),
              // Stages Dropdown
              BlocBuilder<StagesCubit, StagesState>(
                builder: (context, state) {
                  if (state is StagesLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is StagesLoaded) {
                    final items =
                        state.stages.map((stage) => stage.name).toList();
                    return CustomDropdownField(
                      hint: "Choose Stage",
                      items: items,
                      value: _selectedStageName,
                      onChanged: (name) {
                        final stage = state.stages.firstWhere(
                          (e) => e.name == name,
                        );
                        setState(() {
                          _selectedStageName = name;
                          _selectedStageId = stage.id;
                        });
                      },
                    );
                  } else if (state is StagesError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 12),
              buildDateField(" Stage Date (Start)", _oldStageStartDate, (
                picked,
              ) {
                _oldStageStartDate = picked;
                setState(() {});
              }),
              const SizedBox(height: 14),
              buildDateField(" Stage Date (End)", _oldStageEndDate, (picked) {
                _oldStageEndDate = picked;
                setState(() {});
              }),
              // Added By / Assigned From / Assigned To
              BlocBuilder<SalesCubit, SalesState>(
                builder: (context, state) {
                  if (state is SalesLoaded) {
                    final users = state.salesData.data ?? [];
                    return Column(
                      children: [
                        CustomDropdownField(
                          hint: "Choose Added By",
                          items:
                              users.map((e) => e.userlog?.name ?? '').toList(),
                          value: _selectedAddedBy,
                          onChanged: (val) {
                            final user = users.firstWhere(
                              (e) => e.userlog?.name == val,
                            );
                            setState(() {
                              _selectedAddedBy = val;
                              _selectedAddedById =
                                  user.userlog?.id; // نخزن ال id هنا
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomDropdownField(
                          hint: "Choose Assigned From",
                          items:
                              users.map((e) => e.userlog?.name ?? '').toList(),
                          value: _selectedAssignedFrom,
                          onChanged: (val) {
                            final user = users.firstWhere(
                              (e) => e.userlog?.name == val,
                            );
                            setState(() {
                              _selectedAssignedFrom = val;
                              _selectedAssignedFromId = user.userlog?.id;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomDropdownField(
                          hint: "Choose Assigned To",
                          items: users.map((e) => e.name ?? '').toList(),
                          value: _selectedAssignedTo,
                          onChanged: (val) {
                            final user = users.firstWhere((e) => e.name == val);
                            setState(() {
                              _selectedAssignedTo = val;
                              _selectedAssignedToId = user.id;
                            });
                          },
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),

              const SizedBox(height: 14),
              buildDateField("creation Date (start)", _startDate, (picked) {
                _startDate = picked;
                setState(() {});
              }),
              const SizedBox(height: 12),
              buildDateField(" creation Date (end)", _endDate, (picked) {
                _endDate = picked;
                setState(() {});
              }),
              const SizedBox(height: 14),
              buildDateField(
                "Last Stage Update (Start)",
                _lastStageUpdateStart,
                (picked) {
                  _lastStageUpdateStart = picked;
                  setState(() {});
                },
              ),
              const SizedBox(height: 14),
              buildDateField("Last Stage Update (End)", _lastStageUpdateEnd, (
                picked,
              ) {
                _lastStageUpdateEnd = picked;
                setState(() {});
              }),
              const SizedBox(height: 14),
              buildDateField(
                "Last Comment Date (Start)",
                _lastCommentDateStart,
                (picked) {
                  _lastCommentDateStart = picked;
                  setState(() {});
                },
              ),
              const SizedBox(height: 14),
              buildDateField("Last Comment Date (End)", _lastCommentDateEnd, (
                picked,
              ) {
                _lastCommentDateEnd = picked;
                setState(() {});
              }),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          // تنظيف كل الفلاتر
                          _nameController.clear();
                          _selectedCountry = null;
                          _selectedDeveloperId = null;
                          _selectedDeveloperName = null;
                          _selectedProjectId = null;
                          _selectedProjectName = null;
                          _selectedStageId = null;
                          _selectedStageName = null;
                          _selectedChannelId = null;
                          _selectedChannelName = null;
                          _selectedCommunicationWayId = null;
                          _selectedCommunicationWayName = null;
                          _selectedCampaignId = null;
                          _selectedCampaignName = null;
                          _selectedSalesId = null;
                          _selectedSalesName = null;
                          _selectedAddedBy = null;
                          _selectedAssignedFrom = null;
                          _selectedAssignedTo = null;
                          _selectedAddedById = null;
                          _selectedAssignedFromId = null;
                          _selectedAssignedToId = null;
                          _selectedOldStage = null;

                          _startDate = null;
                          _endDate = null;
                          _lastStageUpdateStart = null;
                          _lastStageUpdateEnd = null;
                          _lastCommentDateStart = null;
                          _lastCommentDateEnd = null;
                          _oldStageStartDate = null;
                          _oldStageEndDate = null;
                        });

                        Navigator.pop(context, {
                          'name': null,
                          'country': null,
                          'developerId': null,
                          'projectId': null,
                          'stageId': null,
                          'channelId': null,
                          'salesId': null,
                          'campaignId': null,
                          'communicationWayId': null,
                          'addedBy': null,
                          'assignedFrom': null,
                          'assignedTo': null,
                          'oldStageName': null,
                          'startDate': null,
                          'endDate': null,
                          'lastStageUpdateStart': null,
                          'lastStageUpdateEnd': null,
                          'lastCommentDateStart': null,
                          'lastCommentDateEnd': null,
                          'oldStageDateStart': null,
                          'oldStageDateEnd': null,
                        });
                      },

                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          color: Constants.maincolor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        bool isValidDateRange(DateTime? start, DateTime? end) {
                          return (start == null && end == null) ||
                              (start != null && end != null);
                        }

                        // ✅ دالة إظهار التنبيه
                        Future<void> showValidationDialog(
                          String message,
                        ) async {
                          return showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text("Incomplete Date Range"),
                                  content: Text(message),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                          );
                        }

                        // ✅ التحقق من التواريخ
                        if (!isValidDateRange(_startDate, _endDate)) {
                          showValidationDialog(
                            "Please select both start and end date for creation date.",
                          );
                          return;
                        }

                        if (!isValidDateRange(
                          _lastStageUpdateStart,
                          _lastStageUpdateEnd,
                        )) {
                          showValidationDialog(
                            "Please select both start and end date for last stage update.",
                          );
                          return;
                        }

                        if (!isValidDateRange(
                          _lastCommentDateStart,
                          _lastCommentDateEnd,
                        )) {
                          showValidationDialog(
                            "Please select both start and end date for last comment date.",
                          );
                          return;
                        }
                        if (!isValidDateRange(
                          _oldStageStartDate,
                          _oldStageEndDate,
                        )) {
                          showValidationDialog(
                            "Please select both start and end date for old stage date.",
                          );
                          return;
                        }
                        // 🟡 عند الـ Apply، نرجع كل قيم الفلاتر المختارة
                        Navigator.pop(context, {
                          'name':
                              _nameController.text.trim().isEmpty
                                  ? null
                                  : _nameController.text.trim(),
                          'country': _selectedCountry,
                          'developerId': _selectedDeveloperId,
                          'projectId': _selectedProjectId,
                          'stageId': _selectedStageId,
                          'channelId': _selectedChannelId,
                          'salesId': _selectedSalesId,
                          'campaignId': _selectedCampaignId,
                          'communicationWayId': _selectedCommunicationWayId,

                          'addedBy': _selectedAddedById,
                          'assignedFrom': _selectedAssignedFromId,
                          'assignedTo': _selectedAssignedToId,
                          'oldStageName': _selectedOldStage,
                          'startDate': _startDate,
                          'endDate': _endDate,
                          'lastStageUpdateStart': _lastStageUpdateStart,
                          'lastStageUpdateEnd': _lastStageUpdateEnd,
                          'lastCommentDateStart': _lastCommentDateStart,
                          'lastCommentDateEnd': _lastCommentDateEnd,
                          'oldStageDateStart': _oldStageStartDate,
                          'oldStageDateEnd': _oldStageEndDate,
                        });
                        // ❌ لا تستدعي filterLeadsMarketer هنا. الشاشة الرئيسية هي اللي هتستدعيها.
                        // context.read<GetLeadsMarketerCubit>().filterLeadsMarketer(...)
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
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
  }
}
