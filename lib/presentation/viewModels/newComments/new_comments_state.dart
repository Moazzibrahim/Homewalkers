import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/newCommentsModel.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoadingMore extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<Commentt> comments;
  final bool hasMore;

  const CommentsLoaded({
    required this.comments,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [comments, hasMore];
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object?> get props => [message];
}
