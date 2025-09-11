import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class AddCancelReasonDialog extends StatefulWidget {
  final void Function(String)? onAdd;
  final String? title;

  const AddCancelReasonDialog({super.key, this.onAdd, this.title});

  @override
  State<AddCancelReasonDialog> createState() => _NewCommunicationDialogState();
}

class _NewCommunicationDialogState extends State<AddCancelReasonDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                  child: Image.asset("assets/images/Vector.png"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "New ${widget.title}",
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
            // Input Field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Reason",
                hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
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
                      style: GoogleFonts.montserrat(color: Constants.maincolor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onAdd != null) {
                        widget.onAdd!(_controller.text.trim());
                      }
                      Navigator.of(context).pop();
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
    );
  }
}
