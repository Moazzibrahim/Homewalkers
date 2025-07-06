import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/stage_types/cubit/get_stage_types_cubit.dart';

class AddStageDialog extends StatefulWidget {
  final void Function({
    required String name,
    required String stageType,
    String? comment,
  })
  onAdd;

  const AddStageDialog({super.key, required this.onAdd});

  @override
  State<AddStageDialog> createState() => _AddStageDialogState();
}

class _AddStageDialogState extends State<AddStageDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String? _selectedStageTypeId;

  @override
  void initState() {
    super.initState();
    // تحميل أنواع المراحل عند بداية عرض النموذج
    context.read<StagesCubit>().fetchStages();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Stage"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, 'Stage Name', isRequired: true),
              const SizedBox(height: 12),
              _buildTextField(_commentController, 'Comment', isRequired: false),
              const SizedBox(height: 12),
              BlocBuilder<GetStageTypesCubit, GetStageTypesState>(
                builder: (context, state) {
                  if (state is GetStageTypesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetStageTypesSuccess) {
                    final stages = state.response.data ?? [];
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Stage Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedStageTypeId,
                      items:
                          stages.map((stage) {
                            return DropdownMenuItem<String>(
                              value: stage.id,
                              child: Text(stage.name!),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStageTypeId = value!;
                        });
                      },
                      validator:
                          (value) =>
                              value == null
                                  ? 'Please select a stage type'
                                  : null,
                    );
                  } else if (state is GetStageTypesFailure) {
                    return Text('Error: ${state.message}');
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(
                name: _nameController.text,
                stageType: _selectedStageTypeId!,
                comment: _commentController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator:
          isRequired
              ? (value) =>
                  value == null || value.isEmpty
                      ? 'This field is required'
                      : null
              : null,
    );
  }
}
