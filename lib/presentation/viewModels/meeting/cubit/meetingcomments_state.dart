import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/meetingComments_model.dart';

abstract class MeetingCommentsState extends Equatable {
  const MeetingCommentsState();

  @override
  List<Object?> get props => [];
}

class MeetingCommentsInitial extends MeetingCommentsState {}

class MeetingCommentsLoading extends MeetingCommentsState {}

class MeetingCommentsPaginationLoading extends MeetingCommentsState {}

class MeetingCommentsSuccess extends MeetingCommentsState {
  final MeetingcommentsModel model;
  final bool hasNextPage;

  const MeetingCommentsSuccess({
    required this.model,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [model, hasNextPage];
}

class MeetingCommentsFailure extends MeetingCommentsState {
  final String error;

  const MeetingCommentsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
