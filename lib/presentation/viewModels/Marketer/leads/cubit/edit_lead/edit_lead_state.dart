part of 'edit_lead_cubit.dart';

abstract class EditLeadState extends Equatable {
  const EditLeadState();

  @override
  List<Object> get props => [];
}

class EditLeadInitial extends EditLeadState {}

class EditLeadLoading extends EditLeadState {}

class EditLeadSuccess extends EditLeadState {}

class EditLeadFailure extends EditLeadState {
  final String error;

  const EditLeadFailure({required this.error});

  @override
  List<Object> get props => [error];
}
