class LeadStagesSummaryResponse {
  final bool? success;
  final int? totalLeads;
  final List<LeadStageSummary>? data;

  LeadStagesSummaryResponse({
    this.success,
    this.totalLeads,
    this.data,
  });

  factory LeadStagesSummaryResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LeadStagesSummaryResponse();

    return LeadStagesSummaryResponse(
      success: json['success'] as bool?,
      totalLeads: json['totalLeads'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => LeadStageSummary.fromJson(e))
          .toList(),
    );
  }
}

class LeadStageSummary {
  final String? stageId;
  final String? stageName;
  final int? leadCount;
  final String? percentage;

  LeadStageSummary({
    this.stageId,
    this.stageName,
    this.leadCount,
    this.percentage,
  });

  factory LeadStageSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LeadStageSummary();

    return LeadStageSummary(
      stageId: json['stageId'] as String?,
      stageName: json['stageName'] as String?,
      leadCount: json['leadCount'] as int?,
      percentage: json['percentage'] as String?,
    );
  }
}
