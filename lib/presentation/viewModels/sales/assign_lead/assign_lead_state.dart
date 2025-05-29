// assign_state.dart
abstract class AssignState {}

class AssignInitial extends AssignState {}

class AssignLoading extends AssignState {}

class AssignSuccess extends AssignState {}

class AssignFailure extends AssignState {
  final String error;
  AssignFailure(this.error);
}
