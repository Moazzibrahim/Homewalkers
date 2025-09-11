// ignore_for_file: unused_local_variable, use_build_context_synchronously, non_constant_identifier_names, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
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
    final oldStageController = TextEditingController(text: leadStage ?? '');
    final unitPriceController = TextEditingController();
    final commissionRatioController = TextEditingController();
    final cashbackRatioController = TextEditingController();
    final unitnumberController = TextEditingController();
    final eoiController = TextEditingController();
    String? selectedStageName;
    String? selectedStageId;
    String commissionMoney = '0.00';
    String cashbackMoney = '0.00';
    DateTime? selectedDateTime;
    final prefs = await SharedPreferences.getInstance();
    final savedSalesId =
        prefs.getString('salesIDD') ?? 'default_sales_id'; // Provide a default

    Future<void> pickDateTime(
      BuildContext context,
      Function(DateTime) onPicked,
    ) async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
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
                  // --- Start of Changes ---
                  // Calculation logic
                  void calculateValues() {
                    final double unitPrice =
                        double.tryParse(unitPriceController.text) ?? 0.0;
                    final double commissionRatio =
                        double.tryParse(commissionRatioController.text) ?? 0.0;
                    final double cashbackRatio =
                        double.tryParse(cashbackRatioController.text) ?? 0.0;
                    final double calculatedCommission =
                        (unitPrice * commissionRatio) / 100;
                    // **Important**: Decide how cashback is calculated.
                    // Option 1: Cashback as a percentage of the commission
                    final double calculatedCashback =
                        (calculatedCommission * cashbackRatio) / 100;
                    // Option 2 (alternative): Cashback as a percentage of the unit price
                    // final double calculatedCashback = (unitPrice * cashbackRatio) / 100;
                    // Use setState here to trigger a rebuild of the dialog's content
                    setState(() {
                      commissionMoney = calculatedCommission.toStringAsFixed(2);
                      cashbackMoney = calculatedCashback.toStringAsFixed(2);
                    });
                    print(
                      "Commission: $commissionMoney, Cashback: $cashbackMoney",
                    );
                  }

                  // Add listeners to controllers to automatically recalculate
                  void setupListeners() {
                    unitPriceController.addListener(calculateValues);
                    commissionRatioController.addListener(calculateValues);
                    cashbackRatioController.addListener(calculateValues);
                  }

                  // A flag to ensure listeners are set up only once
                  bool areListenersSetup = false;
                  if (!areListenersSetup) {
                    setupListeners();
                    areListenersSetup = true;
                  }
                  // --- End of Changes ---
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
                                onPressed: () {
                                  // **Important**: Remove listeners to avoid memory leaks
                                  unitPriceController.removeListener(
                                    calculateValues,
                                  );
                                  commissionRatioController.removeListener(
                                    calculateValues,
                                  );
                                  cashbackRatioController.removeListener(
                                    calculateValues,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          /// Old Stage Field
                          CustomTextField(
                            hint: "Old stage",
                            controller: oldStageController,
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
                                    // Logic for picking date
                                    if (value == "Meeting" ||
                                        value == "Follow" ||
                                        value == "Interested" ||
                                        value == "Follow Up" ||
                                        value == "Long Follow") {
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
                                  "error: ${state.message}",
                                  style: const TextStyle(color: Colors.red),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          /// Fields for "Done Deal" stage
                          if (selectedStageName == "Done Deal")
                            Column(
                              children: [
                                SizedBox(height: 12.h),
                                CustomTextField(
                                  hint: "Unit Price",
                                  controller: unitPriceController,
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  // onChanged is no longer needed here as we use a listener
                                ),
                                SizedBox(height: 12.h),
                                CustomTextField(
                                  hint: "Unit number",
                                  controller: unitnumberController,
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                        decimal:
                                            false, // Unit number is likely an integer
                                      ),
                                ),
                                SizedBox(height: 12.h),
                                CustomTextField(
                                  hint: "Commission Ratio (%)",
                                  controller: commissionRatioController,
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  // onChanged is no longer needed here
                                ),
                                SizedBox(height: 12.h),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Commission Money:$commissionMoney",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                CustomTextField(
                                  hint: "Cashback Ratio (%)",
                                  controller: cashbackRatioController,
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  // onChanged is no longer needed here
                                ),
                                SizedBox(height: 12.h),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Cashback Money:$cashbackMoney",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (selectedStageName == "EOI" || 
                                selectedStageName == "Reservation")
                            Column(
                              children: [
                                SizedBox(height: 12.h),
                                CustomTextField(
                                  hint: "Money",
                                  controller: eoiController,
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  // onChanged is no longer needed here as we use a listener
                                ),
                              ],
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
                                      selectedStageName = null;
                                      selectedStageId = null;
                                      unitPriceController.clear();
                                      commissionRatioController.clear();
                                      cashbackRatioController.clear();
                                      unitnumberController.clear();
                                      eoiController.clear();
                                      // No need to call calculateValues() here,
                                      // the listeners will do it automatically when controllers are cleared.
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
                                      color: Constants.maincolor,
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
                                    // Await the first call
                                    await changeStageCubit.changeStage(
                                      leadId: leedId,
                                      laststagedateupdated:
                                          DateTime.now().toIso8601String(),
                                      unitPrice: unitPriceController.text,
                                      commissionratio:
                                          commissionRatioController.text,
                                      commissionmoney: commissionMoney,
                                      cashbackratio:
                                          cashbackRatioController.text,
                                      cashbackmoney: cashbackMoney,
                                      unitnumber: unitnumberController.text,
                                      stagedateupdated:
                                          selectedDateTime
                                              ?.toUtc()
                                              .toIso8601String() ??
                                          DateTime.now()
                                              .toUtc()
                                              .toIso8601String(),
                                      stage: selectedStageId!,
                                      eoi: eoiController.text.isNotEmpty
                                          ? num.tryParse(
                                              eoiController.text,
                                            )
                                          : null,
                                          reservation: eoiController.text.isNotEmpty
                                          ? num.tryParse(
                                              eoiController.text,
                                            )
                                          : null
                                    );
                                    // Check the state after the first call
                                    final stateAfterChange =
                                        changeStageCubit.state;
                                    if (stateAfterChange
                                        is ChangeStageSuccess) {
                                      await changeStageCubit.postLeadStage(
                                        leadId: leedId,
                                        date:
                                            DateTime.now()
                                                .toIso8601String()
                                                .split('T')
                                                .first,
                                        stage: selectedStageId!,
                                        sales: savedSalesId,
                                      );
                                      // **Important**: Remove listeners before closing the dialog
                                      unitPriceController.removeListener(
                                        calculateValues,
                                      );
                                      commissionRatioController.removeListener(
                                        calculateValues,
                                      );
                                      cashbackRatioController.removeListener(
                                        calculateValues,
                                      );

                                      Navigator.pop(context);
                                      onStageChanged(selectedStageName ?? '');

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            stateAfterChange.message,
                                          ),
                                        ),
                                      );
                                    } else if (stateAfterChange
                                        is ChangeStageError) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(stateAfterChange.error),
                                        ),
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
