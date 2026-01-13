import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/region_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/Region/region_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/Region/region_state.dart';

class AddAreaDialog extends StatefulWidget {
  final void Function(String name, String regionId)? onAdd;
  final String? title;
  const AddAreaDialog({super.key, this.onAdd, this.title});

  @override
  State<AddAreaDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddAreaDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedRegionId;
  late final RegionCubit regionCubit;

  @override
  void initState() {
    super.initState();
    regionCubit = RegionCubit(RegionApiService())..fetchRegions();
  }

  @override
  void dispose() {
    regionCubit.close();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: regionCubit)],
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
                      child: SvgPicture.asset("assets/images/area.svg"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "New area",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// area Name
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration("area Name"),
                ),
                const SizedBox(height: 14),

                /// region Dropdown
                BlocBuilder<RegionCubit, RegionState>(
                  builder: (context, state) {
                    if (state is RegionLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is RegionLoaded) {
                      return DropdownButtonFormField<String>(
                        value: selectedRegionId,
                        decoration: _inputDecoration("Select region"),
                        items:
                            state.regions.data
                                .map<DropdownMenuItem<String>>(
                                  (dev) => DropdownMenuItem<String>(
                                    value: dev.id.toString(),
                                    child: Text(dev.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() {
                              selectedRegionId = value;
                              log("Selected region ID: $selectedRegionId");
                            }),
                      );
                    } else {
                      return const Text("Failed to load regions");
                    }
                  },
                ),
                const SizedBox(height: 24),

                /// Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Constants.maincolor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Constants.maincolor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onAdd != null) {
                            if (_nameController.text.trim().isNotEmpty &&
                                selectedRegionId != null) {
                              widget.onAdd!(
                                _nameController.text.trim(),
                                selectedRegionId!,
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
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
