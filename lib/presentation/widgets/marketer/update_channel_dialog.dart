import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class UpdateChannelDialog extends StatefulWidget {
  final void Function(String name, String code)? onAdd;
  final String? title;
  final String? initialName;
  final String? initialCode;

  const UpdateChannelDialog({
    super.key,
    this.onAdd,
    this.title,
    this.initialName,
    this.initialCode,
  });

  @override
  State<UpdateChannelDialog> createState() => _NewCommunicationDialogState();
}

class _NewCommunicationDialogState extends State<UpdateChannelDialog> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialName ?? '';
    _codeController.text = widget.initialCode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    "Update ${widget.title}",
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
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "${widget.title} Name",
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: "Code",
                hintStyle: TextStyle(color: Colors.grey),
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Constants.maincolor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onAdd != null) {
                        widget.onAdd!(
                          _controller.text.trim(),
                          _codeController.text.trim(),
                        );
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
                      "Update",
                      style: TextStyle(color: Colors.white),
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
