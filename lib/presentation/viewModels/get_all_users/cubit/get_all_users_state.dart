part of 'get_all_users_cubit.dart';

abstract class GetAllUsersState extends Equatable {
  const GetAllUsersState();

  @override
  List<Object?> get props => [];
}

class GetAllUsersInitial extends GetAllUsersState {}

class GetAllUsersLoading extends GetAllUsersState {}

class GetAllUsersSuccess extends GetAllUsersState {
  final AllUsersModel users;

  const GetAllUsersSuccess(this.users);

  @override
  List<Object?> get props => [users];
}

class GetAllUsersFailure extends GetAllUsersState {
  final String error;

  const GetAllUsersFailure(this.error);

  @override
  List<Object?> get props => [error];
}
