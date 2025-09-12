import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class AddChannelDialog extends StatefulWidget {
  final void Function(String name, String code)? onAdd;
  final String? title;
  const AddChannelDialog({super.key, this.onAdd, this.title});

  @override
  State<AddChannelDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddChannelDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
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
                    child: Image.asset("assets/images/Vector.png"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "New channel",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child:  Icon(Icons.close, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Project Name
              TextField(
                controller: _nameController,
                decoration: _inputDecoration("channel Name"),
              ),
              const SizedBox(height: 14),

              /// code
              TextField(
                controller: _codeController,
                decoration: _inputDecoration("code"),
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
                        style: GoogleFonts.montserrat(
                          color: Constants.maincolor,
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
                              _codeController.text.trim().isNotEmpty) {
                            widget.onAdd!(
                              _nameController.text.trim(),
                              _codeController.text.trim(),
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
