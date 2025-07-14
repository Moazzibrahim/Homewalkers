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
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_lead_details.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_tabs_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/create_leads.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/get_all_users/cubit/get_all_users_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/developers/developers_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';
import 'package:homewalkers_app/presentation/widgets/custom_app_bar.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/edit_lead_dialog.dart';
import 'package:homewalkers_app/presentation/widgets/marketer/filter_leads_dialog.dart'; // تأكد أن المسار صحيح
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminLeadsScreen extends StatefulWidget {
  final String? stageName;
  const AdminLeadsScreen({super.key, this.stageName});

  @override
  State<AdminLeadsScreen> createState() => _ManagerLeadsScreenState();
}

class _ManagerLeadsScreenState extends State<AdminLeadsScreen> {
  int selectedTab = 0; // 0: Manage Leads, 1: Leads Trash
  String _searchQuery = '';
  late TextEditingController _nameSearchController;
  String? _selectedCountryFilter;
  String? _selectedDeveloperFilter;
  String? _selectedProjectFilter;
  String? _selectedStageFilter;
  String? _selectedChannelFilter;
  String? _selectedSalesFilter;
  String? _selectedCommunicationWayFilter;
  String? _selectedCampaignFilter;
  String? _addedByFilter;
  String? _assignedFromFilter;
  String? _assignedToFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  DateTime? _lastStageUpdateStartFilter;
  DateTime? _lastStageUpdateEndFilter;
  DateTime? _lastCommentDateStartFilter;
  DateTime? _lastCommentDateEndFilter;
  String? _oldStageNameFilter;
  DateTime? _oldStageDateStartFilter;
  DateTime? _oldStageDateEndFilter;

  @override
  void initState() {
    super.initState();
    _nameSearchController = TextEditingController();
    _selectedStageFilter = widget.stageName;
    context.read<GetAllUsersCubit>().fetchAllUsers().then((_) {
      if (_selectedStageFilter != null && _selectedStageFilter!.isNotEmpty) {
        _applyCurrentFilters(); // نفذ الفلترة بعد التحميل
      }
    });
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    super.dispose();
  }

  void _applyCurrentFilters() {
    // لا نطبق الفلاتر إذا كنا في تبويب سلة المهملات
    if (selectedTab == 1) {
      return;
    }
    context.read<GetAllUsersCubit>().filterLeadsAdmin(
      query: _searchQuery,
      country: _selectedCountryFilter,
      developer: _selectedDeveloperFilter,
      project: _selectedProjectFilter,
      stage: _selectedStageFilter,
      channel: _selectedChannelFilter,
      sales: _selectedSalesFilter,
      communicationWay: _selectedCommunicationWayFilter,
      campaign: _selectedCampaignFilter,
      addedBy: _addedByFilter,
      assignedFrom: _assignedFromFilter,
      assignedTo: _assignedToFilter,
      startDate: _startDateFilter,
      endDate: _endDateFilter,
      lastStageUpdateStart: _lastStageUpdateStartFilter,
      lastStageUpdateEnd: _lastStageUpdateEndFilter,
      lastCommentDateStart: _lastCommentDateStartFilter,
      lastCommentDateEnd: _lastCommentDateEndFilter,
      oldStageName: _oldStageNameFilter,
      oldStageDateStart: _oldStageDateStartFilter,
      oldStageDateEnd: _oldStageDateEndFilter,
    );
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
      return dateStr;
    }
  }

  Widget getStatusIcon(String status) {
    switch (status) {
      case 'Follow Up':
        return Icon(
          Icons.mark_email_read_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
      case 'Follow After Meeting':
        return Icon(
          Icons.mark_email_unread_outlined,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Constants.maincolor
                  : Constants.mainDarkmodecolor,
        );
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
    bool isOutdated = false;
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
            MaterialPageRoute(builder: (context) => AdminTabsScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameSearchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                        if (selectedTab == 0) {
                          _applyCurrentFilters();
                        }
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
                        if (selectedTab == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Filtering is not available for the trash.",
                              ),
                            ),
                          );
                          return;
                        }
                        final Map<String, dynamic>?
                        filters = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (dialogContext) {
                            return MultiBlocProvider(
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
                                initialCountry: _selectedCountryFilter,
                                initialDeveloper: _selectedDeveloperFilter,
                                initialProject: _selectedProjectFilter,
                                initialStage: _selectedStageFilter,
                                initialChannel: _selectedChannelFilter,
                                initialSales: _selectedSalesFilter,
                                initialCommunicationWay:
                                    _selectedCommunicationWayFilter,
                                initialCampaign: _selectedCampaignFilter,
                                initialSearchName: _nameSearchController.text,
                              ),
                            );
                          },
                        );
                        if (filters != null) {
                          setState(() {
                            _searchQuery = filters['name'] ?? _searchQuery;
                            _nameSearchController.text = _searchQuery;
                            _selectedCountryFilter = filters['country'];
                            _selectedDeveloperFilter = filters['developer'];
                            _selectedProjectFilter = filters['project'];
                            _selectedStageFilter = filters['stage'];
                            _selectedChannelFilter = filters['channel'];
                            _selectedSalesFilter = filters['sales'];
                            _selectedCommunicationWayFilter =
                                filters['communicationWay'];
                            _selectedCampaignFilter = filters['campaign'];
                            _addedByFilter = filters['addedBy'];
                            _assignedFromFilter = filters['assignedFrom'];
                            _assignedToFilter = filters['assignedTo'];
                            _startDateFilter = filters['startDate'];
                            _endDateFilter = filters['endDate'];
                            _lastStageUpdateStartFilter =
                                filters['lastStageUpdateStart'];
                            _lastStageUpdateEndFilter =
                                filters['lastStageUpdateEnd'];
                            _lastCommentDateStartFilter =
                                filters['lastCommentDateStart'];
                            _lastCommentDateEndFilter =
                                filters['lastCommentDateEnd'];
                            // ✅✅ أضف هذا الجزء هنا لحل المشكلة ✅✅
                            _oldStageNameFilter = filters['oldStageName'];
                            _oldStageDateStartFilter =
                                filters['oldStageDateStart'];
                            _oldStageDateEndFilter = filters['oldStageDateEnd'];
                          });
                          _applyCurrentFilters();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                          _searchQuery = '';
                          _nameSearchController.clear();
                          _selectedCountryFilter = null;
                          _selectedDeveloperFilter = null;
                          _selectedProjectFilter = null;
                          _selectedStageFilter =
                              widget
                                  .stageName; // أرجع stage لو كانت جاية من فوق
                          _selectedChannelFilter = null;
                          _selectedSalesFilter = null;
                          _selectedCommunicationWayFilter = null;
                          _selectedCampaignFilter = null;
                        });

                        if (widget.stageName != null &&
                            widget.stageName!.isNotEmpty) {
                          _applyCurrentFilters(); // لو جاية من الـ Widget نفذ فلترة
                        } else {
                          context
                              .read<GetAllUsersCubit>()
                              .fetchAllUsers(); // غير كده هات الكل
                        }
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
                          _searchQuery = '';
                          _nameSearchController.clear();
                        });
                        context.read<GetAllUsersCubit>().fetchLeadsInTrash();
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
                const SizedBox(width: 2),
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
                      horizontal: 10,
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
                  icon: const Icon(Icons.add, size: 11, color: Colors.white),
                  label: Text(
                    'Create Lead',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<GetAllUsersCubit, GetAllUsersState>(
                builder: (context, state) {
                  // الشرط الأول: عرض مؤشر التحميل إذا كانت أي من الحالتين loading
                  if (state is GetAllUsersLoading ||
                      state is GetLeadsInTrashLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // الشرط الثاني: عرض بيانات سلة المهملات فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 1
                  else if (state is GetLeadsInTrashSuccess &&
                      selectedTab == 1) {
                    final leads = state.leads.data;
                    if (leads == null || leads.isEmpty) {
                      return const Center(child: Text('Leads trash is empty.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<GetAllUsersCubit>().fetchLeadsInTrash();
                      },
                      child: ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(lead.name ?? "No Name"),
                              subtitle: Text(
                                "Phone: ${lead.phone ?? 'N/A'}\nEmail: ${lead.email ?? 'N/A'}",
                              ),
                              leading: Icon(
                                Icons.delete_forever,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  // الشرط الثالث: عرض خطأ سلة المهملات فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 1
                  else if (state is GetLeadsInTrashFailure &&
                      selectedTab == 1) {
                    return Center(child: Text(state.error));
                  }
                  // الشرط الرابع: عرض قائمة الـ Leads الرئيسية فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 0
                  else if (state is GetAllUsersSuccess && selectedTab == 0) {
                    final leads = state.users.data;
                    if (leads == null || leads.isEmpty) {
                      return const Center(child: Text('No leads found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _searchQuery = '';
                          _nameSearchController.clear();
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
                          context.read<GetAllUsersCubit>().fetchAllUsers();
                        } else {
                          context.read<GetAllUsersCubit>().fetchLeadsInTrash();
                        }
                      },
                      child: ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          final salesfcmtoken = lead.sales?.userlog?.fcmtoken;
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
                            isOutdated = difference > 1;
                            log("isOutdated: $isOutdated");
                          }
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
                                          const SizedBox(width: 5),
                                          Text(
                                            lead.stage?.name ?? "none",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
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
                                            "Total Submission: ${lead.totalSubmissions}",
                                            style: TextStyle(
                                              fontSize: 11.sp,
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
                                          showDialog(
                                            context: context,
                                            builder: (_) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: BlocProvider(
                                                  create:
                                                      (_) => LeadCommentsCubit(
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

                                                          // ✅ نفلتر الكومنتات اللي فيها نص فعلي
                                                          final validComments =
                                                              commentsList
                                                                  .where(
                                                                    (c) =>
                                                                        (c.firstcomment?.text?.isNotEmpty ??
                                                                            false) ||
                                                                        (c.secondcomment?.text?.isNotEmpty ??
                                                                            false),
                                                                  )
                                                                  .toList();

                                                          final Comment?
                                                          firstCommentEntry =
                                                              validComments
                                                                      .isNotEmpty
                                                                  ? validComments
                                                                      .first
                                                                  : null;

                                                          final String
                                                          firstCommentText =
                                                              firstCommentEntry
                                                                  ?.firstcomment
                                                                  ?.text ??
                                                              'No comments available.';
                                                          final String
                                                          secondCommentText =
                                                              firstCommentEntry
                                                                  ?.secondcomment
                                                                  ?.text ??
                                                              'No action available.';

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
                                                                firstCommentText,
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
                                                                secondCommentText,
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
                                                              "No comments",
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
                                          // THIS IS NOW THE EDIT BUTTON
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (
                                                      context,
                                                    ) => MultiBlocProvider(
                                                      providers: [
                                                        BlocProvider(
                                                          create:
                                                              (
                                                                _,
                                                              ) => EditLeadCubit(
                                                                EditLeadApiService(),
                                                              ),
                                                        ),
                                                        BlocProvider(
                                                          create:
                                                              (
                                                                _,
                                                              ) => ProjectsCubit(
                                                                ProjectsApiService(),
                                                              )..fetchProjects(),
                                                        ),
                                                        BlocProvider(
                                                          create:
                                                              (
                                                                _,
                                                              ) => StagesCubit(
                                                                StagesApiService(),
                                                              )..fetchStages(),
                                                        ),
                                                        BlocProvider(
                                                          create:
                                                              (
                                                                _,
                                                              ) => GetCommunicationWaysCubit(
                                                                CommunicationWayApiService(),
                                                              )..fetchCommunicationWays(),
                                                        ),
                                                        BlocProvider(
                                                          create:
                                                              (
                                                                _,
                                                              ) => ChannelCubit(
                                                                GetChannelsApiService(),
                                                              )..fetchChannels(),
                                                        ),
                                                        BlocProvider(
                                                          create:
                                                              (
                                                                _,
                                                              ) => GetCampaignsCubit(
                                                                CampaignApiService(),
                                                              )..fetchCampaigns(),
                                                        ),
                                                        BlocProvider(
                                                          create:
                                                              (_) => SalesCubit(
                                                                GetAllSalesApiService(),
                                                              )..fetchAllSales(),
                                                        ),
                                                      ],
                                                      child: EditLeadDialog(
                                                        userId: lead.id!,
                                                        initialName: lead.name,
                                                        initialEmail:
                                                            lead.email,
                                                        initialPhone:
                                                            lead.phone,
                                                        initialCampaignId:
                                                            lead.campaign?.id,
                                                        initialChannelId:
                                                            lead.chanel?.id,
                                                        initialCommunicationWayId:
                                                            lead
                                                                .communicationway
                                                                ?.id,
                                                        initialProjectId:
                                                            lead.project?.id,
                                                        initialStageId:
                                                            lead.stage?.id,
                                                        isCold:
                                                            lead.leedtype ==
                                                                    "Fresh"
                                                                ? false
                                                                : true,
                                                        onSuccess: () {
                                                          context
                                                              .read<
                                                                GetAllUsersCubit
                                                              >()
                                                              .fetchAllUsers(); // 👈 refresh lead list
                                                        },
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
                                                Icons.refresh,
                                                color: Colors.white,
                                                size: 20,
                                              ), // As per image
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // THIS IS THE COPY BUTTON
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
                                                                buildInfoRow(
                                                                  Icons
                                                                      .location_city,
                                                                  "Project",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .project!
                                                                      .name!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .settings,
                                                                  "Developer",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .project!
                                                                      .developer!
                                                                      .name!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons.chat,
                                                                  "Communication Way",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .communicationway!
                                                                      .name!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .date_range,
                                                                  "Creation Date",
                                                                  DateTime.parse(
                                                                    lead
                                                                        .allVersions!
                                                                        .first
                                                                        .recordedAt!,
                                                                  ).toLocal().toString(),
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .device_hub,
                                                                  "Channel",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .chanel!
                                                                      .name!,
                                                                ),
                                                                buildInfoRow(
                                                                  Icons
                                                                      .campaign,
                                                                  "Campaign",
                                                                  lead
                                                                      .allVersions!
                                                                      .first
                                                                      .campaign!
                                                                      .campainName!,
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
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => AdminLeadDetails(
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
                                                      lead.project?.name ?? '',
                                                  leadLastComment:
                                                      lead.lastcommentdate ??
                                                      '',
                                                  leadcampaign:
                                                      lead
                                                          .campaign
                                                          ?.campainName ??
                                                      "campaign",
                                                  leadNotes: "no notes",
                                                  leaddeveloper:
                                                      lead
                                                          .project
                                                          ?.developer
                                                          ?.name ??
                                                      "no developer",
                                                  salesfcmToken: salesfcmtoken,
                                                ),
                                          ),
                                        );
                                        // The original refresh logic is restored here, to run after returning from details page
                                        if (selectedTab == 0) {
                                          context
                                              .read<GetAllUsersCubit>()
                                              .fetchAllUsers();
                                        } else {
                                          context
                                              .read<GetAllUsersCubit>()
                                              .fetchLeadsInTrash();
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
                  }
                  // الشرط الخامس: عرض خطأ الـ Leads الرئيسية فقط إذا كانت الحالة مطابقة والتبويب المحدد هو 0
                  else if (state is GetAllUsersFailure && selectedTab == 0) {
                    return Center(child: Text(' ${state.error}'));
                  }
                  // الحالة الافتراضية: إذا لم تتطابق أي من الشروط السابقة
                  // (مثلاً الحالة هي GetLeadsInTrashSuccess والتبويب هو 0)
                  // نعرض مؤشر تحميل لأننا ننتظر الحالة الصحيحة
                  else {
                    return const Center(child: CircularProgressIndicator());
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
