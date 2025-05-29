import 'package:homewalkers_app/data/models/regions_model.dart';

abstract class RegionState {}

class RegionInitial extends RegionState {}

class RegionLoading extends RegionState {}

class RegionLoaded extends RegionState {
  final RegionsModel regions;

  RegionLoaded(this.regions);
}

class RegionError extends RegionState {
  final String message;

  RegionError(this.message);
}
