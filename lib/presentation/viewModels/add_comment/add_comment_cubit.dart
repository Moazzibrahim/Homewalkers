// add_comment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/add_comment_api_service.dart';
import 'add_comment_state.dart';

class AddCommentCubit extends Cubit<AddCommentState> {
  AddCommentCubit() : super(AddCommentInitial());

  Future<void> addComment({
    required String sales,
    required String text1,
    required String text2,
    required String date,
    required String leed,
    required String userlog,
    required String usernamelog,
  }) async {
    emit(AddCommentLoading());

    try {
      final response = await AddCommentApiService.addComment(
        sales: sales,
        text1: text1,
        text2: text2,
        date: date,
        leed: leed,
        userlog: userlog,
        usernamelog: usernamelog,
      );

      if (response != null) {
        emit(AddCommentSuccess(response));
      } else {
        emit(AddCommentError(" Failed to add comment"));
      }
    } catch (e) {
      emit(AddCommentError(e.toString()));
    }
  }
}
