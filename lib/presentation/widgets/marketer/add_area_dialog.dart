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

  // ── Design tokens ──
  bool get _isLight => Theme.of(context).brightness == Brightness.light;
  Color get _mainColor =>
      _isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
  Color get _textColor => _isLight ? const Color(0xff111827) : Colors.white;
  Color get _subTextColor =>
      _isLight ? Colors.grey.shade500 : Colors.grey[400]!;
  Color get _backgroundColor =>
      _isLight ? Colors.white : const Color(0xff1E1E1E);
  Color get _fieldFillColor =>
      _isLight ? const Color(0xffF7F8FA) : const Color(0xff2A2A2A);
  Color get _fieldBorderColor =>
      _isLight ? const Color(0xffE5E7EB) : Colors.grey.shade800;

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: _subTextColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: regionCubit)],
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ── Header ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _mainColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/images/area.svg",
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            _mainColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "New Area",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Enter the area details below",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: _subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              _isLight
                                  ? Colors.grey.shade100
                                  : Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: _subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ── Body (scrollable) ───────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("Area info"),

                      /// Area Name
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration("Area Name"),
                      ),
                      const SizedBox(height: 14),

                      /// Region Dropdown
                      BlocBuilder<RegionCubit, RegionState>(
                        builder: (context, state) {
                          if (state is RegionLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (state is RegionLoaded) {
                            return DropdownButtonFormField<String>(
                              value: selectedRegionId,
                              decoration: _inputDecoration("Select Region"),
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
                                    log(
                                      "Selected region ID: $selectedRegionId",
                                    );
                                  }),
                            );
                          } else {
                            return Text(
                              "Failed to load regions",
                              style: const TextStyle(color: Colors.redAccent),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              /// ── Buttons ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _fieldBorderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
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
                            backgroundColor: _mainColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
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
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _subTextColor, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: _fieldFillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _fieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _fieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _mainColor, width: 1.6),
      ),
    );
  }
}
