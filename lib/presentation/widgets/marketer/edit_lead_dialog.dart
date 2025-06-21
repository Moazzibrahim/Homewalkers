import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';

class EditLeadDialog extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;

  const EditLeadDialog({
    super.key,
    required this.userId,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
  });

  @override
  State<EditLeadDialog> createState() => _EditLeadDialogState();
}

class _EditLeadDialogState extends State<EditLeadDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    emailController = TextEditingController(text: widget.initialEmail ?? '');
    phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Lead'), // Translated
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'), // Translated
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'), // Translated
          ),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'), // Translated
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'), // Translated
        ),
        BlocConsumer<EditLeadCubit, EditLeadState>(
          listener: (context, state) {
            if (state is EditLeadSuccess) {
              Navigator.pop(context); // Close the dialog
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Edited Successfully'))); // Translated
            } else if (state is EditLeadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit Failed: ${state.error}')), // Translated
              );
            }
          },
          builder: (context, state) {
            if (state is EditLeadLoading) {
              return const CircularProgressIndicator();
            }
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.maincolor,
              ),
              onPressed: () {
                context.read<EditLeadCubit>().editLead(
                      userId: widget.userId,
                      name: nameController.text.trim().isEmpty
                          ? null
                          : nameController.text.trim(),
                      email: emailController.text.trim().isEmpty
                          ? null
                          : emailController.text.trim(),
                      phone: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                    );
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)), // Translated
            );
          },
        ),
      ],
    );
  }
}
