part of 'stages_cubit.dart';

@immutable
abstract class StagesState {}

class StagesInitial extends StagesState {}

class StagesLoading extends StagesState {}

class StagesLoaded extends StagesState {
  final List<StageData> stages;

  StagesLoaded(this.stages);
}

class StagesError extends StagesState {
  final String message;

  StagesError(this.message);
}
