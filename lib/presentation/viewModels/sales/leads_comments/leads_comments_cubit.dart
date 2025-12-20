// --- Cubit ---
// ignore_for_file: avoid_print

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
      await apiService.postReply(commentId: commentId, replyText: replyText);
      emit(ReplySentSuccessfully());
    } catch (e) {
      emit(LeadCommentsError('Failed to send reply: $e'));
    }
  }

  Future<void> fetchAllLeadData(String leedId) async {
    print("[Cubit] fetchAllLeadData called for: $leedId");
    emit(LeadCommentsLoading());
    try {
      final assigned = await apiService.fetchLeadAssigned(leedId);
      print("[Cubit] Lead assigned data fetched: ${assigned.data?.length}");
      final comments = await apiService.fetchActionData(leedId: leedId);
      print("[Cubit] Lead comments data fetched: ${comments.data?.length}");
      emit(LeadCommentsFullLoaded(comments: comments, assigned: assigned));
      print("[Cubit] Emit LeadCommentsFullLoaded done");
    } catch (e) {
      print("[Cubit] Error fetching lead data: $e");
      emit(LeadCommentsError(e.toString()));
    }
  }
}
