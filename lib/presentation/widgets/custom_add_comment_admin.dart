// ignore_for_file: must_be_immutable, use_build_context_synchronously, avoid_print, unused_field
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/models/leadStagesModel.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/change_stage/change_stage_state.dart';
import 'package:homewalkers_app/presentation/widgets/change_stage_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAddCommentAdmin extends StatefulWidget {
  String? buttonName;
  String? optionalName;
  String? leadId;
  String? stageName;
  bool? answered = false;
  String? leadStage;
  String? laststageupdated;
  String? stageId;
  CustomAddCommentAdmin({
    super.key,
    required this.buttonName,
    required this.optionalName,
    this.leadId,
    this.stageName,
    this.answered,
    this.leadStage,
    this.laststageupdated,
    this.stageId,
  });
  @override
  State<CustomAddCommentAdmin> createState() => _AddCommentBottomSheetState();
}

class _AddCommentBottomSheetState extends State<CustomAddCommentAdmin> {
  final TextEditingController _firstCommentController = TextEditingController();
  final TextEditingController _secondCommentController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? salesId;
  String? userlogId;
  bool _showStageSection = false;

  String? _selectedStageName;
  String? _selectedStageId;

  bool _isAnswered = true;
  Map<String, dynamic>? doneDealData;
  DateTime? _selectedStageDate;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // تحميل بيانات المستخدم

    // ✅ ضبط التاريخ والوقت الحالي تلقائيًا عند الفتح
    final now = DateTime.now();
    final formattedNow = DateFormat('yyyy-MM-dd hh:mm a').format(now);
    _dateController.text = formattedNow;
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userlogId = prefs.getString('salesId');
      salesId = prefs.getString('salesId');
      log("Userlog ID: $userlogId");
      log("Sales ID: $salesId");
    });
  }

  void _applyNoAnswerLogic() {
    final now = DateTime.now();
    final formatted = DateFormat("yyyy-MM-dd hh:mm a").format(now);

    _firstCommentController.text = "No Answer";
    _secondCommentController.text = "No Answer هتواصل معاه في $formatted";
    _dateController.text = formatted;
  }

  void _clearNoAnswerLogic() {
    _firstCommentController.clear();
    _secondCommentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    child: const Icon(Icons.comment, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ' ${widget.buttonName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showStageSection = !_showStageSection;
                      });
                    },
                    child: Text(
                      _showStageSection ? "Hide Stage" : "Add action",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // First Comment
              TextFormField(
                controller: _firstCommentController,
                maxLines: 3,
                maxLength: null,
                decoration: InputDecoration(
                  hintText: 'First Comment',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(127, 134, 137, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Second Comment
              TextFormField(
                controller: _secondCommentController,
                maxLines: 3,
                maxLength: null,
                decoration: InputDecoration(
                  hintText: 'Action (plan)',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(127, 134, 137, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_showStageSection)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Change Stage",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    CustomChangeStageWidget(
                      leadStage: widget.leadStage ?? '',
                      leedId: widget.leadId!,
                      salesId: salesId,
                      stageId: widget.stageId,
                      leadstageupdated: widget.laststageupdated,

                      onDoneDealDataChanged: (data) {
                        doneDealData = data;
                      },
                      onStageDateChanged: (date) {
                        _selectedStageDate = date;
                      },

                      onAnswerChanged: (isAnswered) {
                        _isAnswered = isAnswered;

                        if (!isAnswered) {
                          _applyNoAnswerLogic();
                        } else {
                          _clearNoAnswerLogic();
                        }
                      },

                      onStageSelected: (stageName, stageId) {
                        setState(() {
                          _selectedStageName = stageName;
                          _selectedStageId = stageId;
                        });

                        if (stageName.toLowerCase() == "no answer") {
                          _applyNoAnswerLogic();
                        } else {
                          // _clearNoAnswerLogic();
                        }
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 16),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF285E67)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Constants.maincolor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlocConsumer<AddCommentCubit, AddCommentState>(
                      listener: (context, state) {
                        if (state is AddCommentSuccess) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text("Success"),
                                  content: const Text(
                                    "Comment added successfully.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                          );
                        } else if (state is AddCommentError) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: Text(state.message),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is AddCommentLoading;

                        return ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    // ❗ لو فاتح Add action لازم Stage
                                    if (_showStageSection &&
                                        _selectedStageId == null) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => const AlertDialog(
                                              title: Text("Warning"),
                                              content: Text(
                                                "Please choose a stage before adding action.",
                                              ),
                                            ),
                                      );
                                      return;
                                    }

                                    // ⛔ Validation قبل أي حاجة
                                    if (_showStageSection &&
                                        (_selectedStageName == "Done Deal" ||
                                            _selectedStageName == "EOI")) {
                                      if (doneDealData == null ||
                                          doneDealData!.isEmpty ||
                                          (doneDealData!['unitPrice'] == null ||
                                              doneDealData!['unitPrice']
                                                  .toString()
                                                  .isEmpty) ||
                                          (doneDealData!['unitNumber'] ==
                                                  null ||
                                              doneDealData!['unitNumber']
                                                  .toString()
                                                  .isEmpty) ||
                                          (doneDealData!['commissionRatio'] ==
                                                  null ||
                                              doneDealData!['commissionRatio']
                                                  .toString()
                                                  .isEmpty) ||
                                          (doneDealData!['cashbackRatio'] ==
                                                  null ||
                                              doneDealData!['cashbackRatio']
                                                  .toString()
                                                  .isEmpty)) {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                title: const Text("Warning"),
                                                content: Text(
                                                  "$_selectedStageName data is required",
                                                ),
                                              ),
                                        );
                                        return; // ⛔ هنا بيقف كل الزرار
                                      }
                                    }

                                    final text1 =
                                        _firstCommentController.text.trim();
                                    final text2 =
                                        _secondCommentController.text.trim();
                                    final date =
                                        widget.laststageupdated != null &&
                                                widget
                                                    .laststageupdated!
                                                    .isNotEmpty
                                            ? widget.laststageupdated!
                                            : DateFormat(
                                              "yyyy-MM-dd hh:mm a",
                                            ).format(DateTime.now());

                                    // ✅ شيلنا التحقق عن التاريخ
                                    if (salesId != null &&
                                        text1.isNotEmpty &&
                                        text2.isNotEmpty &&
                                        userlogId != null) {
                                      // ✅ إذا تم اختيار Stage جديد
                                      if (_selectedStageId != null &&
                                          _selectedStageName != null) {
                                        try {
                                          final stageDate =
                                              _selectedStageDate?.toUtc() ??
                                              DateTime.now().toUtc();
                                          final leadStageRequest = LeadStageRequest(
                                            lastStageDateUpdated:
                                                stageDate.toIso8601String(),
                                            stage: _selectedStageId!,
                                            stageDateUpdated:
                                                stageDate.toIso8601String(),
                                            unitPrice:
                                                doneDealData?['unitPrice'] ??
                                                '',
                                            // ضع القيم المناسبة إذا لزم الأمر
                                            unitNumber:
                                                doneDealData?['unitNumber'] ??
                                                '',
                                            commissionRatio:
                                                doneDealData?['commissionRatio'] ??
                                                '',
                                            commissionMoney:
                                                doneDealData?['commissionMoney'] ??
                                                '0.00',
                                            cashbackRatio:
                                                doneDealData?['cashbackRatio'] ??
                                                '',
                                            cashbackMoney:
                                                doneDealData?['cashbackMoney'] ??
                                                '0.00',
                                            eoi: null,
                                            reservation: null,
                                          );
                                          print(
                                            "---- Lead Stage Request Data ----",
                                          );
                                          print("Stage ID: $_selectedStageId");
                                          print(
                                            "Unit Price: ${doneDealData?['unitPrice']}",
                                          );
                                          print(
                                            "Unit Number: ${doneDealData?['unitNumber']}",
                                          );
                                          print(
                                            "Commission Ratio: ${doneDealData?['commissionRatio']}",
                                          );
                                          print(
                                            "Commission Money: ${doneDealData?['commissionMoney']}",
                                          );
                                          print(
                                            "Cashback Ratio: ${doneDealData?['cashbackRatio']}",
                                          );
                                          print(
                                            "Cashback Money: ${doneDealData?['cashbackMoney']}",
                                          );
                                          print(
                                            "-------------------------------",
                                          );
                                          print("leadstagerequest: $leadStageRequest");
                                          final changeStageCubit =
                                              context.read<ChangeStageCubit>();
                                          await changeStageCubit.changeStage(
                                            leadId: widget.leadId!,
                                            request: leadStageRequest,
                                          );

                                          if (changeStageCubit.state
                                              is ChangeStageSuccess) {
                                            await changeStageCubit
                                                .postLeadStage(
                                                  leadId: widget.leadId!,
                                                  date:
                                                      DateTime.now()
                                                          .toIso8601String()
                                                          .split('T')
                                                          .first,
                                                  stage: _selectedStageId!,
                                                  sales: salesId!,
                                                );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Stage changed to $_selectedStageName",
                                                ),
                                              ),
                                            );
                                          } else if (changeStageCubit.state
                                              is ChangeStageError) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  (changeStageCubit.state
                                                          as ChangeStageError)
                                                      .error,
                                                ),
                                              ),
                                            );
                                            return; // لو فشل التغيير، لا تضيف الكومنت
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Error changing stage: $e",
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                      }

                                      // ✅ بعد نجاح تغيير Stage أو لو لم يتم تغييره
                                      await context
                                          .read<AddCommentCubit>()
                                          .addComment(
                                            sales: salesId!,
                                            text1: text1,
                                            text2: text2,
                                            date: date,
                                            leed: widget.leadId!,
                                            userlog: userlogId!,
                                            usernamelog: userlogId!,
                                          );

                                      await context
                                          .read<AddCommentCubit>()
                                          .editLastDateComment(widget.leadId!);
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => const AlertDialog(
                                              title: Text("Warning"),
                                              content: Text(
                                                "Please fill in all the required fields.",
                                              ),
                                            ),
                                      );
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    '${widget.optionalName}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        );
                      },
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
