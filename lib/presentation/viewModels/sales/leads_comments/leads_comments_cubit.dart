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
    emit(LeadCommentsLoading()); // أو تقدر تعمل حالة مخصصة لو حبيت
    try {
      final assigned = await apiService.fetchLeadAssigned(id);
      emit(LeadAssignedLoaded(assigned));
    } catch (e) {
      emit(LeadCommentsError(e.toString()));
    }
  }
}
