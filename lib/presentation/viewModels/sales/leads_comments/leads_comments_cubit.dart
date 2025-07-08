// --- Cubit ---
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_all_lead_comments.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/leads_comments/leads_comments_state.dart';

class LeadCommentsCubit extends Cubit<LeadCommentsState> {
  final GetAllLeadCommentsApiService apiService;

  LeadCommentsCubit(this.apiService) : super(LeadCommentsInitial());

  Future<void> fetchLeadComments(String leedId) async {
    emit(LeadCommentsLoading());
    try {
      final data = await apiService.fetchActionData(leedId: leedId);
      emit(LeadCommentsLoaded(data));
    } catch (e) {
      emit(LeadCommentsError(e.toString()));
    }
  }

  Future<void> fetchLeadAssignedData(String id) async {
    try {
      final assigned = await apiService.fetchLeadAssigned(id);
      emit(LeadAssignedLoaded(assigned));
    } catch (e) {
      emit(LeadCommentsError(e.toString()));
    }
  }
  // ✅ إرسال رد من غير ما نعمل تحميل تاني
  Future<void> sendReplyToComment({
    required String commentId,
    required String replyText,
  }) async {
    try {
      await apiService.postReply(
        commentId: commentId,
        replyText: replyText,
      );
      emit(ReplySentSuccessfully());
    } catch (e) {
      emit(LeadCommentsError('Failed to send reply: $e'));
    }
  }
}