// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/Manager/cubit/get_manager_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showFilterDialogManagerr(BuildContext context, bool? data) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create:
                    (_) =>
                        DevelopersCubit(DeveloperApiService())..getDevelopers(),
              ),
              BlocProvider(
                create:
                    (_) => ProjectsCubit(ProjectsApiService())..fetchProjects(),
              ),
              BlocProvider(
                create: (_) => StagesCubit(StagesApiService())..fetchStages(),
              ),
              BlocProvider(
                create:
                    (_) =>
                        ChannelCubit(GetChannelsApiService())..fetchChannels(),
              ),
              BlocProvider(
                create:
                    (_) => SalesCubit(GetAllSalesApiService())..fetchAllSales(),
              ),
            ],
            child: FilterDialog(data: data),
          ),
        ),
  );
}

class FilterDialog extends StatefulWidget {
  final bool? data;
  const FilterDialog({super.key, this.data});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ✅ Multi Selection Sets
  final Set<String> selectedSalesPersons = {};
  final Set<String> selectedDevelopers = {};
  final Set<String> selectedProjects = {};
  final Set<String> selectedChannels = {};
  final Set<String> selectedStages = {};

  String? managerId;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;
  String? result;

  // ✅ للتحكم في إظهار/إخفاء قوائم الـ Multi Select
  bool _showSales = false;
  bool _showDevelopers = false;
  bool _showProjects = false;
  bool _showChannels = false;
  bool _showStages = false;

  @override
  void initState() {
    super.initState();
    context.read<GetManagerLeadsCubit>().getManagerLeadsPagination(data: true);
    _loadManagerId();
    init();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    result = prefs.getString('managerIdspecific');
  }

  Future<void> _loadManagerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      managerId = prefs.getString("managerIdspecific");
    });
    print("managerId: $managerId");
  }

  // ✅ Widget للـ Multi Select Dropdown بشكل أجمل
  Widget buildMultiSelectSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Set<String> selectedItems,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Function(String) onItemTapped,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Constants.maincolor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? Constants.maincolor,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Constants.maincolor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${selectedItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
            onTap: onToggle,
          ),

          // Selected Chips
          if (selectedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    selectedItems.map((item) {
                      return Chip(
                        label: Text(
                          item.length > 20
                              ? '${item.substring(0, 20)}...'
                              : item,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onDeleted: () {
                          setState(() {
                            selectedItems.remove(item);
                          });
                        },
                        backgroundColor: Constants.maincolor.withOpacity(0.1),
                        deleteIconColor: Constants.maincolor,
                        side: BorderSide.none,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
              ),
            ),

          // Expanded Items List
          if (isExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selectedItems.contains(item);
                  return InkWell(
                    onTap: () => onItemTapped(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? Constants.maincolor : null,
                                fontWeight: isSelected ? FontWeight.w500 : null,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Constants.maincolor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime) onDatePicked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Constants.maincolor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Constants.maincolor, size: 20),
        ),
        title: Text(
          value != null ? "${value.day}/${value.month}/${value.year}" : label,
          style: TextStyle(
            fontSize: 14,
            color: value != null ? Constants.maincolor : Colors.grey,
            fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: const Icon(
          Icons.calendar_today,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: Constants.maincolor),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) onDatePicked(picked);
        },
      ),
    );
  }

  // ✅ دوال تحويل الأسماء لـ IDs
  Future<List<String>> _getSalesIdsFromNames(List<String> names) async {
    final state = context.read<SalesCubit>().state;
    if (state is SalesLoaded) {
      return state.salesData.data!
          .where((sales) => names.contains(sales.name))
          .map((e) => e.id!)
          .toList();
    }
    return [];
  }

  Future<List<String>> _getDeveloperIdsFromNames(List<String> names) async {
    final state = context.read<DevelopersCubit>().state;
    if (state is DeveloperSuccess) {
      return state.developersModel.data
          .where((dev) => names.contains(dev.name))
          .map((e) => e.id)
          .toList();
    }
    return [];
  }

  Future<List<String>> _getProjectIdsFromNames(List<String> names) async {
    final state = context.read<ProjectsCubit>().state;
    if (state is ProjectsSuccess) {
      return state.projectsModel.data!
          .where((project) => names.contains(project.name))
          .map((e) => e.id!)
          .toList();
    }
    return [];
  }

  Future<List<String>> _getChannelIdsFromNames(List<String> names) async {
    final state = context.read<ChannelCubit>().state;
    if (state is ChannelLoaded) {
      return state.channelResponse.data
          .where((channel) => names.contains(channel.name))
          .map((e) => e.id)
          .toList();
    }
    return [];
  }

  Future<List<String>> _getStageIdsFromNames(List<String> names) async {
    final state = context.read<StagesCubit>().state;
    if (state is StagesLoaded) {
      return state.stages
          .where((stage) => names.contains(stage.name))
          .map((e) => e.id!)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Constants.maincolor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Constants.maincolor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter Leads',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Search by name...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Constants.maincolor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sales Multi Select
                    BlocBuilder<SalesCubit, SalesState>(
                      builder: (context, state) {
                        if (state is SalesLoaded) {
                          final filteredSales =
                              state.salesData.data?.where((sales) {
                                final role = sales.userlog?.role?.toLowerCase();
                                return (role == 'sales' ||
                                    role == 'team leader' ||
                                    role == 'manager');
                              }).toList() ??
                              [];

                          return buildMultiSelectSection(
                            title: "Sales Person",
                            icon: Icons.person_outline,
                            items:
                                filteredSales.map((e) => e.name ?? '').toList(),
                            selectedItems: selectedSalesPersons,
                            isExpanded: _showSales,
                            onToggle:
                                () => setState(() => _showSales = !_showSales),
                            onItemTapped: (item) {
                              setState(() {
                                if (selectedSalesPersons.contains(item)) {
                                  selectedSalesPersons.remove(item);
                                } else {
                                  selectedSalesPersons.add(item);
                                }
                              });
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // Developers Multi Select
                    BlocBuilder<DevelopersCubit, DevelopersState>(
                      builder: (context, state) {
                        if (state is DeveloperSuccess) {
                          final items =
                              state.developersModel.data
                                  .map((dev) => dev.name)
                                  .whereType<String>()
                                  .toList();
                          return buildMultiSelectSection(
                            title: "Developers",
                            icon: Icons.business,
                            items: items,
                            selectedItems: selectedDevelopers,
                            isExpanded: _showDevelopers,
                            onToggle:
                                () => setState(
                                  () => _showDevelopers = !_showDevelopers,
                                ),
                            onItemTapped: (item) {
                              setState(() {
                                if (selectedDevelopers.contains(item)) {
                                  selectedDevelopers.remove(item);
                                } else {
                                  selectedDevelopers.add(item);
                                }
                              });
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // Channels Multi Select
                    BlocBuilder<ChannelCubit, ChannelState>(
                      builder: (context, state) {
                        if (state is ChannelLoaded) {
                          final items =
                              state.channelResponse.data
                                  .map((channel) => channel.name)
                                  .whereType<String>()
                                  .toList();
                          return buildMultiSelectSection(
                            title: "Channels",
                            icon: Icons.campaign,
                            items: items,
                            selectedItems: selectedChannels,
                            isExpanded: _showChannels,
                            onToggle:
                                () => setState(
                                  () => _showChannels = !_showChannels,
                                ),
                            onItemTapped: (item) {
                              setState(() {
                                if (selectedChannels.contains(item)) {
                                  selectedChannels.remove(item);
                                } else {
                                  selectedChannels.add(item);
                                }
                              });
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // Projects Multi Select
                    BlocBuilder<ProjectsCubit, ProjectsState>(
                      builder: (context, state) {
                        if (state is ProjectsSuccess) {
                          final items =
                              state.projectsModel.data!
                                  .map((project) => project.name)
                                  .whereType<String>()
                                  .toList();
                          return buildMultiSelectSection(
                            title: "Projects",
                            icon: Icons.apartment,
                            items: items,
                            selectedItems: selectedProjects,
                            isExpanded: _showProjects,
                            onToggle:
                                () => setState(
                                  () => _showProjects = !_showProjects,
                                ),
                            onItemTapped: (item) {
                              setState(() {
                                if (selectedProjects.contains(item)) {
                                  selectedProjects.remove(item);
                                } else {
                                  selectedProjects.add(item);
                                }
                              });
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // Stages Multi Select
                    BlocBuilder<StagesCubit, StagesState>(
                      builder: (context, state) {
                        if (state is StagesLoaded) {
                          final items =
                              state.stages
                                  .map((stage) => stage.name)
                                  .whereType<String>()
                                  .toList();
                          return buildMultiSelectSection(
                            title: "Stages",
                            icon: Icons.schema,
                            items: items,
                            selectedItems: selectedStages,
                            isExpanded: _showStages,
                            onToggle:
                                () =>
                                    setState(() => _showStages = !_showStages),
                            onItemTapped: (item) {
                              setState(() {
                                if (selectedStages.contains(item)) {
                                  selectedStages.remove(item);
                                } else {
                                  selectedStages.add(item);
                                }
                              });
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    const SizedBox(height: 8),

                    // Date Fields Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date Range',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildDateField(
                            label: "Last Stage Update (Start)",
                            icon: Icons.update,
                            value: _lastStageUpdateStart,
                            onDatePicked: (picked) {
                              setState(() => _lastStageUpdateStart = picked);
                            },
                          ),
                          buildDateField(
                            label: "Last Stage Update (End)",
                            icon: Icons.update,
                            value: _lastStageUpdateEnd,
                            onDatePicked: (picked) {
                              setState(() => _lastStageUpdateEnd = picked);
                            },
                          ),
                          buildDateField(
                            label: "Creation Date (Start)",
                            icon: Icons.assignment_add,
                            value: _startDate,
                            onDatePicked: (picked) {
                              setState(() => _startDate = picked);
                            },
                          ),
                          buildDateField(
                            label: "Creation Date (End)",
                            icon: Icons.assignment_add,
                            value: _endDate,
                            onDatePicked: (picked) {
                              setState(() => _endDate = picked);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          nameController.clear();
                          selectedSalesPersons.clear();
                          selectedDevelopers.clear();
                          selectedProjects.clear();
                          selectedChannels.clear();
                          selectedStages.clear();
                          _startDate = null;
                          _endDate = null;
                          _lastStageUpdateStart = null;
                          _lastStageUpdateEnd = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Constants.maincolor,
                        side: BorderSide(color: Constants.maincolor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // ✅ Validation للتواريخ
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

                        // ✅ تحويل الأسماء لـ IDs
                        final selectedSalesIds = await _getSalesIdsFromNames(
                          selectedSalesPersons.toList(),
                        );
                        final selectedDeveloperIds =
                            await _getDeveloperIdsFromNames(
                              selectedDevelopers.toList(),
                            );
                        final selectedProjectIds =
                            await _getProjectIdsFromNames(
                              selectedProjects.toList(),
                            );
                        final selectedChannelIds =
                            await _getChannelIdsFromNames(
                              selectedChannels.toList(),
                            );
                        final selectedStageIds = await _getStageIdsFromNames(
                          selectedStages.toList(),
                        );

                        // ✅ تطبيق الفلتر
                        context
                            .read<GetManagerLeadsCubit>()
                            .getManagerLeadsPagination(
                              data: widget.data ?? false,
                              search:
                                  nameController.text.trim().isEmpty
                                      ? null
                                      : nameController.text.trim(),
                              salesIds:
                                  selectedSalesIds.isNotEmpty
                                      ? selectedSalesIds
                                      : null,
                              developerIds:
                                  selectedDeveloperIds.isNotEmpty
                                      ? selectedDeveloperIds
                                      : null,
                              projectIds:
                                  selectedProjectIds.isNotEmpty
                                      ? selectedProjectIds
                                      : null,
                              channelIds:
                                  selectedChannelIds.isNotEmpty
                                      ? selectedChannelIds
                                      : null,
                              stageIds:
                                  selectedStageIds.isNotEmpty
                                      ? selectedStageIds
                                      : null,
                              creationDateFrom: _startDate,
                              creationDateTo: _endDate,
                              lastStageUpdateFrom: _lastStageUpdateStart,
                              lastStageUpdateTo: _lastStageUpdateEnd,
                            );

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.maincolor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
