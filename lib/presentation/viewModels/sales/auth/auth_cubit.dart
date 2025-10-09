// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/login_api_service.dart';
import 'package:homewalkers_app/data/models/login_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/auth/auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginApiService apiService;

  AuthCubit(this.apiService) : super(AuthInitial());

  // 🔐 تسجيل الدخول
  void login(String email, String password, BuildContext context) async {
    emit(AuthLoading());
    try {
      final response = await apiService.login(email, password, context);
      emit(AuthSuccess(response as LoginResponse));
    } catch (e) {
      emit(AuthFailure("Incorrect email or password"));
    }
  }

  // 🚪 تسجيل الخروج
  void logout(BuildContext context) async {
    emit(AuthLoading());
    try {
      await apiService.logout(context);
      emit(AuthLogoutSuccess()); // هنعرف استيت جديدة للنجاح
    } catch (e) {
      emit(AuthFailure("Logout failed"));
    }
  }
}