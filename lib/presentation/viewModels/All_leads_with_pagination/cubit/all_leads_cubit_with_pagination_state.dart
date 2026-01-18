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
