class LeadsStatsModel {
  final bool? success;
  final int? totalLeads;
  final int? totalDuplicates;
  final int? activeSales;
  final List<StageStats>? stages;

  LeadsStatsModel({
    this.success,
    this.totalLeads,
    this.totalDuplicates,
    this.activeSales,
    this.stages,
  });

  factory LeadsStatsModel.fromJson(Map<String, dynamic> json) {
    return LeadsStatsModel(
      success: json['success'],
      totalLeads: json['totalLeads'],
      totalDuplicates: json['totalDuplicates'],
      activeSales: json['activeSales'],
      stages:
          (json['stages'] as List<dynamic>?)
              ?.map((e) => StageStats.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalLeads': totalLeads,
      'totalDuplicates': totalDuplicates,
      'activeSales': activeSales,
      'stages': stages?.map((e) => e.toJson()).toList(),
    };
  }
}

class StageStats {
  final String? stage;
  final String? stageId; // ← added
  final int? leadsCount;

  StageStats({this.stage, this.stageId, this.leadsCount});

  factory StageStats.fromJson(Map<String, dynamic> json) {
    return StageStats(
      stage: json['stage'],
      stageId: json['stage_id'], // ← added
      leadsCount: json['leadsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage, 'stage_id': stageId, // ← added
      'leadsCount': leadsCount,
    };
  }
}
