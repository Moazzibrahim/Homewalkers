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
    String? imagePath, // 👈 تم إضافته
  })
  onAdd;

  const AddUsersDialog({super.key, required this.onAdd});

  @override
  State<AddUsersDialog> createState() => _AddUsersDialogState();
}

class _AddUsersDialogState extends State<AddUsersDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _selectedRole = 'Admin';
  String? _selectedImagePath; // 👈 مسار الصورة

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New User"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_phoneController, 'Phone'),
              _buildTextField(_passwordController, 'Password', obscure: true),
              _buildTextField(
                _confirmPasswordController,
                'Confirm Password',
                obscure: true,
              ),
              _buildRoleDropdown(),
              const SizedBox(height: 10),
              _buildImagePickerSection(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
              backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,),
          onPressed: () => Navigator.of(context).pop(),
          child:  Text("Cancel",style: TextStyle( color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black),),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
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
                imagePath: _selectedImagePath, // 👈 تمرير الصورة
              );
              Navigator.of(context).pop();
            }
          },
          child:  Text("Add",style: TextStyle(color:  Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black),),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRoleDropdown() {
    final roles = ['Admin', 'Marketer', 'Manager', 'Team Leader', 'Sales'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: const InputDecoration(
          labelText: 'Role',
          border: OutlineInputBorder(),
        ),
        items:
            roles.map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedRole = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Profile Image",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
              icon:   Icon(Icons.photo,color:  Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.white),
              label:  Text("Gallery", style: TextStyle(fontSize: 10 ,color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
              ),
              onPressed: () => _pickImage(ImageSource.camera),
              icon:  Icon(Icons.camera_alt,color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.white),
              label: Text("Camera", style: TextStyle(fontSize: 10,color:  Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_selectedImagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_selectedImagePath!),
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}
