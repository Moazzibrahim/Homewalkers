// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String currentVersion = "1.0.2";

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://raw.githubusercontent.com/Moazzibrahim/Homewalkers/main/lib/presentation/screens/Admin/version.json?${DateTime.now().millisecondsSinceEpoch}",
        ),
      );

      final data = jsonDecode(res.body);

      String latest = data['latest_version'];
      bool force = data['force_update'].toString() == 'true';

      if (_isUpdateAvailable(currentVersion, latest)) {
        _showUpdateDialog(context, force);
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  static bool _isUpdateAvailable(String current, String latest) {
    List<int> c = current.split('.').map(int.parse).toList();
    List<int> l = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < c.length; i++) {
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, bool force) {
    showDialog(
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
                  String url;
                  if (Platform.isAndroid) {
                    url =
                        "https://play.google.com/store/apps/details?id=com.realatixcrm.app";
                  } else if (Platform.isIOS) {
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
