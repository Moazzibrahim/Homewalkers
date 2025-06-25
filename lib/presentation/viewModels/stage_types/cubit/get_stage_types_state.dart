part of 'get_stage_types_cubit.dart';

abstract class GetStageTypesState extends Equatable {
  const GetStageTypesState();

  @override
  List<Object?> get props => [];
}

class GetStageTypesInitial extends GetStageTypesState {}

class GetStageTypesLoading extends GetStageTypesState {}

class GetStageTypesSuccess extends GetStageTypesState {
  final StageTypeResponse response;

  const GetStageTypesSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetStageTypesFailure extends GetStageTypesState {
  final String message;

  const GetStageTypesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
