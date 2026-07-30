import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/screens/sales/sales_notifications_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final int? count; // ✅ جديد
  final VoidCallback onBack;
  final VoidCallback? onNotification;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    this.title,
    this.count, // ✅ جديد
    required this.onBack,
    this.onNotification,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppBar(
      backgroundColor: isLight ? Colors.white : Constants.backgroundDarkmode,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0, // ✅ يقرب العنوان من الباك أرو
      leadingWidth: 40, // ✅ قللنا عرض مساحة الباك أرو عشان تقرب من العنوان

      leading: Transform.translate(
        // ✅ أيقونة arrow_back_ios فيها فراغ مرسوم جوه الشكل نفسه على اليمين
        // فبنزحزحها شوية عشان تقرب فعليًا من الكلمة
        offset: const Offset(3, 0),
        child: IconButton(
          padding: EdgeInsets.zero, // ✅ شيل البادينج الافتراضي حوالين الأيقونة
          constraints:
              const BoxConstraints(), // ✅ يمنع الأيقونة تاخد مساحة زيادة
          icon: Icon(
            Icons.arrow_back_ios_new, // ✅ فراغها الداخلي أقل من arrow_back_ios
            size: 24,
            color: isLight ? const Color(0xff080719) : const Color(0xffFFFFFF),
          ),
          onPressed: onBack,
        ),
      ),

      title:
          (title != null && title!.isNotEmpty)
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      color:
                          isLight
                              ? Constants.mainlightmodecolor
                              : const Color(0xffFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Constants.maincolor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color:
                              isLight
                                  ? Constants.mainlightmodecolor
                                  : Constants.mainDarkmodecolor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              )
              : null,

      actions: [
        if (extraActions != null) ...extraActions!,
        Container(
          margin: const EdgeInsets.only(right: 10, left: 6),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none,
              color:
                  isLight
                      ? Constants.mainlightmodecolor
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
