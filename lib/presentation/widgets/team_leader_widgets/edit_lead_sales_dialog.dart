// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';

class EditLeadSalesDialog extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialPhone2;
  final String? initialWhatsappNumber;
  final String? initialNotes;
  final String? initialProjectId;
  final String? salesID;
  final void Function()? onSuccess;

  const EditLeadSalesDialog({
    super.key,
    required this.userId,
    this.initialName,
    this.initialPhone2,
    this.initialWhatsappNumber,
    this.initialNotes,
    this.initialProjectId,
    this.salesID,
    this.onSuccess,
  });

  @override
  State<EditLeadSalesDialog> createState() => _EditLeadDialogState();
}

class _EditLeadDialogState extends State<EditLeadSalesDialog> {
  late TextEditingController nameController;
  late TextEditingController phone2Controller;
  late TextEditingController whatsappNumberController;
  late TextEditingController notesController;
  String? selectedProjectId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    phone2Controller = TextEditingController(text: widget.initialPhone2 ?? '');
    whatsappNumberController = TextEditingController(
      text: widget.initialWhatsappNumber ?? '',
    );
    notesController = TextEditingController(text: widget.initialNotes ?? '');
    selectedProjectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    nameController.dispose();
    phone2Controller.dispose();
    whatsappNumberController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Lead'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phone2Controller,
              decoration: const InputDecoration(
                labelText: 'second Phone Number',
              ),
            ),
            TextField(
              controller: whatsappNumberController,
              decoration: const InputDecoration(labelText: 'whatsapp Number'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
            BlocBuilder<ProjectsCubit, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsSuccess) {
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedProjectId,
                      decoration: const InputDecoration(labelText: 'Project'),
                      items:
                          state.projectsModel.data!.map((project) {
                            return DropdownMenuItem<String>(
                              value: project.id.toString(),
                              child: Text(
                                project.name!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProjectId = value;
                        });
                      },
                    ),
                  );
                } else if (state is ProjectsLoading) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocConsumer<EditLeadCubit, EditLeadState>(
          listener: (context, state) {
            if (state is EditLeadSuccess) {
              Navigator.pop(context);
              if (widget.onSuccess != null) {
                widget.onSuccess!(); // 👈 Call callback
              }
              // ✅ بعد ما يحصل التعديل، نعمل تحديث مباشر للداتا

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edited Successfully')),
              );
            } else if (state is EditLeadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit Failed: ${state.error}')),
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
                // نجهز خريطة بالحقول اللي فيها قيم فعلًا
                final Map<String, dynamic> updatedFields = {};

                if (nameController.text.trim().isNotEmpty) {
                  updatedFields['name'] = nameController.text.trim();
                }
                if (phone2Controller.text.trim().isNotEmpty) {
                  updatedFields['phonenumber2'] = phone2Controller.text.trim();
                }
                if (whatsappNumberController.text.trim().isNotEmpty) {
                  updatedFields['whatsappnumber'] =
                      whatsappNumberController.text.trim();
                }
                if (notesController.text.trim().isNotEmpty) {
                  updatedFields['notes'] = notesController.text.trim();
                }
                if (selectedProjectId != null &&
                    selectedProjectId!.isNotEmpty) {
                  updatedFields['project'] = selectedProjectId;
                }
                // نتحقق إن فيه حاجة فعلاً اتغيرت
                if (updatedFields.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No changes to update')),
                  );
                  return;
                }

                // نرسل الداتا الفعلية
                context.read<EditLeadCubit>().editLead(
                  userId: widget.userId,
                  name: updatedFields['name'],
                  phone2: updatedFields['phonenumber2'],
                  whatsappNumber: updatedFields['whatsappnumber'],
                  notes: updatedFields['notes'],
                  project: updatedFields['project'],
                  salesIdd: widget.salesID,
                );
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            );
          },
        ),
      ],
    );
  }
}
