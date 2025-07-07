// leads_marketier_screen.dart
// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use, unused_local_variable
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/data/data_sources/campaign_api_service.dart';
import 'package:homewalkers_app/data/data_sources/communication_way_api_service.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:homewalkers_app/data/models/add_comment_model.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_lead_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketier_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/get_leads_marketer_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/edit_lead_dialog.dart';
// 🟡 استيراد الـ Dialog الجديد اللي هيرجع القيم
import 'package:homewalkers_app/presentation/widgets/marketer/filter_leads_dialog.dart'; // تأكد أن المسار صحيح
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LeadsMarketierScreen extends StatefulWidget {
  final String? stageName;
  const LeadsMarketierScreen({super.key, this.stageName});

  @override
  State<LeadsMarketierScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<LeadsMarketierScreen> {
  bool? isClearHistoryy;
  DateTime? clearHistoryTimee;
  int selectedTab = 0; // 0: Manage Leads, 1: Leads Trash
  // 🟡 جديد: متغير لحفظ نص البحث
  String _searchQuery = '';
  // 🟡 جديد: TextEditingController كـ field في الـ State
  late TextEditingController _nameSearchController;
  // 🟡 جديد: متغيرات لحفظ حالة الفلاتر من الـ dialog
  String? _selectedCountryFilter;
  String? _selectedDeveloperFilter;
  String? _selectedProjectFilter;
  String? _selectedStageFilter;
  String? _selectedChannelFilter;
  String? _selectedSalesFilter;
  String? _selectedCommunicationWayFilter;
  String? _selectedCampaignFilter;
  @override
  void initState() {
    super.initState();
    _nameSearchController = TextEditingController();
    checkClearHistoryTime();
    checkIsClearHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stage = widget.stageName;
      _selectedStageFilter = stage;

      context.read<GetLeadsMarketerCubit>().getLeadsByMarketer(
        stageFilter: stage, // ⬅️ نمرر الفلتر مباشرة
      );
    });
  }

  @override
  void dispose() {
    _nameSearchController.dispose(); // 🟡 مهم: التخلص من الـ controller
    super.dispose();
  }

  // 🟡 دالة مساعدة لتطبيق الفلاتر الشاملة (البحث + الفلاتر من الـ dialog)
  // 🟡 دالة مساعدة لتطبيق الفلاتر الشاملة (البحث + الفلاتر من الـ dialog)
  void _applyCurrentFilters() {
    context.read<GetLeadsMarketerCubit>().filterLeadsMarketer(
      query: _searchQuery, // نص البحث من TextField
      country: _selectedCountryFilter,
      developer: _selectedDeveloperFilter,
      project: _selectedProjectFilter,
      stage: _selectedStageFilter,
      channel: _selectedChannelFilter,
      sales: _selectedSalesFilter,
      communicationWay: _selectedCommunicationWayFilter,
      campaign: _selectedCampaignFilter,
    );
  }

  Future<void> checkClearHistoryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final time = prefs.getString('clear_history_time');
    if (time != null) {
      setState(() {
        clearHistoryTimee = DateTime.tryParse(time);
      });
      debugPrint('آخر مرة تم فيها الضغط على Clear History: $time');
    }
  }

  Future<void> checkIsClearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final iscleared = prefs.getBool('clearHistory');
    if (mounted) {
      setState(() {
        isClearHistoryy = iscleared;
      });
    }
    debugPrint('Clear History: $iscleared');
  }

  String formatDateTime(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day/$month/$year - $hour:$minute';
    } catch (e) {
      return dateStr; // fallback في حال كان التاريخ مش صحيح
    }
  }

  Widget getStatusIcon(String status) {
    switch (status) {
      case 'Follow Up':
      case 'Follow':
        return Icon(
          Icons.mark_email_unread_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      case 'Meeting':
        return Icon(
          Icons.chat_bubble_outline,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      case 'Done Deal':
        return Icon(
          Icons.check_box_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      case 'Interested':
        return Icon(
          FontAwesomeIcons.check,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      case 'Not Interested':
        return Icon(
          FontAwesomeIcons.timesCircle,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      case 'Fresh':
        return Icon(
          Icons.new_releases,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      case 'Transfer':
        return Icon(
          Icons.no_transfer,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      default:
        return const Icon(Icons.info_outline);
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
    bool isOutdated = false; // قد تحتاج لإعادة تقييمها لكل عنصر
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Constants.backgroundlightmode
              : Constants.backgroundDarkmode,
      appBar: CustomAppBar(
        title: 'Leads',
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MarketierTabsScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Search & filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _nameSearchController, // 🟡 استخدام الـ controller من الـ State
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim(); // 🟡 حفظ قيمة البحث
                        });
                        _applyCurrentFilters(); // 🟡 تطبيق الفلاتر
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: GoogleFonts.montserrat(
                          color: const Color(0xff969696),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Constants.maincolor
                                    : Constants.mainDarkmodecolor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 50.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1F2),
                      border: Border.all(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Constants.maincolor
                                : Constants.mainDarkmodecolor,
                      ),
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
                      onPressed: () async {
                        // 🟡 مهم: استقبل القيم الراجعة من الـ dialog
                        final Map<String, dynamic>?
                        filters = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (dialogContext) {
                            // استخدام dialogContext هنا
                            return MultiBlocProvider(
                              // هذا الجزء كان موجود في showFilterDialogMarketer
                              providers: [
                                BlocProvider(
                                  create:
                                      (_) =>
                                          DevelopersCubit(DeveloperApiService())
                                            ..getDevelopers(),
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
                                          StagesCubit(StagesApiService())
                                            ..fetchStages(),
                                ),
                                BlocProvider(
                                  create:
                                      (_) =>
                                          ChannelCubit(GetChannelsApiService())
                                            ..fetchChannels(),
                                ),
                                BlocProvider(
                                  create:
                                      (_) => GetCommunicationWaysCubit(
                                        CommunicationWayApiService(),
                                      )..fetchCommunicationWays(),
                                ),
                                BlocProvider(
                                  create:
                                      (_) => GetCampaignsCubit(
                                        CampaignApiService(),
                                      )..fetchCampaigns(),
                                ),
                                BlocProvider(
                                  create:
                                      (_) =>
                                          SalesCubit(GetAllSalesApiService())
                                            ..fetchAllSales(),
                                ),
                              ],
                              child: FilterDialog(
                                // 🟡 تمرير القيم الحالية للـ dialog عشان يعرضها
                                initialCountry: _selectedCountryFilter,
                                initialDeveloper: _selectedDeveloperFilter,
                                initialProject: _selectedProjectFilter,
                                initialStage: _selectedStageFilter,
                                initialChannel: _selectedChannelFilter,
                                initialSales: _selectedSalesFilter,
                                initialCommunicationWay:
                                    _selectedCommunicationWayFilter,
                                initialCampaign: _selectedCampaignFilter,
                                initialSearchName:
                                    _nameSearchController
                                        .text, // 🟡 تمرير نص البحث الحالي
                              ),
                            );
                          },
                        );
                        if (filters != null) {
                          // 🟡 تحديث متغيرات الـ State بالفلتر الجديدة
                          setState(() {
                            // 🟡 استخدم الـ `query` اللي رجع من الـ dialog لو مبعوت، أو احتفظ باللي موجود
                            _searchQuery = filters['name'] ?? _searchQuery;
                            _nameSearchController.text =
                                _searchQuery; // تحديث الـ TextField
                            _selectedCountryFilter = filters['country'];
                            _selectedDeveloperFilter = filters['developer'];
                            _selectedProjectFilter = filters['project'];
                            _selectedStageFilter = filters['stage'];
                            _selectedChannelFilter = filters['channel'];
                            _selectedSalesFilter = filters['sales'];
                            _selectedCommunicationWayFilter =
                                filters['communicationWay'];
                            _selectedCampaignFilter = filters['campaign'];
                          });
                          _applyCurrentFilters(); // 🟡 تطبيق الفلاتر الجديدة
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Create Lead Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tabs
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                          _searchQuery = ''; // مسح البحث عند تغيير الـ tab
                          _nameSearchController.clear();
                          // 🟡 مسح باقي الفلاتر عند تغيير الـ tab
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedStageFilter = null;
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                        });
                        // 🟡 استدعي جلب البيانات الأصلية بعد تغيير الـ tab
                        context
                            .read<GetLeadsMarketerCubit>()
                            .getLeadsByMarketer();
                      },
                      child: Column(
                        children: [
                          Text(
                            'Manage Leads',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedTab == 0
                                      ? Constants.maincolor
                                      : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selectedTab == 0)
                            Container(
                              height: 2,
                              width: 50,
                              color: Constants.maincolor,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                          _searchQuery = ''; // مسح البحث عند تغيير الـ tab
                          _nameSearchController.clear();
                          // 🟡 مسح باقي الفلاتر عند تغيير الـ tab
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedStageFilter = null;
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                        });
                        // 🟡 استدعي جلب بيانات سلة المهملات
                        context
                            .read<GetLeadsMarketerCubit>()
                            .getLeadsByMarketerInTrash();
                      },
                      child: Column(
                        children: [
                          Text(
                            'Leads Trash',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedTab == 1
                                      ? Constants.maincolor
                                      : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selectedTab == 1)
                            Container(
                              height: 2,
                              width: 50,
                              color: Constants.maincolor,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Constants.maincolor
                            : Constants.mainDarkmodecolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateLeadScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: Text(
                    'Create Lead',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            // Leads List Based on State
            Expanded(
              child: BlocBuilder<GetLeadsMarketerCubit, GetLeadsMarketerState>(
                builder: (context, state) {
                  if (state is GetLeadsMarketerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetLeadsMarketerSuccess) {
                    final leads = state.leadsResponse.data;
                    if (leads == null || leads.isEmpty) {
                      // 🟡 التأكد من أن leads ليست null
                      return const Center(child: Text('No leads found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _searchQuery = ''; // مسح البحث عند التحديث
                          _nameSearchController.clear();
                          // 🟡 مسح باقي الفلاتر عند التحديث
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedStageFilter = null;
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                        });
                        if (selectedTab == 0) {
                          context
                              .read<GetLeadsMarketerCubit>()
                              .getLeadsByMarketer();
                        } else {
                          context
                              .read<GetLeadsMarketerCubit>()
                              .getLeadsByMarketerInTrash();
                        }
                      },
                      child: ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          final salesfcmtoken = lead.sales?.userlog?.fcmtokenn;
                          final prefs = SharedPreferences.getInstance();
                          final fcmToken = prefs.then(
                            (prefs) => prefs.setString(
                              'fcm_token_sales',
                              salesfcmtoken ?? '',
                            ),
                          );
                          log("fcmToken of sales: $salesfcmtoken");
                          final leadstageupdated = lead.stagedateupdated;
                          final leadStagetype = lead.stage?.name ?? "";
                          // تحويل التاريخ من String إلى DateTime
                          DateTime? stageUpdatedDate;
                          if (leadstageupdated != null) {
                            try {
                              stageUpdatedDate = DateTime.parse(
                                leadstageupdated,
                              );
                              log("stageUpdatedDate: $stageUpdatedDate");
                            } catch (_) {
                              stageUpdatedDate = null;
                            }
                          }
                          if (stageUpdatedDate != null) {
                            final now = DateTime.now().toUtc();
                            log("now: $now");
                            final difference =
                                now.difference(stageUpdatedDate).inMinutes;
                            log("difference: $difference");
                            isOutdated =
                                difference >
                                1; // اعتبره قديم إذا مرّ أكثر من دقيقة
                            log("isOutdated: $isOutdated");
                          }
                          // Add other necessary imports from your project here
                          // (for cubits, constants, different screens, etc.)

                          // Assuming the context and all variables like 'lead', 'isOutdated', 'selectedTab', etc.
                          // from your new code are available.
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ---------- Row 1: Name and Status Icon ----------
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lead.name ?? "No Name",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      (stageUpdatedDate != null &&
                                              (leadStagetype == "Done Deal" ||
                                                  leadStagetype == "Transfer" ||
                                                  leadStagetype == "Fresh" ||
                                                  leadStagetype ==
                                                      "Not Interested"))
                                          ? const SizedBox()
                                          : Icon(
                                            isOutdated
                                                ? Icons.cancel
                                                : Icons.check_circle,
                                            color:
                                                isOutdated
                                                    ? Colors.red
                                                    : Colors.green,
                                            size: 24,
                                          ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // ---------- Row 2: Sales Person ----------
                                  Row(
                                    children: [
                                      // Using the new design's icon
                                      Icon(
                                        Icons.person_pin_outlined,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Constants.maincolor
                                                : Constants.mainDarkmodecolor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          // Logic from your new code
                                          lead.sales?.name ?? "No Sales",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // ---------- Row 3: Stage and Total Submissions ----------
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          getStatusIcon(lead.stage?.name ?? ""),
                                          const SizedBox(width: 6),
                                          Text(
                                            lead.stage?.name ?? "none",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Σ",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            // Logic from your new code
                                            "Total Submission: ${lead.totalSubmissions}",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // ---------- Row 4: WhatsApp and Phone Call ----------
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final phone = lead.phone?.replaceAll(
                                            RegExp(r'\D'),
                                            '',
                                          );
                                          final url = "https://wa.me/$phone";
                                          if (await canLaunchUrl(
                                            Uri.parse(url),
                                          )) {
                                            await launchUrl(
                                              Uri.parse(url),
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Could not open WhatsApp.",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.whatsapp,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              lead.phone ?? '',
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap:
                                            () =>
                                                makePhoneCall(lead.phone ?? ''),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              lead.phone ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),

                                  // ---------- Row 5: Last Comment Button and Action Icons ----------
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        onPressed: () {
                                          // This is the "Last Comment" dialog logic from your new code
                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: BlocProvider(
                                                    create:
                                                        (
                                                          _,
                                                        ) => LeadCommentsCubit(
                                                          GetAllLeadCommentsApiService(),
                                                        )..fetchLeadComments(
                                                          lead.id!,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16.0,
                                                          ),
                                                      child: BlocBuilder<
                                                        LeadCommentsCubit,
                                                        LeadCommentsState
                                                      >(
                                                        builder: (
                                                          context,
                                                          commentState,
                                                        ) {
                                                          if (commentState
                                                              is LeadCommentsLoading) {
                                                            return const SizedBox(
                                                              height: 100,
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            );
                                                          } else if (commentState
                                                              is LeadCommentsError) {
                                                            return SizedBox(
                                                              height: 100,
                                                              child: Center(
                                                                child: Text(
                                                                  "No comments available: ${commentState.message}",
                                                                ),
                                                              ),
                                                            );
                                                          } else if (commentState
                                                              is LeadCommentsLoaded) {
                                                            final commentsData =
                                                                commentState
                                                                    .leadComments
                                                                    .data;
                                                            if (commentsData ==
                                                                    null ||
                                                                commentsData
                                                                    .isEmpty) {
                                                              return const Text(
                                                                'No comments available.',
                                                              );
                                                            }
                                                            final commentsList =
                                                                commentsData
                                                                    .first
                                                                    .comments ??
                                                                [];
                                                            Comment?
                                                            firstCommentEntry;
                                                            if (commentsList
                                                                .isNotEmpty) {
                                                              try {
                                                                firstCommentEntry =
                                                                    commentsList.firstWhere(
                                                                          (
                                                                            element,
                                                                          ) =>
                                                                              element.firstcomment !=
                                                                              null,
                                                                          orElse:
                                                                              () => commentsList.firstWhere(
                                                                                (
                                                                                  element,
                                                                                ) =>
                                                                                    element.secondcomment !=
                                                                                    null,
                                                                              ),
                                                                        )
                                                                        as Comment?;
                                                              } catch (_) {
                                                                firstCommentEntry =
                                                                    null;
                                                              }
                                                            }
                                                            final String
                                                            firstCommentText =
                                                                firstCommentEntry
                                                                    ?.firstcomment!
                                                                    .text ??
                                                                'No comments available.';
                                                            final String
                                                            secondCommentText =
                                                                firstCommentEntry
                                                                    ?.secondcomment!
                                                                    .text ??
                                                                'No comment available.';
                                                            final firstCommentDate =
                                                                DateTime.tryParse(
                                                                  firstCommentEntry
                                                                          ?.firstcomment!
                                                                          .date
                                                                          .toString() ??
                                                                      "",
                                                                )?.toUtc();
                                                            final secondCommentDate =
                                                                DateTime.tryParse(
                                                                  firstCommentEntry
                                                                          ?.secondcomment!
                                                                          .date
                                                                          .toString() ??
                                                                      "",
                                                                )?.toUtc();
                                                            final bool
                                                            showFirstComment =
                                                                isClearHistoryy !=
                                                                    true ||
                                                                (firstCommentDate !=
                                                                        null &&
                                                                    clearHistoryTimee !=
                                                                        null &&
                                                                    firstCommentDate
                                                                        .isAfter(
                                                                          clearHistoryTimee!,
                                                                        ));
                                                            final bool
                                                            showSecondComment =
                                                                isClearHistoryy !=
                                                                    true ||
                                                                (secondCommentDate !=
                                                                        null &&
                                                                    clearHistoryTimee !=
                                                                        null &&
                                                                    secondCommentDate
                                                                        .isAfter(
                                                                          clearHistoryTimee!,
                                                                        ));
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  "Last Comment",
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  showFirstComment
                                                                      ? firstCommentText
                                                                      : 'no comments available',
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Text(
                                                                  "Action (Plan)",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Constants
                                                                            .maincolor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  showSecondComment
                                                                      ? secondCommentText
                                                                      : 'no actions available.',
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            );
                                                          } else {
                                                            return const SizedBox(
                                                              height: 100,
                                                              child: Text(
                                                                "no comments",
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "Last Comment",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          // Edit Button with logic from your new code
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => BlocProvider(
                                                      create:
                                                          (_) => EditLeadCubit(
                                                            EditLeadApiService(),
                                                          ),
                                                      child: EditLeadDialog(
                                                        userId: lead.id!,
                                                        initialName: lead.name,
                                                        initialEmail:
                                                            lead.email,
                                                        initialPhone:
                                                            lead.phone,
                                                      ),
                                                    ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                              child: Icon(
                                                Icons.edit_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              ), // Using a more appropriate icon for Edit
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Copy Button with logic from your new code
                                          InkWell(
                                            onTap: () {
                                              if (lead.totalSubmissions! > 1) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => Dialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                16.0,
                                                              ),
                                                          child: SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      backgroundColor:
                                                                          Theme.of(context).brightness ==
                                                                                  Brightness.light
                                                                              ? Constants.maincolor
                                                                              : Constants.mainDarkmodecolor,
                                                                      child: Icon(
                                                                        Icons
                                                                            .copy,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 12,
                                                                    ),
                                                                    Text(
                                                                      "Show Duplicate",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Spacer(),
                                                                    IconButton(
                                                                      icon: Icon(
                                                                        Icons
                                                                            .close,
                                                                      ),
                                                                      onPressed:
                                                                          () => Navigator.pop(
                                                                            context,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      lead.name ??
                                                                          "",
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    "Lead Information :",
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          Colors
                                                                              .grey[700],
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                // Using the specific fields from your new code's dialog
                                                                buildInfoRow(
                                                                  Icons
                                                                      .location_city,
                                                                  "Project",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .projectName!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .settings,
                                                                  "Developer",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .developerName!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons.chat,
                                                                  "Communication Way",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .communicationWay!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .date_range,
                                                                  "Creation Date",
                                                                  DateTime.parse(
                                                                    lead
                                                                        .allVersions!
                                                                        .first
                                                                        .versionDate!,
                                                                  ).toLocal().toString(),
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .device_hub,
                                                                  "Channel",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .channelName!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .campaign,
                                                                  "Campaign",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .campaignName!,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        title: const Text(
                                                          "No Duplicates",
                                                        ),
                                                        content: const Text(
                                                          "This lead has no duplicates.",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                    ),
                                                            child: const Text(
                                                              "OK",
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              }
                                            },
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Constants.maincolor
                                                      : Constants
                                                          .mainDarkmodecolor,
                                              child: Icon(
                                                Icons.content_copy_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // ---------- Row 6: View More Link ----------
                                  SizedBox(height: 8.h),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () async {
                                        // Navigation and refresh logic from your new code
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => BlocProvider(
                                                  create: (_) => LeadCommentsCubit(GetAllLeadCommentsApiService()),
                                                  child: MarketerLeadDetailsScreen(
                                                    leedId: lead.id!,
                                                    leadName: lead.name ?? '',
                                                    leadPhone: lead.phone ?? '',
                                                    leadEmail: lead.email ?? '',
                                                    leadStage:
                                                        lead.stage?.name ?? '',
                                                    leadStageId:
                                                        lead.stage?.id ?? '',
                                                    leadChannel:
                                                        lead.chanel?.name ?? '',
                                                    leadCreationDate:
                                                        lead.createdAt != null
                                                            ? formatDateTime(
                                                              lead.createdAt!,
                                                            )
                                                            : '',
                                                    leadProject:
                                                        lead.project?.name ??
                                                        '',
                                                    leadLastComment:
                                                        lead.lastcommentdate ??
                                                        '',
                                                    leadcampaign:
                                                        lead.campaign?.name ??
                                                        "campaign",
                                                    leadNotes:
                                                        lead.notes ??
                                                        "no notes",
                                                    leaddeveloper:
                                                        lead
                                                            .project
                                                            ?.developer
                                                            ?.name ??
                                                        "no developer",
                                                    salesfcmtoken:
                                                        salesfcmtoken!,
                                                  ),
                                                ),
                                          ),
                                        );
                                        if (selectedTab == 0) {
                                          context
                                              .read<GetLeadsMarketerCubit>()
                                              .getLeadsByMarketer();
                                        } else {
                                          context
                                              .read<GetLeadsMarketerCubit>()
                                              .getLeadsByMarketerInTrash();
                                        }
                                      },
                                      child: Text(
                                        'View More',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Constants.maincolor
                                                  : Constants.mainDarkmodecolor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is GetLeadsMarketerFailure) {
                    return Center(child: Text(' ${state.errorMessage}'));
                  } else {
                    return const Center(child: Text('No leads found.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 8),
          Text("$title : ", style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
