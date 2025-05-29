abstract class ChangeStageState {}

class ChangeStageInitial extends ChangeStageState {}

class ChangeStageLoading extends ChangeStageState {}

class ChangeStageSuccess extends ChangeStageState {
  final String message;
  ChangeStageSuccess(this.message);
}

class ChangeStageError extends ChangeStageState {
  final String error;
  ChangeStageError(this.error);
}
