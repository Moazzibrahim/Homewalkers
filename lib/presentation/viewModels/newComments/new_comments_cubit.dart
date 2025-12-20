import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/newCommentsApiService.dart';
import 'package:homewalkers_app/data/models/newCommentsModel.dart';
import 'package:homewalkers_app/presentation/viewModels/newComments/new_comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final Newcommentsapiservice apiService;

  CommentsCubit(this.apiService) : super(CommentsInitial());

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  final List<Commentt> _comments = [];

  /// 🔹 Fetch first page / refresh
  Future<void> fetchComments({
    required String leadId,
    required String userId,
    bool reset = false,
  }) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _comments.clear();
    }

    _isLoading = true;
    emit(CommentsLoading());

    try {
      final response = await apiService.fetchLeadComments(
        leadId: leadId,
        userId: userId,
        page: _currentPage,
      );

      final newComments = response.comments ?? [];

      _comments.addAll(newComments);
      _hasMore = response.pagination?.hasNext ?? false;
      _currentPage++;

      emit(
        CommentsLoaded(
          comments: List.unmodifiable(_comments),
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      emit(CommentsError(e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  /// 🔹 Load more (pagination)
  Future<void> loadMoreComments({
    required String leadId,
    required String userId,
  }) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    emit(CommentsLoadingMore());

    try {
      final response = await apiService.fetchLeadComments(
        leadId: leadId,
        userId: userId,
        page: _currentPage,
      );

      final newComments = response.comments ?? [];

      _comments.addAll(newComments);
      _hasMore = response.pagination?.hasNext ?? false;
      _currentPage++;

      emit(
        CommentsLoaded(
          comments: List.unmodifiable(_comments),
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      emit(CommentsError(e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  void clear() {
    _currentPage = 1;
    _hasMore = true;
    _comments.clear();
    emit(CommentsInitial());
  }
}
