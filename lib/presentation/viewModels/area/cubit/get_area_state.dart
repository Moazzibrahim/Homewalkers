part of 'get_area_cubit.dart';

abstract class GetAreaState extends Equatable {
  const GetAreaState();

  @override
  List<Object?> get props => [];
}

class GetAreaInitial extends GetAreaState {}

class GetAreaLoading extends GetAreaState {}

class GetAreaLoaded extends GetAreaState {
  final List<AreaData> areas;

  const GetAreaLoaded(this.areas);

  @override
  List<Object?> get props => [areas];
}

class GetAreaError extends GetAreaState {
  final String message;

  const GetAreaError(this.message);

  @override
  List<Object?> get props => [message];
}
