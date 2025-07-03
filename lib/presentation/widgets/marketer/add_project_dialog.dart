import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_cities_api_service.dart';
import 'package:homewalkers_app/data/models/developers_model.dart';
import 'package:homewalkers_app/data/models/cities_model.dart';
import 'package:homewalkers_app/presentation/viewModels/cities/cubit/get_cities_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';

class AddProjectDialog extends StatefulWidget {
  final void Function(
    String name,
    String developerId,
    String cityId,
    String area,
  )?
  onAdd;
  final String? title;
  const AddProjectDialog({super.key, this.onAdd, this.title});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  String? selectedDeveloperId;
  String? selectedCityId;

  late final DevelopersCubit developersCubit;
  late final GetCitiesCubit citiesCubit;

  @override
  void initState() {
    super.initState();
    developersCubit = DevelopersCubit(DeveloperApiService())..getDevelopers();
    citiesCubit = GetCitiesCubit(GetCitiesApiService())..fetchCities();
  }

  @override
  void dispose() {
    developersCubit.close();
    citiesCubit.close();
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: developersCubit),
        BlocProvider.value(value: citiesCubit),
      ],
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          isDark
                              ? Constants.mainDarkmodecolor
                              : Constants.maincolor,
                      child: Image.asset("assets/images/Vector.png"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "New Project",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Project Name
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration("Project Name"),
                ),
                const SizedBox(height: 14),

                /// Developer Dropdown
                BlocBuilder<DevelopersCubit, DevelopersState>(
                  builder: (context, state) {
                    if (state is DeveloperLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is DeveloperSuccess) {
                      return DropdownButtonFormField<String>(
                        value: selectedDeveloperId,
                        decoration: _inputDecoration("Select Developer"),
                        items:
                            state.developersModel.data
                                .map(
                                  (DeveloperData dev) => DropdownMenuItem(
                                    value: dev.id.toString(),
                                    child: Text(dev.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() {
                              selectedDeveloperId = value;
                            }),
                      );
                    } else {
                      return const Text("Failed to load developers");
                    }
                  },
                ),
                const SizedBox(height: 14),

                /// City Dropdown
                BlocBuilder<GetCitiesCubit, GetCitiesState>(
                  builder: (context, state) {
                    if (state is GetCitiesLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is GetCitiesSuccess) {
                      return DropdownButtonFormField<String>(
                        value: selectedCityId,
                        decoration: _inputDecoration("Select City"),
                        items:
                            state.cities!
                                .map(
                                  (Cityy city) => DropdownMenuItem(
                                    value: city.id.toString(),
                                    child: Text(city.name ?? 'Unknown'),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() {
                              selectedCityId = value;
                            }),
                      );
                    } else {
                      return const Text("Failed to load cities");
                    }
                  },
                ),
                const SizedBox(height: 14),
                /// Area
                TextField(
                  controller: _areaController,
                  decoration: _inputDecoration("Area"),
                ),
                const SizedBox(height: 24),
                /// Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF003D48)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF003D48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onAdd != null) {
                            if (_nameController.text.trim().isNotEmpty &&
                                selectedDeveloperId != null &&
                                selectedCityId != null &&
                                _areaController.text.trim().isNotEmpty) {
                              widget.onAdd!(
                                _nameController.text.trim(),
                                selectedDeveloperId!,
                                selectedCityId!,
                                _areaController.text.trim(),
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Constants.maincolor
                                  : Constants.mainDarkmodecolor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Add",
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
