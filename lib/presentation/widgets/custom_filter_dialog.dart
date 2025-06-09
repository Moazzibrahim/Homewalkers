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

void showFilterDialog(BuildContext context) {
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
          child: const FilterDialog(),
        ),
  );
}

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

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
  List<Country> countries = [];

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
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedCountry?.name ?? "Select Country",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 👇 Developer Dropdown باستخدام BlocBuilder
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
                      value: selectedDeveloper,
                      onChanged:
                          (val) => setState(() => selectedDeveloper = val),
                    );
                  } else if (state is DeveloperError) {
                    return Text(
                      "خطأ: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is ProjectsSuccess) {
                    final items =
                        state.projectsModel.data
                            .map((project) => project.name)
                            .toList();
                    return CustomDropdownField(
                      hint: "Choose Project",
                      items: items,
                      value: selectedProject,
                      onChanged: (val) => setState(() => selectedProject = val),
                    );
                  } else if (state is ProjectsError) {
                    return Text(
                      "خطأ: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
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
                      value: selectedChannel,
                      onChanged: (val) => setState(() => selectedChannel = val),
                    );
                  } else if (state is ChannelError) {
                    return Text(
                      "خطأ: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 12),
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
                      value: selectedStage,
                      onChanged: (value) {
                        setState(() {
                          selectedStage = value;
                        });
                      },
                    );
                  } else if (state is StagesError) {
                    return Text(
                      "خطأ: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
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
                          nameController.clear();
                          selectedCountry = null;
                          selectedDeveloper = null;
                          selectedProject = null;
                          selectedStage = null;
                          selectedChannel = null;
                        });
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          color: Color(0xff326677),
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
                        context.read<GetLeadsCubit>().filterLeads(
                          name:
                              nameController.text.trim().isEmpty
                                  ? null
                                  : nameController.text.trim(),
                          country: selectedCountry?.phoneCode, // مثل: "20"
                          developer: selectedDeveloper,
                          project: selectedProject,
                          stage: selectedStage,
                          channel: selectedChannel,
                        );
                        Navigator.pop(context); // ✅ اقفل الـDialog بعد التطبيق
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
