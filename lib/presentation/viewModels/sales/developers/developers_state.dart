part of 'developers_cubit.dart';


sealed class DevelopersState {}

final class DevelopersInitial extends DevelopersState {}

final class DeveloperLoading extends DevelopersState {}

final class DeveloperSuccess extends DevelopersState {
  final DevelopersModel developersModel;

  DeveloperSuccess(this.developersModel);
}
final class DeveloperError extends DevelopersState {
  final String error;

  DeveloperError(this.error);
}