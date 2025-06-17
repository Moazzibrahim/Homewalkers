import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final TextEditingController _dateController = TextEditingController();
  String? selectedDeveloper;
  String? selectedProject;
  String? selectedStage;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // أقل تاريخ ممكن تختاره
      lastDate: DateTime(2050), // أكبر تاريخ ممكن تختاره
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => DevelopersCubit(DeveloperApiService())..getDevelopers(),
        ),
        BlocProvider(
          create: (_) => ProjectsCubit(ProjectsApiService())..fetchProjects(),
        ),
        BlocProvider(
          create: (_) => StagesCubit(StagesApiService())..fetchStages(),
        ),
      ],

      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: "create lead",
              onBack: () => Navigator.pop(context),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  // color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Create New Lead",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(hint: "Full Name"),
                    CustomTextField(hint: "Email Address"),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(143, 146, 146, 1),
                          ),
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        initialCountryCode: 'AE',
                        onChanged: (phone) {
                          log(phone.completeNumber);
                        },
                      ),
                    ),

                    /// ✅ Creation Date with Date Picker
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Creation Date",
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(143, 146, 146, 1),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffE1E1E1),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

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
                                (val) =>
                                    setState(() => selectedDeveloper = val),
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
                            value: selectedProject,
                            onChanged:
                                (val) => setState(() => selectedProject = val),
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
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                              side: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.maincolor
                                      : Constants.mainDarkmodecolor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Add Lead",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }
}
