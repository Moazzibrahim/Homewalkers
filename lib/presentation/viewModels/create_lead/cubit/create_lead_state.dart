part of 'create_lead_cubit.dart';

abstract class CreateLeadState extends Equatable {
  const CreateLeadState();

  @override
  List<Object> get props => [];
}

class CreateLeadInitial extends CreateLeadState {}

class CreateLeadLoading extends CreateLeadState {}

class CreateLeadSuccess extends CreateLeadState {
  final String message;

  const CreateLeadSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CreateLeadFailure extends CreateLeadState {
  final String error;

  const CreateLeadFailure(this.error);

  @override
  List<Object> get props => [error];
}
