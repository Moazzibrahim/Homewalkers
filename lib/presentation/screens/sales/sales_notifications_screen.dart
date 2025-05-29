import 'package:flutter/material.dart';

class SalesNotificationsScreen extends StatelessWidget {
  const SalesNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        // backgroundColor: Colors.white,
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Color(0xff080719)
                        : Color(0xffFFFFFF),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/sales_image.png'),
              radius: 24,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello M. Ibrahem',
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Color(0xff080719)
                            : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Sales',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Spacer(),
            _iconBox(Icons.comment_rounded, () {}),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              // color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "All",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text("Comments", style: TextStyle(color: Colors.grey)),
                      Text("Transfer", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                // color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    NotificationTile(
                      name: "Ahmed Sami",
                      action: "Commented On",
                      time: "10:00 AM",
                      date: "2 days ago",
                      avatarUrl: null,
                    ),
                    NotificationTile(
                      name: "Ahmed Sami",
                      action: "Transfer You Leads",
                      time: "2 Min Ago",
                      date: "Today",
                      avatarUrl: null,
                    ),
                    CalendarTile(
                      date: "APR",
                      day: "6",
                      title: "Meeting With Ahmed Younes",
                      subtitle: "Ahmed Younes has accepted this event",
                      accepted: true,
                    ),
                    CalendarTile(
                      date: "APR",
                      day: "6",
                      title: "Meeting With Ahmed Younes",
                      subtitle: "Ahmed Younes has declined this event",
                      accepted: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _iconBox(IconData icon, void Function() onPressed) {
    return Container(
      decoration: BoxDecoration(
        // color: Color(0xFFE8F1F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Color(0xff2D6A78)),
        onPressed: onPressed,
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String name, action, date, time;
  final String? avatarUrl;

  const NotificationTile({
    super.key,
    required this.name,
    required this.action,
    required this.date,
    required this.time,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$name $action",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(date),
                      SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(time),
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
}

class CalendarTile extends StatelessWidget {
  final String date;
  final String day;
  final String title;
  final String subtitle;
  final bool accepted;

  const CalendarTile({
    super.key,
    required this.date,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.accepted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              // color: Colors.teal[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  day,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                // color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      text: "Ahmed Younes has ",
                      children: [
                        TextSpan(
                          text: accepted ? "accepted" : "declined",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: " this event"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
