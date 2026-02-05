import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/lead_comments_model.dart';
import 'package:homewalkers_app/data/models/leads_assigned_model.dart';
import 'package:homewalkers_app/data/models/newCommentsModel.dart';

// --- States ---
abstract class LeadCommentsState extends Equatable {
  const LeadCommentsState();

  @override
  List<Object?> get props => [];
}

class LeadCommentsInitial extends LeadCommentsState {}

class LeadCommentsLoading extends LeadCommentsState {}

class LeadCommentsLoaded extends LeadCommentsState {
  final LeadCommentsModel leadComments;

  const LeadCommentsLoaded(this.leadComments);

  @override
  List<Object?> get props => [leadComments];
}

class LeadCommentsError extends LeadCommentsState {
  final String message;

  const LeadCommentsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ حالة جديدة
class LeadAssignedLoaded extends LeadCommentsState {
  final LeadAssignedModel leadAssigned;

  const LeadAssignedLoaded(this.leadAssigned);

  @override
  List<Object?> get props => [leadAssigned];
}

class ReplySentSuccessfully extends LeadCommentsState {}

class LeadCommentsFullLoaded extends LeadCommentsState {
  final LeadCommentsModel comments;
  final LeadAssignedModel assigned;

  const LeadCommentsFullLoaded({
    required this.comments,
    required this.assigned,
  });

  @override
  List<Object?> get props => [comments, assigned];
}

// ✅ New state for paginated/commented data
class NewCommentsLoaded extends LeadCommentsState {
  final NewCommentsModel newComments;

  const NewCommentsLoaded(this.newComments);

  @override
  List<Object?> get props => [newComments];
}