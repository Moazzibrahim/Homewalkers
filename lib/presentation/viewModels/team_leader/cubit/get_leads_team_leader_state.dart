part of 'get_leads_team_leader_cubit.dart';

sealed class GetLeadsTeamLeaderState extends Equatable {
  const GetLeadsTeamLeaderState();

  @override
  List<Object> get props => [];
}

final class GetLeadsTeamLeaderInitial extends GetLeadsTeamLeaderState {}

final class GetLeadsTeamLeaderLoading extends GetLeadsTeamLeaderState {}

final class GetLeadsTeamLeaderSuccess extends GetLeadsTeamLeaderState {
  final LeadResponse leadsData;

  const GetLeadsTeamLeaderSuccess(this.leadsData);

  @override
  List<Object> get props => [leadsData];
}

final class GetLeadsTeamLeaderError extends GetLeadsTeamLeaderState {
  final String message;

  const GetLeadsTeamLeaderError(this.message);

  @override
  List<Object> get props => [message];
}

class GetLeadsTeamLeaderStageCountLoaded extends GetLeadsTeamLeaderState {
  final Map<String, int> stageCounts;

  const GetLeadsTeamLeaderStageCountLoaded(this.stageCounts);

  @override
  List<Object> get props => [stageCounts];
}

// ✅ ============ STATES FOR PAGINATION ============

/// 🟢 حالة تحميل البيانات لأول مرة أو عند التحديث
final class GetLeadsTeamLeaderPaginationLoading extends GetLeadsTeamLeaderState {}

/// 🟢 حالة نجاح تحميل البيانات مع وجود بيانات
final class GetLeadsTeamLeaderPaginationSuccess extends GetLeadsTeamLeaderState {
  final TeamleaderPaginationLeadsModel model;

  const GetLeadsTeamLeaderPaginationSuccess(this.model);

  @override
  List<Object> get props => [model];
}

/// 🟢 حالة عدم وجود بيانات (فارغة)
final class GetLeadsTeamLeaderPaginationEmpty extends GetLeadsTeamLeaderState {}

/// 🔴 حالة حدوث خطأ في تحميل البيانات
final class GetLeadsTeamLeaderPaginationError extends GetLeadsTeamLeaderState {
  final String message;

  const GetLeadsTeamLeaderPaginationError(this.message);

  @override
  List<Object> get props => [message];
}

/// 🟡 حالة تحميل المزيد من البيانات (للاستخدام الداخلي أو UI)
/// (اختياري - يمكن استخدام isFetchingMore بدلاً من هذه الحالة)
final class GetLeadsTeamLeaderLoadingMore extends GetLeadsTeamLeaderState {}

// في ملف get_leads_team_leader_state.dart
class GetLeadsTeamLeaderPaginationLoadingMore extends GetLeadsTeamLeaderState {
  final TeamleaderPaginationLeadsModel currentData;
  
  GetLeadsTeamLeaderPaginationLoadingMore({required this.currentData});
}