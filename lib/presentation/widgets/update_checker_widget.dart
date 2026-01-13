// // ignore_for_file: use_build_context_synchronously

// import 'package:in_app_update/in_app_update.dart';
// import 'package:flutter/material.dart';

// class UpdateChecker {
//   static bool _dialogShown = false;

//   static Future<void> check(BuildContext context) async {
//     if (_dialogShown) return;
//     _dialogShown = true;

//     try {
//       final info = await InAppUpdate.checkForUpdate();

//       if (info.updateAvailability ==
//           UpdateAvailability.updateAvailable) {
//         _showDialog(context);
//       }
//     } catch (e) {
//       debugPrint("Update check error: $e");
//     }
//   }

//   static void _showDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text('Update Available'),
//         content: const Text(
//           'A new update is available on Google Play.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await InAppUpdate.performImmediateUpdate();
//             },
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leadStagesModel.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:intl/intl.dart';

class ChangeStageContent extends StatefulWidget {
  final String? leadStage;
  final String leedId;
  final String? leadstageupdated;
  final String? stageId;
  final Function(bool isAnswered, String stageName)? onSuccess;

  const ChangeStageContent({
    super.key,
    required this.leadStage,
    required this.leedId,
    this.leadstageupdated,
    this.stageId,
    this.onSuccess,
  });

  @override
  State<ChangeStageContent> createState() => _ChangeStageContentState();
}

class _ChangeStageContentState extends State<ChangeStageContent> {
  final oldStageController = TextEditingController();
  final unitPriceController = TextEditingController();
  final commissionRatioController = TextEditingController();
  final cashbackRatioController = TextEditingController();
  final unitnumberController = TextEditingController();
  final eoiController = TextEditingController();
  late TextEditingController stageUpdatedController;

  String? selectedStageName;
  String? selectedStageId;
  String commissionMoney = '0.00';
  String cashbackMoney = '0.00';

  DateTime? selectedDateTime;
  DateTime? selectedStageUpdatedDateTime;

  bool isAnswered = true;
  bool isApplying = false;

  @override
  void initState() {
    super.initState();

    oldStageController.text = widget.leadStage ?? '';
    isAnswered = !(widget.leadStage?.toLowerCase() == "no answer");

    stageUpdatedController = TextEditingController(
      text: widget.leadstageupdated != null &&
              widget.leadstageupdated!.isNotEmpty
          ? DateFormat("yyyy-MM-dd hh:mm a").format(
              DateTime.tryParse(widget.leadstageupdated!)?.toLocal() ??
                  DateTime.now(),
            )
          : DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now()),
    );

    unitPriceController.addListener(_calculateValues);
    commissionRatioController.addListener(_calculateValues);
    cashbackRatioController.addListener(_calculateValues);
  }

  void _calculateValues() {
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    final commissionRatio =
        double.tryParse(commissionRatioController.text) ?? 0;
    final cashbackRatio =
        double.tryParse(cashbackRatioController.text) ?? 0;

    final commission = (unitPrice * commissionRatio) / 100;
    final cashback = (commission * cashbackRatio) / 100;

    setState(() {
      commissionMoney = commission.toStringAsFixed(2);
      cashbackMoney = cashback.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StagesCubit, StagesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Old stage + switch
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hint: "Old stage",
                    controller: oldStageController,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  children: [
                    Switch(
                      value: isAnswered,
                      activeColor: Constants.maincolor,
                      onChanged: (v) => setState(() => isAnswered = v),
                    ),
                    Text(
                      isAnswered ? "Answer" : "NO Answer",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isAnswered ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12.h),

            /// Dropdown
            if (state is StagesLoaded)
              CustomDropdownField(
                hint: "Choose Stage",
                items: state.stages.map((e) => e.name).toList(),
                value: selectedStageName,
                onChanged: (value) {
                  setState(() {
                    selectedStageName = value;
                    selectedStageId =
                        state.stages.firstWhere((e) => e.name == value).id;
                    isAnswered = value?.toLowerCase() != "no answer";
                  });
                },
              ),

            /// Done Deal fields
            if (selectedStageName == "Done Deal") ...[
              SizedBox(height: 12.h),
              CustomTextField(
                hint: "Unit Price",
                controller: unitPriceController,
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                hint: "Unit number",
                controller: unitnumberController,
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                hint: "Commission Ratio (%)",
                controller: commissionRatioController,
              ),
              Text("Commission Money: $commissionMoney"),
              SizedBox(height: 12.h),
              CustomTextField(
                hint: "Cashback Ratio (%)",
                controller: cashbackRatioController,
              ),
              Text("Cashback Money: $cashbackMoney"),
            ],

            /// Stage date updated (رجعناها ✔️)
            SizedBox(height: 12.h),
            CustomTextField(
              hint: "Stage Date Updated",
              controller: stageUpdatedController,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      final fullDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      selectedStageUpdatedDateTime = fullDate;
                      stageUpdatedController.text = DateFormat(
                        "yyyy-MM-dd hh:mm a",
                      ).format(fullDate);
                    }
                  }
                },
              ),
            ),

            SizedBox(height: 20.h),

            /// Buttons (نفس الستايل 100%)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedStageName = null;
                        selectedStageId = null;
                        unitPriceController.clear();
                        commissionRatioController.clear();
                        cashbackRatioController.clear();
                        unitnumberController.clear();
                        eoiController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Constants.maincolor),
                    ),
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        color: Constants.maincolor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isApplying
                        ? null
                        : () async {
                            setState(() => isApplying = true);

                            await context.read<ChangeStageCubit>().changeStage(
                                  leadId: widget.leedId,
                                  request:  LeadStageRequest(
                                              lastStageDateUpdated:
                                                  DateTime.now()
                                                      .toIso8601String(),
                                              stage:
                                                  selectedStageId ??
                                                 // stageId ??
                                                  '',
                                              stageDateUpdated:
                                                  (selectedStageName != null &&
                                                          selectedStageName!
                                                              .isNotEmpty)
                                                      ? (selectedDateTime
                                                              ?.toUtc()
                                                              .toIso8601String() ??
                                                          DateTime.now()
                                                              .toUtc()
                                                              .toIso8601String())
                                                      : (selectedStageUpdatedDateTime
                                                              ?.toUtc()
                                                              .toIso8601String() ??
                                                          DateTime.now()
                                                              .toUtc()
                                                              .toIso8601String()),
                                              unitPrice:
                                                  unitPriceController.text,
                                              unitNumber:
                                                  unitnumberController.text,
                                              commissionRatio:
                                                  commissionRatioController
                                                      .text,
                                              commissionMoney: commissionMoney,
                                              cashbackRatio:
                                                  cashbackRatioController.text,
                                              cashbackMoney: cashbackMoney,
                                              eoi:
                                                  eoiController.text.isNotEmpty
                                                      ? num.tryParse(
                                                        eoiController.text,
                                                      )
                                                      : null,
                                              reservation:
                                                  eoiController.text.isNotEmpty
                                                      ? num.tryParse(
                                                        eoiController.text,
                                                      )
                                                      : null,
                                            ),
                                );

                            setState(() => isApplying = false);
                            widget.onSuccess
                                ?.call(isAnswered, selectedStageName ?? '');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.maincolor,
                    ),
                    child: isApplying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Apply"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
