// import 'package:bloc/bloc.dart';
// import 'package:homewalkers_app/data/data_sources/get_new_admin_users_api_service.dart';
// import 'package:homewalkers_app/data/models/new_admin_users_model.dart';
// import 'package:homewalkers_app/presentation/viewModels/new_admin/cubit/get_new_all_users_admin_state.dart';


// // --- Cubit Class ---
// // هذا الكلاس هو المسؤول عن إدارة الحالة ومنطق الأعمال
// class GetNewAllUsersAdminCubit extends Cubit<GetNewAllUsersAdminState> {
//   final GetNewAdminUsersApiService _apiService;
//   List<Leaddd> _originalLeads = []; 

//   GetNewAllUsersAdminCubit(this._apiService) : super(GetNewAllUsersAdminInitial());

//     List<Leaddd> getOriginalLeads() => _originalLeads;

//   // دالة لجلب بيانات المستخدمين من الـ API
//   Future<void> fetchNewAdminUsers() async {
//     emit(GetNewAllUsersAdminLoading());
//     try {
//       final usersModel = await _apiService.getNewAdminUsers();
//       if (usersModel != null) {
//         emit(GetNewAllUsersAdminSuccess(usersModel));
//       } else {
//         emit(const GetNewAllUsersAdminFailure('Failed to fetch users. Response was null.'));
//       }
//     } catch (e) {
//       emit(GetNewAllUsersAdminFailure('An error occurred: ${e.toString()}'));
//     }
//   }
//    void applyFilters(Map<String, dynamic> filters) {
//     // Start with the full list of leads
//     List<Leaddd> filteredLeads = List.from(_originalLeads);

//     // Helper function to parse dates safely
//     DateTime? _safeParse(String? dateString) {
//       if (dateString == null) return null;
//       try {
//         return DateTime.parse(dateString);
//       } catch (e) {
//         return null;
//       }
//     }

//     // Apply each filter
//     filteredLeads = filteredLeads.where((lead) {
//       // Text search filter
//       final String? nameQuery = filters['name'];
//       if (nameQuery != null && nameQuery.isNotEmpty) {
//         final query = nameQuery.toLowerCase();
//         final nameMatch = lead.name?.toLowerCase().contains(query) ?? false;
//         final emailMatch = lead.email?.toLowerCase().contains(query) ?? false;
//         final phoneMatch = lead.phone?.toLowerCase().contains(query) ?? false;
//         if (!(nameMatch || emailMatch || phoneMatch)) return false;
//       }

//       // Dropdown filters
//       if (filters['project'] != null && lead.project?.name != filters['project']) return false;
//       if (filters['stage'] != null && lead.stage?.name != filters['stage']) return false;
//       if (filters['addedBy'] != null && lead.addby?.name != filters['addedBy']) return false;
//       if (filters['assignedTo'] != null) {
//         bool isAssignedTo = lead.leadAssigns?.any((a) => a.assignedTo?.name == filters['assignedTo']) ?? false;
//         if (!isAssignedTo) return false;
//       }
      
//       // Date filters
//       final DateTime? creationStart = filters['creationDateStart'];
//       final DateTime? creationEnd = filters['creationDateEnd'];
//       final leadCreationDate = _safeParse(lead.createdAt);

//       if (creationStart != null && leadCreationDate != null) {
//         if (leadCreationDate.isBefore(creationStart)) return false;
//       }
//       if (creationEnd != null && leadCreationDate != null) {
//         // Add one day to the end date to include the whole day
//         if (leadCreationDate.isAfter(creationEnd.add(const Duration(days: 1)))) return false;
//       }
      
//       final DateTime? lastCommentDateFilter = filters['lastCommentDate'];
//       final leadLastCommentDate = _safeParse(lead.lastcommentdate);
//       if (lastCommentDateFilter != null && leadLastCommentDate != null) {
//           if (leadLastCommentDate.year != lastCommentDateFilter.year ||
//               leadLastCommentDate.month != lastCommentDateFilter.month ||
//               leadLastCommentDate.day != lastCommentDateFilter.day) return false;
//       }
      
//       final DateTime? lastStageUpdateFilter = filters['lastStageUpdateDate'];
//       final leadLastStageUpdate = _safeParse(lead.stagedateupdated);
//       if (lastStageUpdateFilter != null && leadLastStageUpdate != null) {
//          if (leadLastStageUpdate.year != lastStageUpdateFilter.year ||
//              leadLastStageUpdate.month != lastStageUpdateFilter.month ||
//              leadLastStageUpdate.day != lastStageUpdateFilter.day) return false;
//       }

//       return true; // If all checks pass, include the lead
//     }).toList();
//     // Create a new model with the filtered data
//     final filteredModel = NewAdminUsersModel(
//       results: filteredLeads.length,
//       data: filteredLeads,
//       // You might want to adjust pagination info or set it to null
//       pagination: Pagination(currentPage: 1, limit: filteredLeads.length, numberOfPages: 1),
//     );

//     emit(GetNewAllUsersAdminSuccess(filteredModel));
//   }

//   void resetFilters() {
//     // If for some reason the original list is empty, fetch it again.
//     if (_originalLeads.isEmpty && state is! GetNewAllUsersAdminLoading) {
//       fetchNewAdminUsers();
//       return;
//     }
    
//     // Create a model with the original, unfiltered data
//     final originalModel = NewAdminUsersModel(
//       results: _originalLeads.length,
//       data: _originalLeads,
//       pagination: Pagination(currentPage: 1, limit: _originalLeads.length, numberOfPages: 1),
//     );
//     emit(GetNewAllUsersAdminSuccess(originalModel));
//   }
// }