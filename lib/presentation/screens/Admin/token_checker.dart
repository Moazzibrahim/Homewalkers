import 'package:flutter/material.dart';
import 'package:homewalkers_app/presentation/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProtectedScreenWrapper extends StatefulWidget {
  final Widget child;
  const ProtectedScreenWrapper({required this.child, super.key});

  @override
  State<ProtectedScreenWrapper> createState() => _ProtectedScreenWrapperState();
}

class _ProtectedScreenWrapperState extends State<ProtectedScreenWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkToken();
    }
  }

  Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
