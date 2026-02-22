part of 'get_leads_cubit.dart';

@immutable
sealed class GetLeadsState {}

final class GetLeadsInitial extends GetLeadsState {}

final class GetLeadsLoading extends GetLeadsState {}

final class GetLeadsSuccess extends GetLeadsState {
  final LeadResponse assignedModel;

  GetLeadsSuccess(this.assignedModel);
}

final class GetLeadsError extends GetLeadsState {
  final String message;

  GetLeadsError(this.message);
}

class GetStageCountSuccess extends GetLeadsState {
  final Map<String, int> stageCounts;

  GetStageCountSuccess(this.stageCounts);
}

final class GetSalesLeadsWithPaginationLoading extends GetLeadsState {}

final class GetSalesLeadsWithPaginationSuccess extends GetLeadsState {
  final Salesleadsmodelwithpagination model;

  GetSalesLeadsWithPaginationSuccess(this.model);
}

final class GetSalesLeadsWithPaginationError extends GetLeadsState {
  final String message;

  GetSalesLeadsWithPaginationError(this.message);
}

final class GetSalesLeadsWithPaginationEmpty extends GetLeadsState {}

class PostMeetingCommentLoading extends GetLeadsState {}

class PostMeetingCommentSuccess extends GetLeadsState {
  final String message;
  PostMeetingCommentSuccess(this.message);
}

class PostMeetingCommentError extends GetLeadsState {
  final String error;
  PostMeetingCommentError(this.error);
}
