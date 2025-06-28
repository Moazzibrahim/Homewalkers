import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
  AddUserCubit() : super(AddUserInitial());

  Future<void> signupUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String role,
  }) async {
    emit(AddUserLoading());

    final String url = 'https://apirender8.onrender.com/api/v1/Signup';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'role': role,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        emit(AddUserSuccess(message: 'User added successfully', data: responseData));
      } else {
        emit(AddUserError(message: 'Failed: ${response.body}'));
      }
    } catch (e) {
      emit(AddUserError(message: 'Error: $e'));
    }
  }
}
