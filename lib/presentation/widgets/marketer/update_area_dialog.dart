import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/region_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/Region/region_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/Region/region_state.dart';

class UpdateAreaDialog extends StatefulWidget {
  final void Function(String name, String regionId)? onAdd;
  final String? title;
  final String? oldName;
  final String? oldRegionId;

  const UpdateAreaDialog({
    super.key,
    this.onAdd,
    this.title,
    this.oldName,
    this.oldRegionId,
  });

  @override
  State<UpdateAreaDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<UpdateAreaDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedRegionId;
  late final RegionCubit regionCubit;

  @override
  void initState() {
    super.initState();
    regionCubit = RegionCubit(RegionApiService())..fetchRegions();
    _nameController.text = widget.oldName ?? '';
    selectedRegionId = widget.oldRegionId;
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
                      child: Image.asset("assets/images/Vector.png"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "update area",
                        style: GoogleFonts.montserrat(
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
                          backgroundColor:
                              isDark
                                  ? Constants.mainDarkmodecolor
                                  : Constants.maincolor,
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newName = _nameController.text.trim();
                          final newRegionId = selectedRegionId;

                          final isChanged =
                              newName != (widget.oldName ?? '') ||
                              newRegionId != (widget.oldRegionId ?? '');

                          if (!isChanged) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please change at least one field.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (widget.onAdd != null && newRegionId != null) {
                            widget.onAdd!(newName, newRegionId);
                            Navigator.of(context).pop();
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
                          "update",
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
