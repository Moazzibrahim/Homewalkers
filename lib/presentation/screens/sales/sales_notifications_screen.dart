// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:homewalkers_app/data/models/notifications_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/notifications/notifications_cubit.dart'; // ⚠️ Adjust the path to your cubit file

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
    // ✅ Fetch notifications once when the screen loads
    context.read<NotificationCubit>().fetchNotifications();
    // Set a custom locale for timeago if needed
    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  }

   String _formatDate(String? dateString) {
    if (dateString == null) return "just now";
    final date = DateTime.tryParse(dateString);
    if (date == null) return "just now";
    // ✅ Use the default format instead of 'en_short'
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            indicatorColor: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor,
            labelColor: Theme.of(context).brightness == Brightness.light ? Constants.maincolor : Constants.mainDarkmodecolor,
            unselectedLabelColor: Colors.black,
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
            final allNotifications = context.read<NotificationCubit>().notifications;
            if (allNotifications.isEmpty) {
              return const Center(child: Text('No notifications yet.'));
            }
            // Filter notifications based on type
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
        child: Text("No notifications in this category.",
            style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        final type = item.typenotification;

        // You can add more types here as needed
        if (type == 'comment' || type == 'transfer') {
          return _buildCommentOrTransferTile(item);
        } else if (type == 'event') {
          // Example for event tile
          return _buildEventTile(item);
        }
        // Default tile for any other type
        return _buildCommentOrTransferTile(item);
      },
    );
  }

  Widget _buildCommentOrTransferTile(NotificationItem item) {
    final senderName = item.userdoaction?.name ?? 'Someone';
    final actionText =
        item.typenotification == 'comment' ? 'Commented On' : 'Transfer You';
    final leadName = item.lead?.name ?? 'Leads';
    final fullAction = '$senderName $actionText $leadName';

    return Card(
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
                  Text(fullAction,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(_formatDate(item.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        TimeOfDay.fromDateTime(DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now()).format(context),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)
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
    // This is an example based on the image. You might need to adjust fields.
    final eventName = item.message ?? "Meeting With Ahmed Younes";
    final description = "Ahmed Younes has";
    final status = "accepted"; // This should come from your data

    // Example logic to get date parts
    final date = DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now();
    final month =
        '${date.month}'.toUpperCase(); // You'd want to map this to 'APR', 'MAY' etc.
    final day = '${date.day}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              children: [
                Text(month,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(day,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.fontFamily),
                      children: [
                        TextSpan(text: '$description '),
                        TextSpan(
                          text: status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'accepted'
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