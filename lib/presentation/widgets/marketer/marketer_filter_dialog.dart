// filter_leads_dialog.dart
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
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';

class SelectItem {
  final String id;
  final String name;

  SelectItem({required this.id, required this.name});
}

// ✅ ويدجت جديد للـ Multi-Select Dropdown
class MultiSelectDropdown extends StatefulWidget {
  final String hint;
  final List<SelectItem> items; // 🔥 بدل String
  final List<String> selectedItems; // 🔥 دي IDs
  final Function(List<String>) onChanged;

  // ignore: use_super_parameters
  const MultiSelectDropdown({
    Key? key,
    required this.hint,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final List<String>? result = await showDialog<List<String>>(
          context: context,
          builder: (BuildContext context) {
            return MultiSelectDialog(
              title: widget.hint,
              items: widget.items,
              selectedItems: widget.selectedItems,
            );
          },
        );
        if (result != null) {
          widget.onChanged(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.hint,
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
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Text(
          widget.selectedItems.isEmpty
              ? widget.hint
              : "${widget.selectedItems.length} selected",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color:
                widget.selectedItems.isEmpty
                    ? const Color.fromRGBO(143, 146, 146, 1)
                    : Theme.of(context).brightness == Brightness.light
                    ? const Color(0xff080719)
                    : const Color(0xffFFFFFF),
          ),
        ),
      ),
    );
  }
}

// ✅ ديالوج الـ Multi-Select
class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<SelectItem> items;
  final List<String> selectedItems;

  const MultiSelectDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
  }) : super(key: key);

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.title}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isSelected = _tempSelectedItems.contains(item.id);
            return CheckboxListTile(
              title: Text(item.name),
              value: isSelected,
              activeColor: Constants.maincolor,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _tempSelectedItems.add(item.id);
                  } else {
                    _tempSelectedItems.remove(item.id);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _tempSelectedItems);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class MarketerFilterDialog extends StatefulWidget {
  // تعديل الأنواع لتصبح List<String> بدلاً من String?
  final List<String>? initialCountry;
  final List<String>? initialDeveloper;
  final List<String>? initialProject;
  final List<String>? initialStage;
  final List<String>? initialChannel;
  final List<String>? initialSales;
  final List<String>? initialCommunicationWay;
  final List<String>? initialCampaign;
  final String? initialSearchName;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? initialLastStageUpdateStart;
  final DateTime? initialLastStageUpdateEnd;

  const MarketerFilterDialog({
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
    this.initialStartDate,
    this.initialEndDate,
    this.initialLastStageUpdateStart,
    this.initialLastStageUpdateEnd,
  });

  @override
  State<MarketerFilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<MarketerFilterDialog> {
  late TextEditingController _nameController;

  // تعديل الأنواع لتصبح List<String>
  List<String> _selectedCountry = [];
  List<String> _selectedDeveloper = [];
  List<String> _selectedProject = [];
  List<String> _selectedStage = [];
  List<String> _selectedChannel = [];
  List<String> _selectedCommunicationWay = [];
  List<String> _selectedCampaign = [];
  List<String> _selectedSales = [];
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialSearchName);

    // تهيئة القوائم بالقيم الأولية
    _selectedCountry = widget.initialCountry ?? [];
    _selectedDeveloper = widget.initialDeveloper ?? [];
    _selectedProject = widget.initialProject ?? [];
    _selectedStage = widget.initialStage ?? [];
    _selectedChannel = widget.initialChannel ?? [];
    _selectedSales = widget.initialSales ?? [];
    _selectedCommunicationWay = widget.initialCommunicationWay ?? [];
    _selectedCampaign = widget.initialCampaign ?? [];

    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _lastStageUpdateStart = widget.initialLastStageUpdateStart;
    _lastStageUpdateEnd = widget.initialLastStageUpdateEnd;
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
              // ✅ Sales Multi-Select
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
                    final items =
                        filteredSales.map((e) {
                          return SelectItem(
                            id: e.id.toString(),
                            name: e.name ?? '',
                          );
                        }).toList();
                    return MultiSelectDropdown(
                      hint: "Choose Sales",
                      items: items,
                      selectedItems: _selectedSales,
                      onChanged: (values) {
                        setState(() => _selectedSales = values);
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

              // ✅ Developer Multi-Select
              BlocBuilder<DevelopersCubit, DevelopersState>(
                builder: (context, state) {
                  if (state is DeveloperSuccess) {
                    final items =
                        state.developersModel.data.map((dev) {
                          return SelectItem(
                            id: dev.id.toString(),
                            name: dev.name,
                          );
                        }).toList();
                    return MultiSelectDropdown(
                      hint: "Choose Developer",
                      items: items,
                      selectedItems: _selectedDeveloper,
                      onChanged: (values) {
                        setState(() => _selectedDeveloper = values);
                      },
                    );
                  } else if (state is DeveloperLoading) {
                    return const CircularProgressIndicator();
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

              // ✅ Channel Multi-Select
              BlocBuilder<ChannelCubit, ChannelState>(
                builder: (context, state) {
                  if (state is ChannelLoaded) {
                    final items =
                        state.channelResponse.data.map((dev) {
                          return SelectItem(
                            id: dev.id.toString(),
                            name: dev.name,
                          );
                        }).toList();
                    return MultiSelectDropdown(
                      hint: "Choose channel",
                      items: items,
                      selectedItems: _selectedChannel,
                      onChanged: (values) {
                        setState(() => _selectedChannel = values);
                      },
                    );
                  } else if (state is ChannelLoading) {
                    return const CircularProgressIndicator();
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

              // ✅ Project Multi-Select
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsSuccess) {
                    final items =
                        state.projectsModel.data!.map((project) {
                          return SelectItem(
                            id: project.id.toString(),
                            name: project.name ?? '',
                          );
                        }).toList();
                    return MultiSelectDropdown(
                      hint: "Choose Project",
                      items: items,
                      selectedItems: _selectedProject,
                      onChanged: (values) {
                        setState(() => _selectedProject = values);
                      },
                    );
                  } else if (state is ProjectsLoading) {
                    return const CircularProgressIndicator();
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

              // ✅ Campaign Multi-Select
              BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
                builder: (context, state) {
                  if (state is GetCampaignsSuccess) {
                    final items =
                        state.campaigns.data!.map((campaign) {
                          return SelectItem(
                            id: campaign.id.toString(),
                            name: campaign.campainName ?? '',
                          );
                        }).toList();
                    return MultiSelectDropdown(
                      hint: "Choose Campaign",
                      items: items,
                      selectedItems: _selectedCampaign,
                      onChanged: (values) {
                        setState(() => _selectedCampaign = values);
                      },
                    );
                  } else if (state is GetCampaignsLoading) {
                    return const CircularProgressIndicator();
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

              // ✅ Communication Way Multi-Select
              BlocBuilder<GetCommunicationWaysCubit, GetCommunicationWaysState>(
                builder: (context, state) {
                  if (state is GetCommunicationWaysLoaded) {
                    final items =
                        state.response.data!.map((communicationway) {
                          return SelectItem(
                            id: communicationway.id.toString(),
                            name: communicationway.name ?? '',
                          );
                        }).toList();
                    return MultiSelectDropdown(
                      hint: "Choose communication way",
                      items: items,
                      selectedItems: _selectedCommunicationWay,
                      onChanged: (values) {
                        setState(() => _selectedCommunicationWay = values);
                      },
                    );
                  } else if (state is GetCommunicationWaysLoading) {
                    return const CircularProgressIndicator();
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

              // ✅ Stage Multi-Select
              BlocBuilder<StagesCubit, StagesState>(
                builder: (context, state) {
                  if (state is StagesLoaded) {
                    final items =
                        state.stages.map((stage) {
                          return SelectItem(
                            id: stage.id.toString(),
                            name: stage.name ?? '',
                          );
                        }).toList();
                    return MultiSelectDropdown(
                      hint: "Choose Stage",
                      items: items,
                      selectedItems: _selectedStage,
                      onChanged: (values) {
                        setState(() {
                          _selectedStage = values;
                        });
                      },
                    );
                  } else if (state is StagesLoading) {
                    return const CircularProgressIndicator();
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
              const SizedBox(height: 14),
              buildDateField("creation Date (start)", _startDate, (picked) {
                setState(() => _startDate = picked);
              }),
              const SizedBox(height: 12),
              buildDateField(" creation Date (end)", _endDate, (picked) {
                setState(() => _endDate = picked);
              }),
              const SizedBox(height: 14),
              buildDateField(
                "Last Stage Update (Start)",
                _lastStageUpdateStart,
                (picked) {
                  setState(() => _lastStageUpdateStart = picked);
                },
              ),
              const SizedBox(height: 14),
              buildDateField("Last Stage Update (End)", _lastStageUpdateEnd, (
                picked,
              ) {
                setState(() => _lastStageUpdateEnd = picked);
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
                          _nameController.clear();
                          _selectedCountry = [];
                          _selectedDeveloper = [];
                          _selectedProject = [];
                          _selectedStage = [];
                          _selectedChannel = [];
                          _selectedSales = [];
                          _selectedCommunicationWay = [];
                          _selectedCampaign = [];
                          _startDate = null;
                          _endDate = null;
                          _lastStageUpdateStart = null;
                          _lastStageUpdateEnd = null;
                        });
                        // Return all filters as null or empty lists
                        Navigator.pop(context, {
                          'name': null,
                          'country': [],
                          'developer': [],
                          'project': [],
                          'stage': [],
                          'channel': [],
                          'sales': [],
                          'communicationWay': [],
                          'campaign': [],
                          'startDate': null,
                          'endDate': null,
                          'lastStageUpdateStart': null,
                          'lastStageUpdateEnd': null,
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

                        // Return all filters with Lists
                        Navigator.pop(context, {
                          'name':
                              _nameController.text.trim().isEmpty
                                  ? null
                                  : _nameController.text.trim(),
                          'country': _selectedCountry,
                          'developer': _selectedDeveloper,
                          'project': _selectedProject,
                          'stage': _selectedStage,
                          'channel': _selectedChannel,
                          'sales': _selectedSales,
                          'communicationWay': _selectedCommunicationWay,
                          'campaign': _selectedCampaign,
                          'startDate': _startDate,
                          'endDate': _endDate,
                          'lastStageUpdateStart': _lastStageUpdateStart,
                          'lastStageUpdateEnd': _lastStageUpdateEnd,
                        });
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
