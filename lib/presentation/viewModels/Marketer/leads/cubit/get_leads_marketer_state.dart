part of 'get_leads_marketer_cubit.dart';

sealed class GetLeadsMarketerState extends Equatable {
  const GetLeadsMarketerState();

  @override
  List<Object> get props => [];
}

final class GetLeadsMarketerInitial extends GetLeadsMarketerState {}

final class GetLeadsMarketerLoading extends GetLeadsMarketerState {}

final class GetLeadsMarketerSuccess extends GetLeadsMarketerState {
  final LeadResponse leadsResponse;
  const GetLeadsMarketerSuccess(this.leadsResponse);

  @override
  List<Object> get props => [leadsResponse];
}

final class GetLeadsMarketerFailure extends GetLeadsMarketerState {
  final String errorMessage;
  const GetLeadsMarketerFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

/// ✅ Dashboard States
class GetMarketerDashboardLoading extends GetLeadsMarketerState {}

class GetMarketerDashboardSuccess extends GetLeadsMarketerState {
  final MarketerDashboardModel dashboardModel;
  const GetMarketerDashboardSuccess(this.dashboardModel);

  @override
  List<Object> get props => [dashboardModel];
}

class GetMarketerDashboardFailure extends GetLeadsMarketerState {
  final String message;
  const GetMarketerDashboardFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// ✅ Pagination States
class GetLeadsMarketerPaginationLoading extends GetLeadsMarketerState {
  final bool isLoadingMore;
  final int currentPage;

  const GetLeadsMarketerPaginationLoading({
    required this.isLoadingMore,
    required this.currentPage,
  });

  @override
  List<Object> get props => [isLoadingMore, currentPage];
}

/// ✅ Pagination Success State - يدعم النوعين leads و leadsDatum
class GetLeadsMarketerPaginationSuccess extends GetLeadsMarketerState {
  final NewMarketerPaginationModel paginationModel; // للتوافق مع الكود القديم

  const GetLeadsMarketerPaginationSuccess({required this.paginationModel});

  @override
  List<Object> get props => [paginationModel];
}

/// ✅ Pagination Failure State
class GetLeadsMarketerPaginationFailure extends GetLeadsMarketerState {
  final String message;
  final bool isLoadingMore;

  const GetLeadsMarketerPaginationFailure(
    this.message, {
    required this.isLoadingMore,
  });

  @override
  List<Object> get props => [message, isLoadingMore];
}

/// ✅ Optional: Empty State للـ Pagination (عند عدم وجود بيانات)
class GetLeadsMarketerPaginationEmpty extends GetLeadsMarketerState {
  final String message;

  const GetLeadsMarketerPaginationEmpty([this.message = "لا توجد بيانات"]);

  @override
  List<Object> get props => [message];
}
