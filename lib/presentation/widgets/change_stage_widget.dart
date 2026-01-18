// ignore_for_file: unused_local_variable, use_build_context_synchronously, non_constant_identifier_names, avoid_print, unused_element, deprecated_member_use, unused_field, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_dropdown_widget.dart';
import 'package:homewalkers_app/presentation/widgets/custom_text_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomChangeStageWidget extends StatefulWidget {
  final String? leadStage;
  final String leedId;
  final String? salesId;
  final String? leadstageupdated;
  final String? stageId;
  final Function(String, String?) onStageSelected;
  final Function(bool isAnswered)? onAnswerChanged;
  final Function(Map<String, dynamic>)? onDoneDealDataChanged;
  final Function(DateTime)? onStageDateChanged;

  const CustomChangeStageWidget({
    Key? key,
    required this.leadStage,
    required this.leedId,
    required this.onStageSelected,
    this.salesId,
    this.leadstageupdated,
    this.stageId,
    this.onAnswerChanged,
    this.onDoneDealDataChanged,
    this.onStageDateChanged,
  }) : super(key: key);

  @override
  State<CustomChangeStageWidget> createState() =>
      _CustomChangeStageWidgetState();
}

class _CustomChangeStageWidgetState extends State<CustomChangeStageWidget> {
  late TextEditingController oldStageController;
  late TextEditingController unitPriceController;
  late TextEditingController commissionRatioController;
  late TextEditingController cashbackRatioController;
  late TextEditingController unitnumberController;
  late TextEditingController eoiController;
  late TextEditingController stageUpdatedController;

  late GlobalKey<FormState> formKey;

  String? selectedStageName;
  String? selectedStageId;
  String commissionMoney = '0.00';
  String cashbackMoney = '0.00';
  DateTime? selectedDateTime;
  DateTime? selectedStageUpdatedDateTime;

  bool isAnswered = true;
  bool areListenersSetup = false;

  String? _savedSalesId;
  String? _role;
  // ignore: prefer_final_fields
  bool _stageInitialized = false;

  @override
  void initState() {
    super.initState();
    // تهيئة selectedStageName بالقيمة الأولية
    selectedStageName = null;
    oldStageController = TextEditingController(text: widget.leadStage ?? '');
    unitPriceController = TextEditingController();
    commissionRatioController = TextEditingController();
    cashbackRatioController = TextEditingController();
    unitnumberController = TextEditingController();
    eoiController = TextEditingController();
    stageUpdatedController = TextEditingController(
      text:
          widget.leadstageupdated != null && widget.leadstageupdated!.isNotEmpty
              ? DateFormat("yyyy-MM-dd hh:mm a").format(
                DateTime.tryParse(widget.leadstageupdated!)?.toLocal() ??
                    DateTime.now(),
              )
              : DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now()),
    );

    formKey = GlobalKey<FormState>();

    isAnswered = !(widget.leadStage?.toLowerCase() == "no answer");

    // تحميل البيانات من SharedPreferences
    _loadSharedPreferences();

    // إعداد listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupListeners();
    });
  }

  Future<void> _loadSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? '';
      _savedSalesId = prefs.getString('salesIDD') ?? 'default_sales_id';
    });
  }

  // Calculation logic
  void calculateValues() {
    final double unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;
    final double commissionRatio =
        double.tryParse(commissionRatioController.text) ?? 0.0;
    final double cashbackRatio =
        double.tryParse(cashbackRatioController.text) ?? 0.0;
    final double calculatedCommission = (unitPrice * commissionRatio) / 100;
    final double calculatedCashback =
        (calculatedCommission * cashbackRatio) / 100;

    setState(() {
      commissionMoney = calculatedCommission.toStringAsFixed(2);
      cashbackMoney = calculatedCashback.toStringAsFixed(2);
    });
  }

  void _notifyDoneDealData() {
    if (selectedStageName?.toLowerCase() == "done deal" &&
        widget.onDoneDealDataChanged != null) {
      final data = {
        'unitPrice':
            unitPriceController.text.isNotEmpty
                ? unitPriceController.text
                : '0',
        'unitNumber':
            unitnumberController.text.isNotEmpty
                ? unitnumberController.text
                : '1',
        'commissionRatio':
            commissionRatioController.text.isNotEmpty
                ? commissionRatioController.text
                : '0',
        'commissionMoney':
            commissionMoney.isNotEmpty ? commissionMoney : '0.00',
        'cashbackRatio':
            cashbackRatioController.text.isNotEmpty
                ? cashbackRatioController.text
                : '0',
        'cashbackMoney': cashbackMoney.isNotEmpty ? cashbackMoney : '0.00',
      };
      widget.onDoneDealDataChanged!(data);
    }
  }

  // Add listeners to controllers to automatically recalculate
  void setupListeners() {
    if (!areListenersSetup) {
      unitPriceController.addListener(() {
        calculateValues();
        _notifyDoneDealData();
      });
      commissionRatioController.addListener(() {
        calculateValues();
        _notifyDoneDealData();
      });
      cashbackRatioController.addListener(() {
        calculateValues();
        _notifyDoneDealData();
      });
      unitnumberController.addListener(() {
        _notifyDoneDealData();
      });
      cashbackRatioController.addListener(() {
        _notifyDoneDealData();
      });
      areListenersSetup = true;
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedStageUpdatedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          selectedStageUpdatedDateTime ?? DateTime.now(),
        ),
      );

      if (time != null) {
        final fullDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          selectedStageUpdatedDateTime = fullDate;
          stageUpdatedController.text = DateFormat(
            "yyyy-MM-dd hh:mm a",
          ).format(fullDate);
        });

        // ✅ ابعت التاريخ للـ Parent
        widget.onStageDateChanged?.call(fullDate);

        // حفظ في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pickedDateTime', fullDate.toIso8601String());
      }
    }
  }

  @override
  void dispose() {
    // تنظيف الـ listeners لتجنب تسرب الذاكرة
    if (areListenersSetup) {
      unitPriceController.removeListener(calculateValues);
      commissionRatioController.removeListener(calculateValues);
      cashbackRatioController.removeListener(calculateValues);
    }

    oldStageController.dispose();
    unitPriceController.dispose();
    commissionRatioController.dispose();
    cashbackRatioController.dispose();
    unitnumberController.dispose();
    eoiController.dispose();
    stageUpdatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StagesCubit(StagesApiService())..fetchStages(),
        ),
        //   BlocProvider(create: (context) => ChangeStageCubit()),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Old Stage Field
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Switch(
                    activeColor: Constants.maincolor,
                    value: isAnswered,
                    onChanged: (value) {
                      setState(() {
                        isAnswered = value;
                      });
                      widget.onAnswerChanged?.call(value);
                    },
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

          /// Dropdown for Stages
          BlocBuilder<StagesCubit, StagesState>(
            builder: (context, state) {
              if (state is StagesLoading) {
                return const CircularProgressIndicator();
              } else if (state is StagesLoaded) {
                /// 👇 stages الأساسية
                List stages = state.stages;

                /// 🔐 لو مش Admin ولا Marketer → نخفي No stage و fresh
                if (_role != 'Admin' && _role != 'Marketer') {
                  stages =
                      stages
                          .where(
                            (stage) =>
                                stage.name?.toLowerCase() != 'no stage' &&
                                stage.name?.toLowerCase() != 'fresh',
                          )
                          .toList();
                }

                // الحصول على القائمة مع إزالة التكرارات
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
                          stages.firstWhere((stage) => stage.name == value).id;

                      /// 🔥 لو اليوزر اختار NO ANSWER → خلي السويتش OFF تلقائي
                      if (value?.toLowerCase() == "no answer") {
                        isAnswered = false;
                      } else if (value != null) {
                        isAnswered = true;
                      }

                      // إرسال البيانات فور الاختيار
                      widget.onStageSelected(value ?? '', selectedStageId);
                      _notifyDoneDealData(); // لو Stage = Done Deal
                    });
                  },
                );
              } else if (state is StagesError) {
                return Text(
                  "error: stages did not change",
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
                      if (value == null || value.trim().isEmpty) {
                        return "Unit Price is required";
                      }
                    }
                    return null;
                  },
                  textInputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: 12.h),
                CustomTextField(
                  hint: "Unit number",
                  controller: unitnumberController,
                  validator: (value) {
                    if (selectedStageName == "Done Deal") {
                      if (value == null || value.trim().isEmpty) {
                        return "Unit number is required";
                      }
                    }
                    return null;
                  },
                  textInputType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                ),
                SizedBox(height: 12.h),
                CustomTextField(
                  hint: "Commission Ratio (%)",
                  controller: commissionRatioController,
                  validator: (value) {
                    if (selectedStageName == "Done Deal") {
                      if (value == null || value.trim().isEmpty) {
                        return "Commission Ratio is required";
                      }
                    }
                    return null;
                  },
                  textInputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Commission Money: $commissionMoney",
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
                      if (value == null || value.trim().isEmpty) {
                        return "cashback Ratio is required";
                      }
                    }
                    return null;
                  },
                  textInputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Cashback Money: $cashbackMoney",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

          if (selectedStageName == "EOI" || selectedStageName == "Reservation")
            Column(
              children: [
                SizedBox(height: 12.h),
                CustomTextField(
                  hint: "Money",
                  controller: eoiController,
                  textInputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),

          /// New Field: Stage Updated Date
          SizedBox(height: 12.h),
          CustomTextField(
            hint: "Stage Date Updated",
            controller: stageUpdatedController,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDateTime,
            ),
          ),
        ],
      ),
    );
  }
}
