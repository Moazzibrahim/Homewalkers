// ignore_for_file: file_names

class TeamleaderDataDashboardModel {
  final bool? success;
  final DashboardData? data;
  final MetaData? meta;

  TeamleaderDataDashboardModel({this.success, this.data, this.meta});

  factory TeamleaderDataDashboardModel.fromJson(Map<String, dynamic> json) =>
      TeamleaderDataDashboardModel(
        success: json['success'] as bool?,
        data: json['data'] != null
            ? DashboardData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
        meta: json['meta'] != null
            ? MetaData.fromJson(json['meta'] as Map<String, dynamic>)
            : null,
      );
}

class DashboardData {
  final TeamLeaderInfo? teamleaderInfo;
  final List<DashboardStage>? dashboard;
  final TeamLeaderStage? teamLeaderFresh;
  final TeamLeaderStage? teamLeaderPending;
  final num? salesCount;
  final Summary? summary;

  DashboardData({
    this.teamleaderInfo,
    this.dashboard,
    this.teamLeaderFresh,
    this.teamLeaderPending,
    this.salesCount,
    this.summary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        teamleaderInfo: json['teamleaderInfo'] != null
            ? TeamLeaderInfo.fromJson(json['teamleaderInfo'] as Map<String, dynamic>)
            : null,
        dashboard: (json['dashboard'] as List<dynamic>?)
            ?.map((e) => DashboardStage.fromJson(e as Map<String, dynamic>))
            .toList(),
        teamLeaderFresh: json['teamLeaderFresh'] != null
            ? TeamLeaderStage.fromJson(json['teamLeaderFresh'] as Map<String, dynamic>)
            : null,
        teamLeaderPending: json['teamLeaderPending'] != null
            ? TeamLeaderStage.fromJson(json['teamLeaderPending'] as Map<String, dynamic>)
            : null,
        salesCount: json['salesCount'] != null ? (json['salesCount'] as num) : null,
        summary: json['summary'] != null
            ? Summary.fromJson(json['summary'] as Map<String, dynamic>)
            : null,
      );
}

class TeamLeaderInfo {
  final String? id;
  final String? name;
  final String? email;

  TeamLeaderInfo({this.id, this.name, this.email});

  factory TeamLeaderInfo.fromJson(Map<String, dynamic> json) => TeamLeaderInfo(
        id: json['id'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
      );
}

class DashboardStage {
  final String? stageId;
  final String? stageName;
  final num? leadsCount;

  DashboardStage({this.stageId, this.stageName, this.leadsCount});

  factory DashboardStage.fromJson(Map<String, dynamic> json) => DashboardStage(
        stageId: json['stageId'] as String?,
        stageName: json['stageName'] as String?,
        leadsCount: json['leadsCount'] != null ? (json['leadsCount'] as num) : null,
      );
}

class TeamLeaderStage {
  final String? stageId;
  final String? stageName;
  final num? leadsCount;
  final String? description;
  final List<String>? salesIds;

  TeamLeaderStage({
    this.stageId,
    this.stageName,
    this.leadsCount,
    this.description,
    this.salesIds,
  });

  factory TeamLeaderStage.fromJson(Map<String, dynamic> json) => TeamLeaderStage(
        stageId: json['stageId'] as String?,
        stageName: json['stageName'] as String?,
        leadsCount: json['leadsCount'] != null ? (json['leadsCount'] as num) : null,
        description: json['description'] as String?,
        salesIds: (json['salesIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
      );
}

class Summary {
  final num? totalLeads;
  final num? teamLeaderFreshLeads;
  final num? teamLeaderPendingLeads;
  final num? totalStages;
  final num? stagesWithLeads;

  Summary({
    this.totalLeads,
    this.teamLeaderFreshLeads,
    this.teamLeaderPendingLeads,
    this.totalStages,
    this.stagesWithLeads,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        totalLeads: json['totalLeads'] != null ? (json['totalLeads'] as num) : null,
        teamLeaderFreshLeads: json['teamLeaderFreshLeads'] != null
            ? (json['teamLeaderFreshLeads'] as num)
            : null,
        teamLeaderPendingLeads: json['teamLeaderPendingLeads'] != null
            ? (json['teamLeaderPendingLeads'] as num)
            : null,
        totalStages: json['totalStages'] != null ? (json['totalStages'] as num) : null,
        stagesWithLeads: json['stagesWithLeads'] != null
            ? (json['stagesWithLeads'] as num)
            : null,
      );
}

class MetaData {
  final String? executionTime;
  final bool? fromCache;
  final String? timestamp;

  MetaData({this.executionTime, this.fromCache, this.timestamp});

  factory MetaData.fromJson(Map<String, dynamic> json) => MetaData(
        executionTime: json['executionTime'] as String?,
        fromCache: json['fromCache'] as bool?,
        timestamp: json['timestamp'] as String?,
      );
}
