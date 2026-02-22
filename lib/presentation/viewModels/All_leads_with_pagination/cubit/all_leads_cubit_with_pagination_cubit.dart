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

  AllLeadsCubitWithPagination(this.apiService)
      : super(AllLeadsInitial());

  /// =======================
  /// ✅ Active Leads
  /// =======================
  Future<void> fetchLeads({
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? salesIds,
    List<String>? developerIds,
    List<String>? projectIds,
    List<String>? channelIds,
    List<String>? campaignIds,
    List<String>? communicationWayIds,
    List<String>? stageIds,
    List<String>? addedByIds,
    List<String>? assignedFromIds,
    List<String>? assignedToIds,

    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,

    bool? duplicates,
    bool? ignoreDuplicate,
    bool? transferefromdata,
    bool? data,
  }) async {

    /// ✅ لو أول صفحة → reset حقيقي
    if (page == 1) {
      leads.clear();
      emit(AllLeadsLoading());
    }

    try {
      final response = await apiService.fetchLeads(
        page: page,
        limit: limit,
        search: search,

        /// ✅ مرر الليستات زي ما هي
        salesIds: salesIds,
        developerIds: developerIds,
        projectIds: projectIds,
        channelIds: channelIds,
        campaignIds: campaignIds,
        communicationWayIds: communicationWayIds,
        stageIds: stageIds,
        addedByIds: addedByIds,
        assignedFromIds: assignedFromIds,
        assignedToIds: assignedToIds,

        stageDateFrom: stageDateFrom,
        stageDateTo: stageDateTo,
        creationDateFrom: creationDateFrom,
        creationDateTo: creationDateTo,
        lastStageUpdateFrom: lastStageUpdateFrom,
        lastStageUpdateTo: lastStageUpdateTo,
        lastCommentDateFrom: lastCommentDateFrom,
        lastCommentDateTo: lastCommentDateTo,
        duplicates: duplicates,
        ignoreDuplicate: ignoreDuplicate,
        data: data,
        transferefromdata: transferefromdata,
      );

      if (response != null) {
        final newData = response.data ?? [];

        /// ⭐ pagination accumulation
        leads.addAll(newData);

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
