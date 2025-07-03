import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/edit_comment_api_service.dart';

part 'edit_comment_state.dart';

class EditCommentCubit extends Cubit<EditCommentState> {
  final EditCommentApiService apiService;

  EditCommentCubit(this.apiService) : super(EditCommentInitial());

  Future<bool> editComment({
    required String commentId,
    required String firstText,
    required String secondText,
  }) async {
    emit(EditCommentLoading());

    final success = await apiService.editComment(
      commentId: commentId,
      firstText: firstText,
      secondText: secondText,
    );

    if (success) {
      emit(EditCommentSuccess());
      return true;
    } else {
      emit(EditCommentFailure('فشل تعديل التعليق'));
      return false;
    }
  }
}

