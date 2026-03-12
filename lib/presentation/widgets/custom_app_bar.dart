import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // 👈 جعلها nullable
  final VoidCallback onBack;
  final VoidCallback? onNotification;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    this.title, // 👈 جعلها optional
    required this.onBack,
    this.onNotification,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Constants.backgroundDarkmode,
      elevation: 0,
      automaticallyImplyLeading: false,

      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? const Color(0xff080719)
                  : const Color(0xffFFFFFF),
        ),
        onPressed: onBack,
      ),

      // 👇 إظهار العنوان فقط إذا كان موجوداً وليس فارغاً
      title:
          (title != null && title!.isNotEmpty)
              ? Text(
                title!,
                style: TextStyle(
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? const Color(0xff080719)
                          : const Color(0xffFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
              : null, // 👈 إذا كان العنوان فارغاً، لا نضع أي widget في الـ title

      actions: [
        if (extraActions != null) ...extraActions!,

        Container(
          margin: const EdgeInsets.only(right: 10, left: 6),
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
