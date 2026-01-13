part of 'get_all_users_cubit.dart';

abstract class GetAllUsersState extends Equatable {
  const GetAllUsersState();

  @override
  List<Object?> get props => [];
}

class GetAllUsersInitial extends GetAllUsersState {}

class GetAllUsersLoading extends GetAllUsersState {}

class GetAllUsersSuccess extends GetAllUsersState {
  final AllUsersModel users;

  const GetAllUsersSuccess(this.users);

  @override
  List<Object?> get props => [users];
}

class GetAllUsersFailure extends GetAllUsersState {
  final String error;

  const GetAllUsersFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class GetLeadsInTrashLoading extends GetAllUsersState {}

class GetLeadsInTrashSuccess extends GetAllUsersState {
  final LeadResponse leads;

  const GetLeadsInTrashSuccess(this.leads);

  @override
  List<Object?> get props => [leads];
}

class GetLeadsInTrashFailure extends GetAllUsersState {
  final String error;

  const GetLeadsInTrashFailure(this.error);

  @override
  List<Object?> get props => [error];
}
// New state to hold our processed and sorted list
class UsersLeadCountSuccess extends GetAllUsersState {
  final Map<String, int> leadCounts;

  const UsersLeadCountSuccess(this.leadCounts);

  @override
  List<Object> get props => [leadCounts];
}
class StagesStatsLoading extends GetAllUsersState {}

class StagesStatsSuccess extends GetAllUsersState {
  final LeadsStatsModel data;
  const StagesStatsSuccess(this.data);
}

class StagesStatsFailure extends GetAllUsersState {
  final String error;
  const StagesStatsFailure(this.error);
}

/// ✅ State تدل أن كل الـ leads اتحملت (3000) وجاهزة للفلترة
class AllLeadsLoaded extends GetAllUsersState {
  const AllLeadsLoaded();
}

