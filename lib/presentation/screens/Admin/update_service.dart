// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String currentVersion = "1.0.3";

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      DateTime now = DateTime.now();

      // 📅 آخر مرة ظهر فيها البوب أب
      final lastShownString = prefs.getString('last_update_shown');
      DateTime? lastShown =
          lastShownString != null ? DateTime.parse(lastShownString) : null;

      // 🏷️ آخر نسخة تم عرض البوب أب لها
      final lastShownVersion = prefs.getString('last_update_version');
      // 🆕 أول مرة يفتح التطبيق → متعرضش update
      if (lastShownVersion == null) {
        prefs.setString('last_update_version', currentVersion);
        prefs.setString('last_update_shown', now.toIso8601String());
        return;
      }

      // 🌐 جلب JSON بدون كاش
      final res = await http
          .get(
            Uri.parse(
              "https://raw.githubusercontent.com/Moazzibrahim/Homewalkers/main/lib/presentation/screens/Admin/version.json?${DateTime.now().millisecondsSinceEpoch}",
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);

      String latest = data['latest_version'];
      bool force = data['force_update'].toString() == 'true';

      // 🚫 لو نفس النسخة → مفيش داعي للبوب أب
      if (currentVersion == latest) return;

      // 🚫 لو اتعرض النهاردة أو لنفس النسخة
      if ((lastShown != null &&
              lastShown.year == now.year &&
              lastShown.month == now.month &&
              lastShown.day == now.day) ||
          (lastShownVersion != null && lastShownVersion == latest)) {
        return;
      }

      // ✅ تحقق من وجود تحديث
      if (_isUpdateAvailable(currentVersion, latest)) {
        await _showUpdateDialog(context, force);

        // 💾 حفظ بعد العرض
        prefs.setString('last_update_shown', now.toIso8601String());
        prefs.setString('last_update_version', latest);
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  // ✅ مقارنة آمنة للفيرجن
  static bool _isUpdateAvailable(String current, String latest) {
    List<int> c = current.split('.').map(int.parse).toList();
    List<int> l = latest.split('.').map(int.parse).toList();

    int maxLength = c.length > l.length ? c.length : l.length;

    for (int i = 0; i < maxLength; i++) {
      int cv = i < c.length ? c[i] : 0;
      int lv = i < l.length ? l[i] : 0;

      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }

  static Future<void> _showUpdateDialog(
    BuildContext context,
    bool force,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: !force,
      builder:
          (_) => AlertDialog(
            title: const Text("Update Available"),
            content: const Text(
              "A new version of the app is available. Please update to the latest version.",
            ),
            actions: [
              if (!force)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.maincolor,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Later",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.maincolor,
                ),
                onPressed: () async {
                  String url = "";

                  // ✅ تحديد المنصة بشكل صحيح
                  if (defaultTargetPlatform == TargetPlatform.android) {
                    url =
                        "https://play.google.com/store/apps/details?id=com.realatixcrm.app";
                  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                    url = "https://apps.apple.com/app/id6758859624";
                  } else {
                    return;
                  }

                  final uri = Uri.parse(url);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
