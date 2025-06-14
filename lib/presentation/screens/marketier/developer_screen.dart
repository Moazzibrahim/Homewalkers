// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/add_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/delete_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/update_dialog.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF4F4F4),
      appBar: CustomAppBar(
        title: "Developer",
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AddDialog(
                            onAdd: (value) {
                              // هنا تنفذ العملية بعد الضغط على Add
                              print("تمت الإضافة: $value");
                            },
                            title: "Developer",
                          ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Add New Developer",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCommunicationCard(
              "Mobile",
              "23 April 2025 - 8:37 AM",
              Constants.maincolor,
              context,
            ),
            const SizedBox(height: 12),
            _buildCommunicationCard(
              "WhatsApp",
              "23 April 2025 - 8:37 AM",
              Constants.maincolor,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationCard(
    String name,
    String dateTime,
    Color mainColor,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE5F4F5),
                child: Icon(
                  Icons.contact_mail,
                  size: 16,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Developer : $name",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE5F4F5),
                child: Icon(
                  Icons.calendar_today,
                  size: 16,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Creation Date : $dateTime",
                  style: GoogleFonts.montserrat(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.copy, size: 20, color: Colors.grey),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => UpdateDialog(
                          onAdd: (value) {
                            // هنا تنفذ العملية بعد الضغط على Add
                            print("تمت الإضافة: $value");
                          },
                          title: "Developer",
                        ),
                  );
                },
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => DeleteDialog(
                          onCancel: () => Navigator.of(context).pop(),
                          onConfirm: () {
                            // تنفيذ الحذف
                            Navigator.of(context).pop();
                          },
                          title: "Developer",
                        ),
                  );
                },
                child: Image.asset("assets/images/delete.png"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
