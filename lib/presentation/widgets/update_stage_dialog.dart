// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/stage_types/cubit/get_stage_types_cubit.dart';

class UpdateStageDialog extends StatefulWidget {
  final void Function(String name, String comment, String stageType)? onAdd;
  final String? title;
  final String? oldName;
  final String? oldComment;
  final String? oldStageTypeId;

  const UpdateStageDialog({
    super.key,
    this.onAdd,
    this.title,
    this.oldName,
    this.oldComment,
    this.oldStageTypeId,
  });

  @override
  State<UpdateStageDialog> createState() => _NewCommunicationDialogState();
}

class _NewCommunicationDialogState extends State<UpdateStageDialog> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedStageTypeId;

  @override
  void initState() {
    super.initState();
    context.read<StagesCubit>().fetchStages();
    context.read<GetStageTypesCubit>().fetchStageTypes();
    _controller.text = widget.oldName ?? '';
    _codeController.text = widget.oldComment ?? '';
    _selectedStageTypeId = widget.oldStageTypeId;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row
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
                    "update ${widget.title}",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Input Field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "${widget.title} Name",
                hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<GetStageTypesCubit, GetStageTypesState>(
              builder: (context, state) {
                if (state is GetStageTypesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetStageTypesSuccess) {
                  final stages = state.response.data;
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Stage Type',
                      border: OutlineInputBorder(),
                    ),
                    value:
                        stages!.any((stage) => stage.id == _selectedStageTypeId)
                            ? _selectedStageTypeId
                            : null, // ✅ التأكد من صلاحية القيمة
                    items:
                        stages.map((stage) {
                          return DropdownMenuItem<String>(
                            value: stage.id,
                            child: Text(stage.name ?? ''),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStageTypeId = value!;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Please select a stage type' : null,
                  );
                } else if (state is GetStageTypesFailure) {
                  return Text('Error: ${state.message}');
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: "comment",
                hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
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
                      final name = _controller.text.trim();
                      final comment = _codeController.text.trim();
                      final typeId = _selectedStageTypeId;

                      final isChanged =
                          name != (widget.oldName ?? '') ||
                          comment != (widget.oldComment ?? '') ||
                          typeId != (widget.oldStageTypeId ?? '');

                      if (!isChanged) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please change at least one field.'),
                          ),
                        );
                        return;
                      }

                      if (widget.onAdd != null && typeId != null) {
                        widget.onAdd!(name, comment, typeId);
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
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
