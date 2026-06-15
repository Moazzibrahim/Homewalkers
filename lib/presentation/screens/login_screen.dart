// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  bool isPasswordVisible = false;
  bool isEmailValid = true;
  bool isEmailError = false;
  bool isPasswordError = false;
  String errorMessage = '';
  // final LoginApiService apiService = LoginApiService();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final savedRememberMe = prefs.getBool('remember_me') ?? false;
    if (savedRememberMe) {
      setState(() {
        rememberMe = true;
        emailController.text = savedEmail ?? '';
        passwordController.text = savedPassword ?? '';
      });
    }
  }

  // ── Dark navy colors ──────────────────────────────────────────
  static const Color _bgDark = Color(0xFF0D1B3E);
  static const Color _cardBg = Color(0xFF112044);
  static const Color _fieldBg = Color(0xFF162654);
  static const Color _borderColor = Color(0xFF1E3366);
  static const Color _accentBlue = Color(0xFF3B6FE8);
  static const Color _labelColor = Color(0xFF7A9CC6);
  static const Color _textColor = Color(0xFFCDD9F0);
  static const Color _hintColor = Color(0xFF4A6A9A);

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData suffixIcon,
    Widget? suffixWidget,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hintColor, fontSize: 14),
      filled: true,
      fillColor: _fieldBg,
      suffixIcon: suffixWidget ?? Icon(suffixIcon, color: _hintColor, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accentBlue, width: 1.5),
      ),
      errorText: errorText,
      errorStyle: const TextStyle(color: Color(0xffFF6B6B)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xffFF6B6B), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xffFF6B6B), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(LoginApiService()),
      child: Scaffold(
        backgroundColor: _bgDark,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // ── Logo area ──────────────────────────────────
                    const SizedBox(height: 80),
                    Image.asset(
                      "assets/images/logo_transparent.png",
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 15),
                    // ── Card ───────────────────────────────────────
                    Container(
                      margin: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                      ), // بدون margin جانبي
                      padding: const EdgeInsets.only(
                        top: 32,
                        bottom: 0,
                        right: 3,
                        left: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        border: Border.all(color: _borderColor),
                      ),
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Welcome ${state.loginResponse.user.name}',
                                ),
                              ),
                            );
                          } else if (state is AuthFailure) {
                            setState(() {
                              isEmailError = true;
                              isPasswordError = true;
                              errorMessage = state.message;
                            });
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Eyebrow label ──────────────────
                              Text(
                                "EXECUTIVE ACCESS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _labelColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // ── Title ──────────────────────────
                              const Text(
                                "Sign in to Realatix",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // ── Email label ────────────────────
                              const Text(
                                "EMAIL ADDRESS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _labelColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: emailController,
                                style: const TextStyle(
                                  color: _textColor,
                                  fontSize: 14,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    isEmailValid = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}',
                                    ).hasMatch(value);
                                    isEmailError = false;
                                  });
                                },
                                decoration: _fieldDecoration(
                                  hint: 'example@homewalkers.com',
                                  suffixIcon: Icons.mail_outline,
                                  errorText:
                                      isEmailError
                                          ? errorMessage
                                          : (!isEmailValid
                                              ? "Invalid Email Address"
                                              : null),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Password label ─────────────────
                              const Text(
                                "SECURITY KEY",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _labelColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: passwordController,
                                style: const TextStyle(
                                  color: _textColor,
                                  fontSize: 14,
                                ),
                                obscureText: !isPasswordVisible,
                                onChanged: (_) {
                                  setState(() {
                                    isPasswordError = false;
                                  });
                                },
                                decoration: _fieldDecoration(
                                  hint: "••••••••",
                                  suffixIcon: Icons.visibility,
                                  suffixWidget: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: _hintColor,
                                      size: 20,
                                    ),
                                    onPressed:
                                        () => setState(() {
                                          isPasswordVisible =
                                              !isPasswordVisible;
                                        }),
                                  ),
                                  errorText:
                                      isPasswordError ? errorMessage : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Remember me ────────────────────
                              Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: rememberMe,
                                      onChanged:
                                          (value) => setState(() {
                                            rememberMe = value!;
                                          }),
                                      activeColor: _accentBlue,
                                      checkColor: Colors.white,
                                      side: const BorderSide(
                                        color: _accentBlue,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Keep session active",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _textColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // ── Login Button ───────────────────
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (rememberMe) {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                        'saved_email',
                                        emailController.text,
                                      );
                                      await prefs.setString(
                                        'saved_password',
                                        passwordController.text,
                                      );
                                      await prefs.setBool('remember_me', true);
                                    } else {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.remove('saved_email');
                                      await prefs.remove('saved_password');
                                      await prefs.setBool('remember_me', false);
                                    }
                                    context.read<AuthCubit>().login(
                                      emailController.text,
                                      passwordController.text,
                                      context,
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 58,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF0D47A1),
                                          Color(0xFF003178),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(
                                          19,
                                        ), // ✅ أسفل بس
                                        bottomRight: Radius.circular(
                                          19,
                                        ), // ✅ أسفل بس
                                        topLeft: Radius.circular(
                                          0,
                                        ), // ❌ فوق مستقيم
                                        topRight: Radius.circular(
                                          0,
                                        ), // ❌ فوق مستقيم
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFF1E4FA0),
                                        width: 1,
                                      ),
                                    ),
                                    child:
                                        state is AuthLoading
                                            ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "ENTER WORKSPACE",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
