// lib/presentation/viewModels/request_leads/request_leads_cubit.dart

// ignore_for_file: constant_identifier_names

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:homewalkers_app/data/data_sources/request_leads_api_service.dart';
import 'package:homewalkers_app/data/models/get_all_lead_requests_model.dart';
import 'package:homewalkers_app/data/models/request_leads_model.dart';
import 'package:homewalkers_app/presentation/viewModels/request_leads/request_leads_state.dart';

class RequestLeadsCubit extends Cubit<RequestLeadsState> {
  final RequestLeadsFromDataApiService _apiService;

  // Store current filters
  String? _currentStatus;
  String? _currentFromDate;
  String? _currentToDate;
  String? _currentUserId;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  int _totalPages = 0;

  // ✅ أضف هذا: عدد العناصر في كل صفحة
  static const int ITEMS_PER_PAGE = 20;

  RequestLeadsCubit(this._apiService) : super(RequestLeadsInitial());

  /// Request leads from data centre
  Future<void> requestLeads({required int requestedLimit}) async {
    try {
      emit(RequestLeadsLoading());
      log("🔄 RequestLeadsCubit: Requesting $requestedLimit leads");

      final response = await _apiService.requestLeads(
        requestedLimit: requestedLimit,
      );

      if (response.isSuccess) {
        log(
          "✅ RequestLeadsCubit: Success - Got ${response.data?.leads.length ?? 0} leads",
        );
        emit(RequestLeadsSuccess(response));
      } else {
        log("❌ RequestLeadsCubit: Failed - ${response.message}");
        emit(RequestLeadsFailure(response.message));
      }
    } catch (e) {
      log("❌ RequestLeadsCubit: Error - $e");
      emit(RequestLeadsFailure(e.toString()));
    }
  }

  /// Get all requests history with infinite scroll support
  Future<void> getAllRequests({
    bool isRefresh = false,
    String? status,
    String? fromDate,
    String? toDate,
    String? userId,
  }) async {
    try {
      // Reset pagination if refreshing
      if (isRefresh) {
        _currentPage = 1;
        _totalPages = 0;
        _currentStatus = status;
        _currentFromDate = fromDate;
        _currentToDate = toDate;
        _currentUserId = userId;
        emit(GetAllRequestsLoading());
      } else if (_isLoadingMore) {
        return; // Prevent multiple simultaneous loads
      }

      _isLoadingMore = true;

      log("🔄 RequestLeadsCubit: Fetching requests - Page: $_currentPage");
      if (status != null) log("🏷️ Status: $status");
      if (fromDate != null) log("📅 From Date: $fromDate");
      if (toDate != null) log("📅 To Date: $toDate");
      if (userId != null) log("👤 UserId filter: $userId");

      final response = await _apiService.getAllRequests(
        page: _currentPage,
        limit: ITEMS_PER_PAGE,
        fromDate: fromDate ?? _currentFromDate,
        toDate: toDate ?? _currentToDate,
        status: status ?? _currentStatus,
        userId: userId ?? _currentUserId,
      );

      if (response.status == 'success') {
        final currentState = state;

        // ✅ الطريقة الصحيحة: تحقق من عدد النتائج الفعلي
        // لا تثق بـ totalPages من API إذا كانت خاطئة
        final itemsReturned = response.data.length;
        final isLastPage = itemsReturned < ITEMS_PER_PAGE || itemsReturned == 0;

        // تحديث إجمالي الصفحات من الـ API (للتوثيق فقط)
        _totalPages = response.pagination.totalPages;

        log("📊 API Response Analysis:");
        log("   Current Page: $_currentPage");
        log("   Items returned: $itemsReturned");
        log("   Page limit: $ITEMS_PER_PAGE");
        log("   API totalPages: $_totalPages");
        log("   Detected as last page: $isLastPage");

        if (isRefresh || currentState is! GetAllRequestsSuccess) {
          // First load or refresh
          log("✅ Loaded $itemsReturned requests (Total: ${response.results})");
          emit(
            GetAllRequestsSuccess(
              requests: response.data,
              pagination: response.pagination,
              hasReachedMax: isLastPage,
              currentStatus: status ?? _currentStatus,
              currentFromDate: fromDate ?? _currentFromDate,
              currentToDate: toDate ?? _currentToDate,
              currentUserId: userId ?? _currentUserId,
            ),
          );
        } else {
          // Load more - append to existing list
          final updatedRequests = List<RequestLog>.from(currentState.requests)
            ..addAll(response.data);

          log(
            "✅ Loaded more: +$itemsReturned requests (Total: ${updatedRequests.length})",
          );

          emit(
            currentState.copyWith(
              requests: updatedRequests,
              pagination: response.pagination,
              hasReachedMax: isLastPage,
            ),
          );
        }

        // ✅ فقط زيادة الصفحة إذا لم نصل للآخر
        if (!isLastPage) {
          _currentPage++;
          log("📄 Moving to next page: $_currentPage");
        } else {
          log("🛑 Reached end of results - no more items");
        }
      } else {
        log("❌ RequestLeadsCubit: Failed - ${response.status}");
        if (isRefresh) {
          emit(GetAllRequestsFailure(response.status));
        }
      }
    } catch (e) {
      log("❌ RequestLeadsCubit: Error - $e");
      if (isRefresh) {
        emit(GetAllRequestsFailure(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Load more requests (for infinite scroll)
  Future<void> loadMoreRequests() async {
    final currentState = state;

    if (currentState is! GetAllRequestsSuccess) {
      log("⚠️ Invalid state for loading more");
      return;
    }

    if (currentState.hasReachedMax) {
      log("⚠️ Already reached end of results");
      return;
    }

    if (_isLoadingMore) {
      log("⚠️ Already loading more");
      return;
    }

    log("🔄 Loading more requests... (Page: $_currentPage)");
    await getAllRequests(
      isRefresh: false,
      status: currentState.currentStatus,
      fromDate: currentState.currentFromDate,
      toDate: currentState.currentToDate,
      userId: currentState.currentUserId,
    );
  }

  /// Refresh requests (pull to refresh)
  Future<void> refreshRequests() async {
    log("🔄 Refreshing requests...");
    await getAllRequests(isRefresh: true);
  }

  /// Filter by status
  Future<void> filterByStatus(String? status) async {
    log("🏷️ Filtering by status: $status");
    _currentPage = 1;
    _totalPages = 0;
    await getAllRequests(isRefresh: true, status: status);
  }

  /// Filter by date range
  Future<void> filterByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final fromDateStr = _formatDate(fromDate);
    final toDateStr = _formatDate(toDate);
    log("📅 Filtering by date range: $fromDateStr to $toDateStr");
    _currentPage = 1;
    _totalPages = 0;
    await getAllRequests(
      isRefresh: true,
      fromDate: fromDateStr,
      toDate: toDateStr,
    );
  }

  /// Filter by specific user (Admin only)
  Future<void> filterByUserId(String? userId) async {
    log("👤 Filtering by userId: $userId");
    _currentPage = 1;
    _totalPages = 0;
    await getAllRequests(isRefresh: true, userId: userId);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    log("🧹 Clearing all filters");
    _currentStatus = null;
    _currentFromDate = null;
    _currentToDate = null;
    _currentUserId = null;
    _currentPage = 1;
    _totalPages = 0;
    await getAllRequests(isRefresh: true);
  }

  /// Get completed requests only
  Future<void> getCompletedRequests() async {
    await filterByStatus('completed');
  }

  /// Get failed requests only
  Future<void> getFailedRequests() async {
    await filterByStatus('failed');
  }

  /// Get pending requests only
  Future<void> getPendingRequests() async {
    await filterByStatus('pending');
  }

  /// Get requests from last 30 days
  Future<void> getRecentRequests() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    await filterByDateRange(fromDate: startDate, toDate: endDate);
  }

  /// Reset to initial state
  void reset() {
    log("🔄 RequestLeadsCubit: Resetting state");
    _currentPage = 1;
    _totalPages = 0;
    _currentStatus = null;
    _currentFromDate = null;
    _currentToDate = null;
    _currentUserId = null;
    _isLoadingMore = false;
    emit(RequestLeadsInitial());
  }

  /// Check if user can request more leads based on summary
  bool canRequestMoreLeads(RequestSummary? summary, int requestedLimit) {
    if (summary == null) return true;
    return summary.remaining >= requestedLimit;
  }

  /// Get remaining leads count
  int getRemainingLeads(RequestSummary? summary) {
    return summary?.remaining ?? 0;
  }

  /// Get max allowed leads
  int getMaxAllowedLeads(RequestSummary? summary) {
    return summary?.maxAllowed ?? 0;
  }

  /// Get total taken leads
  int getTotalTakenLeads(RequestSummary? summary) {
    return summary?.totalTaken ?? 0;
  }

  // ==================== Helper Methods ====================

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
