// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/add_comment/add_comment_state.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCommentBottomSheet extends StatefulWidget {
  String? buttonName;
  String? optionalName;
  String? leadId;
  AddCommentBottomSheet({
    super.key,
    required this.buttonName,
    required this.optionalName,
    this.leadId,
  });
  @override
  State<AddCommentBottomSheet> createState() => _AddCommentBottomSheetState();
}

class _AddCommentBottomSheetState extends State<AddCommentBottomSheet> {
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
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userlogId = prefs.getString('userlog');
      salesId = prefs.getString('salesId');
      log("Userlog ID: $userlogId");
      log("Sales ID: $salesId");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              ],
            ),
            const SizedBox(height: 12),
            // First Comment
            TextFormField(
              controller: _firstCommentController,
              maxLines: 3,
              maxLength: 200,
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
              maxLength: 200,
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
            const SizedBox(height: 8),
            // Action Date & Time
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    final combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    // عدل هنا حسب الصيغة اللي السيرفر بيتوقعها
                    final formatted = DateFormat(
                      "yyyy-MM-ddTHH:mm:ss",
                    ).format(combinedDateTime);
                    _dateController.text = formatted;
                  }
                }
              },
              decoration: InputDecoration(
                hintText: 'Action Date & Time',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(143, 146, 146, 1),
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: const Icon(Icons.calendar_today_outlined),
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
                      side: const BorderSide(color: Constants.maincolor),
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
                                      Navigator.of(
                                        context,
                                      ).pop(); // Close dialog
                                      Navigator.of(
                                        context,
                                      ).pop(true); // Close bottom sheet
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
                      return ElevatedButton(
                        onPressed: () async {
                          final text1 = _firstCommentController.text.trim();
                          final text2 = _secondCommentController.text.trim();
                          final date = _dateController.text.trim();

                          if (salesId != null &&
                              text1.isNotEmpty &&
                              text2.isNotEmpty &&
                              date.isNotEmpty &&
                              userlogId != null) {
                            // ✅ نفذ الإضافة واستنى النجاح
                            await context.read<AddCommentCubit>().addComment(
                              sales: salesId!,
                              text1: text1,
                              text2: text2,
                              date: date,
                              leed: widget.leadId!,
                              userlog: userlogId!,
                              usernamelog: userlogId!,
                            );
                            // ✅ بعد ما يتم إضافة التعليق بنجاح، عدل الـ lastcommentdate
                            await context
                                .read<AddCommentCubit>()
                                .editLastDateComment(widget.leadId!);

                            log("text 1: $text1, text 2: $text2, date: $date");
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
                        child: Text(
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
    );
  }
}
