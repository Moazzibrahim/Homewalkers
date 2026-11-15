import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaConfig {
  // Constants.baseUrl = "https://<domain>/api/v1" -> strip /api/v1 to get the host root.
  // Read on every request, so switching company takes effect immediately.
  static String Function() baseUrl =
      () => Constants.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

  static Future<String?> Function() token = () async {
    final p = await SharedPreferences.getInstance();
    return p.getString('token'); // same key your LoginApiService saves
  };

  static Future<void> Function(String) saveToken = (t) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('token', t);
  };

  static Future<String> Function() deviceId = () async {
    final p = await SharedPreferences.getInstance();
    return p.getString('deviceId') ?? ''; // same key as login
  };
}
