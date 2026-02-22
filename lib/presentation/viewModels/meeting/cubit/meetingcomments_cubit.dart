import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/meeting/get_meeting_comments.dart';
import 'package:homewalkers_app/data/models/meetingComments_model.dart';
import 'package:homewalkers_app/presentation/viewModels/meeting/cubit/meetingcomments_state.dart';

class MeetingCommentsCubit extends Cubit<MeetingCommentsState> {
  final MeetingCommentsApiService apiService;

  MeetingCommentsCubit(this.apiService) : super(MeetingCommentsInitial());

  int currentPage = 1;
  bool isFetching = false;
  bool hasNextPage = true;

  final List<LeadHistoryData> allComments = [];

  Future<void> fetchMeetingComments({
    int limit = 10,
    String? stageIds,
    String? salesDeveloperIds,
    String? leadNames,
    String? phones,
    String? sales,
    String? stageDateFrom,
    String? stageDateTo,
    String? commentCreatedFrom,
    String? commentCreatedTo,
    String? userId,
    bool isLoadMore = false,
  }) async {
    if (isFetching) return;

    if (!isLoadMore) {
      emit(MeetingCommentsLoading());
      currentPage = 1;
      hasNextPage = true;
      allComments.clear();
    } else {
      if (!hasNextPage) return;
      emit(MeetingCommentsPaginationLoading());
    }

    try {
      isFetching = true;

      final MeetingcommentsModel response = await apiService
          .fetchMeetingComments(
            page: currentPage,
            limit: limit,
            stageIds: stageIds,
            salesDeveloperIds: salesDeveloperIds,
            leadNames: leadNames,
            phones: phones,
            sales: sales,
            stageDateFrom: stageDateFrom,
            stageDateTo: stageDateTo,
            commentCreatedFrom: commentCreatedFrom,
            commentCreatedTo: commentCreatedTo,
            userId: userId,
          );

      final newData = response.data ?? [];

      allComments.addAll(newData);

      hasNextPage = response.pagination?.hasNextPage ?? false;

      currentPage++;

      emit(MeetingCommentsSuccess(model: response, hasNextPage: hasNextPage));
    } catch (e) {
      emit(MeetingCommentsFailure(e.toString()));
    } finally {
      isFetching = false;
    }
  }

  Future<void> refresh({required String token}) async {
    await fetchMeetingComments(isLoadMore: false);
  }
}
