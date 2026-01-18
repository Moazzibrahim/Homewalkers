import 'package:bloc/bloc.dart';
import 'package:homewalkers_app/data/data_sources/Admin_with_pagination/fetch_data_with_pagination.dart';
import 'package:homewalkers_app/data/models/leadsAdminModelWithPagination.dart';
import 'package:homewalkers_app/presentation/viewModels/All_leads_with_pagination/cubit/all_leads_cubit_with_pagination_state.dart';

class AllLeadsCubitWithPagination extends Cubit<AllLeadsState> {
  final LeadsApiServiceWithQuery apiService;

  /// ✅ Active leads (متراكمة مع pagination)
  final List<LeadDataWithPagination> leads = [];

  /// 🗑️ Trash leads
  final List<LeadDataWithPagination> trashLeads = [];

  AllLeadsCubitWithPagination(this.apiService) : super(AllLeadsInitial());

  /// =======================
  /// ✅ Active Leads
  /// =======================
  Future<void> fetchLeads({
    int page = 1,
    int limit = 10,
    String? search,
    String? salesId,
    String? developerId,
    String? projectId,
    String? channelId,
    String? campaignId,
    String? communicationWayId,
    String? stageId,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    String? addedById,
    String? assignedFromId,
    String? assignedToId,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,
    bool? duplicates,
    bool? ignoreDuplicate,
  }) async {
    /// ✅ لو أول صفحة + الفلاتر اتغيرت → reset حقيقي

    if (page == 1) {
      leads.clear();
      emit(AllLeadsLoading());
    }
    try {
      final response = await apiService.fetchLeads(
        page: page,
        limit: limit,
        search: search,
        salesId: salesId,
        developerId: developerId,
        projectId: projectId,
        channelId: channelId,
        campaignId: campaignId,
        communicationWayId: communicationWayId,
        stageId: stageId,
        stageDateFrom: stageDateFrom,
        stageDateTo: stageDateTo,
        addedById: addedById,
        assignedFromId: assignedFromId,
        assignedToId: assignedToId,
        creationDateFrom: creationDateFrom,
        creationDateTo: creationDateTo,
        lastStageUpdateFrom: lastStageUpdateFrom,
        lastStageUpdateTo: lastStageUpdateTo,
        lastCommentDateFrom: lastCommentDateFrom,
        lastCommentDateTo: lastCommentDateTo,
        duplicates: duplicates,
        ignoreDuplicate: ignoreDuplicate,
      );

      if (response != null) {
        final newData = response.data ?? [];
        leads.addAll(newData);

        /// ⭐ pagination
        final bool hasMore = newData.length == limit;

        emit(AllLeadsLoaded(response, hasMore));
      } else {
        emit(AllLeadsError("Failed to fetch leads"));
      }
    } catch (e) {
      emit(AllLeadsError("Error: $e"));
    }
  }
  

  /// =======================
  /// 🗑️ Trash Leads
  /// =======================
  Future<void> fetchLeadsInTrash({int page = 1, int limit = 10}) async {
    if (page == 1) {
      emit(AllLeadsTrashLoading());
    }

    try {
      final response = await apiService.fetchLeadsInTrash(
        page: page,
        limit: limit,
      );

      if (response != null) {
        if (page == 1) {
          trashLeads.clear();
        }

        final newData = response.data ?? [];
        trashLeads.addAll(newData);

        emit(AllLeadsTrashLoaded(response));
      } else {
        emit(AllLeadsTrashError("Failed to fetch trash leads"));
      }
    } catch (e) {
      emit(AllLeadsTrashError("Error: $e"));
    }
  }
}
