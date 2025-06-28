part of 'add_user_cubit.dart';

abstract class AddUserState extends Equatable {
  const AddUserState();

  @override
  List<Object?> get props => [];
}

class AddUserInitial extends AddUserState {}

class AddUserLoading extends AddUserState {}

class AddUserSuccess extends AddUserState {
  final String message;
  final Map<String, dynamic> data;

  const AddUserSuccess({required this.message, required this.data});

  @override
  List<Object?> get props => [message, data];
}

class AddUserError extends AddUserState {
  final String message;

  const AddUserError({required this.message});

  @override
  List<Object?> get props => [message];
}
