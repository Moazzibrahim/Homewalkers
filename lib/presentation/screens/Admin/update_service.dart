// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
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
      bool force = data['force_update'];

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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Later"),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.maincolor,
                ),
                onPressed: () async {
                  final url = Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.realatixcrm.app&hl=en",
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
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
