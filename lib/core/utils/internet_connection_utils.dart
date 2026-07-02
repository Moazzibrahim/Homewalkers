import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class NoInternetWrapper extends StatefulWidget {
  final Widget child;
  const NoInternetWrapper({super.key, required this.child});

  @override
  State<NoInternetWrapper> createState() => _NoInternetWrapperState();
}

class _NoInternetWrapperState extends State<NoInternetWrapper> {
  bool _isConnected = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _check());
  }

  Future<void> _check() async {
    bool connected = false;
    for (final host in ['one.one.one.one', 'google.com', 'apple.com']) {
      try {
        final result = await InternetAddress.lookup(
          host,
        ).timeout(const Duration(seconds: 2));
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          connected = true;
          break;
        }
      } catch (_) {
        continue;
      }
    }
    if (mounted && connected != _isConnected) {
      setState(() => _isConnected = connected);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (!_isConnected)
            Positioned(
              bottom: 500,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  color: const Color(0xFFB00020),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
