import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/all_users_model.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
part 'get_all_users_state.dart';

class GetAllUsersCubit extends Cubit<GetAllUsersState> {
  final GetAllUsersApiService apiService;

  GetAllUsersCubit(this.apiService) : super(GetAllUsersInitial());

  Future<void> fetchAllUsers() async {
    emit(GetAllUsersLoading());
    final response = await apiService.getUsers();

    if (response != null) {
      emit(GetAllUsersSuccess(response));
    } else {
      emit(GetAllUsersFailure('Failed to fetch users.'));
    }
  }
}
