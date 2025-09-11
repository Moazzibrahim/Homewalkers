// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/stage_types/cubit/get_stage_types_cubit.dart';

class UpdateStageTypeDialog extends StatefulWidget {
  final void Function(String name, String comment)? onAdd;
  final String? title;
  final String? initialName;
  final String? initialComment;

  const UpdateStageTypeDialog({
    super.key,
    this.onAdd,
    this.title,
    this.initialName,
    this.initialComment,
  });

  @override
  State<UpdateStageTypeDialog> createState() => _UpdateStageTypeDialogState();
}

class _UpdateStageTypeDialogState extends State<UpdateStageTypeDialog> {
  late final TextEditingController _controller;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _codeController = TextEditingController(text: widget.initialComment ?? '');
    context.read<StagesCubit>().fetchStages();
    context.read<GetStageTypesCubit>().fetchStageTypes();
  }

  @override
  void dispose() {
    _controller.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
        // ✅ لمنع overflow
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
              // Input Fields
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
                        side: const BorderSide(color: Constants.maincolor),
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
                        if (_controller.text.trim().isNotEmpty) {
                          widget.onAdd?.call(
                            _controller.text.trim(),
                            _codeController.text
                                .trim(), // ✅ comment not required
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
}
