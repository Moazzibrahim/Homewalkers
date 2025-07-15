import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';

class UpdateUserDialog extends StatefulWidget {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool opencomments;
  final bool closeDoneDealcomments;

  final void Function({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String role,
    required bool opencomments,
    required bool closeDoneDealcomments,
  })
  onUpdate;

  const UpdateUserDialog({
    super.key,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.opencomments,
    required this.closeDoneDealcomments,
    required this.onUpdate,
  });

  @override
  State<UpdateUserDialog> createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  final roles = ['Admin', 'Marketer', 'Manager', 'Team Leader', 'Sales'];

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedRole;
  late bool _openComments;
  late bool _closeDoneDealComments;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _selectedRole = widget.role;
    _openComments = widget.opencomments;
    _closeDoneDealComments = widget.closeDoneDealcomments;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    child: Image.asset("assets/images/Vector.png"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Update User",
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

              // Input fields
              _buildInputField(_nameController, "Name"),
              const SizedBox(height: 12),
              _buildInputField(_emailController, "Email"),
              const SizedBox(height: 12),
              _buildInputField(_phoneController, "Phone"),
              const SizedBox(height: 12),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items:
                    roles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(
                          role,
                          style: GoogleFonts.montserrat(fontSize: 14),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Select Role",
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              // Toggle switches
              SwitchListTile(
                activeColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
                title: Text("Open Comments", style: GoogleFonts.montserrat()),
                value: _openComments,
                onChanged: (value) {
                  setState(() => _openComments = value);
                },
              ),
              SwitchListTile(
                activeColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
                title: Text(
                  "Close Done Deal Comments",
                  style: GoogleFonts.montserrat(),
                ),
                value: _closeDoneDealComments,
                onChanged: (value) {
                  setState(() => _closeDoneDealComments = value);
                },
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF003D48)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
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
                        // القيم الجديدة بعد التعديل
                        final newName = _nameController.text.trim();
                        final newEmail = _emailController.text.trim();
                        final newPhone = _phoneController.text.trim();
                        final isSomethingChanged =
                            newName != widget.name ||
                            newEmail != widget.email ||
                            newPhone != widget.phone ||
                            _selectedRole != widget.role ||
                            _openComments != widget.opencomments ||
                            _closeDoneDealComments !=
                                widget.closeDoneDealcomments;

                        if (!isSomethingChanged) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please change at least one field before updating.',
                              ),
                            ),
                          );
                          return;
                        }
                        widget.onUpdate(
                          id: widget.id,
                          name: newName,
                          email: newEmail,
                          phone: newPhone,
                          role: _selectedRole,
                          opencomments: _openComments,
                          closeDoneDealcomments: _closeDoneDealComments,
                        );
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

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
