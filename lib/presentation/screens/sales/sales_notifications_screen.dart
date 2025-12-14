// ignore_for_file: unused_local_variable, non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_comments_screen.dart';
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
  @override
  void initState() {
    super.initState();
    _initPrefsAndNotifications();
  }

  Future<void> _initPrefsAndNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    if (role == "Admin") {
      context.read<NotificationCubit>().fetchAllNotifications();
    } else {
      context.read<NotificationCubit>().fetchNotifications();
    }

    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM').format(date); // مثل '6 APR'
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            isLight
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
              isLight
                  ? Constants.backgroundlightmode
                  : Constants.backgroundDarkmode,
          toolbarHeight: 80,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isLight ? const Color(0xff080719) : Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          bottom: TabBar(
            indicatorColor:
                isLight ? Constants.maincolor : Constants.mainDarkmodecolor,
            labelColor:
                isLight ? Constants.maincolor : Constants.mainDarkmodecolor,
            unselectedLabelColor: isLight ? Colors.black : Colors.grey[400],
            tabs: const [
              Tab(text: "All"),
              Tab(text: "Comments"),
              Tab(text: "Assign"),
            ],
          ),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }
            final allNotifications = context.read<NotificationCubit>().notifications;
            if (allNotifications.isEmpty) {
              return const Center(child: Text('No notifications yet.'));
            }
            final comments =
                allNotifications
                    .where((n) => n.typenotification == 'comment')
                    .toList();
            final assigns =
                allNotifications
                    .where((n) => n.typenotification == 'assign')
                    .toList();

            return TabBarView(
              children: [
                _buildNotificationList(context,allNotifications),
                _buildNotificationList(context,comments),
                _buildNotificationList(context,assigns),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, List<NotificationItem> notifications) {
  if (notifications.isEmpty) {
    return const Center(
      child: Text(
        "No notifications in this category.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  return RefreshIndicator(
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
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        final type = item.typenotification;

        if (type == 'comment' || type == 'assign') {
          return _buildCommentOrassignTile(item);
        } else if (type == 'event') {
          return _buildEventTile(item);
        }
        return _buildCommentOrassignTile(item);
      },
    ),
  );
}


  Widget _buildCommentOrassignTile(NotificationItem item) {
  final isLight = Theme.of(context).brightness == Brightness.light;
  final senderName = item.userdoaction?.name ?? 'Someone';
  final actionText =
      item.typenotification == 'comment' ? 'Commented On' : 'assigned You ';
  final leadName = item.lead?.name ?? 'Leads';
  final fullAction = '$senderName $actionText $leadName';

  final textColor = isLight ? Colors.black : Colors.white;
  final subTextColor = isLight ? Colors.grey[600] : Colors.grey[300];
  final cardColor = isLight ? Colors.white : const Color(0xFF1E1E1E);

  return InkWell(
    onTap: () {
      if (item.typenotification == 'comment') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SalesCommentsScreen(
              leedId: item.lead?.id ?? "",       // مهم جداً
              fcmtoken: item.lead?.sales?.userlog?.fcmToken ?? "",           // لو موجود
              leadName: item.lead?.name ?? "",   // اسم الليد
              managerfcm: item.userdoaction?.fcmToken,
            ),
          ),
        );
      }
    },

    child: Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullAction,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Constants.maincolor),
                      const SizedBox(width: 4),
                      Text(
                        _formatDay(
                          DateTime.tryParse(item.createdAt ?? '') ??
                              DateTime.now(),
                        ),
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time,
                          size: 14, color: Constants.maincolor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(
                          (DateTime.tryParse(item.createdAt ?? '') ??
                                  DateTime.now())
                              .toUtc()
                              .add(const Duration(hours: 4)),
                        ),
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildEventTile(NotificationItem item) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final titleColor = isLight ? Colors.black : Colors.white;
    final subColor = isLight ? Colors.grey[600] : Colors.grey[300];
    final cardColor = isLight ? Colors.white : const Color(0xFF1E1E1E);

    final eventName = item.message ?? "Meeting With Ahmed Younes";
    final description = "Ahmed Younes has";
    final status = "accepted";

    final date = DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now();
    final month = DateFormat('MMM').format(date).toUpperCase();
    final day = '${date.day}';

    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  month,
                  style: TextStyle(
                    color: subColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: subColor,
                        fontSize: 14,
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
                                    ? Colors.green
                                    : Colors.red,
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
      ),
    );
  }
}
