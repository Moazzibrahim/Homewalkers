// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:homewalkers_app/presentation/screens/decider_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _taglineAnimation;
  late Animation<double> _bottomAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _iconAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.elasticOut),
    );

    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.35, curve: Curves.easeOut),
    );

    _taglineAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.4, curve: Curves.easeOut),
    );

    _bottomAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.45, curve: Curves.easeOut),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DeciderScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A1D4E),
                  Color(0xFF0D2158),
                  Color(0xFF0E2866),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Geometric shapes ────────────────────────────────────────
          ..._buildGeoShapes(),

          // ── Center content ──────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon box ──
                ScaleTransition(
                  scale: _iconAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Image.asset(
                        'assets/images/icon.jpeg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App name
                FadeTransition(
                  opacity: _textAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_textAnimation),
                    child: const Text(
                      'Realatix CRM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Divider
                FadeTransition(
                  opacity: _textAnimation,
                  child: Container(
                    width: 32,
                    height: 2,
                    color: Color(0xffB0C6FF),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                FadeTransition(
                  opacity: _taglineAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_taglineAnimation),
                    child: Text(
                      'Architectural Precision in Asset\nManagement.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom section ───────────────────────────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _bottomAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  children: [
                    // "Initializing..." label
                    Text(
                      'INITIALIZING CORE INFRASTRUCTURE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(active: true),
                        const SizedBox(width: 5),
                        _dot(active: true),
                        const SizedBox(width: 5),
                        _dot(active: false),
                      ],
                    ),

                    const SizedBox(height: 11),

                    // Progress bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder:
                          (_, __) => Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            ),
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

  Widget _dot({required bool active}) => Container(
    width: 5,
    height: 5,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(active ? 0.85 : 0.3),
    ),
  );

  List<Widget> _buildGeoShapes() {
    final shapeStyle = BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: const Color(0xFF1E3C8C).withOpacity(0.35),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    );
    return [
      Positioned(
        top: -60,
        right: -80,
        child: Transform.rotate(
          angle: 0.44,
          child: Container(width: 260, height: 300, decoration: shapeStyle),
        ),
      ),
      Positioned(
        top: 20,
        left: -90,
        child: Transform.rotate(
          angle: -0.26,
          child: Container(width: 200, height: 240, decoration: shapeStyle),
        ),
      ),
      Positioned(
        top: 100,
        right: -50,
        child: Transform.rotate(
          angle: 0.7,
          child: Container(
            width: 220,
            height: 180,
            decoration: shapeStyle.copyWith(
              color: const Color(0xFF193780).withOpacity(0.25),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 120,
        left: -30,
        child: Transform.rotate(
          angle: 0.17,
          child: Container(
            width: 150,
            height: 200,
            decoration: shapeStyle.copyWith(
              color: const Color(0xFF122D78).withOpacity(0.2),
            ),
          ),
        ),
      ),
    ];
  }
}
