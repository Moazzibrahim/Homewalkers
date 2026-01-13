// ignore_for_file: unused_local_variable, use_build_context_synchronously, non_constant_identifier_names, avoid_print, unused_element, deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leadStagesModel.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomChangeStageDialog {
  static Future<bool?> showChangeDialog({
    required BuildContext context,
    required String? leadStage,
    required String leedId,
    required String? salesId,
    String? leadstageupdated,
    String? stageId,
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
    final stageUpdatedController = TextEditingController(
      text:
          leadstageupdated != null && leadstageupdated.isNotEmpty
              ? DateFormat("yyyy-MM-dd hh:mm a").format(
                DateTime.tryParse(leadstageupdated)?.toLocal() ??
                    DateTime.now(),
              )
              : DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now()),
    );
    final formKey = GlobalKey<FormState>();
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';

    String? selectedStageName;
    String? selectedStageId;
    String commissionMoney = '0.00';
    String cashbackMoney = '0.00';
    DateTime? selectedDateTime;
    DateTime? selectedStageUpdatedDateTime;
    final savedSalesId =
        prefs.getString('salesIDD') ?? 'default_sales_id'; // Provide a default
    //  bool isAnswered = true;
    bool isAnswered = !(leadStage?.toLowerCase() == "no answer");

    bool isApplying = false;
    log(" Saved leadstageupdated: $leadstageupdated ");
    int leadScore = 0;

    // switches
    bool signInterested = false;
    bool authority = false;

    // budget
    double? projectBudget;
    double startProjectPrice = 1000000; // مثال (بعد كده ييجي من API)

    // dropdowns
    String? needValue;
    String? propertyTypeValue;
    String? timelineValue;
    int budgetScore = 0;
    int stageBonusScore = 0;
    double animatedScoreValue = 0;
    int lastScore = 0;
    bool areListenersSetup = false;

    Future<void> pickDateTime(
      BuildContext context,
      Function(DateTime) onPicked,
    ) async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2050),
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

          // 🧠 حفظ القيمة في SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('pickedDateTime', dateTime.toIso8601String());

          // 🔁 استدعاء callback في نفس الوقت لو محتاج تستخدمها جوه الdialog
          onPicked(dateTime);

          print("✅ Picked DateTime saved: $dateTime");
        }
      }
    }

    return showDialog(
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
                  final scoringStages = [
                    'meeting',
                    'follow after meeting',
                    'interested',
                    'follow up',
                    'done deal',
                  ];
                  bool showScoringSection = scoringStages.contains(
                    selectedStageName?.toLowerCase(),
                  );

                  void calculateLeadScore() {
                    int score = 0;
                    stageBonusScore = 0;
                    if (selectedStageName != null) {
                      final stage = selectedStageName!.toLowerCase();
                      if (stage == 'meeting' ||
                          stage == 'follow after meeting') {
                        stageBonusScore = 1;
                      }
                    }
                    score += stageBonusScore;

                    // 1️⃣ Sign & Interested
                    if (signInterested) score += 1;

                    // 2️⃣ Project Budget
                    // 2️⃣ Project Budget
                    // 2️⃣ Project Budget
                    // 2️⃣ Project Budget
                    budgetScore = 0;

                    if (projectBudget != null &&
                        projectBudget! > 0 &&
                        startProjectPrice > 0) {
                      if (projectBudget! >= startProjectPrice) {
                        // مليون أو أكتر
                        budgetScore = 3;
                      } else if (projectBudget! > startProjectPrice * 0.5) {
                        // أكتر من 500 ألف وأقل من مليون
                        budgetScore = 2;
                      } else if (projectBudget! == startProjectPrice * 0.5) {
                        // 500 ألف بالظبط
                        budgetScore = 1;
                      }
                    }

                    score += budgetScore;

                    // 3️⃣ Authority
                    if (authority) score += 1;

                    // 4️⃣ Need
                    if (needValue == 'Residential' || needValue == 'Investor') {
                      score += 1;
                    }

                    // 5️⃣ Property Type
                    if (propertyTypeValue != null &&
                        propertyTypeValue != 'Not clear') {
                      score += 1;
                    }

                    // 6️⃣ Timeline
                    if (timelineValue == 'Within week to 1 month') {
                      score += 2;
                    } else if (timelineValue == 'Within 1 month to 3 months') {
                      score += 1;
                    }

                    setState(() {
                      lastScore = leadScore;
                      leadScore = score.clamp(0, 10);
                      animatedScoreValue = leadScore / 10; // 0.0 → 1.0
                    });
                  }

                  Color scoreColor() {
                    if (leadScore >= 8) return Colors.red;
                    if (leadScore >= 5) return Colors.orange;
                    return Colors.blue;
                  }

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

                  String calculateLeadTemperature() {
                    if (leadScore >= 8) return 'Hot';
                    if (leadScore >= 5) return 'Warm';
                    return 'Cold';
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
                  return Form(
                    key: formKey,
                    child: Padding(
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
                                    Navigator.pop(context, null);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            /// Old Stage Field
                            Row(
                              children: [
                                // Expanded علشان الـTextField ياخد المساحة الباقية
                                Expanded(
                                  child: CustomTextField(
                                    hint: "Old stage",
                                    controller: oldStageController,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                // السويتش + النص
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Switch(
                                      activeColor: Constants.maincolor,
                                      value: isAnswered,
                                      onChanged: (value) {
                                        setState(() {
                                          isAnswered = value;
                                        });
                                      },
                                    ),
                                    Text(
                                      isAnswered ? "Answer" : "NO Answer",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isAnswered
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            /// Dropdown for Stages
                            BlocBuilder<StagesCubit, StagesState>(
                              builder: (context, state) {
                                if (state is StagesLoading) {
                                  return const CircularProgressIndicator();
                                } else if (state is StagesLoaded) {
                                  /// 👇 stages الأساسية
                                  List stages = state.stages;

                                  /// 🔐 لو مش Admin ولا Marketer → نخفي No stage و fresh
                                  if (role != 'Admin' && role != 'Marketer') {
                                    stages =
                                        stages
                                            .where(
                                              (stage) =>
                                                  stage.name?.toLowerCase() !=
                                                      'no stage' &&
                                                  stage.name?.toLowerCase() !=
                                                      'fresh',
                                            )
                                            .toList();
                                  }
                                  final List<String> items =
                                      stages
                                          .map((e) => e.name)
                                          .whereType<String>() // يشيل أي null
                                          .toList();
                                  return CustomDropdownField(
                                    hint: "Choose Stage",
                                    items: items,
                                    value: selectedStageName,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedStageName = value;
                                        selectedStageId =
                                            stages
                                                .firstWhere(
                                                  (stage) =>
                                                      stage.name == value,
                                                )
                                                .id;

                                        /// 🔥 لو اليوزر اختار NO ANSWER → خلي السويتش OFF تلقائي
                                        if (value?.toLowerCase() ==
                                            "no answer") {
                                          isAnswered = false;
                                        } else {
                                          isAnswered = true;
                                        }
                                      });
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
                                    validator: (value) {
                                      if (selectedStageName == "Done Deal") {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Unit Price is required";
                                        }
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      if (selectedStageName == "Done Deal") {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Unit number is required";
                                        }
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      if (selectedStageName == "Done Deal") {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Commission Ratio is required";
                                        }
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      if (selectedStageName == "Done Deal") {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "cashback Ratio is required";
                                        }
                                      }
                                      return null;
                                    },
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
                            // ✅ TextField لتاريخ Stage Updated
                            /// New Field: Stage Updated Date
                            SizedBox(height: 12.h),
                            CustomTextField(
                              hint: "Stage Date Updated",
                              controller: stageUpdatedController,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  // 🧠 لو فيه تاريخ محفوظ مسبقًا نحوله لـ DateTime
                                  if (selectedStageUpdatedDateTime == null &&
                                      stageUpdatedController.text.isNotEmpty) {
                                    try {
                                      selectedStageUpdatedDateTime = DateFormat(
                                        "yyyy-MM-dd hh:mm a",
                                      ).parse(stageUpdatedController.text);
                                    } catch (e) {
                                      selectedStageUpdatedDateTime =
                                          DateTime.tryParse(
                                            leadstageupdated ?? '',
                                          ) ??
                                          DateTime.now();
                                    }
                                  }
                                  // 🗓️ عرض الـ Date Picker
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedStageUpdatedDateTime ??
                                        DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2050),
                                  );

                                  if (pickedDate != null) {
                                    // ⏰ عرض الـ Time Picker
                                    final pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                        selectedStageUpdatedDateTime ??
                                            DateTime.now(),
                                      ),
                                    );

                                    if (pickedTime != null) {
                                      // 🧩 دمج التاريخ والوقت
                                      final fullDate = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                      // 🧠 تحديث المتغير + الكنترولر
                                      selectedStageUpdatedDateTime = fullDate;
                                      // solution
                                      selectedDateTime = fullDate;
                                      stageUpdatedController.text = DateFormat(
                                        "yyyy-MM-dd hh:mm a",
                                      ).format(fullDate);
                                    }
                                  }
                                },
                              ),
                            ),
                            // SizedBox(height: 12.h),
                            // if (showScoringSection)
                            //   Card(
                            //     elevation: 3,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(12.r),
                            //     ),
                            //     child: Padding(
                            //       padding: EdgeInsets.all(12.w),
                            //       child: Column(
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.start,
                            //         children: [
                            //           Text(
                            //             "Lead Qualification",
                            //             style: TextStyle(
                            //               fontSize: 16.sp,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //           ),

                            //           /// Sign & Interested
                            //           SwitchListTile(
                            //             title: const Text("Sign & Interested"),
                            //             value: signInterested,
                            //             onChanged: (val) {
                            //               setState(() => signInterested = val);
                            //               calculateLeadScore();
                            //             },
                            //           ),

                            //           /// Project Budget
                            //           Row(
                            //             children: [
                            //               Expanded(
                            //                 child: CustomTextField(
                            //                   hint: "Project Budget",
                            //                   textInputType:
                            //                       const TextInputType.numberWithOptions(
                            //                         decimal: true,
                            //                       ),
                            //                   onChanged: (val) {
                            //                     final cleanValue =
                            //                         val
                            //                             .replaceAll(',', '')
                            //                             .trim();
                            //                     projectBudget = double.tryParse(
                            //                       cleanValue,
                            //                     );
                            //                     calculateLeadScore();
                            //                   },
                            //                 ),
                            //               ),
                            //             ],
                            //           ),

                            //           /// Authority
                            //           SwitchListTile(
                            //             title: const Text("Authority"),
                            //             value: authority,
                            //             onChanged: (val) {
                            //               setState(() => authority = val);
                            //               calculateLeadScore();
                            //             },
                            //           ),

                            //           /// Need
                            //           CustomDropdownField(
                            //             hint: "Need",
                            //             items: const [
                            //               'Residential',
                            //               'Investor',
                            //               'Not clear',
                            //             ],
                            //             value: needValue,
                            //             onChanged: (val) {
                            //               setState(() => needValue = val);
                            //               calculateLeadScore();
                            //             },
                            //           ),

                            //           /// Property Type
                            //           CustomDropdownField(
                            //             hint: "Property Type",
                            //             items: const [
                            //               'Studio',
                            //               '1BHK',
                            //               '2BHK',
                            //               '3BHK',
                            //               '4BHK',
                            //               'Villa',
                            //               'Not clear',
                            //             ],
                            //             value: propertyTypeValue,
                            //             onChanged: (val) {
                            //               setState(
                            //                 () => propertyTypeValue = val,
                            //               );
                            //               calculateLeadScore();
                            //             },
                            //           ),

                            //           /// Timeline
                            //           CustomDropdownField(
                            //             hint: "Timeline",
                            //             items: const [
                            //               'Within week to 1 month',
                            //               'Within 1 month to 3 months',
                            //               'More than 3 months',
                            //             ],
                            //             value: timelineValue,
                            //             onChanged: (val) {
                            //               setState(() => timelineValue = val);
                            //               calculateLeadScore();
                            //             },
                            //           ),
                            //           SizedBox(height: 10.h),

                            //           /// Result
                            //           Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               /// SCORE TEXT WITH ANIMATION
                            //               AnimatedScale(
                            //                 scale:
                            //                     leadScore > lastScore
                            //                         ? 1.1
                            //                         : 1.0,
                            //                 duration: const Duration(
                            //                   milliseconds: 300,
                            //                 ),
                            //                 curve: Curves.easeOutBack,
                            //                 child: Text(
                            //                   "Score: $leadScore / 10",
                            //                   style: TextStyle(
                            //                     fontSize: 16.sp,
                            //                     fontWeight: FontWeight.bold,
                            //                     color: scoreColor(),
                            //                   ),
                            //                 ),
                            //               ),
                            //               SizedBox(height: 6.h),

                            //               /// PROGRESS BAR
                            //               TweenAnimationBuilder<double>(
                            //                 tween: Tween<double>(
                            //                   begin: 0,
                            //                   end: animatedScoreValue,
                            //                 ),
                            //                 duration: const Duration(
                            //                   milliseconds: 500,
                            //                 ),
                            //                 curve: Curves.easeInOut,
                            //                 builder: (context, value, _) {
                            //                   return ClipRRect(
                            //                     borderRadius:
                            //                         BorderRadius.circular(10.r),
                            //                     child: LinearProgressIndicator(
                            //                       value: value,
                            //                       minHeight: 8.h,
                            //                       backgroundColor:
                            //                           Colors.grey.shade300,
                            //                       valueColor:
                            //                           AlwaysStoppedAnimation(
                            //                             scoreColor(),
                            //                           ),
                            //                     ),
                            //                   );
                            //                 },
                            //               ),
                            //               SizedBox(height: 8.h),

                            //               /// TEMPERATURE CHIP
                            //               Align(
                            //                 alignment: Alignment.centerRight,
                            //                 child: Chip(
                            //                   label: Text(
                            //                     calculateLeadTemperature(),
                            //                     style: const TextStyle(
                            //                       fontWeight: FontWeight.w600,
                            //                     ),
                            //                   ),
                            //                   backgroundColor:
                            //                       calculateLeadTemperature() ==
                            //                               'Hot'
                            //                           ? Colors.red[100]
                            //                           : calculateLeadTemperature() ==
                            //                               'Warm'
                            //                           ? Colors.orange[100]
                            //                           : Colors.blue[100],
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
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
                                        //stageUpdatedController.clear();
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
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
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
                                    onPressed:
                                        isApplying
                                            ? null
                                            : () async {
                                              if (selectedStageName ==
                                                  "Done Deal") {
                                                if (!formKey.currentState!
                                                    .validate()) {
                                                  return; // وقف التنفيذ
                                                }
                                              }
                                              // ⛔ يمنع الضغط مرتين
                                              setState(() => isApplying = true);
                                              final leadStageRequest = LeadStageRequest(
                                                lastStageDateUpdated:
                                                    DateTime.now()
                                                        .toIso8601String(),
                                                stage:
                                                    selectedStageId ??
                                                    stageId ??
                                                    '',
                                                stageDateUpdated:
                                                    (selectedStageName !=
                                                                null &&
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
                                                commissionMoney:
                                                    commissionMoney,
                                                cashbackRatio:
                                                    cashbackRatioController
                                                        .text,
                                                cashbackMoney: cashbackMoney,
                                                eoi:
                                                    eoiController
                                                            .text
                                                            .isNotEmpty
                                                        ? num.tryParse(
                                                          eoiController.text,
                                                        )
                                                        : null,
                                                reservation:
                                                    eoiController
                                                            .text
                                                            .isNotEmpty
                                                        ? num.tryParse(
                                                          eoiController.text,
                                                        )
                                                        : null,
                                              );
                                              print(
                                                "leadstageupdated: $selectedStageUpdatedDateTime and  selecteddate: $selectedDateTime",
                                              );
                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              // 🧮 نفس اللوجيك اللي عندك
                                              final String
                                              stageDateUpdatedInSharedPreferences =
                                                  (selectedStageName != null &&
                                                          selectedStageName
                                                                  ?.isNotEmpty ==
                                                              true)
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
                                                              .toIso8601String());
                                              // 💾 حفظ في SharedPreferences
                                              await prefs.setString(
                                                'stageDateUpdated',
                                                stageDateUpdatedInSharedPreferences,
                                              );
                                              print(
                                                '✅ Saved stageDateUpdated: $stageDateUpdatedInSharedPreferences',
                                              );
                                              final changeStageCubit =
                                                  context
                                                      .read<ChangeStageCubit>();
                                              // أول استدعاء لتغيير المرحلة
                                              await changeStageCubit
                                                  .changeStage(
                                                    leadId: leedId,
                                                    request: leadStageRequest,
                                                  );
                                              final stateAfterChange =
                                                  changeStageCubit.state;
                                              setState(
                                                () => isApplying = false,
                                              );
                                              if (stateAfterChange
                                                  is ChangeStageSuccess) {
                                                // إرسال الـ stage الجديد للسيرفر
                                                await changeStageCubit
                                                    .postLeadStage(
                                                      leadId: leedId,
                                                      date:
                                                          DateTime.now()
                                                              .toIso8601String()
                                                              .split('T')
                                                              .first,
                                                      stage:
                                                          selectedStageId ??
                                                          stageId ??
                                                          '',
                                                      sales: savedSalesId,
                                                    );
                                                // إزالة الـ listeners
                                                unitPriceController
                                                    .removeListener(
                                                      calculateValues,
                                                    );
                                                commissionRatioController
                                                    .removeListener(
                                                      calculateValues,
                                                    );
                                                cashbackRatioController
                                                    .removeListener(
                                                      calculateValues,
                                                    );
                                                // ✅ هنا بنرجع القيمة isAnswered للصفحة اللي فتحت الديالوج
                                                Navigator.pop(
                                                  context,
                                                  isAnswered,
                                                );
                                                onStageChanged(
                                                  selectedStageName ?? '',
                                                );
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
                                                    content: Text(
                                                      stateAfterChange.error,
                                                    ),
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
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                    ),
                                    child:
                                        isApplying
                                            ? SizedBox(
                                              height: 20.h,
                                              width: 20.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : Text(
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
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }
}
