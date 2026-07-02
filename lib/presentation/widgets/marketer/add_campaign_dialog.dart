// ignore_for_file: unused_field, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCampaignDialog extends StatefulWidget {
  final void Function(
    String name,
    String date,
    bool isActive,
    String cost,
    String addBy,
    String updatedBy,
  )?
  onAdd;
  final String? title;
  const AddCampaignDialog({super.key, this.onAdd, this.title});

  @override
  State<AddCampaignDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddCampaignDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  Future<String?> getSalesIdFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('salesId');
  }

  bool _isActive = true;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
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
    return Dialog(
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
                        "assets/images/campaign.svg",
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
                          "New Campaign",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Enter the campaign details below",
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
                      child: Icon(Icons.close, size: 18, color: _subTextColor),
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
                    _sectionLabel("Campaign info"),

                    /// Campaign Name
                    TextField(
                      controller: _nameController,
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration("Campaign Name"),
                    ),
                    const SizedBox(height: 14),

                    /// Cost
                    TextField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration("Cost"),
                    ),
                    const SizedBox(height: 14),

                    /// Date Picker
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _pickDate(context),
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration("Select Date").copyWith(
                        suffixIcon: Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: _mainColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel("Status"),

                    /// Active Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _fieldFillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _fieldBorderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Is Active",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _textColor,
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            activeColor: _mainColor,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
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
                        onPressed: () async {
                          if (widget.onAdd != null) {
                            if (_nameController.text.trim().isNotEmpty &&
                                _costController.text.trim().isNotEmpty &&
                                _dateController.text.trim().isNotEmpty) {
                              widget.onAdd!(
                                _nameController.text.trim(),
                                _dateController.text.trim(),
                                _isActive,
                                _costController.text.trim(),
                                await getSalesIdFromSharedPreferences() ?? "",
                                await getSalesIdFromSharedPreferences() ?? "",
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
