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
    final media = MediaQuery.of(context);
    final width = media.size.width;

    final bool isTablet7 = width >= 600 && width < 900;
    final bool isTablet10 = width >= 900;

    final double dialogHorizontalPadding =
        isTablet10
            ? 220
            : isTablet7
            ? 120
            : 24;

    final double fieldFontSize =
        isTablet10
            ? 18
            : isTablet7
            ? 16
            : 14;

    final double verticalSpacing =
        isTablet10
            ? 18
            : isTablet7
            ? 14
            : 10;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: dialogHorizontalPadding,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Edit Lead',
        style: TextStyle(
          fontSize:
              isTablet10
                  ? 22
                  : isTablet7
                  ? 19
                  : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(fontSize: fieldFontSize),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(fontSize: fieldFontSize),
              ),
            ),
            SizedBox(height: verticalSpacing),
            TextField(
              controller: phone2Controller,
              style: TextStyle(fontSize: fieldFontSize),
              decoration: InputDecoration(
                labelText: 'second Phone Number',
                labelStyle: TextStyle(fontSize: fieldFontSize),
              ),
            ),
            SizedBox(height: verticalSpacing),
            TextField(
              controller: whatsappNumberController,
              style: TextStyle(fontSize: fieldFontSize),
              decoration: InputDecoration(
                labelText: 'whatsapp Number',
                labelStyle: TextStyle(fontSize: fieldFontSize),
              ),
            ),
            SizedBox(height: verticalSpacing),
            TextField(
              controller: notesController,
              style: TextStyle(fontSize: fieldFontSize),
              decoration: InputDecoration(
                labelText: 'Notes',
                labelStyle: TextStyle(fontSize: fieldFontSize),
              ),
              maxLines: 2,
            ),
            SizedBox(height: verticalSpacing),
            BlocBuilder<ProjectsCubit, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsSuccess) {
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedProjectId,
                      decoration: InputDecoration(
                        labelText: 'Project',
                        labelStyle: TextStyle(fontSize: fieldFontSize),
                      ),
                      items:
                          state.projectsModel.data!.map((project) {
                            return DropdownMenuItem<String>(
                              value: project.id.toString(),
                              child: Text(
                                project.name!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: fieldFontSize),
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
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical:
            isTablet10
                ? 16
                : isTablet7
                ? 12
                : 8,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(fontSize: fieldFontSize)),
        ),
        BlocConsumer<EditLeadCubit, EditLeadState>(
          listener: (context, state) {
            if (state is EditLeadSuccess) {
              Navigator.pop(context);
              widget.onSuccess?.call();
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
              return const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              );
            }

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.maincolor,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      isTablet10
                          ? 32
                          : isTablet7
                          ? 26
                          : 20,
                  vertical:
                      isTablet10
                          ? 14
                          : isTablet7
                          ? 12
                          : 10,
                ),
              ),
              onPressed: () {
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

                if (updatedFields.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No changes to update')),
                  );
                  return;
                }

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
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fieldFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
