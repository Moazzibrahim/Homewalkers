// ignore_for_file: non_constant_identifier_names

class SalesDataDashboardCountModel {
  final bool? success;
  final SalesStagesData? data;
  final Meta? meta;

  SalesDataDashboardCountModel({this.success, this.data, this.meta});

  factory SalesDataDashboardCountModel.fromJson(Map<String, dynamic> json) {
    return SalesDataDashboardCountModel(
      success: json['success'],
      data:
          json['data'] != null ? SalesStagesData.fromJson(json['data']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class SalesStagesData {
  final SalesInfo? salesInfo;
  final List<StageData>? stages;
  final Summary? summary;

  SalesStagesData({this.salesInfo, this.stages, this.summary});

  factory SalesStagesData.fromJson(Map<String, dynamic> json) {
    return SalesStagesData(
      salesInfo:
          json['salesInfo'] != null
              ? SalesInfo.fromJson(json['salesInfo'])
              : null,
      stages:
          json['stages'] != null
              ? List<StageData>.from(
                json['stages'].map((x) => StageData.fromJson(x)),
              )
              : null,
      summary:
          json['summary'] != null ? Summary.fromJson(json['summary']) : null,
    );
  }
}

class SalesInfo {
  final String? id;
  final String? name;
  final String? email;

  SalesInfo({this.id, this.name, this.email});

  factory SalesInfo.fromJson(Map<String, dynamic> json) {
    return SalesInfo(id: json['id'], name: json['name'], email: json['email']);
  }
}

class StageData {
  final String? stageId;
  final String? stageName;
  final num? leadsCount;

  StageData({this.stageId, this.stageName, this.leadsCount});

  factory StageData.fromJson(Map<String, dynamic> json) {
    return StageData(
      stageId: json['stageId'],
      stageName: json['stageName'],
      leadsCount: json['leadsCount'],
    );
  }
}

class Summary {
  final num? totalLeads;
  final num? totalStages;

  Summary({this.totalLeads, this.totalStages});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalLeads: json['totalLeads'],
      totalStages: json['totalStages'],
    );
  }
}

class Meta {
  final String? executionTime;
  final String? timestamp;

  Meta({this.executionTime, this.timestamp});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      executionTime: json['executionTime'],
      timestamp: json['timestamp'],
    );
  }
}
