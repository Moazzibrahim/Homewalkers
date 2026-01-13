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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
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
                    child: SvgPicture.asset("assets/images/campaign.svg"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "New campaign",
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

              /// Campaign Name
              TextField(
                controller: _nameController,
                decoration: _inputDecoration("Campaign Name"),
              ),
              const SizedBox(height: 14),

              /// Cost
              TextField(
                controller: _costController,
                decoration: _inputDecoration("Cost"),
              ),
              const SizedBox(height: 14),

              /// Date Picker
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _pickDate(context),
                decoration: _inputDecoration("Select Date").copyWith(
                  suffixIcon: const Icon(Icons.calendar_today),
                ), // أيقونة التقويم
              ),
              const SizedBox(height: 14),

              /// Active Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Is Active", style: TextStyle(fontSize: 14)),
                  Switch(
                    value: _isActive,
                    activeColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ],
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
                        backgroundColor:
                            isDark
                                ? Constants.mainDarkmodecolor
                                : Constants.maincolor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Add", style: TextStyle(color: Colors.white)),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
