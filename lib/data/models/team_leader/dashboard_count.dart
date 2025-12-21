class TeamleaderDashboardResponse {
  final bool? success;
  final DashboardData? data;
  final Meta? meta;

  TeamleaderDashboardResponse({
    this.success,
    this.data,
    this.meta,
  });

  factory TeamleaderDashboardResponse.fromJson(Map<String, dynamic> json) {
    return TeamleaderDashboardResponse(
      success: json['success'],
      data: json['data'] != null
          ? DashboardData.fromJson(json['data'])
          : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class DashboardData {
  final TeamLeaderInfo? teamleaderInfo;
  final List<StageDashboard>? dashboard;
  final TeamLeaderFresh? teamLeaderFresh; // ✅ جديد
  final int? salesCount;
  final Summary? summary;

  DashboardData({
    this.teamleaderInfo,
    this.dashboard,
    this.teamLeaderFresh,
    this.salesCount,
    this.summary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      teamleaderInfo: json['teamleaderInfo'] != null
          ? TeamLeaderInfo.fromJson(json['teamleaderInfo'])
          : null,
      dashboard: json['dashboard'] != null
          ? (json['dashboard'] as List)
              .map((e) => StageDashboard.fromJson(e))
              .toList()
          : null,
      teamLeaderFresh: json['teamLeaderFresh'] != null
          ? TeamLeaderFresh.fromJson(json['teamLeaderFresh'])
          : null,
      salesCount: json['salesCount'],
      summary:
          json['summary'] != null ? Summary.fromJson(json['summary']) : null,
    );
  }
}

class TeamLeaderInfo {
  final String? id;
  final String? name;
  final String? email;

  TeamLeaderInfo({
    this.id,
    this.name,
    this.email,
  });

  factory TeamLeaderInfo.fromJson(Map<String, dynamic> json) {
    return TeamLeaderInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class StageDashboard {
  final String? stageId;
  final String? stageName;
  final int? leadsCount;

  StageDashboard({
    this.stageId,
    this.stageName,
    this.leadsCount,
  });

  factory StageDashboard.fromJson(Map<String, dynamic> json) {
    return StageDashboard(
      stageId: json['stageId'],
      stageName: json['stageName'],
      leadsCount: json['leadsCount'],
    );
  }
}

/// ✅ موديل teamLeaderFresh
class TeamLeaderFresh {
  final String? stageName;
  final int? leadsCount;
  final String? description;

  TeamLeaderFresh({
    this.stageName,
    this.leadsCount,
    this.description,
  });

  factory TeamLeaderFresh.fromJson(Map<String, dynamic> json) {
    return TeamLeaderFresh(
      stageName: json['stageName'],
      leadsCount: json['leadsCount'],
      description: json['description'],
    );
  }
}

class Summary {
  final int? totalLeads;
  final int? teamLeaderFreshLeads; // ✅ جديد
  final int? totalStages;
  final int? stagesWithLeads;

  Summary({
    this.totalLeads,
    this.teamLeaderFreshLeads,
    this.totalStages,
    this.stagesWithLeads,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalLeads: json['totalLeads'],
      teamLeaderFreshLeads: json['teamLeaderFreshLeads'],
      totalStages: json['totalStages'],
      stagesWithLeads: json['stagesWithLeads'],
    );
  }
}

class Meta {
  final String? executionTime;
  final bool? fromCache;
  final String? timestamp;

  Meta({
    this.executionTime,
    this.fromCache,
    this.timestamp,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      executionTime: json['executionTime'],
      fromCache: json['fromCache'],
      timestamp: json['timestamp'],
    );
  }
}
