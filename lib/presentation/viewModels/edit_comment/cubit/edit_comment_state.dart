part of 'edit_comment_cubit.dart';

abstract class EditCommentState extends Equatable {
  const EditCommentState();

  @override
  List<Object> get props => [];
}

class EditCommentInitial extends EditCommentState {}

class EditCommentLoading extends EditCommentState {}

class EditCommentSuccess extends EditCommentState {}

class EditCommentFailure extends EditCommentState {
  final String error;

  const EditCommentFailure(this.error);

  @override
  List<Object> get props => [error];
}
