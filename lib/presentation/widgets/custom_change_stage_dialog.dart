// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/change_stage/change_stage_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/change_stage/change_stage_state.dart';
import 'package:homewalkers_app/presentation/viewModels/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomChangeStageDialog {
  static Future<void> showChangeDialog({
    required BuildContext context,
    required String? leadStage,
    required String leedId,
    required String? salesId,
    required Function(String) onStageChanged,
  }) async {
    final stagesCubit = context.read<StagesCubit>();
    stagesCubit.fetchStages();
    final nameController = TextEditingController(text: leadStage ?? '');
    String? selectedStageName;
    String? selectedStageId;
    String? unitPriceValue;
    DateTime? selectedDateTime;
    final prefs = await SharedPreferences.getInstance();
    final salesId = prefs.getString('salesId');

    Future<void> pickDateTime(
      BuildContext context,
      Function(DateTime) onPicked,
    ) async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          onPicked(dateTime);
        }
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: stagesCubit),
              BlocProvider(create: (context) => ChangeStageCubit()),
            ],
            child: Dialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Header
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.maincolor
                                        : Constants.mainDarkmodecolor,
                                child: const Icon(
                                  Icons.change_circle,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Change Stage',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          /// Old Stage Field
                          CustomTextField(
                            hint: "Old stage",
                            controller: nameController,
                          ),
                          SizedBox(height: 12.h),

                          /// Dropdown for Stages
                          BlocBuilder<StagesCubit, StagesState>(
                            builder: (context, state) {
                              if (state is StagesLoading) {
                                return const CircularProgressIndicator();
                              } else if (state is StagesLoaded) {
                                final stages = state.stages;
                                final items =
                                    stages.map((e) => e.name).toList();
                                return CustomDropdownField(
                                  hint: "Choose Stage",
                                  items: items,
                                  value: selectedStageName,
                                  onChanged: (value) async {
                                    setState(() {
                                      selectedStageName = value;
                                      selectedStageId =
                                          stages
                                              .firstWhere(
                                                (stage) => stage.name == value,
                                              )
                                              .id;
                                    });
                                    if (value == "Meeting" ||
                                        value == "Follow" ||
                                        value == "Cancel Meeting") {
                                      await pickDateTime(context, (
                                        pickedDateTime,
                                      ) {
                                        setState(() {
                                          selectedDateTime = pickedDateTime;
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        selectedDateTime = null;
                                      });
                                    }
                                  },
                                );
                              } else if (state is StagesError) {
                                return Text(
                                  "خطأ: ${state.message}",
                                  style: const TextStyle(color: Colors.red),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          if (selectedStageName == "Done Deal")
                            CustomTextField(
                              hint: "Unit Price",
                              controller: TextEditingController(
                                text: unitPriceValue ?? '',
                              ),
                            ),
                          SizedBox(height: 20.h),

                          /// Action Buttons
                          Row(
                            children: [
                              /// Reset Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      nameController.clear();
                                      selectedStageName = null;
                                      selectedStageId = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Constants.maincolor
                                              : Constants.mainDarkmodecolor,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Reset",
                                    style: TextStyle(
                                      color: const Color(0xff326677),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              /// Apply Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (selectedStageId == null ||
                                        selectedStageId!.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please select a stage",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final changeStageCubit =
                                        context.read<ChangeStageCubit>();
                                    // نفّذ تغيير المرحلة
                                    await changeStageCubit.changeStage(
                                      leadId: leedId,
                                      laststagedateupdated:
                                          DateTime.now().toIso8601String(),
                                      unitPrice: unitPriceValue,
                                      stagedateupdated:
                                          selectedDateTime?.toIso8601String() ??
                                          DateTime.now().toIso8601String(),
                                      stage: selectedStageId!,
                                    );
                                    // بعد ما يتم التغيير بنجاح
                                    final state = changeStageCubit.state;
                                    if (state is ChangeStageSuccess) {
                                      // نفذ postLeadStage بعد نجاح تغيير المرحلة
                                      await changeStageCubit.postLeadStage(
                                        leadId: leedId,
                                        date:
                                            DateTime.now()
                                                .toIso8601String()
                                                .split('T')
                                                .first,
                                        stage: selectedStageId!,
                                        sales: salesId!, // عدّلها حسب المطلوب
                                      );
                                      final newState = changeStageCubit.state;
                                      if (newState is ChangeStageSuccess) {
                                        Navigator.pop(context);
                                        onStageChanged(selectedStageName ?? '');
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(newState.message),
                                          ),
                                        );
                                      } else if (newState is ChangeStageError) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(newState.error),
                                          ),
                                        );
                                      }
                                    } else if (state is ChangeStageError) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(state.error)),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.maincolor
                                            : Constants.mainDarkmodecolor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Apply",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }
}
