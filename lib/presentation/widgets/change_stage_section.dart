// ignore_for_file: must_be_immutable, non_constant_identifier_names, use_build_context_synchronously, avoid_print

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

class ChangeStageSection extends StatefulWidget {
  final String? leadStage;
  final String leadId;
  final String? salesId;
  final String? stageId;
  final String? leadstageupdated;
 final bool? initialIsAnswered;
  final void Function(String newStage,String newStageId, bool isAnswered) onSubmit;

  const ChangeStageSection({
    super.key,
    required this.leadStage,
    required this.leadId,
    required this.salesId,
    required this.onSubmit,
    this.stageId,
    this.leadstageupdated,
    this.initialIsAnswered,
  });

  @override
  State<ChangeStageSection> createState() => _ChangeStageSectionState();
}

class _ChangeStageSectionState extends State<ChangeStageSection> {
  final unitPriceController = TextEditingController();
  final commissionRatioController = TextEditingController();
  final cashbackRatioController = TextEditingController();
  final unitnumberController = TextEditingController();
  final eoiController = TextEditingController();
  final oldStageController = TextEditingController();
  final stageUpdatedController = TextEditingController();

  String? selectedStageName;
  String? selectedStageId;
  String commissionMoney = '0.00';
  String cashbackMoney = '0.00';

  DateTime? selectedStageDate;
  DateTime? selectedStageUpdatedDate;

  bool isAnswered = true;

  @override
  void initState() {
    super.initState();
    oldStageController.text = widget.leadStage ?? "";
    isAnswered = widget.initialIsAnswered!; // تعيين القيمة المبدئية
    if (widget.leadstageupdated != null &&
        widget.leadstageupdated!.isNotEmpty) {
      final date = DateTime.tryParse(widget.leadstageupdated!);
      stageUpdatedController.text = DateFormat(
        "yyyy-MM-dd hh:mm a",
      ).format(date ?? DateTime.now());
      selectedStageUpdatedDate = date ?? DateTime.now();
    }

    commissionRatioController.addListener(_calculateValues);
    cashbackRatioController.addListener(_calculateValues);
    unitPriceController.addListener(_calculateValues);

    final stagesCubit = context.read<StagesCubit>();
    stagesCubit.fetchStages();
  }

  void _calculateValues() {
    final double unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;
    final double commissionRatio =
        double.tryParse(commissionRatioController.text) ?? 0.0;
    final double cashbackRatio =
        double.tryParse(cashbackRatioController.text) ?? 0.0;

    final double commission = (unitPrice * commissionRatio) / 100;
    final double cashback = (commission * cashbackRatio) / 100;

    setState(() {
      commissionMoney = commission.toStringAsFixed(2);
      cashbackMoney = cashback.toStringAsFixed(2);
    });
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedStageUpdatedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedStageUpdatedDate ?? DateTime.now(),
      ),
    );

    if (time == null) return;

    final fullDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      selectedStageUpdatedDate = fullDate;
      stageUpdatedController.text = DateFormat(
        "yyyy-MM-dd hh:mm a",
      ).format(fullDate);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("pickedDateTime", fullDate.toIso8601String());
  }

  @override
  void dispose() {
    unitPriceController.dispose();
    commissionRatioController.dispose();
    cashbackRatioController.dispose();
    unitnumberController.dispose();
    eoiController.dispose();
    oldStageController.dispose();
    stageUpdatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stagesCubit = context.read<StagesCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Old stage + switch
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: "Old stage",
                controller: oldStageController,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Switch(
                  value: isAnswered,
                  onChanged: (v) => setState(() => isAnswered = v),
                  activeColor: Constants.maincolor,
                ),
                Text(
                  isAnswered ? "Answer" : "No Answer",
                  style: TextStyle(
                    color: isAnswered ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stages Dropdown
        BlocBuilder<StagesCubit, StagesState>(
          builder: (context, state) {
            if (state is StagesLoaded) {
              final items = state.stages.map((e) => e.name).toList();
              return CustomDropdownField(
                hint: "Choose Stage",
                value: selectedStageName,
                items: items,
                onChanged: (val) async {
                  setState(() {
                    selectedStageName = val;
                    selectedStageId =
                        state.stages.firstWhere((e) => e.name == val).id;
                  });

                  final selectedDateTime =
                      selectedStageUpdatedDate ?? DateTime.now();

                  final leadStageRequest = LeadStageRequest(
                    lastStageDateUpdated: DateTime.now().toIso8601String(),
                    stage: selectedStageId ?? widget.stageId ?? '',
                    stageDateUpdated:
                        selectedDateTime.toUtc().toIso8601String(),
                    unitPrice: unitPriceController.text,
                    unitNumber: unitnumberController.text,
                    commissionRatio: commissionRatioController.text,
                    commissionMoney: commissionMoney,
                    cashbackRatio: cashbackRatioController.text,
                    cashbackMoney: cashbackMoney,
                    eoi:
                        eoiController.text.isNotEmpty
                            ? num.tryParse(eoiController.text)
                            : null,
                    reservation:
                        eoiController.text.isNotEmpty
                            ? num.tryParse(eoiController.text)
                            : null,
                  );

                  // final changeStageCubit = context.read<ChangeStageCubit>();
                    // أول API → update stage الفعلي
                    // await changeStageCubit.changeStage(
                    //   leadId: widget.leadId,
                    //   request: leadStageRequest,
                    // );
                    // // تاني API → تسجّل المرحلة في history
                    // await changeStageCubit.postLeadStage(
                    //   leadId: widget.leadId,
                    //   date: selectedDateTime.toIso8601String(),
                    //   stage: selectedStageId ?? '',
                    //   sales: widget.salesId ?? '',
                    // );
                  
                  // Callback لو محتاجه للشاشة الأب
                  widget.onSubmit(selectedStageName!,selectedStageId!, isAnswered,);
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),

        if (selectedStageName == "Done Deal") ...[
          const SizedBox(height: 12),
          CustomTextField(hint: "Unit Price", controller: unitPriceController),
          const SizedBox(height: 12),
          CustomTextField(
            hint: "Unit Number",
            controller: unitnumberController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            hint: "Commission Ratio (%)",
            controller: commissionRatioController,
          ),
          const SizedBox(height: 12),
          Text("Commission Money: $commissionMoney"),
          const SizedBox(height: 12),
          CustomTextField(
            hint: "Cashback Ratio (%)",
            controller: cashbackRatioController,
          ),
          const SizedBox(height: 12),
          Text("Cashback Money: $cashbackMoney"),
        ],

        if (selectedStageName == "EOI" || selectedStageName == "Reservation")
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CustomTextField(hint: "Money", controller: eoiController),
          ),

        const SizedBox(height: 12),
        CustomTextField(
          hint: "Stage Date Updated",
          controller: stageUpdatedController,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDateTime,
          ),
        ),
      ],
    );
  }
}
