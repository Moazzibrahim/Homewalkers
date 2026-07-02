import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddUsersDialog extends StatefulWidget {
  final void Function({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String role,
    String? imagePath,
  })
  onAdd;

  const AddUsersDialog({super.key, required this.onAdd});

  @override
  State<AddUsersDialog> createState() => _AddUsersDialogState();
}

class _AddUsersDialogState extends State<AddUsersDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _roleSearchController = TextEditingController();

  String _selectedRole = 'Admin';
  String? _selectedImagePath;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _showRoleDropdown = false;

  final List<String> _allRoles = [
    'Admin',
    'Marketer',
    'Manager',
    'Team Leader',
    'Sales',
  ];
  List<String> _filteredRoles = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _filteredRoles = List.from(_allRoles);
    _roleSearchController.addListener(() {
      final q = _roleSearchController.text.toLowerCase();
      setState(() {
        _filteredRoles =
            _allRoles.where((r) => r.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _roleSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _selectedImagePath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mainColor =
        isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
    final bgColor =
        isLight ? Constants.backgroundlightmode : Constants.backgroundDarkmode;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Add New User",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image at top center
                      Center(child: _buildImageSection(mainColor, isLight)),
                      const SizedBox(height: 24),

                      _sectionLabel("Personal Info", isLight),
                      const SizedBox(height: 10),
                      _buildField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        mainColor: mainColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        mainColor: mainColor,
                        isLight: isLight,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        mainColor: mainColor,
                        isLight: isLight,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),

                      _sectionLabel("Security", isLight),
                      const SizedBox(height: 10),
                      _buildField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        mainColor: mainColor,
                        isLight: isLight,
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        mainColor: mainColor,
                        isLight: isLight,
                        obscure: _obscureConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                        ),
                        extraValidator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      _sectionLabel("Role", isLight),
                      const SizedBox(height: 10),
                      _buildRoleSelector(mainColor, isLight),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),

            // ── Actions ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: mainColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onAdd(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text,
                            passwordConfirm: _confirmPasswordController.text,
                            role: _selectedRole,
                            imagePath: _selectedImagePath,
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Add User",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
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

  // ── Section Label ──────────────────────────────────────────────────────
  Widget _sectionLabel(String label, bool isLight) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isLight ? Colors.grey[500] : Colors.grey[400],
        letterSpacing: 1.2,
      ),
    );
  }

  // ── Text Field ─────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color mainColor,
    required bool isLight,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? extraValidator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: isLight ? Colors.black87 : Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isLight ? Colors.grey[500] : Colors.grey[400],
        ),
        prefixIcon: Icon(icon, color: mainColor, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isLight ? Colors.white : const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isLight ? Colors.grey[200]! : Colors.grey[700]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isLight ? Colors.grey[200]! : Colors.grey[700]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: mainColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return '$label is required';
        if (extraValidator != null) return extraValidator(value);
        return null;
      },
    );
  }

  // ── Role Selector with Search ──────────────────────────────────────────
  Widget _buildRoleSelector(Color mainColor, bool isLight) {
    return Column(
      children: [
        // Selected role display / tap to open
        GestureDetector(
          onTap: () {
            setState(() {
              _showRoleDropdown = !_showRoleDropdown;
              if (!_showRoleDropdown) _roleSearchController.clear();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    _showRoleDropdown
                        ? mainColor
                        : (isLight ? Colors.grey[200]! : Colors.grey[700]!),
                width: _showRoleDropdown ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.badge_outlined, color: mainColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedRole,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLight ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
                Icon(
                  _showRoleDropdown
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ],
            ),
          ),
        ),

        // Expandable search + list
        if (_showRoleDropdown) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: isLight ? Colors.white : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLight ? Colors.grey[200]! : Colors.grey[700]!,
              ),
            ),
            child: Column(
              children: [
                // Search field inside dropdown
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _roleSearchController,
                    style: TextStyle(
                      fontSize: 13,
                      color: isLight ? Colors.black87 : Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search role...",
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isLight ? Colors.grey[400] : Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: isLight ? Colors.grey[400] : Colors.grey[500],
                      ),
                      filled: true,
                      fillColor:
                          isLight ? Colors.grey[50] : const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Role list
                ..._filteredRoles.map((role) {
                  final isSelected = role == _selectedRole;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRole = role;
                        _showRoleDropdown = false;
                        _roleSearchController.clear();
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? mainColor
                                        : (isLight
                                            ? Colors.black87
                                            : Colors.white),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              color: mainColor,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Image Section ──────────────────────────────────────────────────────
  Widget _buildImageSection(Color mainColor, bool isLight) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mainColor.withOpacity(0.1),
                border: Border.all(color: mainColor.withOpacity(0.3), width: 2),
                image:
                    _selectedImagePath != null
                        ? DecorationImage(
                          image: FileImage(File(_selectedImagePath!)),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _selectedImagePath == null
                      ? Icon(Icons.person_outline, color: mainColor, size: 36)
                      : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _showImageSourcePicker(mainColor, isLight),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: mainColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLight ? Colors.white : Colors.grey[900]!,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Profile Photo",
          style: TextStyle(
            fontSize: 12,
            color: isLight ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  void _showImageSourcePicker(Color mainColor, bool isLight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight ? Colors.white : const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 44,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library_outlined, color: mainColor),
                  ),
                  title: const Text("Choose from Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt_outlined, color: mainColor),
                  ),
                  title: const Text("Take a Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}
