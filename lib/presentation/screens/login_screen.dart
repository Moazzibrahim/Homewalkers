// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
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
  final LoginApiService apiService = LoginApiService();

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(apiService),
      child: Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Constants.backgroundlightmode
                : Constants.backgroundDarkmode,
        body: Stack(
          children: [
            // الخلفية
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/background.png',
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    color: Color(0xFFF6F3EC), // الخلفية السفلية
                  ),
                ),
              ],
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // بطاقة كاملة في المنتصف
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.only(
                        right: 16,
                        left: 16,
                        top: 32,
                        bottom: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      width: 350,
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
                              errorMessage =
                                  state.message; // يمكنك تخصيصها حسب الرسالة
                            });
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "LOGO",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30,
                                    color: Constants.maincolor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Center(
                                child: Text(
                                  "Let’s Login to Your\nAccount First!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff222222),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email Field
                              const Text(
                                "Email Address",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff222222),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: emailController,
                                style: TextStyle(color: Color(0xff7F8689)),
                                onChanged: (value) {
                                  setState(() {
                                    isEmailValid = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}',
                                    ).hasMatch(value);
                                    isEmailError =
                                        false; // عند الكتابة نلغي الخطأ
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'example@gmail.com',
                                  hintStyle: const TextStyle(
                                    color: Color(0xff7F8689),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.mail_outline,
                                    color: Color(0xff7F8689),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          Constants
                                              .maincolor, // ← لما يتم التركيز
                                      width: 1.5,
                                    ),
                                  ),
                                  errorText:
                                      isEmailError
                                          ? errorMessage // أو "Invalid email or password"
                                          : (!isEmailValid
                                              ? "Invalid Email Address"
                                              : null),
                                  errorStyle: const TextStyle(
                                    color: Color(0xffFF0000),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xffFF0000),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Password Field
                              const Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff222222),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: passwordController,
                                style: TextStyle(color: Color(0xff7F8689)),
                                obscureText: !isPasswordVisible,
                                onChanged: (_) {
                                  setState(() {
                                    isPasswordError = false;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "••••••••",
                                  hintStyle: TextStyle(
                                    color: Color(0xff7F8689),
                                  ),
                                  suffixIcon: IconButton(
                                    color: const Color(0xff7F8689),
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          Constants
                                              .maincolor, // ← لما يتم التركيز
                                      width: 1.5,
                                    ),
                                  ),
                                  errorText:
                                      isPasswordError ? errorMessage : null,
                                  errorStyle: const TextStyle(
                                    color: Color(0xffFF0000),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xffFF0000),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Remember Me
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Color(0xffD4E3FF),
                                    activeColor: Constants.maincolor,
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Remember me",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff222222),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constants.maincolor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
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
                                  child:
                                      state is AuthLoading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            "Login",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
