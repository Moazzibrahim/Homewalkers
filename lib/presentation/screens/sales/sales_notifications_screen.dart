// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:intl/intl.dart';
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
    context.read<NotificationCubit>().fetchNotifications();
    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "just now";
    final utcDate = DateTime.tryParse(dateString);
    if (utcDate == null) return "just now";
    final uaeTime = utcDate.toUtc().add(const Duration(hours: 4));
    return timeago.format(uaeTime);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            isLight ? Constants.backgroundlightmode : Constants.backgroundDarkmode,
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
              isLight ? Constants.backgroundlightmode : Constants.backgroundDarkmode,
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
              Tab(text: "Transfer"),
            ],
          ),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }

            final allNotifications =
                context.read<NotificationCubit>().notifications;

            if (allNotifications.isEmpty) {
              return const Center(child: Text('No notifications yet.'));
            }

            final comments = allNotifications
                .where((n) => n.typenotification == 'comment')
                .toList();
            final transfers = allNotifications
                .where((n) => n.typenotification == 'transfer')
                .toList();

            return TabBarView(
              children: [
                _buildNotificationList(allNotifications),
                _buildNotificationList(comments),
                _buildNotificationList(transfers),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text(
          "No notifications in this category.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        final type = item.typenotification;

        if (type == 'comment' || type == 'transfer') {
          return _buildCommentOrTransferTile(item);
        } else if (type == 'event') {
          return _buildEventTile(item);
        }
        return _buildCommentOrTransferTile(item);
      },
    );
  }

  Widget _buildCommentOrTransferTile(NotificationItem item) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final senderName = item.userdoaction?.name ?? 'Someone';
    final actionText =
        item.typenotification == 'comment' ? 'Commented On' : 'Transfer You';
    final leadName = item.lead?.name ?? 'Leads';
    final fullAction = '$senderName $actionText $leadName';

    final textColor = isLight ? Colors.black : Colors.white;
    final subTextColor = isLight ? Colors.grey[600] : Colors.grey[300];
    final cardColor = isLight ? Colors.white : const Color(0xFF1E1E1E);

    return Card(
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
                      Icon(Icons.calendar_today, size: 14, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(item.createdAt),
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: subTextColor),
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
                Text(month, style: TextStyle(color: subColor, fontWeight: FontWeight.bold)),
                Text(day, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: subColor,
                        fontSize: 14,
                        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                      ),
                      children: [
                        TextSpan(text: '$description '),
                        TextSpan(
                          text: status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'accepted' ? Colors.green : Colors.red,
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
