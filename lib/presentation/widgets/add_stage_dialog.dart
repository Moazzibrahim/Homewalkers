import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
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
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // ── Design tokens ──
  bool get _isLight => Theme.of(context).brightness == Brightness.light;
  Color get _mainColor =>
      _isLight ? Constants.maincolor : Constants.mainDarkmodecolor;
  Color get _textColor => _isLight ? const Color(0xff111827) : Colors.white;
  Color get _subTextColor =>
      _isLight ? Colors.grey.shade500 : Colors.grey[400]!;
  Color get _backgroundColor =>
      _isLight ? Colors.white : const Color(0xff1E1E1E);
  Color get _fieldFillColor =>
      _isLight ? const Color(0xffF7F8FA) : const Color(0xff2A2A2A);
  Color get _fieldBorderColor =>
      _isLight ? const Color(0xffE5E7EB) : Colors.grey.shade800;

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: _subTextColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _mainColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.stairs_rounded,
                      color: _mainColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add New Stage",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Enter the stage details below",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: _subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            _isLight
                                ? Colors.grey.shade100
                                : Colors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18, color: _subTextColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// ── Body (scrollable) ───────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("Stage info"),
                      _buildTextField(
                        _nameController,
                        'Stage Name',
                        isRequired: true,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        _commentController,
                        'Comment',
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel("Type"),
                      BlocBuilder<GetStageTypesCubit, GetStageTypesState>(
                        builder: (context, state) {
                          if (state is GetStageTypesLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (state is GetStageTypesSuccess) {
                            final stages = state.response.data ?? [];
                            return DropdownButtonFormField<String>(
                              decoration: _inputDecoration('Select Stage Type'),
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
                            return Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.redAccent),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),

            /// ── Buttons ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _fieldBorderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                        child: const Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
      decoration: _inputDecoration(label),
      validator:
          isRequired
              ? (value) =>
                  value == null || value.isEmpty
                      ? 'This field is required'
                      : null
              : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _subTextColor, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: _fieldFillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _fieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _fieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _mainColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
