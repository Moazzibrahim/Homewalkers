// lib/presentation/viewModels/request_leads/request_leads_state.dart

import 'package:homewalkers_app/data/models/get_all_lead_requests_model.dart';
import 'package:homewalkers_app/data/models/request_leads_model.dart';

// ==================== States ====================

abstract class RequestLeadsState {}

class RequestLeadsInitial extends RequestLeadsState {}

// === Request Leads States ===
class RequestLeadsLoading extends RequestLeadsState {}

class RequestLeadsSuccess extends RequestLeadsState {
  final RequestLeadsResponse response;
  final List<Lead> leads;
  final RequestSummary summary;

  RequestLeadsSuccess(this.response)
    : leads = response.data?.leads ?? [],
      summary =
          response.data?.summary ??
          RequestSummary(
            requested: 0,
            transferred: 0,
            availableInPool: 0,
            takenBefore: 0,
            totalTaken: 0,
            maxAllowed: 0,
            remaining: 0,
          );
}

class RequestLeadsFailure extends RequestLeadsState {
  final String message;
  final int? statusCode;

  RequestLeadsFailure(this.message, {this.statusCode});
}

// === Get All Requests States (With Infinite Scroll Support) ===
class GetAllRequestsLoading extends RequestLeadsState {}

class GetAllRequestsSuccess extends RequestLeadsState {
  final List<RequestLog> requests;
  final PaginationInfo pagination;
  final bool hasReachedMax;
  final String? currentStatus;
  final String? currentFromDate;
  final String? currentToDate;
  final String? currentUserId;

  GetAllRequestsSuccess({
    required this.requests,
    required this.pagination,
    this.hasReachedMax = false,
    this.currentStatus,
    this.currentFromDate,
    this.currentToDate,
    this.currentUserId,
  });

  GetAllRequestsSuccess copyWith({
    List<RequestLog>? requests,
    PaginationInfo? pagination,
    bool? hasReachedMax,
    String? currentStatus,
    String? currentFromDate,
    String? currentToDate,
    String? currentUserId,
  }) {
    return GetAllRequestsSuccess(
      requests: requests ?? this.requests,
      pagination: pagination ?? this.pagination,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentStatus: currentStatus ?? this.currentStatus,
      currentFromDate: currentFromDate ?? this.currentFromDate,
      currentToDate: currentToDate ?? this.currentToDate,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class GetAllRequestsFailure extends RequestLeadsState {
  final String message;
  final int? statusCode;

  GetAllRequestsFailure(this.message, {this.statusCode});
}

// ==================== Events ====================

abstract class RequestLeadsEvent {}

class RequestLeadsRequested extends RequestLeadsEvent {
  final int requestedLimit;

  RequestLeadsRequested({required this.requestedLimit});
}

class ResetRequestLeads extends RequestLeadsEvent {}

// Events for GetAllRequests with Infinite Scroll
class GetAllRequestsEvent extends RequestLeadsEvent {
  final bool isRefresh;
  final String? status;
  final String? fromDate;
  final String? toDate;
  final String? userId;

  GetAllRequestsEvent({
    this.isRefresh = false,
    this.status,
    this.fromDate,
    this.toDate,
    this.userId,
  });
}

class LoadMoreRequests extends RequestLeadsEvent {}
