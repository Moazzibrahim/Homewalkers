class MarketerDashboardModel {
  bool? success;
  SearchInfo? searchInfo;
  UserInfo? userInfo;
  num? totalLeads;
  List<SampleLeadsPreview>? sampleLeadsPreview;
  List<StageData>? data;

  MarketerDashboardModel({
    this.success,
    this.searchInfo,
    this.userInfo,
    this.totalLeads,
    this.sampleLeadsPreview,
    this.data,
  });

  factory MarketerDashboardModel.fromJson(Map<String, dynamic> json) {
    return MarketerDashboardModel(
      success: json['success'],
      searchInfo:
          json['searchInfo'] != null
              ? SearchInfo.fromJson(json['searchInfo'])
              : null,
      userInfo:
          json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
      totalLeads: json['totalLeads'],
      sampleLeadsPreview:
          json['sampleLeadsPreview'] != null
              ? (json['sampleLeadsPreview'] as List)
                  .map((e) => SampleLeadsPreview.fromJson(e))
                  .toList()
              : null,
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((e) => StageData.fromJson(e))
                  .toList()
              : null,
    );
  }
}

class SearchInfo {
  String? method;
  List<String>? usedChannels;
  DatabaseStats? databaseStats;

  SearchInfo({this.method, this.usedChannels, this.databaseStats});

  factory SearchInfo.fromJson(Map<String, dynamic> json) {
    return SearchInfo(
      method: json['method'],
      usedChannels:
          json['usedChannels'] != null
              ? List<String>.from(json['usedChannels'])
              : null,
      databaseStats:
          json['databaseStats'] != null
              ? DatabaseStats.fromJson(json['databaseStats'])
              : null,
    );
  }
}

class DatabaseStats {
  num? totalLeadsInDB;
  num? leadsWithChannelField;
  String? matchPercentage;

  DatabaseStats({
    this.totalLeadsInDB,
    this.leadsWithChannelField,
    this.matchPercentage,
  });

  factory DatabaseStats.fromJson(Map<String, dynamic> json) {
    return DatabaseStats(
      totalLeadsInDB: json['totalLeadsInDB'],
      leadsWithChannelField: json['leadsWithChannelField'],
      matchPercentage: json['matchPercentage'],
    );
  }
}

class UserInfo {
  String? id;
  String? name;
  String? role;
  num? channelsCount;

  UserInfo({this.id, this.name, this.role, this.channelsCount});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      channelsCount: json['channelsCount'],
    );
  }
}

class SampleLeadsPreview {
  String? name;
  String? chanel;
  String? source;

  SampleLeadsPreview({this.name, this.chanel, this.source});

  factory SampleLeadsPreview.fromJson(Map<String, dynamic> json) {
    return SampleLeadsPreview(
      name: json['name'],
      chanel: json['chanel'],
      source: json['source'],
    );
  }
}

class StageData {
  String? stageId;
  String? stageName;
  num? leadCount;
  String? percentage;

  StageData({this.stageId, this.stageName, this.leadCount, this.percentage});

  factory StageData.fromJson(Map<String, dynamic> json) {
    return StageData(
      stageId: json['stageId'],
      stageName: json['stageName'],
      leadCount: json['leadCount'],
      percentage: json['percentage'],
    );
  }
}
