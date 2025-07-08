
abstract class AddCommentState {}

class AddCommentInitial extends AddCommentState {}

class AddCommentLoading extends AddCommentState {}

class AddCommentSuccess extends AddCommentState {
  final dynamic response;
  AddCommentSuccess(this.response);
}

class AddCommentError extends AddCommentState {
  final String message;
  AddCommentError(this.message);
}
