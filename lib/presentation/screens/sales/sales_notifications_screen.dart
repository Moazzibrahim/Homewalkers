// ignore_for_file: unused_local_variable, non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/Admin/admin_lead_details.dart';
import 'package:homewalkers_app/presentation/screens/manager/leads_details_screen_manager.dart';
import 'package:homewalkers_app/presentation/screens/marketier/marketer_lead_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_leads_details_screen.dart';
import 'package:homewalkers_app/presentation/screens/team_leader/leads_details_team_leader_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:homewalkers_app/data/models/notifications_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart';

class SalesNotificationsScreen extends StatefulWidget {
  const SalesNotificationsScreen({super.key});

  @override
  State<SalesNotificationsScreen> createState() =>
      _SalesNotificationsScreenState();
}

class _SalesNotificationsScreenState extends State<SalesNotificationsScreen> {
  final ScrollController _allScrollController = ScrollController();
  final ScrollController _commentsScrollController = ScrollController();
  final ScrollController _assignScrollController = ScrollController();
  final ScrollController _createdScrollController = ScrollController();

  String? _role;

  static const Color _blue = Color(0xFF1a4db3);
  static const Color _gold = Color(0xff7E5700);

  @override
  void initState() {
    super.initState();
    _initPrefsAndNotifications();
    _setupScrollListeners();
  }

  Future<void> _initPrefsAndNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');

    if (_role == "Admin") {
      context.read<NotificationCubit>().fetchAllNotifications();
    } else {
      context.read<NotificationCubit>().fetchNotifications();
    }

    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  }

  void _setupScrollListeners() {
    _allScrollController.addListener(_onAllScroll);
    _commentsScrollController.addListener(_onCommentsScroll);
    _assignScrollController.addListener(_onAssignScroll);
    _createdScrollController.addListener(_onCreatedScroll);
  }

  void _onAllScroll() {
    if (_isNearBottom(_allScrollController)) _loadMore();
  }

  void _onCommentsScroll() {
    if (_isNearBottom(_commentsScrollController)) _loadMore();
  }

  void _onAssignScroll() {
    if (_isNearBottom(_assignScrollController)) _loadMore();
  }

  void _onCreatedScroll() {
    if (_isNearBottom(_createdScrollController)) _loadMore();
  }

  bool _isNearBottom(ScrollController controller) {
    if (!controller.hasClients) return false;
    final maxScroll = controller.position.maxScrollExtent;
    final current = controller.offset;
    return current >= maxScroll - 100;
  }

  void _loadMore() {
    final cubit = context.read<NotificationCubit>();
    if (_role == "Admin") {
      cubit.fetchMoreAllNotifications();
    } else {
      cubit.fetchMoreNotifications();
    }
  }

  @override
  void dispose() {
    _allScrollController.removeListener(_onAllScroll);
    _commentsScrollController.removeListener(_onCommentsScroll);
    _assignScrollController.removeListener(_onAssignScroll);
    _createdScrollController.removeListener(_onCreatedScroll);
    _allScrollController.dispose();
    _commentsScrollController.dispose();
    _assignScrollController.dispose();
    _createdScrollController.dispose();
    super.dispose();
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday)
      return 'Yesterday';
    else
      return DateFormat('d MMM').format(date);
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

  Future<bool> _checkNotificationBeforeOpen({required String leadId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userlogId = prefs.getString('salesId') ?? '';
      final url = Uri.parse(
        '${Constants.baseUrl}/users/sales/checknotifcationbeforeopen/$leadId/$userlogId',
      );
      print('🔍 Check URL: $url');
      print('🔍 Token: $token');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('🔍 Check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('🔍 Error checking notification: $e');
      return false;
    }
  }

  Future<void> _checkThenNavigate({
    required String? leadId,
    required VoidCallback onAllowed,
  }) async {
    // ✅ Admin يعدي مباشرة بدون check
    if (_role == 'Admin') {
      onAllowed();
      return;
    }

    if (leadId == null || leadId.isEmpty) {
      onAllowed();
      return;
    }

    final allowed = await _checkNotificationBeforeOpen(leadId: leadId);
    if (!mounted) return;
    if (allowed) {
      onAllowed();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This lead has been transferred to another sales.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _navigateToLeadDetails(NotificationItem item) {
    final lead = item.lead;
    if (lead == null) return;

    _checkThenNavigate(
      leadId: lead.id,
      onAllowed: () {
        final firstVersion =
            (lead.allVersions != null && lead.allVersions!.isNotEmpty)
                ? lead.allVersions!.first
                : null;

        switch (_role) {
          case 'Admin':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => AdminLeadDetails(
                      leedId: lead.id!,
                      leadName: lead.name ?? '',
                      leadPhone: lead.phone ?? '',
                      leadEmail: lead.email ?? '',
                      leadStage: lead.stage?.name ?? '',
                      leadStageId: lead.stage?.id ?? '',
                      leadSalesName: lead.sales?.name ?? '',
                      leadChannel: lead.chanel?.name ?? '',
                      leadCreationDate:
                          lead.createdAt != null
                              ? formatDateTimeToDubai(
                                lead.createdAt!.toString(),
                              )
                              : '',
                      leadProject: lead.project?.name ?? '',
                      leadLastComment: lead.lastcommentdate.toString(),
                      leadcampaign: lead.campaign?.CampainName ?? "campaign",
                      leadNotes: "no notes",
                      leaddeveloper:
                          lead.project?.developer?.name ?? "no developer",
                      salesfcmToken: lead.sales?.userlog?.fcmToken,
                      leadwhatsappnumber:
                          lead.whatsappnumber ?? 'no whatsapp number',
                      jobdescription:
                          lead.jobdescription ?? 'no job description',
                      secondphonenumber:
                          lead.phonenumber2 ?? 'no second phone number',
                      laststageupdated: lead.stagedateupdated.toString(),
                      stageId: lead.stage?.id,
                      totalsubmissions: lead.totalSubmissions.toString(),
                      leadversions: lead.allVersions,
                      leadversionscampaign:
                          firstVersion?.campaign?.CampainName ?? "No campaign",
                      leadversionsproject:
                          firstVersion?.project?.name ?? "No project",
                      leadversionsdeveloper:
                          firstVersion?.project?.developer?.name ??
                          "No developer",
                      leadversionschannel:
                          firstVersion?.chanel?.name ?? "No channel",
                      leadversionscommunicationway:
                          firstVersion?.communicationway?.name ??
                          "No communication way",
                      leadStages: [lead.stage?.id],
                      cashbackmoney: lead.cashbackmoney,
                      cashbackratio: lead.cashbackratio,
                      commissionmoney: lead.commissionmoney,
                      commissionratio: lead.commissionratio,
                      unitPrice: lead.unit_price,
                      unitnumber: lead.unitnumber,
                      linkCampaign: lead.campaign?.redirectLink,
                      campaignRedirectLink: lead.campaignRedirectLink,
                      question1_text: lead.question1_text,
                      question1_answer: lead.question1_answer,
                      question2_text: lead.question2_text,
                      question2_answer: lead.question2_answer,
                      question3_text: lead.question3_text,
                      question3_answer: lead.question3_answer,
                      question4_text: lead.question4_text,
                      question4_answer: lead.question4_answer,
                      question5_text: lead.question5_text,
                      question5_answer: lead.question5_answer,
                    ),
              ),
            );
            break;

          case 'Marketer':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MarketerLeadDetailsScreen(
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
                      leadcampaign: lead.campaign?.CampainName ?? "campaign",
                      leadNotes: lead.jobdescription ?? "no notes",
                      leaddeveloper:
                          lead.project?.developer?.name ?? "no developer",
                      salesfcmtoken:
                          lead.sales?.userlog?.fcmToken ?? 'no fcm token',
                      leadwhatsappnumber:
                          lead.whatsappnumber ?? 'no whatsapp number',
                      jobdescription:
                          lead.jobdescription ?? 'no job description',
                      secondphonenumber:
                          lead.phonenumber2 ?? 'no second phone number',
                      laststageupdated: lead.stagedateupdated,
                      stageId: lead.stage?.id,
                      totalsubmissions: lead.totalSubmissions.toString(),
                      leadversions: lead.allVersions,
                      leadversionscampaign:
                          firstVersion?.campaign?.CampainName ?? "No campaign",
                      leadversionsproject:
                          firstVersion?.project?.name ?? "No project",
                      leadversionsdeveloper:
                          firstVersion?.project?.developer?.name ??
                          "No developer",
                      leadversionschannel:
                          firstVersion?.chanel?.name ?? "No channel",
                      leadversionscommunicationway:
                          firstVersion?.communicationway?.name ??
                          "No communication way",
                      leadStages: [lead.stage?.id],
                      leadSalesName: lead.sales?.name ?? '',
                      campaignlink:
                          lead.campaign?.redirectLink ?? 'no campaign link',
                      campaignRedirectLink: lead.campaignRedirectLink,
                      question1_text: lead.question1_text,
                      question1_answer: lead.question1_answer,
                      question2_text: lead.question2_text,
                      question2_answer: lead.question2_answer,
                      question3_text: lead.question3_text,
                      question3_answer: lead.question3_answer,
                      question4_text: lead.question4_text,
                      question4_answer: lead.question4_answer,
                      question5_text: lead.question5_text,
                      question5_answer: lead.question5_answer,
                    ),
              ),
            );
            break;

          case 'Manager':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => LeadsDetailsManagerScreen(
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
                      leadcampaign: lead.campaign?.CampainName ?? "campaign",
                      leaddeveloper:
                          lead.project?.developer?.name ?? "no developer",
                      fcmtoken: lead.sales?.userlog?.fcmToken ?? '',
                      leadwhatsappnumber: lead.whatsappnumber,
                      jobdescription:
                          lead.jobdescription ?? 'no job description',
                      secondphonenumber: lead.phonenumber2,
                      laststageupdated: lead.stagedateupdated,
                      stageId: lead.stage?.id ?? '',
                      leadSalesName: lead.sales?.name ?? '',
                      leadLastDateAssigned: lead.lastdateassign,
                      question1_text: lead.question1_text,
                      question1_answer: lead.question1_answer,
                      question2_text: lead.question2_text,
                      question2_answer: lead.question2_answer,
                      question3_text: lead.question3_text,
                      question3_answer: lead.question3_answer,
                      question4_text: lead.question4_text,
                      question4_answer: lead.question4_answer,
                      question5_text: lead.question5_text,
                      question5_answer: lead.question5_answer,
                    ),
              ),
            );
            break;

          case 'Team Leader':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => LeadsDetailsTeamLeaderScreen(
                      leedId: lead.id.toString(),
                      leadName: lead.name ?? 'No Name',
                      leadPhone: lead.phone ?? 'No Phone',
                      leadEmail: lead.email ?? 'No Email',
                      leadStage: lead.stage?.name ?? 'No Stage',
                      leadStageId: lead.stage?.id.toString() ?? '',
                      leadChannel: lead.chanel?.name ?? 'No Channel',
                      leadSalesName: lead.sales?.name ?? 'No Sales',
                      leadCreationDate:
                          lead.createdAt != null
                              ? formatDateTimeToDubai(lead.createdAt!)
                              : '',
                      leadProject: lead.project?.name ?? 'No Project',
                      leadLastComment:
                          lead.lastcommentdate ?? 'No Last Comment',
                      leadcampaign: lead.campaign?.CampainName ?? 'No Campaign',
                      leadNotes: 'No Notes',
                      leaddeveloper:
                          lead.project?.developer?.name ?? 'No Developer',
                      userlogname: lead.sales?.userlog?.name ?? 'No User',
                      teamleadername:
                          lead.sales?.teamleader?.name ?? 'No Team Leader',
                      fcmtoken: lead.sales?.userlog?.fcmToken ?? '',
                      managerfcmtoken: lead.sales?.manager?.fcmToken ?? '',
                      leadwhatsappnumber:
                          lead.whatsappnumber ?? lead.phone ?? '',
                      jobdescription:
                          lead.jobdescription ?? 'no job description',
                      secondphonenumber:
                          lead.phonenumber2 ?? 'no second phone number',
                      laststageupdated: lead.stagedateupdated ?? '',
                      stageId: lead.stage?.id ?? 'No Stage ID',
                      leadLastDateAssigned: lead.lastdateassign ?? '',
                      isresetcreationdate: lead.resetcreationdate ?? false,
                      question1_text: lead.question1_text,
                      question1_answer: lead.question1_answer,
                      question2_text: lead.question2_text,
                      question2_answer: lead.question2_answer,
                      question3_text: lead.question3_text,
                      question3_answer: lead.question3_answer,
                      question4_text: lead.question4_text,
                      question4_answer: lead.question4_answer,
                      question5_text: lead.question5_text,
                      question5_answer: lead.question5_answer,
                    ),
              ),
            );
            break;

          case 'Sales':
          default:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SalesLeadsDetailsScreen(
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
                      leadcampaign: lead.campaign?.CampainName ?? "campaign",
                      leadNotes: "",
                      leaddeveloper:
                          lead.project?.developer?.name ?? "no developer",
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
                      question1_text: lead.question1_text,
                      question1_answer: lead.question1_answer,
                      question2_text: lead.question2_text,
                      question2_answer: lead.question2_answer,
                      question3_text: lead.question3_text,
                      question3_answer: lead.question3_answer,
                      question4_text: lead.question4_text,
                      question4_answer: lead.question4_answer,
                      question5_text: lead.question5_text,
                      question5_answer: lead.question5_answer,
                    ),
              ),
            );
            break;
        }
      },
    );
  }

  // ─── UI HELPERS ───────────────────────────────────────────────

  Widget _buildTabLabel(String label, int count, bool isActive) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: isActive ? _blue : Colors.grey.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIX: _buildStatCard — replaced non-uniform Border with ClipRRect + bottom accent bar
  Widget _buildStatCard(
    String number,
    String label,
    Color numColor,
    bool isActive,
    bool isLight,
  ) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: numColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom accent bar
              Container(
                height: 2.5,
                color: isActive ? _gold : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor =
        isLight ? Constants.backgroundlightmode : Constants.backgroundDarkmode;
    final headerColor = isLight ? Colors.white : const Color(0xFF1A1A1A);

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final allNotifications =
            context.read<NotificationCubit>().notifications;

        final comments =
            allNotifications
                .where((n) => n.typenotification == 'comment')
                .toList();
        final assigns =
            allNotifications
                .where((n) => n.typenotification == 'assign')
                .toList();
        final created =
            allNotifications
                .where(
                  (n) =>
                      n.typenotification != 'comment' &&
                      n.typenotification != 'assign',
                )
                .toList();

        final totalCount = allNotifications.length;
        final commentCount = comments.length;
        final assignCount = assigns.length;
        final createdCount = created.length;

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: headerColor,
              toolbarHeight: 72,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isLight ? const Color(0xff080719) : Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                  Text(
                    'ACTIVITY CENTER',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Builder(
                  builder: (ctx) {
                    final tabIndex = DefaultTabController.of(ctx).index;
                    return TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: _blue,
                      indicatorWeight: 2.5,
                      labelColor: _blue,
                      unselectedLabelColor:
                          isLight ? Colors.grey[600] : Colors.grey[400],
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      tabs: [
                        _buildTabLabel('All', totalCount, tabIndex == 0),
                        _buildTabLabel('Comments', commentCount, tabIndex == 1),
                        _buildTabLabel(
                          'Assignments',
                          assignCount,
                          tabIndex == 2,
                        ),
                        _buildTabLabel('Created', createdCount, tabIndex == 3),
                      ],
                    );
                  },
                ),
              ),
            ),
            body: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                if (allNotifications.isEmpty) {
                  return const Center(child: Text('No notifications yet.'));
                }

                final unreadCount =
                    allNotifications.where((n) => n.isRead == false).length;
                final readCount =
                    allNotifications.where((n) => n.isRead == true).length;

                return Column(
                  children: [
                    // ── Stats Row ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Row(
                        children: [
                          _buildStatCard(
                            '${allNotifications.length}',
                            'TOTAL',
                            _blue,
                            false,
                            isLight,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            '$unreadCount',
                            'UNREAD',
                            _gold,
                            true,
                            isLight,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            '$readCount',
                            'READ',
                            isLight ? Colors.black87 : Colors.white,
                            false,
                            isLight,
                          ),
                        ],
                      ),
                    ),

                    // ── Tab Content ──
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildNotificationList(
                            context,
                            allNotifications,
                            _allScrollController,
                            state,
                            isLight,
                          ),
                          _buildNotificationList(
                            context,
                            comments,
                            _commentsScrollController,
                            state,
                            isLight,
                          ),
                          _buildNotificationList(
                            context,
                            assigns,
                            _assignScrollController,
                            state,
                            isLight,
                          ),
                          _buildNotificationList(
                            context,
                            created,
                            _createdScrollController,
                            state,
                            isLight,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ─── NOTIFICATION LIST ────────────────────────────────────────

  Widget _buildNotificationList(
    BuildContext context,
    List<NotificationItem> notifications,
    ScrollController scrollController,
    NotificationState state,
    bool isLight,
  ) {
    if (notifications.isEmpty && !state.isLoadingMore) {
      return const Center(
        child: Text(
          "No notifications in this category.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      color: _blue,
      onRefresh: () async {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');
        if (role == "Admin") {
          await context.read<NotificationCubit>().fetchAllNotifications();
        } else {
          await context.read<NotificationCubit>().fetchNotifications();
        }
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: notifications.length + 1,
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.hasMore) {
              return _buildShowingAndLoadMore(
                notifications.length,
                isLight,
                context,
              );
            }
            return const SizedBox.shrink();
          }

          final item = notifications[index];
          final type = item.typenotification;

          if (type == 'comment' || type == 'assign') {
            return _buildCommentOrAssignTile(item, isLight);
          } else if (type == 'event') {
            return _buildEventTile(item, isLight);
          }
          return _buildCommentOrAssignTile(item, isLight);
        },
      ),
    );
  }

  Widget _buildShowingAndLoadMore(
    int showing,
    bool isLight,
    BuildContext context,
  ) {
    final total = context.read<NotificationCubit>().notifications.length;
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          'SHOWING $showing OF $total NOTIFICATIONS',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _loadMore,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: isLight ? Colors.white : const Color(0xFF1E1E1E),
            ),
            child: Text(
              'Load More',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── COMMENT / ASSIGN TILE ────────────────────────────────────

  // ✅ FIX: replaced non-uniform Border with ClipRRect + left accent bar as a child widget
  Widget _buildCommentOrAssignTile(NotificationItem item, bool isLight) {
    final isAssign = item.typenotification == 'assign';
    final accentColor = isAssign ? _gold : _blue;
    final senderName = item.userdoaction?.name ?? 'Someone';
    final leadName = item.lead?.name ?? 'Lead';
    final cardColor = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final subTextColor = isLight ? Colors.grey[600] : Colors.grey[300];

    final timeStr = DateFormat('h:mm a').format(
      (DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now()).toUtc().add(
        const Duration(hours: 4),
      ),
    );
    final dayStr = _formatDay(
      DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now(),
    );

    return InkWell(
      onTap: () {
        _checkThenNavigate(
          leadId: item.lead?.id,
          onAllowed: () {
            if (item.typenotification == 'comment') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SalesCommentsScreen(
                        leedId: item.lead?.id ?? "",
                        fcmtoken: item.lead?.sales?.userlog?.fcmToken ?? "",
                        leadName: item.lead?.name ?? "",
                        managerfcm: item.userdoaction?.fcmToken,
                      ),
                ),
              );
            } else if (item.typenotification == 'assign') {
              _navigateToLeadDetails(item);
            }
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          // ✅ uniform border — no crash
          border: Border.all(color: Colors.grey.withOpacity(0.13)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ Left accent bar as a plain Container child
                Container(width: 3, color: accentColor),
                // Card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 23,
                              backgroundColor:
                                  isAssign
                                      ? const Color(0xFFF5EDD3)
                                      : const Color(0xFFDEE8F7),
                              child: Icon(
                                Icons.person_rounded,
                                color: accentColor,
                                size: 22,
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cardColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  isAssign
                                      ? Icons.assignment_outlined
                                      : Icons.chat_bubble_outline_rounded,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAssign ? 'NEW ASSIGNMENT' : 'NEW COMMENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isLight ? Colors.black87 : Colors.white,
                                    height: 1.4,
                                    fontFamily:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.fontFamily,
                                  ),
                                  children:
                                      isAssign
                                          ? [
                                            const TextSpan(text: 'Lead '),
                                            TextSpan(
                                              text: leadName,
                                              style: const TextStyle(
                                                color: _blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' has been assigned to ',
                                            ),
                                            TextSpan(
                                              text:
                                                  item.lead?.sales?.name ??
                                                  'Unknown',
                                              style: const TextStyle(
                                                color: _blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ]
                                          : [
                                            TextSpan(
                                              text: senderName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ' commented on Lead ',
                                            ),
                                            TextSpan(
                                              text: leadName,
                                              style: const TextStyle(
                                                color: _blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$dayStr · $timeStr',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        isAssign ? 'View Lead' : 'View Comment',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Icon(
                                        isAssign
                                            ? Icons.arrow_forward_rounded
                                            : Icons.reply_rounded,
                                        size: 14,
                                        color: accentColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Unread dot
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── EVENT TILE ───────────────────────────────────────────────

  Widget _buildEventTile(NotificationItem item, bool isLight) {
    final titleColor = isLight ? Colors.black : Colors.white;
    final subColor = isLight ? Colors.grey[600] : Colors.grey[300];
    final cardColor = isLight ? Colors.white : const Color(0xFF1E1E1E);

    final eventName = item.message ?? "Meeting With Ahmed Younes";
    final description = "Ahmed Younes has";
    const status = "accepted";

    final date = DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now();
    final month = DateFormat('MMM').format(date).toUpperCase();
    final day = '${date.day}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.13)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: subColor,
                      fontSize: 13,
                      fontFamily:
                          Theme.of(context).textTheme.bodyLarge?.fontFamily,
                    ),
                    children: [
                      TextSpan(text: '$description '),
                      TextSpan(
                        text: status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              status == 'accepted'
                                  ? Colors.green[600]
                                  : Colors.red[600],
                        ),
                      ),
                      const TextSpan(text: ' this event'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
