// ignore_for_file: must_be_immutable, use_build_context_synchronously, avoid_print, unused_field
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // ✅ عوامل التصغير responsive
  late bool isTabletDevice;
  late double tabletScale;
  late double tabletFontScale;
  late double tabletWidthScale;
  late double tabletHeightScale;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    final now = DateTime.now();
    final formattedNow = DateFormat('yyyy-MM-dd hh:mm a').format(now);
    _dateController.text = formattedNow;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ حساب عوامل التصغير بناءً على حجم الشاشة
    final data = MediaQuery.of(context);
    final physicalSize = data.size;
    final diagonal = math.sqrt(
      math.pow(physicalSize.width, 2) + math.pow(physicalSize.height, 2),
    );
    final inches = diagonal / (data.devicePixelRatio * 160);
    isTabletDevice = inches >= 7.0;

    tabletScale = isTabletDevice ? 0.85 : 1.0;
    tabletFontScale = isTabletDevice ? 0.9 : 1.0;
    tabletWidthScale = isTabletDevice ? 0.85 : 1.0;
    tabletHeightScale = isTabletDevice ? 0.9 : 1.0;
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
        padding: EdgeInsets.fromLTRB(
          (16 * tabletWidthScale).w,
          (16 * tabletHeightScale).h,
          (16 * tabletWidthScale).w,
          (80 * tabletHeightScale).h,
        ),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850],
          borderRadius: BorderRadius.vertical(
            top: Radius.circular((16 * tabletScale).r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: (20 * tabletFontScale).r,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    child: Icon(
                      Icons.comment,
                      size: (20 * tabletFontScale).sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: (8 * tabletWidthScale).w),
                  Text(
                    ' ${widget.buttonName}',
                    style: TextStyle(
                      fontSize: (16 * tabletFontScale).sp,
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
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: (12 * tabletWidthScale).w,
                        vertical: (8 * tabletHeightScale).h,
                      ),
                    ),
                    child: Text(
                      _showStageSection ? "Hide Stage" : "Add action",
                      style: TextStyle(
                        fontSize: (16 * tabletFontScale).sp,
                        fontWeight: FontWeight.w600,
                        color: Constants.maincolor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: (12 * tabletHeightScale).h),

              // First Comment
              TextFormField(
                controller: _firstCommentController,
                maxLines: 3,
                maxLength: null,
                decoration: InputDecoration(
                  hintText: 'First Comment',
                  hintStyle: TextStyle(
                    fontSize: (14 * tabletFontScale).sp,
                    color: const Color.fromRGBO(127, 134, 137, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular((8 * tabletScale).r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: (12 * tabletWidthScale).w,
                    vertical: (16 * tabletHeightScale).h,
                  ),
                ),
                style: TextStyle(fontSize: (14 * tabletFontScale).sp),
              ),

              SizedBox(height: (8 * tabletHeightScale).h),

              // Second Comment
              TextFormField(
                controller: _secondCommentController,
                maxLines: 3,
                maxLength: null,
                decoration: InputDecoration(
                  hintText: 'Action (plan)',
                  hintStyle: TextStyle(
                    fontSize: (14 * tabletFontScale).sp,
                    color: const Color.fromRGBO(127, 134, 137, 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular((8 * tabletScale).r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: (12 * tabletWidthScale).w,
                    vertical: (16 * tabletHeightScale).h,
                  ),
                ),
                style: TextStyle(fontSize: (14 * tabletFontScale).sp),
              ),

              if (_showStageSection)
                Column(
                  children: [
                    SizedBox(height: (10 * tabletHeightScale).h),
                    Text(
                      "Change Stage",
                      style: TextStyle(
                        fontSize: (16 * tabletFontScale).sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: (10 * tabletHeightScale).h),

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
                        }
                      },
                    ),
                  ],
                ),

              SizedBox(height: (16 * tabletHeightScale).h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF285E67)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            (8 * tabletScale).r,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: (16 * tabletWidthScale).w,
                          vertical: (12 * tabletHeightScale).h,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Constants.maincolor,
                          fontSize: (17 * tabletFontScale).sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: (12 * tabletWidthScale).w),

                  Expanded(
                    child: BlocConsumer<AddCommentCubit, AddCommentState>(
                      listener: (context, state) {
                        if (state is AddCommentSuccess) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      (12 * tabletScale).r,
                                    ),
                                  ),
                                  title: Text(
                                    "Success",
                                    style: TextStyle(
                                      fontSize: (18 * tabletFontScale).sp,
                                    ),
                                  ),
                                  content: Text(
                                    "Comment added successfully.",
                                    style: TextStyle(
                                      fontSize: (14 * tabletFontScale).sp,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: (14 * tabletFontScale).sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        } else if (state is AddCommentError) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      (12 * tabletScale).r,
                                    ),
                                  ),
                                  title: Text(
                                    "Error",
                                    style: TextStyle(
                                      fontSize: (18 * tabletFontScale).sp,
                                    ),
                                  ),
                                  content: Text(
                                    state.message,
                                    style: TextStyle(
                                      fontSize: (14 * tabletFontScale).sp,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: (14 * tabletFontScale).sp,
                                        ),
                                      ),
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
                                    if (_showStageSection &&
                                        _selectedStageId == null) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      (12 * tabletScale).r,
                                                    ),
                                              ),
                                              title: Text(
                                                "Warning",
                                                style: TextStyle(
                                                  fontSize:
                                                      (18 * tabletFontScale).sp,
                                                ),
                                              ),
                                              content: Text(
                                                "Please choose a stage before adding action.",
                                                style: TextStyle(
                                                  fontSize:
                                                      (14 * tabletFontScale).sp,
                                                ),
                                              ),
                                            ),
                                      );
                                      return;
                                    }

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
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        (12 * tabletScale).r,
                                                      ),
                                                ),
                                                title: Text(
                                                  "Warning",
                                                  style: TextStyle(
                                                    fontSize:
                                                        (18 * tabletFontScale)
                                                            .sp,
                                                  ),
                                                ),
                                                content: Text(
                                                  "$_selectedStageName data is required",
                                                  style: TextStyle(
                                                    fontSize:
                                                        (14 * tabletFontScale)
                                                            .sp,
                                                  ),
                                                ),
                                              ),
                                        );
                                        return;
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

                                    if (salesId != null &&
                                        text1.isNotEmpty &&
                                        text2.isNotEmpty &&
                                        userlogId != null) {
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
                                          print(
                                            "leadstagerequest: $leadStageRequest",
                                          );
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
                                                  style: TextStyle(
                                                    fontSize:
                                                        (14 * tabletFontScale)
                                                            .sp,
                                                  ),
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
                                                  style: TextStyle(
                                                    fontSize:
                                                        (14 * tabletFontScale)
                                                            .sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Error changing stage: $e",
                                                style: TextStyle(
                                                  fontSize:
                                                      (14 * tabletFontScale).sp,
                                                ),
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                      }

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
                                            (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      (12 * tabletScale).r,
                                                    ),
                                              ),
                                              title: Text(
                                                "Warning",
                                                style: TextStyle(
                                                  fontSize:
                                                      (18 * tabletFontScale).sp,
                                                ),
                                              ),
                                              content: Text(
                                                "Please fill in all the required fields.",
                                                style: TextStyle(
                                                  fontSize:
                                                      (14 * tabletFontScale).sp,
                                                ),
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
                              borderRadius: BorderRadius.circular(
                                (8 * tabletScale).r,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: (16 * tabletWidthScale).w,
                              vertical: (12 * tabletHeightScale).h,
                            ),
                          ),
                          child:
                              isLoading
                                  ? SizedBox(
                                    height: (20 * tabletFontScale).h,
                                    width: (20 * tabletFontScale).w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    '${widget.optionalName}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: (14 * tabletFontScale).sp,
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
