import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class NoInternetWrapper extends StatefulWidget {
  final Widget child;
  const NoInternetWrapper({super.key, required this.child});

  @override
  State<NoInternetWrapper> createState() => _NoInternetWrapperState();
}

class _NoInternetWrapperState extends State<NoInternetWrapper>
    with WidgetsBindingObserver {
  bool _isConnected = true;
  int _consecutiveFailures = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    _check();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _check());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ رجعنا من الخلفية: صفّر أي فشل قديم وسيب للشبكة فرصة تصحى
      _consecutiveFailures = 0;
      _stopTimer();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _startTimer();
        _check();
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // ✅ التطبيق في الخلفية: وقف الفحص خالص عشان مايتراكمش failures غلط
      _stopTimer();
    }
  }

  Future<bool> _hasInternet() async {
    for (final host in ['one.one.one.one', 'google.com', 'apple.com']) {
      try {
        final result = await InternetAddress.lookup(
          host,
        ).timeout(const Duration(seconds: 2));
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Future<void> _check() async {
    final connected = await _hasInternet();

    if (connected) {
      _consecutiveFailures = 0;
      if (mounted && !_isConnected) {
        setState(() => _isConnected = true);
      }
      return;
    }

    _consecutiveFailures++;
    if (_consecutiveFailures >= 2 && mounted && _isConnected) {
      setState(() => _isConnected = false);
    }

    if (_consecutiveFailures == 1) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _check();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
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
