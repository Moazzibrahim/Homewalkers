import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:country_picker/country_picker.dart';

void showFilterDialog(
  BuildContext context,
  bool? data,
  bool? transferfromdata,
  Function(Map<String, dynamic>)? onFiltersApplied,
) {
  showDialog(
    context: context,
    builder:
        (context) => MultiBlocProvider(
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
                  (_) => ChannelCubit(GetChannelsApiService())..fetchChannels(),
            ),
          ],
          child: FilterDialog(
            data: data,
            transferfromdata: transferfromdata,
            onFiltersApplied: onFiltersApplied,
          ),
        ),
  );
}

class FilterDialog extends StatefulWidget {
  final bool? data;
  final bool? transferfromdata;
  final Function(Map<String, dynamic>)? onFiltersApplied;

  const FilterDialog({
    super.key,
    this.data,
    this.transferfromdata,
    this.onFiltersApplied,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController nameController = TextEditingController();
  Country? selectedCountry;
  String? selectedDeveloper;
  String? selectedProject;
  String? selectedStage;
  String? selectedChannel;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _lastStageUpdateStart;
  DateTime? _lastStageUpdateEnd;

  // ─────────────────────────────────────────────
  // ✅ Bottom sheet بحث قابل لإعادة الاستخدام لأي ليستة
  // ─────────────────────────────────────────────
  Future<String?> _showSearchableList({
    required String title,
    required List<String> items,
    required String? selectedValue,
  }) async {
    String query = '';
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final filtered =
                items
                    .where((e) => e.toLowerCase().contains(query.toLowerCase()))
                    .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (selectedValue != null)
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext, ''),
                          child: const Text("Clear"),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    onChanged: (v) => setModalState(() => query = v),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(sheetContext).size.height * 0.4,
                    ),
                    child:
                        filtered.isEmpty
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                "No results",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final isSelected = item == selectedValue;
                                return ListTile(
                                  title: Text(item),
                                  trailing:
                                      isSelected
                                          ? Icon(
                                            Icons.check,
                                            color: Constants.maincolor,
                                          )
                                          : null,
                                  onTap:
                                      () => Navigator.pop(sheetContext, item),
                                );
                              },
                            ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // ✅ حقل الفلتر اللي بيفتح البحث
  // ─────────────────────────────────────────────
  Widget _buildSearchableDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    required bool isTablet7,
    required bool isTablet10,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final result = await _showSearchableList(
          title: hint,
          items: items,
          selectedValue: value,
        );
        if (result == '') {
          onChanged(null); // ✅ تم مسح الفلتر
        } else if (result != null) {
          onChanged(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize:
                isTablet10
                    ? 16
                    : isTablet7
                    ? 15
                    : 14,
            color: const Color.fromRGBO(143, 146, 146, 1),
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffE1E1E1)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical:
                isTablet10
                    ? 20
                    : isTablet7
                    ? 18
                    : 16,
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value ?? hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize:
                isTablet10
                    ? 16
                    : isTablet7
                    ? 15
                    : 14,
            fontWeight: FontWeight.w400,
            color:
                value == null
                    ? const Color.fromRGBO(143, 146, 146, 1)
                    : Theme.of(context).brightness == Brightness.light
                    ? const Color(0xff080719)
                    : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildDateField(
    String label,
    DateTime? value,
    Function(DateTime) onDatePicked,
    bool isTablet7,
    bool isTablet10,
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
            hintStyle: TextStyle(
              fontSize:
                  isTablet10
                      ? 16
                      : isTablet7
                      ? 15
                      : 14,
              color: const Color.fromRGBO(143, 146, 146, 1),
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffE1E1E1)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical:
                  isTablet10
                      ? 20
                      : isTablet7
                      ? 18
                      : 16,
            ),
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          child: Text(
            value != null ? "${value.toLocal()}".split(' ')[0] : label,
            style: TextStyle(
              fontSize:
                  isTablet10
                      ? 16
                      : isTablet7
                      ? 15
                      : 14,
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
    final width = MediaQuery.of(context).size.width;

    final bool isTablet7 = width >= 600 && width < 900;
    final bool isTablet10 = width >= 900;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal:
            isTablet10
                ? 200
                : isTablet7
                ? 120
                : 16,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(
          isTablet10
              ? 24
              : isTablet7
              ? 20
              : 16,
        ),
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
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize:
                          isTablet10
                              ? 22
                              : isTablet7
                              ? 19
                              : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(hint: "Full Name", controller: nameController),
              const SizedBox(height: 12),

              /// ✅ Developers - قابل للبحث
              BlocBuilder<DevelopersCubit, DevelopersState>(
                builder: (context, state) {
                  if (state is DeveloperSuccess) {
                    final items =
                        state.developersModel.data
                            .map((e) => e.name ?? '')
                            .where((e) => e.isNotEmpty)
                            .toList();
                    return _buildSearchableDropdown(
                      hint: "Choose Developer",
                      items: items,
                      value: selectedDeveloper,
                      onChanged:
                          (val) => setState(() => selectedDeveloper = val),
                      isTablet7: isTablet7,
                      isTablet10: isTablet10,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),

              /// ✅ Projects - قابل للبحث
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsSuccess) {
                    final items =
                        (state.projectsModel.data ?? [])
                            .map((e) => e.name ?? '')
                            .where((e) => e.isNotEmpty)
                            .toList();
                    return _buildSearchableDropdown(
                      hint: "Choose Project",
                      items: items,
                      value: selectedProject,
                      onChanged: (val) => setState(() => selectedProject = val),
                      isTablet7: isTablet7,
                      isTablet10: isTablet10,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),

              /// ✅ Channels - قابل للبحث
              BlocBuilder<ChannelCubit, ChannelState>(
                builder: (context, state) {
                  if (state is ChannelLoaded) {
                    final items =
                        state.channelResponse.data
                            .map((e) => e.name ?? '')
                            .where((e) => e.isNotEmpty)
                            .toList();
                    return _buildSearchableDropdown(
                      hint: "Choose channel",
                      items: items,
                      value: selectedChannel,
                      onChanged: (val) => setState(() => selectedChannel = val),
                      isTablet7: isTablet7,
                      isTablet10: isTablet10,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),

              /// ✅ Stages - قابل للبحث
              BlocBuilder<StagesCubit, StagesState>(
                builder: (context, state) {
                  if (state is StagesLoaded) {
                    final items =
                        state.stages
                            .map((e) => e.name ?? '')
                            .where((e) => e.isNotEmpty)
                            .toList();
                    return _buildSearchableDropdown(
                      hint: "Choose Stage",
                      items: items,
                      value: selectedStage,
                      onChanged: (val) => setState(() => selectedStage = val),
                      isTablet7: isTablet7,
                      isTablet10: isTablet10,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 12),
              buildDateField(
                "Last Stage Update (Start)",
                _lastStageUpdateStart,
                (v) => setState(() => _lastStageUpdateStart = v),
                isTablet7,
                isTablet10,
              ),
              buildDateField(
                "Last Stage Update (End)",
                _lastStageUpdateEnd,
                (v) => setState(() => _lastStageUpdateEnd = v),
                isTablet7,
                isTablet10,
              ),
              buildDateField(
                "Creation Date (Start)",
                _startDate,
                (v) => setState(() => _startDate = v),
                isTablet7,
                isTablet10,
              ),
              buildDateField(
                "Creation Date (End)",
                _endDate,
                (v) => setState(() => _endDate = v),
                isTablet7,
                isTablet10,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          nameController.clear();
                          selectedCountry = null;
                          selectedDeveloper = null;
                          selectedProject = null;
                          selectedStage = null;
                          selectedChannel = null;
                          _startDate = null;
                          _endDate = null;
                          _lastStageUpdateStart = null;
                          _lastStageUpdateEnd = null;
                        });

                        final clearedFilters = {
                          'name': null,
                          'developerId': null,
                          'projectId': null,
                          'stageId': null,
                          'channelId': null,
                          'creationDateFrom': null,
                          'creationDateTo': null,
                          'stageDateFrom': null,
                          'stageDateTo': null,
                        };
                        widget.onFiltersApplied?.call(clearedFilters);

                        context
                            .read<GetLeadsCubit>()
                            .fetchSalesLeadsWithPagination(
                              search: null,
                              developerId: null,
                              projectId: null,
                              channelId: null,
                              stageId: null,
                              stageDateFrom: null,
                              stageDateTo: null,
                              creationDateFrom: null,
                              creationDateTo: null,
                              data: widget.data,
                              transferefromdata: widget.transferfromdata,
                              resetPagination: true, // ✅ ضروري
                            );

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical:
                              isTablet10
                                  ? 16
                                  : isTablet7
                                  ? 14
                                  : 10,
                        ),
                        side: BorderSide(color: Constants.maincolor),
                      ),
                      child: Text(
                        "Reset",
                        style: TextStyle(
                          color: Constants.maincolor,
                          fontSize:
                              isTablet10
                                  ? 18
                                  : isTablet7
                                  ? 16
                                  : 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final stagesState = context.read<StagesCubit>().state;
                        final developersState =
                            context.read<DevelopersCubit>().state;
                        final projectsState =
                            context.read<ProjectsCubit>().state;
                        final channelsState =
                            context.read<ChannelCubit>().state;

                        String? developerId;
                        String? projectId;
                        String? stageId;
                        String? channelId;

                        // ✅ orElse أضيفت لمنع الـ crash لو العنصر مش موجود
                        if (developersState is DeveloperSuccess &&
                            selectedDeveloper != null) {
                          final match =
                              developersState.developersModel.data
                                  .where((e) => e.name == selectedDeveloper)
                                  .toList();
                          developerId =
                              match.isNotEmpty
                                  ? match.first.id.toString()
                                  : null;
                        }

                        if (projectsState is ProjectsSuccess &&
                            selectedProject != null) {
                          final match =
                              (projectsState.projectsModel.data ?? [])
                                  .where((e) => e.name == selectedProject)
                                  .toList();
                          projectId =
                              match.isNotEmpty
                                  ? match.first.id.toString()
                                  : null;
                        }

                        if (channelsState is ChannelLoaded &&
                            selectedChannel != null) {
                          final match =
                              channelsState.channelResponse.data
                                  .where((e) => e.name == selectedChannel)
                                  .toList();
                          channelId =
                              match.isNotEmpty
                                  ? match.first.id.toString()
                                  : null;
                        }

                        if (stagesState is StagesLoaded &&
                            selectedStage != null) {
                          final match =
                              stagesState.stages
                                  .where((e) => e.name == selectedStage)
                                  .toList();
                          stageId =
                              match.isNotEmpty
                                  ? match.first.id.toString()
                                  : null;
                        }

                        final appliedFilters = {
                          'name':
                              nameController.text.trim().isEmpty
                                  ? null
                                  : nameController.text.trim(),
                          'developerId': developerId,
                          'projectId': projectId,
                          'stageId': stageId,
                          'channelId': channelId,
                          'creationDateFrom': _startDate,
                          'creationDateTo': _endDate,
                          'stageDateFrom': _lastStageUpdateStart,
                          'stageDateTo': _lastStageUpdateEnd,
                        };

                        widget.onFiltersApplied?.call(appliedFilters);

                        context
                            .read<GetLeadsCubit>()
                            .fetchSalesLeadsWithPagination(
                              search:
                                  nameController.text.trim().isEmpty
                                      ? null
                                      : nameController.text.trim(),
                              developerId: developerId,
                              projectId: projectId,
                              channelId: channelId,
                              stageId: stageId,
                              stageDateFrom: _lastStageUpdateStart,
                              stageDateTo: _lastStageUpdateEnd,
                              creationDateFrom: _startDate,
                              creationDateTo: _endDate,
                              data: widget.data,
                              transferefromdata: widget.transferfromdata,
                              resetPagination: true, // ✅ ضروري
                            );

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.maincolor,
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(color: Colors.white),
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
