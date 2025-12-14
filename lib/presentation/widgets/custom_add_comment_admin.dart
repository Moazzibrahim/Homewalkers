// ignore_for_file: must_be_immutable, use_build_context_synchronously, avoid_print
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_state.dart';
import 'package:homewalkers_app/presentation/widgets/custom_change_stage_dialog.dart';
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
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final String salesId = prefs.getString('salesIdD') ?? '';

                      // 🧠 استدعاء الديالوج وانتظار النتيجة
                      final bool?
                      isAnswered = await CustomChangeStageDialog.showChangeDialog(
                        context: context,
                        leadStage: widget.leadStage,
                        leedId: widget.leadId!,
                        salesId: salesId,
                        stageId: widget.stageId,
                        onStageChanged: (newStage) {
                          // 🔒 هنخلي التغيير داخل setState يحصل بس لما العملية تنجح (هنتأكد تحت)
                          widget.leadStage = newStage;
                        },
                        leadstageupdated: widget.laststageupdated,
                      );

                      // ✅ لو العملية فشلت أو رجعت null (يعني المستخدم قفل الديالوج أو حصل خطأ)
                      if (isAnswered == null) {
                        log(
                          "❌ Stage change canceled or failed, no updates applied.",
                        );
                        return;
                      }

                      // ✅ لو العملية نجحت فعلاً، نكمل
                      final pickedDateTimeStr = prefs.getString(
                        'pickedDateTime',
                      );
                      final now = DateTime.now();
                      String formattedNow = DateFormat(
                        "yyyy-MM-dd hh:mm a",
                      ).format(now);
                      String formattedPickedDate = formattedNow;

                      if (pickedDateTimeStr != null &&
                          pickedDateTimeStr.isNotEmpty) {
                        try {
                          final pickedDateTime = DateTime.parse(
                            pickedDateTimeStr,
                          );
                          formattedPickedDate = DateFormat(
                            "yyyy-MM-dd hh:mm a",
                          ).format(pickedDateTime);
                        } catch (e) {
                          print("❌ Error parsing pickedDateTime: $e");
                        }
                      }

                      await Future.delayed(const Duration(milliseconds: 200));
                      log("✅ Stage change success, isAnswered: $isAnswered");

                      setState(() {
                        if (isAnswered == true) {
                          _firstCommentController.text = "Answer";
                          _secondCommentController.text = "Answer";
                          _dateController.text = formattedPickedDate;
                        } else {
                          _firstCommentController.text = "No Answer";
                          _secondCommentController.text =
                              "No Answer هتواصل معاه في $formattedPickedDate";
                          _dateController.text = formattedPickedDate;
                        }
                      });
                      // // ✅ التحديث يحصل فقط بعد نجاح العملية
                      // setState(() {
                      //   // لو مش Transfer و مش Not Interested
                      //   if (isAnswered == true &&
                      //       widget.leadStage != "Transfer" &&
                      //       widget.leadStage != "Not Interested") {
                      //     _firstCommentController.text = "Answer";
                      //     _secondCommentController.text =
                      //         "${widget.leadStage} within $formattedPickedDate";
                      //     _dateController.text = formattedPickedDate;
                      //   } else if (isAnswered == false &&
                      //       widget.leadStage != "Transfer" &&
                      //       widget.leadStage != "Not Interested") {
                      //     _firstCommentController.text = "No Answer";
                      //     _secondCommentController.text =
                      //         "${widget.leadStage} within $formattedPickedDate";
                      //     _dateController.text = formattedPickedDate;
                      //   } else if (widget.leadStage == "Transfer" ||
                      //       widget.leadStage == "Not Interested") {
                      //     _firstCommentController.text = "";
                      //     _secondCommentController.text = "";
                      //     _dateController.text = formattedPickedDate;
                      //   }
                      // });
                    },
                    child: const Text(
                      "Add action",
                      style: TextStyle(
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
                                      context
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

                                      log(
                                        "text 1: $text1, text 2: $text2, date: $date",
                                      );
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
