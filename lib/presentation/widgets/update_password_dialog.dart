import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class UpdateUserPasswordDialog extends StatefulWidget {
  final String userId;
  final Future<void> Function(
    String id,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  )
  onUpdatePassword;

  const UpdateUserPasswordDialog({
    super.key,
    required this.userId,
    required this.onUpdatePassword,
  });

  @override
  State<UpdateUserPasswordDialog> createState() =>
      _UpdateUserPasswordDialogState();
}

class _UpdateUserPasswordDialogState extends State<UpdateUserPasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      child: const Icon(Icons.lock, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Update Password",
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

                _buildPasswordField(
                  _currentPasswordController,
                  "Current Password",
                ),
                const SizedBox(height: 12),
                _buildPasswordField(_newPasswordController, "New Password"),
                const SizedBox(height: 12),
                _buildPasswordField(
                  _confirmPasswordController,
                  "Confirm Password",
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await widget.onUpdatePassword(
                              widget.userId,
                              _currentPasswordController.text.trim(),
                              _newPasswordController.text.trim(),
                              _confirmPasswordController.text.trim(),
                            );
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
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$hint is required';
        if (hint == "Confirm Password" &&
            value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
