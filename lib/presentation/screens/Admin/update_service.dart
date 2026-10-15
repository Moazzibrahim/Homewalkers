import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  /// The current version of this app release (matches pubspec.yaml: 1.1.27)
  static const String currentAppVersion = '1.1.27';

  // Remote Config Keys
  static const String keyShowUpdateDialog = 'show_update_dialog';
  static const String keyLatestVersion = 'latest_version';
  static const String keyMinRequiredVersion = 'min_required_version';
  static const String keyForceUpdate = 'force_update';
  static const String keyUpdateTitle = 'update_title';
  static const String keyUpdateMessage = 'update_message';
  static const String keyUpdateUrlAndroid = 'update_url_android';
  static const String keyUpdateUrlIos = 'update_url_ios';

  // Fallback default store links
  static const String defaultAndroidUrl =
      'https://play.google.com/store/apps/details?id=com.realatixcrm.app';
  static const String defaultIosUrl =
      'https://apps.apple.com/app/id6758859624';

  static bool _isDialogShowing = false;
  static bool _sessionChecked = false;

  /// Initialize Firebase Remote Config with default parameters & settings
  static Future<void> initRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      await remoteConfig.setDefaults({
        keyShowUpdateDialog: false,
        keyLatestVersion: currentAppVersion,
        keyMinRequiredVersion: currentAppVersion,
        keyForceUpdate: false,
        keyUpdateTitle: 'Update Available',
        keyUpdateMessage:
            'A new version of Realatix CRM is available. Please update now to get the latest features and performance improvements.',
        keyUpdateUrlAndroid: defaultAndroidUrl,
        keyUpdateUrlIos: defaultIosUrl,
      });

      await remoteConfig
          .fetchAndActivate()
          .timeout(const Duration(seconds: 4), onTimeout: () => false);
      log('✅ Remote Config initialized and fetched successfully');
    } catch (e) {
      log('⚠️ Error initializing Remote Config: $e');
    }
  }

  /// Check for update and show update dialog if required
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool forceCheck = false,
  }) async {
    // Avoid showing duplicate dialogs or re-checking in the same session (unless forced)
    if (_isDialogShowing) return;
    if (_sessionChecked && !forceCheck) return;

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Ensure fetch settings are configured
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      // Fetch and activate latest values from Firebase
      await remoteConfig
          .fetchAndActivate()
          .timeout(const Duration(seconds: 4), onTimeout: () => false);

      // Read remote values
      final showUpdateDialogFlag = remoteConfig.getBool(keyShowUpdateDialog);
      final latestVersion = remoteConfig.getString(keyLatestVersion).trim();
      final minRequiredVersion =
          remoteConfig.getString(keyMinRequiredVersion).trim();
      final forceUpdateFlag = remoteConfig.getBool(keyForceUpdate);
      final updateTitle = remoteConfig.getString(keyUpdateTitle).trim();
      final updateMessage = remoteConfig.getString(keyUpdateMessage).trim();
      final androidUrl = remoteConfig.getString(keyUpdateUrlAndroid).trim();
      final iosUrl = remoteConfig.getString(keyUpdateUrlIos).trim();

      log(
        '📦 Remote Config Check: Current: $currentAppVersion | Latest: $latestVersion | ShowFlag: $showUpdateDialogFlag | Min: $minRequiredVersion | Force: $forceUpdateFlag',
      );

      // Check whether an update should be displayed:
      // 1. If show_update_dialog is true
      // 2. OR latest_version > currentAppVersion
      final isNewerVersion = latestVersion.isNotEmpty &&
          compareVersions(latestVersion, currentAppVersion) > 0;
      final shouldShow = showUpdateDialogFlag || isNewerVersion;

      if (!shouldShow) {
        log('✅ App is up to date ($currentAppVersion)');
        _sessionChecked = true;
        return;
      }

      // Determine if update is forced (no "Later" button, cannot dismiss):
      // 1. Current version is strictly less than min_required_version
      // 2. OR force_update flag is true
      bool isForce = false;
      if (minRequiredVersion.isNotEmpty &&
          compareVersions(minRequiredVersion, currentAppVersion) > 0) {
        isForce = true;
      } else if (forceUpdateFlag) {
        isForce = true;
      }

      if (!context.mounted) {
        log('⚠️ Context not mounted, skipping dialog presentation');
        return;
      }

      _sessionChecked = true;

      final storeUrl = defaultTargetPlatform == TargetPlatform.iOS
          ? (iosUrl.isNotEmpty ? iosUrl : defaultIosUrl)
          : (androidUrl.isNotEmpty ? androidUrl : defaultAndroidUrl);

      final displayNewVersion =
          latestVersion.isNotEmpty ? latestVersion : currentAppVersion;

      await _showUpdateDialog(
        context: context,
        isForce: isForce,
        title: updateTitle.isNotEmpty ? updateTitle : 'Update Available',
        message: updateMessage.isNotEmpty
            ? updateMessage
            : 'A new version of the app is available. Please update now to enjoy the latest features.',
        storeUrl: storeUrl,
        newVersion: displayNewVersion,
        currentVersion: currentAppVersion,
      );
    } catch (e, st) {
      log('❌ UpdateService error: $e');
      log('Stack trace: $st');
    }
  }

  /// Compares two version strings (supports semantic versions and optional +buildNumber)
  /// Returns:
  ///   > 0 if v1 > v2
  ///   < 0 if v1 < v2
  ///   == 0 if v1 == v2
  static int compareVersions(String v1, String v2) {
    try {
      final v1Parts = v1.trim().split('+');
      final v2Parts = v2.trim().split('+');

      final v1Core =
          v1Parts[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2Core =
          v2Parts[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen =
          v1Core.length > v2Core.length ? v1Core.length : v2Core.length;
      for (int i = 0; i < maxLen; i++) {
        final n1 = i < v1Core.length ? v1Core[i] : 0;
        final n2 = i < v2Core.length ? v2Core[i] : 0;
        if (n1 != n2) {
          return n1.compareTo(n2);
        }
      }

      // If semantic versions are identical, compare build number if available
      final b1 = v1Parts.length > 1 ? (int.tryParse(v1Parts[1]) ?? 0) : 0;
      final b2 = v2Parts.length > 1 ? (int.tryParse(v2Parts[1]) ?? 0) : 0;
      return b1.compareTo(b2);
    } catch (e) {
      log('⚠️ Error comparing versions "$v1" and "$v2": $e');
      return 0;
    }
  }

  /// Launch store URL
  static Future<void> _launchStore(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('❌ Failed to launch store URL ($url): $e');
    }
  }

  /// Show modern, branded update dialog
  static Future<void> _showUpdateDialog({
    required BuildContext context,
    required bool isForce,
    required String title,
    required String message,
    required String storeUrl,
    required String newVersion,
    required String currentVersion,
  }) async {
    _isDialogShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (dialogContext) {
        return PopScope(
          canPop: !isForce,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App / Update Icon with Gradient background
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: Constants.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Constants.maincolor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Version badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildVersionBadge(
                        label: 'v$currentVersion',
                        color: Colors.grey.shade600,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      _buildVersionBadge(
                        label: 'v$newVersion',
                        color: Constants.maincolor,
                        backgroundColor:
                            Constants.maincolor.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description / Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(dialogContext).brightness ==
                              Brightness.dark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                      height: 1.4,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      if (!isForce) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text(
                              'Later',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.maincolor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await _launchStore(storeUrl);
                          },
                          child: const Text(
                            'Update Now',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _isDialogShowing = false;
  }

  static Widget _buildVersionBadge({
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
