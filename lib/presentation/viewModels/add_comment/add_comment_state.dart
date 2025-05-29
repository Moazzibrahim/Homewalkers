// add_comment_state.dart
import 'package:homewalkers_app/data/models/add_comment_model.dart';

abstract class AddCommentState {}

class AddCommentInitial extends AddCommentState {}

class AddCommentLoading extends AddCommentState {}

class AddCommentSuccess extends AddCommentState {
  final CommentResponse response;
  AddCommentSuccess(this.response);
}

class AddCommentError extends AddCommentState {
  final String message;
  AddCommentError(this.message);
}
