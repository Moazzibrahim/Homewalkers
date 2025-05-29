import 'package:homewalkers_app/data/models/login_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponse loginResponse;
  AuthSuccess(this.loginResponse);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
