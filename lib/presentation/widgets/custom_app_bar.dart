import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onNotification;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.onNotification,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
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
            onPressed: onBack,
          ),
          Text(
            title,
            style: TextStyle(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Color(0xff080719)
                      : Color(0xffFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        // Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 6),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFE8F1F2),
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: IconButton(
        //     icon: Icon(
        //       Icons.comment_rounded,
        //       color:
        //           Theme.of(context).brightness == Brightness.light
        //               ? Constants.maincolor
        //               : Constants.mainDarkmodecolor,
        //     ),
        //     onPressed: () {},
        //   ),
        // ),
        Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none,
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Constants.maincolor
                      : Constants.mainDarkmodecolor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesNotificationsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
