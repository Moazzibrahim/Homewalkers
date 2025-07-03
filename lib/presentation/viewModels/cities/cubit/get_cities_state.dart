part of 'get_cities_cubit.dart';

abstract class GetCitiesState extends Equatable {
  const GetCitiesState();

  @override
  List<Object?> get props => [];
}

class GetCitiesInitial extends GetCitiesState {}

class GetCitiesLoading extends GetCitiesState {}

class GetCitiesSuccess extends GetCitiesState {
  final List<Cityy>? cities;
  final List<Region> ?regions;

  const GetCitiesSuccess({ this.cities,this.regions});

  @override
  List<Object?> get props => [cities];
}

class GetCitiesFailure extends GetCitiesState {
  final String error;

  const GetCitiesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
