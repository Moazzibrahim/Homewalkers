import 'package:homewalkers_app/data/models/assign_history_model.dart';
import 'package:homewalkers_app/data/models/leadsAdminModelWithPagination.dart';

abstract class AllLeadsState {}

class AllLeadsInitial extends AllLeadsState {}

/// ================= Active =================
class AllLeadsLoading extends AllLeadsState {}

class AllLeadsLoaded extends AllLeadsState {
  final Leadsadminmodelwithpagination leadsData;
  final bool hasMore;

  AllLeadsLoaded(this.leadsData, this.hasMore);
}

class AllLeadsError extends AllLeadsState {
  final String message;
  AllLeadsError(this.message);
}

/// ================= Trash =================
class AllLeadsTrashLoading extends AllLeadsState {}

class AllLeadsTrashLoaded extends AllLeadsState {
  final Leadsadminmodelwithpagination leadsData;
  AllLeadsTrashLoaded(this.leadsData);
}

class AllLeadsTrashError extends AllLeadsState {
  final String message;
  AllLeadsTrashError(this.message);
}

// ─── Assign History States ───
class AssignHistoryLoading extends AllLeadsState {}

class AssignHistoryLoaded extends AllLeadsState {
  final AssignHistoryResponse response;
  AssignHistoryLoaded(this.response);
}

class AssignHistoryError extends AllLeadsState {
  final String message;
  AssignHistoryError(this.message);
}
