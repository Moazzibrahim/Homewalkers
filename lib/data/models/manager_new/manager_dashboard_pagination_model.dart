class ManagerDashboardPaginationModel {
  bool? success;
  DashboardData? data;
  Meta? meta;

  ManagerDashboardPaginationModel({this.success, this.data, this.meta});

  factory ManagerDashboardPaginationModel.fromJson(Map<String, dynamic> json) {
    return ManagerDashboardPaginationModel(
      success: json['success'],
      data: json['data'] != null
          ? DashboardData.fromJson(json['data'])
          : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class DashboardData {
  ManagerInfo? managerInfo;
  List<StageDashboard>? dashboard;
  ManagerStage? managerFresh;
  ManagerStage? managerPending;
  List<TeamLeader>? teamLeaders;
  List<Sales>? directManagerSales;
  int? directManagerSalesCount;
  int? salesCount;
  Summary? summary;

  DashboardData({
    this.managerInfo,
    this.dashboard,
    this.managerFresh,
    this.managerPending,
    this.teamLeaders,
    this.directManagerSales,
    this.directManagerSalesCount,
    this.salesCount,
    this.summary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      managerInfo: json['managerInfo'] != null
          ? ManagerInfo.fromJson(json['managerInfo'])
          : null,
      dashboard: json['dashboard'] != null
          ? List<StageDashboard>.from(
              json['dashboard'].map((x) => StageDashboard.fromJson(x)))
          : [],
      managerFresh: json['managerFresh'] != null
          ? ManagerStage.fromJson(json['managerFresh'])
          : null,
      managerPending: json['managerPending'] != null
          ? ManagerStage.fromJson(json['managerPending'])
          : null,
      teamLeaders: json['teamLeaders'] != null
          ? List<TeamLeader>.from(
              json['teamLeaders'].map((x) => TeamLeader.fromJson(x)))
          : [],
      directManagerSales: json['directManagerSales'] != null
          ? List<Sales>.from(
              json['directManagerSales'].map((x) => Sales.fromJson(x)))
          : [],
      directManagerSalesCount: json['directManagerSalesCount'],
      salesCount: json['salesCount'],
      summary: json['summary'] != null
          ? Summary.fromJson(json['summary'])
          : null,
    );
  }
}

class ManagerInfo {
  String? id;
  String? name;
  String? email;

  ManagerInfo({this.id, this.name, this.email});

  factory ManagerInfo.fromJson(Map<String, dynamic> json) {
    return ManagerInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class StageDashboard {
  String? stageId;
  String? stageName;
  int? leadsCount;

  StageDashboard({this.stageId, this.stageName, this.leadsCount});

  factory StageDashboard.fromJson(Map<String, dynamic> json) {
    return StageDashboard(
      stageId: json['stageId'],
      stageName: json['stageName'],
      leadsCount: json['leadsCount'],
    );
  }
}

class ManagerStage {
  String? stageName;
  int? leadsCount;
  String? description;
  String? stageId;
  List<String>? salesIds;

  ManagerStage({
    this.stageName,
    this.leadsCount,
    this.description,
    this.stageId,
    this.salesIds,
  });

  factory ManagerStage.fromJson(Map<String, dynamic> json) {
    return ManagerStage(
      stageName: json['stageName'],
      leadsCount: json['leadsCount'],
      description: json['description'],
      stageId: json['stageId'],
      salesIds: json['salesIds'] != null
          ? List<String>.from(json['salesIds'])
          : [],
    );
  }
}

class TeamLeader {
  TeamLeaderInfo? teamLeaderInfo;
  List<Sales>? sales;
  int? salesCount;
  LeadsStats? leads;

  TeamLeader({
    this.teamLeaderInfo,
    this.sales,
    this.salesCount,
    this.leads,
  });

  factory TeamLeader.fromJson(Map<String, dynamic> json) {
    return TeamLeader(
      teamLeaderInfo: json['teamLeaderInfo'] != null
          ? TeamLeaderInfo.fromJson(json['teamLeaderInfo'])
          : null,
      sales: json['sales'] != null
          ? List<Sales>.from(
              json['sales'].map((x) => Sales.fromJson(x)))
          : [],
      salesCount: json['salesCount'],
      leads: json['leads'] != null
          ? LeadsStats.fromJson(json['leads'])
          : null,
    );
  }
}

class TeamLeaderInfo {
  String? id;
  String? name;
  String? email;
  String? role;

  TeamLeaderInfo({this.id, this.name, this.email, this.role});

  factory TeamLeaderInfo.fromJson(Map<String, dynamic> json) {
    return TeamLeaderInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class Sales {
  String? id;
  String? name;
  UserLog? userlog;

  Sales({this.id, this.name, this.userlog});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      id: json['id'],
      name: json['name'],
      userlog: json['userlog'] != null
          ? UserLog.fromJson(json['userlog'])
          : null,
    );
  }
}

class UserLog {
  String? id;
  String? name;
  String? email;

  UserLog({this.id, this.name, this.email});

  factory UserLog.fromJson(Map<String, dynamic> json) {
    return UserLog(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class LeadsStats {
  int? fresh;
  int? pending;
  int? total;

  LeadsStats({this.fresh, this.pending, this.total});

  factory LeadsStats.fromJson(Map<String, dynamic> json) {
    return LeadsStats(
      fresh: json['fresh'],
      pending: json['pending'],
      total: json['total'],
    );
  }
}

class Summary {
  int? totalLeads;
  int? managerFreshLeads;
  int? managerPendingLeads;
  int? totalTeamLeaders;
  int? totalSales;
  int? totalStages;
  int? stagesWithLeads;

  Summary({
    this.totalLeads,
    this.managerFreshLeads,
    this.managerPendingLeads,
    this.totalTeamLeaders,
    this.totalSales,
    this.totalStages,
    this.stagesWithLeads,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalLeads: json['totalLeads'],
      managerFreshLeads: json['managerFreshLeads'],
      managerPendingLeads: json['managerPendingLeads'],
      totalTeamLeaders: json['totalTeamLeaders'],
      totalSales: json['totalSales'],
      totalStages: json['totalStages'],
      stagesWithLeads: json['stagesWithLeads'],
    );
  }
}

class Meta {
  String? executionTime;
  bool? fromCache;
  String? timestamp;

  Meta({this.executionTime, this.fromCache, this.timestamp});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      executionTime: json['executionTime'],
      fromCache: json['fromCache'],
      timestamp: json['timestamp'],
    );
  }
}