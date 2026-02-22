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
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:country_picker/country_picker.dart';

void showFilterDialog(
  BuildContext context,
  bool? data,
  bool? transferfromdata,
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
          child: FilterDialog(data: data, transferfromdata: transferfromdata),
        ),
  );
}

class FilterDialog extends StatefulWidget {
  final bool? data;
  final bool? transferfromdata;
  const FilterDialog({super.key, this.data, this.transferfromdata});

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
              GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      setState(() {
                        selectedCountry = country;
                      });
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: "Select Country",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    child: Text(
                      selectedCountry?.name ?? "Select Country",
                      style: TextStyle(
                        fontSize:
                            isTablet10
                                ? 16
                                : isTablet7
                                ? 15
                                : 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              /// Developers
              BlocBuilder<DevelopersCubit, DevelopersState>(
                builder: (context, state) {
                  if (state is DeveloperSuccess) {
                    return CustomDropdownField(
                      hint: "Choose Developer",
                      items:
                          state.developersModel.data
                              .map((e) => e.name)
                              .toList(),
                      value: selectedDeveloper,
                      onChanged:
                          (val) => setState(() => selectedDeveloper = val),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),

              /// Projects
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsSuccess) {
                    return CustomDropdownField(
                      hint: "Choose Project",
                      items:
                          state.projectsModel.data!.map((e) => e.name).toList(),
                      value: selectedProject,
                      onChanged: (val) => setState(() => selectedProject = val),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),

              /// Channels
              BlocBuilder<ChannelCubit, ChannelState>(
                builder: (context, state) {
                  if (state is ChannelLoaded) {
                    return CustomDropdownField(
                      hint: "Choose channel",
                      items:
                          state.channelResponse.data
                              .map((e) => e.name)
                              .toList(),
                      value: selectedChannel,
                      onChanged: (val) => setState(() => selectedChannel = val),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),

              /// Stages
              BlocBuilder<StagesCubit, StagesState>(
                builder: (context, state) {
                  if (state is StagesLoaded) {
                    return CustomDropdownField(
                      hint: "Choose Stage",
                      items: state.stages.map((e) => e.name).toList(),
                      value: selectedStage,
                      onChanged: (val) => setState(() => selectedStage = val),
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

                        if (developersState is DeveloperSuccess &&
                            selectedDeveloper != null) {
                          developerId =
                              developersState.developersModel.data
                                  .firstWhere(
                                    (e) => e.name == selectedDeveloper,
                                  )
                                  .id
                                  .toString();
                        }

                        if (projectsState is ProjectsSuccess &&
                            selectedProject != null) {
                          projectId =
                              projectsState.projectsModel.data!
                                  .firstWhere((e) => e.name == selectedProject)
                                  .id
                                  .toString();
                        }

                        if (channelsState is ChannelLoaded &&
                            selectedChannel != null) {
                          channelId =
                              channelsState.channelResponse.data
                                  .firstWhere((e) => e.name == selectedChannel)
                                  .id
                                  .toString();
                        }

                        if (stagesState is StagesLoaded &&
                            selectedStage != null) {
                          stageId =
                              stagesState.stages
                                  .firstWhere((e) => e.name == selectedStage)
                                  .id
                                  .toString();
                        }

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
