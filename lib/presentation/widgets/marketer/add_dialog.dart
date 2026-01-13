import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class AddDialog extends StatefulWidget {
  final void Function(String)? onAdd;
  final String? title;

  const AddDialog({super.key, this.onAdd, this.title});

  @override
  State<AddDialog> createState() => _NewCommunicationDialogState();
}

class _NewCommunicationDialogState extends State<AddDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
    final textColor = isLight ? Colors.black : Colors.white;
    final backgroundColor = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final hintTextColor = isLight ? Colors.grey : Colors.grey[400];
    final borderColor = mainColor;
    final cancelTextColor = isLight ? Constants.maincolor : Colors.grey[300];

    return Dialog(
      backgroundColor: backgroundColor,
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
                  backgroundColor: mainColor,
                  child: SvgPicture.asset("assets/images/add.svg"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "New ${widget.title}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Input Field
            TextField(
              controller: _controller,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "${widget.title} Name",
                hintStyle: TextStyle(color: hintTextColor),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mainColor, width: 2),
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
                      side: BorderSide(color: mainColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: cancelTextColor),
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
                      backgroundColor: mainColor,
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
    );
  }
}
