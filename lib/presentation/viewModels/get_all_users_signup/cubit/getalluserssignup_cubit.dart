import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/all_users_model_for_add_users.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_for_signup_api_service.dart';

part 'getalluserssignup_state.dart';

class GetalluserssignupCubit extends Cubit<GetalluserssignupState> {
  final GetAllUsersForSignupApiService _apiService;

  GetalluserssignupCubit(this._apiService) : super(GetalluserssignupInitial());

  Future<void> fetchUsers() async {
    emit(GetalluserssignupLoading());
    try {
      final users = await _apiService.getUsers();
      if (users != null) {
        emit(GetalluserssignupSuccess(users));
      } else {
        emit(GetalluserssignupFailure("No users found"));
      }
    } catch (e) {
      emit(GetalluserssignupFailure(e.toString()));
    }
  }
}
