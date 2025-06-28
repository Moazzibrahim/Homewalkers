part of 'getalluserssignup_cubit.dart';

abstract class GetalluserssignupState extends Equatable {
  const GetalluserssignupState();

  @override
  List<Object?> get props => [];
}

class GetalluserssignupInitial extends GetalluserssignupState {}

class GetalluserssignupLoading extends GetalluserssignupState {}

class GetalluserssignupSuccess extends GetalluserssignupState {
  final AllUsersModelForAddUsers users;

  const GetalluserssignupSuccess(this.users);

  @override
  List<Object?> get props => [users];
}

class GetalluserssignupFailure extends GetalluserssignupState {
  final String message;

  const GetalluserssignupFailure(this.message);

  @override
  List<Object?> get props => [message];
}
