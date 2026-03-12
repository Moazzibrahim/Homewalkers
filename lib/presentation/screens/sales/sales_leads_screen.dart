// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable, library_private_types_in_public_api, unused_field
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/meeting/get_meeting_comments.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/models/salesLeadsModelWithPagination.dart';
import 'package:homewalkers_app/data/models/stages_models.dart';
import 'package:homewalkers_app/presentation/screens/Admin/meetingCommentsScreen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_data_dashboard_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales_tabs_screen.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/meeting/cubit/meetingcomments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_leads_sales/get_leads_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/custom_filter_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/team_leader_widgets/edit_lead_sales_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// كلاس للقيم المتجاوبة
class ResponsiveSalesValues {
  final bool isTablet;
  final bool isLargeTablet;
  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;

  // قيم مخصصة
  final double horizontalPadding;
  final double verticalPadding;
  final double cardMarginHorizontal;
  final double cardMarginVertical;
  final double cardPadding;
  final double fontSizeSmall;
  final double fontSizeMedium;
  final double fontSizeLarge;
  final double fontSizeXLarge;
  final double iconSizeSmall;
  final double iconSizeMedium;
  final double iconSizeLarge;
  final double buttonHeight;
  final double buttonWidth;
  final double avatarRadius;
  final double dialogHorizontalPadding;
  final double dialogVerticalPadding;
  final int crossAxisCount; // للـ Grid لو استخدمناه
  final double stageContainerHPadding;
  final double stageContainerVPadding;

  ResponsiveSalesValues({
    required this.isTablet,
    required this.isLargeTablet,
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.cardMarginHorizontal,
    required this.cardMarginVertical,
    required this.cardPadding,
    required this.fontSizeSmall,
    required this.fontSizeMedium,
    required this.fontSizeLarge,
    required this.fontSizeXLarge,
    required this.iconSizeSmall,
    required this.iconSizeMedium,
    required this.iconSizeLarge,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.avatarRadius,
    required this.dialogHorizontalPadding,
    required this.dialogVerticalPadding,
    required this.crossAxisCount,
    required this.stageContainerHPadding,
    required this.stageContainerVPadding,
  });

  factory ResponsiveSalesValues.fromContext(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final bool isLandscape = width > height;
    final bool isTablet = width >= 600;
    final bool isLargeTablet = width >= 900;

    // هواتف صغيرة
    if (width < 360) {
      return ResponsiveSalesValues(
        isTablet: isTablet,
        isLargeTablet: isLargeTablet,
        isLandscape: isLandscape,
        screenWidth: width,
        screenHeight: height,
        horizontalPadding: 8.0,
        verticalPadding: 8.0,
        cardMarginHorizontal: 8.0,
        cardMarginVertical: 2.0,
        cardPadding: 12.0,
        fontSizeSmall: 10.0,
        fontSizeMedium: 11.0,
        fontSizeLarge: 12.0,
        fontSizeXLarge: 14.0,
        iconSizeSmall: 16.0,
        iconSizeMedium: 18.0,
        iconSizeLarge: 20.0,
        buttonHeight: 36.0,
        buttonWidth: 36.0,
        avatarRadius: 18.0,
        dialogHorizontalPadding: 16.0,
        dialogVerticalPadding: 16.0,
        crossAxisCount: 1,
        stageContainerHPadding: 8.0,
        stageContainerVPadding: 4.0,
      );
    }
    // هواتف عادية
    else if (width < 600) {
      return ResponsiveSalesValues(
        isTablet: isTablet,
        isLargeTablet: isLargeTablet,
        isLandscape: isLandscape,
        screenWidth: width,
        screenHeight: height,
        horizontalPadding: 13.0,
        verticalPadding: 10.0,
        cardMarginHorizontal: 3.0,
        cardMarginVertical: 4.0,
        cardPadding: 19.0,
        fontSizeSmall: 12.0,
        fontSizeMedium: 13.0,
        fontSizeLarge: 14.0,
        fontSizeXLarge: 16.0,
        iconSizeSmall: 18.0,
        iconSizeMedium: 20.0,
        iconSizeLarge: 22.0,
        buttonHeight: 44.0,
        buttonWidth: 44.0,
        avatarRadius: 20.0,
        dialogHorizontalPadding: 20.0,
        dialogVerticalPadding: 16.0,
        crossAxisCount: isLandscape ? 2 : 1,
        stageContainerHPadding: 10.0,
        stageContainerVPadding: 5.0,
      );
    }
    // تابلت صغير (600-900)
    else if (width < 900) {
      // في وضع Landscape للتابلت
      if (isLandscape) {
        return ResponsiveSalesValues(
          isTablet: isTablet,
          isLargeTablet: isLargeTablet,
          isLandscape: isLandscape,
          screenWidth: width,
          screenHeight: height,
          horizontalPadding: 24.0,
          verticalPadding: 20.0,
          cardMarginHorizontal: 20.0,
          cardMarginVertical: 8.0,
          cardPadding: 20.0,
          fontSizeSmall: 14.0,
          fontSizeMedium: 15.0,
          fontSizeLarge: 16.0,
          fontSizeXLarge: 18.0,
          iconSizeSmall: 22.0,
          iconSizeMedium: 24.0,
          iconSizeLarge: 26.0,
          buttonHeight: 52.0,
          buttonWidth: 52.0,
          avatarRadius: 24.0,
          dialogHorizontalPadding: 32.0,
          dialogVerticalPadding: 24.0,
          crossAxisCount: 3,
          stageContainerHPadding: 12.0,
          stageContainerVPadding: 6.0,
        );
      }
      // Portrait للتابلت
      else {
        return ResponsiveSalesValues(
          isTablet: isTablet,
          isLargeTablet: isLargeTablet,
          isLandscape: isLandscape,
          screenWidth: width,
          screenHeight: height,
          horizontalPadding: 24.0,
          verticalPadding: 16.0,
          cardMarginHorizontal: 24.0,
          cardMarginVertical: 8.0,
          cardPadding: 20.0,
          fontSizeSmall: 13.0,
          fontSizeMedium: 14.0,
          fontSizeLarge: 15.0,
          fontSizeXLarge: 17.0,
          iconSizeSmall: 20.0,
          iconSizeMedium: 22.0,
          iconSizeLarge: 24.0,
          buttonHeight: 48.0,
          buttonWidth: 48.0,
          avatarRadius: 22.0,
          dialogHorizontalPadding: 28.0,
          dialogVerticalPadding: 20.0,
          crossAxisCount: 2,
          stageContainerHPadding: 12.0,
          stageContainerVPadding: 6.0,
        );
      }
    }
    // تابلت كبير (>900)
    else {
      if (isLandscape) {
        return ResponsiveSalesValues(
          isTablet: isTablet,
          isLargeTablet: isLargeTablet,
          isLandscape: isLandscape,
          screenWidth: width,
          screenHeight: height,
          horizontalPadding: 32.0,
          verticalPadding: 24.0,
          cardMarginHorizontal: 32.0,
          cardMarginVertical: 12.0,
          cardPadding: 24.0,
          fontSizeSmall: 15.0,
          fontSizeMedium: 16.0,
          fontSizeLarge: 17.0,
          fontSizeXLarge: 20.0,
          iconSizeSmall: 24.0,
          iconSizeMedium: 26.0,
          iconSizeLarge: 28.0,
          buttonHeight: 56.0,
          buttonWidth: 56.0,
          avatarRadius: 26.0,
          dialogHorizontalPadding: 48.0,
          dialogVerticalPadding: 32.0,
          crossAxisCount: 4,
          stageContainerHPadding: 14.0,
          stageContainerVPadding: 8.0,
        );
      } else {
        return ResponsiveSalesValues(
          isTablet: isTablet,
          isLargeTablet: isLargeTablet,
          isLandscape: isLandscape,
          screenWidth: width,
          screenHeight: height,
          horizontalPadding: 32.0,
          verticalPadding: 20.0,
          cardMarginHorizontal: 32.0,
          cardMarginVertical: 10.0,
          cardPadding: 24.0,
          fontSizeSmall: 14.0,
          fontSizeMedium: 15.0,
          fontSizeLarge: 16.0,
          fontSizeXLarge: 18.0,
          iconSizeSmall: 22.0,
          iconSizeMedium: 24.0,
          iconSizeLarge: 26.0,
          buttonHeight: 52.0,
          buttonWidth: 52.0,
          avatarRadius: 24.0,
          dialogHorizontalPadding: 40.0,
          dialogVerticalPadding: 28.0,
          crossAxisCount: 3,
          stageContainerHPadding: 14.0,
          stageContainerVPadding: 8.0,
        );
      }
    }
  }
}

class SalesLeadsScreen extends StatefulWidget {
  final String? stageName;
  final String? stageId;
  final bool? data; // true for Data Center, false for Sales, null for all
  final bool?
  transferfromdata; // true for transferred from data center, false for not transferred, null for all

  const SalesLeadsScreen({
    super.key,
    this.stageName,
    this.stageId,
    this.data,
    this.transferfromdata,
  });

  @override
  State<SalesLeadsScreen> createState() => _SalesLeadsScreenState();
}

class _SalesLeadsScreenState extends State<SalesLeadsScreen> {
  bool _showCheckboxes = false;
  String? _selectedLeadId;
  LeadPagination? _selectedLead;
  late ScrollController _scrollController;
  late ResponsiveSalesValues _responsive;
  final nameController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log("🚀 ============ SALES LEADS SCREEN INIT ============");

      final cubit = context.read<GetLeadsCubit>();

      await cubit.fetchSalesLeadsWithPagination(
        data: widget.data,
        transferefromdata: widget.transferfromdata,
        stageId: widget.stageId,
        resetPagination: true,
      );

      context.read<SalesCubit>().fetchAllSales();

      log("🚀 ============ SALES LEADS SCREEN INIT END ============");
    });
  }

  void _onScroll() {
    final cubit = context.read<GetLeadsCubit>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (cubit.hasMoreData && !cubit.isFetchingMore) {
        log("📜 Loading more data... Page: ${cubit.currentPage}");

        cubit.fetchSalesLeadsWithPagination(
          isLoadMore: true,
          limit: 10,
          data: widget.data,
          transferefromdata: widget.transferfromdata,
          stageId: widget.stageId,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    nameController.dispose();
    _debounceTimer?.cancel(); // إلغاء التايمر عند الخروج
    super.dispose();
  }

  String formatDateTimeToDubai(String dateStr) {
    try {
      final utcTime = DateTime.parse(dateStr).toUtc();
      final dubaiTime = utcTime.add(const Duration(hours: 4));
      final day = dubaiTime.day.toString().padLeft(2, '0');
      final month = dubaiTime.month.toString().padLeft(2, '0');
      final year = dubaiTime.year;
      int hour = dubaiTime.hour;
      final minute = dubaiTime.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$day/$month/$year - ${hour.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (e) {
      return dateStr;
    }
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
    } else {
      print('Could not launch $phoneUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    _responsive = ResponsiveSalesValues.fromContext(context);

    return BlocBuilder<GetLeadsCubit, GetLeadsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          appBar: CustomAppBar(
            //  title: 'Leads',
            onBack: () {
              if (widget.transferfromdata == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesTabsScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesDataDashboardScreen(),
                  ),
                );
              }
            },
            extraActions: [
              _buildSearchAndFilter(),
            ], // هنا بقى البحث والفلتر جوه الـ AppBar
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(GetLeadsState state) {
    return Column(
      children: [
        _buildActionButtons(), // الأزرار (Edit, Add Meeting, Create Lead)
        Expanded(child: _buildLeadsList(state)),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return SizedBox(
      width: (_responsive.screenWidth * 0.7).clamp(220.0, 360.0),
      // margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nameController,
              onChanged: (value) {
                final cubit = context.read<GetLeadsCubit>();
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  cubit.fetchSalesLeadsWithPagination(
                    search: value.trim(),
                    data: widget.data,
                    transferefromdata: widget.transferfromdata,
                    stageId: widget.stageId,
                  );
                });
              },
              style: TextStyle(
                // 🔹 إضافة هذه الخاصية
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                fontSize: _responsive.fontSizeMedium.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: const Color(0xff969696),
                  fontSize: _responsive.fontSizeMedium.sp,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: _responsive.iconSizeMedium.sp,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Constants.maincolor
                          : Constants.mainDarkmodecolor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: _responsive.buttonHeight * 0.3,
                  horizontal: _responsive.horizontalPadding.w * 0.5,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).brightness ==
                            Brightness
                                .light // 🔹 تغيير لون الخلفية
                        ? Colors.white
                        : const Color(0xFF2C2C2C), // لون غامق للوضع الليلي
                isDense: true,
              ),
            ),
          ),
          SizedBox(width: _responsive.horizontalPadding.w * 0.6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Constants.maincolor
                        : Constants.mainDarkmodecolor,
              ),
              onPressed: () {
                showFilterDialog(
                  context,
                  widget.data ?? false,
                  widget.transferfromdata ?? false,
                );
              },
            ),
          ),
          SizedBox(width: _responsive.horizontalPadding.w * 0.1),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // إذا كانت الشيكات غير ظاهرة، لا نضيف أي شيء (لا Padding ولا Row)
    if (!_showCheckboxes) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _responsive.horizontalPadding.w,
        vertical: _responsive.verticalPadding.h * 0.5,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _responsive.horizontalPadding.w * 0.5,
              vertical: _responsive.verticalPadding.h * 0.2,
            ),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Constants.maincolor
                      : Constants.mainDarkmodecolor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 Edit Icon
                GestureDetector(
                  onTap: () async {
                    log("_selectedLead ID: ${_selectedLead?.id}");
                    if (_selectedLead != null) {
                      final result = await showDialog(
                        context: context,
                        builder:
                            (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create:
                                      (_) =>
                                          EditLeadCubit(EditLeadApiService()),
                                ),
                                BlocProvider(
                                  create:
                                      (_) =>
                                          ProjectsCubit(ProjectsApiService())
                                            ..fetchProjects(),
                                ),
                                BlocProvider(
                                  create:
                                      (_) =>
                                          SalesCubit(GetAllSalesApiService())
                                            ..fetchAllSales(),
                                ),
                              ],
                              child: EditLeadSalesDialog(
                                userId: _selectedLead!.id ?? '',
                                initialName: _selectedLead!.name ?? '',
                                initialPhone2:
                                    _selectedLead!.phonenumber2 ?? '',
                                initialWhatsappNumber:
                                    _selectedLead!.whatsappnumber ?? '',
                                initialNotes: '',
                                initialProjectId: _selectedLead!.project?.id,
                                salesID: _selectedLead!.sales?.id ?? '',
                                onSuccess: () {
                                  context
                                      .read<GetLeadsCubit>()
                                      .fetchSalesLeadsWithPagination(
                                        data: widget.data,
                                        transferefromdata:
                                            widget.transferfromdata,
                                        stageId: widget.stageId,
                                      );
                                },
                              ),
                            ),
                      );

                      if (result == true) {
                        context
                            .read<GetLeadsCubit>()
                            .fetchSalesLeadsWithPagination(
                              data: widget.data,
                              transferefromdata: widget.transferfromdata,
                              stageId: widget.stageId,
                            );
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(_responsive.cardPadding.w * 0.4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: _responsive.iconSizeMedium.sp,
                    ),
                  ),
                ),

                SizedBox(width: _responsive.horizontalPadding.w * 3.5),

                /// 🔹 Add Meeting Icon
                GestureDetector(
                  onTap: () {
                    if (_selectedLead != null) {
                      _showAddMeetingSheet(context, _selectedLead!.id!);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(_responsive.cardPadding.w * 0.4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.event,
                      color: Colors.white,
                      size: _responsive.iconSizeMedium.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMeetingSheet(BuildContext context, String leadId) {
    final commentController = TextEditingController();
    final salesDeveloperController =
        TextEditingController(); // 🔹 حقل Sales Developer Name
    DateTime? selectedDate;
    StageDatas? selectedStage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (context) {
            final cubit = StagesCubit(StagesApiService());
            cubit.fetchStages();
            return cubit;
          },
          child: MultiBlocListener(
            listeners: [
              BlocListener<GetLeadsCubit, GetLeadsState>(
                listener: (context, state) {
                  if (state is PostMeetingCommentSuccess) {
                    final parentContext =
                        context; // أفضل طريقة: تمرر الـ context الأساسي للـ Scaffold عند فتح الـ BottomSheet
                    Navigator.pop(context); // تقفل الـ BottomSheet أولاً
                    // بعد الإغلاق، نستخدم parent context للـ Snackbar
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text("Meeting comment added successfully"),
                        ),
                      );
                      final cubit = context.read<GetLeadsCubit>();
                      cubit.fetchSalesLeadsWithPagination(
                        data: widget.data,
                        transferefromdata: widget.transferfromdata,
                        stageId: widget.stageId,
                        resetPagination: true,
                      );
                    });
                  }
                },
              ),
            ],
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// 🔹 Stage Dropdown
                        BlocBuilder<StagesCubit, StagesState>(
                          builder: (context, state) {
                            if (state is StagesLoading) {
                              return const CircularProgressIndicator();
                            }

                            if (state is StagesLoaded) {
                              // فلتر على الثلاث مراحل المطلوبة فقط
                              final stages =
                                  state.stages
                                      .where(
                                        (s) =>
                                            s.name?.toLowerCase() == "eoi" ||
                                            s.name?.toLowerCase() ==
                                                "done deal" ||
                                            s.name?.toLowerCase() == "meeting",
                                      )
                                      .toList();

                              return DropdownButtonFormField<StageDatas>(
                                decoration: const InputDecoration(
                                  labelText: "Stage",
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedStage,
                                items:
                                    stages
                                        .map(
                                          (stage) => DropdownMenuItem(
                                            value: stage,
                                            child: Text(stage.name ?? ""),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() => selectedStage = value);
                                },
                              );
                            }

                            if (state is StagesError) {
                              return Text("Error: ${state.message}");
                            }

                            return const SizedBox();
                          },
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 Stage Date + Time
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                            );

                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (time != null) {
                                setState(() {
                                  selectedDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              selectedDate == null
                                  ? "Select Stage Date"
                                  : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year} "
                                      "${TimeOfDay.fromDateTime(selectedDate!).format(context)}",
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 Comment
                        TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 Sales Developer Name
                        TextField(
                          controller: salesDeveloperController,
                          decoration: const InputDecoration(
                            labelText: "Sales Developer Name",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 Buttons
                        BlocBuilder<GetLeadsCubit, GetLeadsState>(
                          builder: (context, state) {
                            final isLoading =
                                state is PostMeetingCommentLoading;

                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Constants.maincolor,
                                    ),
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () {
                                              // ✅ تحقق من الحقول المطلوبة
                                              if (selectedStage == null) {
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
                                              if (selectedDate == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please select stage date",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (commentController
                                                  .text
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please enter a comment",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (salesDeveloperController
                                                  .text
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please enter Sales Developer Name",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              // تحويل التاريخ لتوقيت دبي
                                              final dubaiDate = selectedDate!
                                                  .toUtc()
                                                  .add(
                                                    const Duration(hours: 4),
                                                  );
                                              context
                                                  .read<GetLeadsCubit>()
                                                  .postMeetingCommentWithStage(
                                                    leadId: leadId,
                                                    stageId: selectedStage!.id!,
                                                    comment:
                                                        commentController.text,
                                                    stageDate: dubaiDate,
                                                    salesdeveloperName:
                                                        salesDeveloperController
                                                            .text,
                                                    refreshAfterSuccess: true,
                                                  );
                                            },
                                    child:
                                        isLoading
                                            ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Text(
                                              "Add Comment",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Constants.maincolor,
                                    ),
                                    onPressed: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final userId = prefs.getString('salesId');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => BlocProvider(
                                                create:
                                                    (
                                                      context,
                                                    ) => MeetingCommentsCubit(
                                                      MeetingCommentsApiService(),
                                                    ),
                                                child: MeetingCommentsScreen(
                                                  userId: userId,
                                                ),
                                              ),
                                        ),
                                      );
                                      // هنا هتحدد وجهة All Comments بعدين
                                    },
                                    child: const Text(
                                      "All Comments",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeadsList(GetLeadsState state) {
    if (state is GetSalesLeadsWithPaginationLoading) {
      return _buildShimmerLoading();
    } else if (state is GetSalesLeadsWithPaginationSuccess) {
      final leads = state.model.data;
      if (leads!.isEmpty) {
        return Center(
          child: Text(
            'No leads found.',
            style: TextStyle(fontSize: _responsive.fontSizeLarge.sp),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          final cubit = context.read<GetLeadsCubit>();
          await cubit.fetchSalesLeadsWithPagination(
            data: widget.data,
            transferefromdata: widget.transferfromdata,
            stageId: widget.stageId,
          );
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: leads.length + 1,
          padding: EdgeInsets.all(_responsive.horizontalPadding.w),
          itemBuilder: (context, index) {
            if (index >= leads.length) {
              return const SizedBox();
            }
            final lead = leads[index];
            return _buildLeadCard(lead);
          },
        ),
      );
    } else if (state is GetSalesLeadsWithPaginationError) {
      return Center(
        child: Text(
          ' ${state.message}',
          style: TextStyle(fontSize: _responsive.fontSizeLarge.sp),
        ),
      );
    } else {
      return Center(
        child: Text(
          'No leads found.',
          style: TextStyle(fontSize: _responsive.fontSizeLarge.sp),
        ),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: EdgeInsets.all(_responsive.horizontalPadding.w),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: _responsive.verticalPadding.h),
            height: _responsive.isTablet ? 180.h : 120.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeadCard(LeadPagination lead) {
    bool isOutdated = false;
    final salesfcmtoken = lead.sales?.teamleader?.fcmToken;
    final leadassign = lead.assign;
    final leadstageupdated = lead.stagedateupdated;
    final leadStagetype = lead.stage?.name ?? "";

    DateTime? stageUpdatedDate;
    if (leadstageupdated != null && leadstageupdated.isNotEmpty) {
      stageUpdatedDate = DateTime.tryParse(leadstageupdated);
      if (stageUpdatedDate != null) {
        final now = DateTime.now().toUtc();
        final difference = now.difference(stageUpdatedDate).inMinutes;
        isOutdated = difference > 1;
      }
    }

    return InkWell(
      onLongPress: () {
        setState(() {
          _showCheckboxes = true;
          _selectedLead = lead;
          _selectedLeadId = lead.id;
        });
      },
      onTap: () async {
        if (leadassign == false) {
          final updatedStageName = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider(
                    create:
                        (_) =>
                            LeadCommentsCubit(GetAllLeadCommentsApiService()),
                    child: SalesLeadsDetailsScreen(
                      leedId: lead.id!,
                      leadName: lead.name ?? '',
                      leadPhone: lead.phone ?? '',
                      leadEmail: lead.email ?? '',
                      leadStage: lead.stage?.name ?? '',
                      leadStageId: lead.stage?.id ?? '',
                      leadChannel: lead.chanel?.name ?? '',
                      leadCreationDate:
                          lead.createdAt != null
                              ? formatDateTimeToDubai(lead.createdAt!)
                              : '',
                      leadProject: lead.project?.name ?? '',
                      leadLastComment: lead.lastcommentdate ?? '',
                      leadcampaign: lead.campaign?.campainName ?? "campaign",
                      leadNotes: "",
                      leaddeveloper:
                          lead.project?.developer?.name ?? "no developer",
                      fcmtoken: salesfcmtoken,
                      managerfcmtoken: lead.sales?.manager?.fcmToken,
                      teamleaderfcmtoken: lead.sales?.teamleader?.fcmToken,
                      leadwhatsappnumber:
                          lead.whatsappnumber ?? 'no whatsapp number',
                      jobdescription:
                          lead.jobdescription ?? 'no job description',
                      secondphonenumber:
                          lead.phonenumber2 ?? 'no second phone number',
                      laststageupdated: lead.stagedateupdated,
                      stageId: lead.stage?.id,
                      leadLastDateAssigned: lead.lastdateassign,
                      isleadAssigned: lead.assign,
                      resetcreationdate: lead.resetcreationdate,
                    ),
                  ),
            ),
          );
          final cubit = context.read<GetLeadsCubit>();
          await cubit.fetchSalesLeadsWithPagination(
            data: widget.data,
            transferefromdata: widget.transferfromdata,
            stageId: widget.stageId,
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Attention",
                  style: TextStyle(fontSize: _responsive.fontSizeLarge.sp),
                ),
                content: Text(
                  "You must receive this lead first.",
                  style: TextStyle(fontSize: _responsive.fontSizeMedium.sp),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _responsive.fontSizeMedium.sp,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Card(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.grey[900],
        margin: EdgeInsets.symmetric(
          horizontal: _responsive.cardMarginHorizontal.w,
          vertical: _responsive.cardMarginVertical.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(_responsive.cardPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stage and Date Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStageContainer(lead, isOutdated),
                        SizedBox(height: _responsive.verticalPadding.h * 1.2),
                        Text(
                          "SD: ${lead.stagedateupdated != null ? formatDateTimeToDubai(lead.stagedateupdated!) : "N/A"}",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeSmall.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black87
                                    : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showCheckboxes)
                    Checkbox(
                      value: _selectedLeadId == lead.id,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedLeadId = lead.id;
                          } else {
                            _selectedLeadId = null;
                            _showCheckboxes = false;
                          }
                        });
                      },
                    ),
                  if (leadassign == true) _buildDownloadButton(lead),
                ],
              ),

              if (leadassign == true)
                Padding(
                  padding: EdgeInsets.only(
                    top: _responsive.verticalPadding.h * 0.3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [DotLoading()],
                  ),
                ),

              SizedBox(height: _responsive.verticalPadding.h),
              const Divider(thickness: 1.5),
              SizedBox(height: _responsive.verticalPadding.h),

              // Name and Project
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lead.name ?? "No Name",
                      style: TextStyle(
                        fontSize: _responsive.fontSizeXLarge.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      lead.project?.name ?? "N/A",
                      style: TextStyle(
                        fontSize: _responsive.fontSizeMedium.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              SizedBox(height: _responsive.verticalPadding.h * 0.5),

              // Phone
              InkWell(
                onTap: () {
                  final phone = lead.phone ?? '';
                  final formattedPhone =
                      phone.startsWith('0') ? phone : '+$phone';
                  makePhoneCall(formattedPhone);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.grey
                              : Constants.mainDarkmodecolor,
                      size: _responsive.iconSizeMedium.sp,
                    ),
                    SizedBox(width: _responsive.horizontalPadding.w * 0.3),
                    Expanded(
                      child: Text(
                        lead.phone ?? 'N/A',
                        style: TextStyle(
                          fontSize: _responsive.fontSizeMedium.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: _responsive.verticalPadding.h * 2.5),

              // Sales Person and Actions
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_pin_outlined,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.grey
                                : Constants.mainDarkmodecolor,
                        size: _responsive.iconSizeMedium.sp,
                      ),
                      SizedBox(width: _responsive.horizontalPadding.w * 0.3),
                      Expanded(
                        child: Text(
                          lead.sales?.name ?? "none",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeLarge.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.phone,
                            onTap: () {
                              final phone = lead.phone ?? '';
                              final formattedPhone =
                                  phone.startsWith('0') ? phone : '+$phone';
                              makePhoneCall(formattedPhone);
                            },
                          ),
                          _buildActionButton(
                            icon: FontAwesomeIcons.whatsapp,
                            isFaIcon: true,
                            onTap: () async {
                              final rawPhone =
                                  (lead.phone?.isNotEmpty == true
                                          ? lead.phone
                                          : lead.whatsappnumber)
                                      ?.replaceAll(RegExp(r'\D'), '') ??
                                  '';
                              final formattedPhone =
                                  rawPhone.startsWith('0')
                                      ? rawPhone
                                      : '+$rawPhone';
                              final url = "https://wa.me/$formattedPhone";
                              try {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Could not open WhatsApp."),
                                  ),
                                );
                              }
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.chat_bubble_outline,
                            onTap: () => _showCommentsDialog(lead),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: _responsive.verticalPadding.h * 0.25),

                  // Creation Date
                  if (lead.resetcreationdate == false)
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey
                                  : Constants.mainDarkmodecolor,
                          size: _responsive.iconSizeMedium.sp,
                        ),
                        SizedBox(width: _responsive.horizontalPadding.w * 0.3),
                        Text(
                          " ${lead.date != null ? formatDateTimeToDubai(lead.date!) : "N/A"}",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeSmall.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageContainer(LeadPagination lead, bool isOutdated) {
    final leadStagetype = lead.stage?.name ?? "";
    final bool isFinalStage =
        leadStagetype == "Done Deal" ||
        leadStagetype == "Transfer" ||
        leadStagetype == "Fresh" ||
        leadStagetype == "Not Interested";

    final Color stageColor =
        isFinalStage
            ? Constants.maincolor
            : isOutdated
            ? Colors.red
            : Colors.green;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _responsive.stageContainerHPadding.w,
        vertical: _responsive.stageContainerVPadding.h,
      ),
      decoration: BoxDecoration(
        color: stageColor.withOpacity(0.1),
        border: Border.all(color: stageColor),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: stageColor,
            size: _responsive.iconSizeSmall.sp,
          ),
          SizedBox(width: _responsive.horizontalPadding.w * 0.2),
          Flexible(
            child: Text(
              lead.stage?.name ?? "Unknown",
              style: TextStyle(
                fontSize: _responsive.fontSizeSmall.sp,
                fontWeight: FontWeight.bold,
                color: stageColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(LeadPagination lead) {
    return InkWell(
      borderRadius: BorderRadius.circular(40.r),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => EditLeadCubit(EditLeadApiService()),
                ),
              ],
              child: Builder(
                builder: (innerContext) {
                  bool isLoading = false;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text(
                          "Confirmation",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeLarge.sp,
                          ),
                        ),
                        content: Text(
                          "Are you sure to receive this lead?",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Constants.maincolor,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsive.fontSizeMedium.sp,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Constants.maincolor,
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      setState(() => isLoading = true);
                                      try {
                                        await innerContext
                                            .read<EditLeadCubit>()
                                            .editLeadAssignvalue(
                                              userId: lead.id!,
                                              assign: false,
                                            );
                                        if (!context.mounted) return;
                                        Navigator.pop(innerContext);
                                        final cubit =
                                            innerContext.read<GetLeadsCubit>();
                                        await cubit
                                            .fetchSalesLeadsWithPagination(
                                              data: widget.data,
                                              transferefromdata:
                                                  widget.transferfromdata,
                                              stageId: widget.stageId,
                                            );
                                      } finally {
                                        if (context.mounted) {
                                          setState(() => isLoading = false);
                                        }
                                      }
                                    },
                            child:
                                isLoading
                                    ? SizedBox(
                                      height: _responsive.iconSizeSmall.h,
                                      width: _responsive.iconSizeSmall.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      "OK",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _responsive.fontSizeMedium.sp,
                                      ),
                                    ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
      child: CircleAvatar(
        radius: _responsive.avatarRadius.r,
        backgroundColor: Constants.maincolor.withOpacity(0.15),
        child: Icon(
          Icons.download,
          color: Constants.maincolor,
          size: _responsive.iconSizeLarge.sp,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required dynamic icon,
    required VoidCallback onTap,
    bool isFaIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.all(_responsive.cardPadding.w * 0.3),
        margin: EdgeInsets.symmetric(
          horizontal: _responsive.horizontalPadding.w * 0.15,
        ),
        decoration: BoxDecoration(
          color: Constants.maincolor,
          shape: BoxShape.circle,
        ),
        child:
            isFaIcon
                ? FaIcon(
                  icon,
                  color: Colors.white,
                  size: _responsive.iconSizeSmall.sp,
                )
                : Icon(
                  icon,
                  color: Colors.white,
                  size: _responsive.iconSizeSmall.sp,
                ),
      ),
    );
  }

  void _showCommentsDialog(LeadPagination lead) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: _responsive.dialogHorizontalPadding.w,
            vertical: _responsive.dialogVerticalPadding.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: BlocProvider(
            create:
                (_) =>
                    LeadCommentsCubit(GetAllLeadCommentsApiService())
                      ..fetchNewComments(leadId: lead.id!, page: 1, limit: 10),
            child: Padding(
              padding: EdgeInsets.all(_responsive.cardPadding.w),
              child: BlocBuilder<LeadCommentsCubit, LeadCommentsState>(
                builder: (context, commentState) {
                  if (commentState is LeadCommentsLoading) {
                    return SizedBox(
                      height: _responsive.isTablet ? 300.h : 200.h,
                      child: Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: ListView.builder(
                            padding: EdgeInsets.all(_responsive.cardPadding.w),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: _responsive.verticalPadding.h,
                                ),
                                height: _responsive.isTablet ? 120.h : 80.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  } else if (commentState is LeadCommentsError) {
                    return SizedBox(
                      height: _responsive.isTablet ? 200.h : 150.h,
                      child: Center(
                        child: Text(
                          "No comments available",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                      ),
                    );
                  } else if (commentState is NewCommentsLoaded) {
                    final newCommentsData = commentState.newComments;
                    if (newCommentsData.comments == null ||
                        newCommentsData.comments!.isEmpty) {
                      return Text(
                        'No comments available.',
                        style: TextStyle(
                          fontSize: _responsive.fontSizeMedium.sp,
                        ),
                      );
                    }
                    final firstComment = newCommentsData.comments!.first;
                    final String firstCommentText =
                        firstComment.firstcomment?.text ??
                        "No comment available.";
                    final String secondCommentText =
                        firstComment.secondcomment?.text ??
                        'No action available.';

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Comment",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: _responsive.fontSizeLarge.sp,
                          ),
                        ),
                        SizedBox(height: _responsive.verticalPadding.h * 0.3),
                        Text(
                          firstCommentText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                        SizedBox(height: _responsive.verticalPadding.h),
                        Text(
                          "Action (Plan)",
                          style: TextStyle(
                            color: Constants.maincolor,
                            fontWeight: FontWeight.w600,
                            fontSize: _responsive.fontSizeLarge.sp,
                          ),
                        ),
                        SizedBox(height: _responsive.verticalPadding.h * 0.3),
                        Text(
                          secondCommentText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox(
                      height: _responsive.isTablet ? 200.h : 150.h,
                      child: Center(
                        child: Text(
                          "No comments",
                          style: TextStyle(
                            fontSize: _responsive.fontSizeMedium.sp,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class DotLoading extends StatefulWidget {
  const DotLoading({super.key});

  @override
  _DotLoadingState createState() => _DotLoadingState();
}

class _DotLoadingState extends State<DotLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.5;
      return Tween<double>(begin: 0, end: 10).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end > 1.0 ? 1.0 : end,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSalesValues.fromContext(context);

    return SizedBox(
      height: responsive.iconSizeSmall.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding.w * 0.1,
            ),
            child: _buildDot(_animations[index]),
          );
        }),
      ),
    );
  }

  Widget _buildDot(Animation<double> animation) {
    final responsive = ResponsiveSalesValues.fromContext(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -animation.value),
          child: Container(
            width: responsive.iconSizeSmall * 0.3,
            height: responsive.iconSizeSmall * 0.3,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.grey
                      : Constants.mainDarkmodecolor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
