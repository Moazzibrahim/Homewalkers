class AdminSalesModel {
  bool? success;
  List<SalesData>? data;
  Meta? meta;

  AdminSalesModel({
    this.success,
    this.data,
    this.meta,
  });

  factory AdminSalesModel.fromJson(Map<String, dynamic> json) {
    return AdminSalesModel(
      success: json['success'],
      data: json['data'] != null
          ? List<SalesData>.from(
              json['data'].map((x) => SalesData.fromJson(x)),
            )
          : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((x) => x.toJson()).toList(),
      'meta': meta?.toJson(),
    };
  }
}
class SalesData {
  String? salesId;
  String? salesName;
  int? activeLeadsCount;
  String? teamleaderId;
  String? managerId;

  SalesData({
    this.salesId,
    this.salesName,
    this.activeLeadsCount,
    this.teamleaderId,
    this.managerId,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      salesId: json['salesId'],
      salesName: json['salesName'],
      activeLeadsCount: json['activeLeadsCount'],
      teamleaderId: json['teamleaderId'],
      managerId: json['managerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesId': salesId,
      'salesName': salesName,
      'activeLeadsCount': activeLeadsCount,
      'teamleaderId': teamleaderId,
      'managerId': managerId,
    };
  }
}
class Meta {
  int? totalSales;
  int? totalActiveLeads;
  String? executionTime;
  String? timestamp;
  bool? isFast;
  FiltersApplied? filtersApplied;

  Meta({
    this.totalSales,
    this.totalActiveLeads,
    this.executionTime,
    this.timestamp,
    this.isFast,
    this.filtersApplied,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      totalSales: json['totalSales'],
      totalActiveLeads: json['totalActiveLeads'],
      executionTime: json['executionTime'],
      timestamp: json['timestamp'],
      isFast: json['isFast'],
      filtersApplied: json['filtersApplied'] != null
          ? FiltersApplied.fromJson(json['filtersApplied'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalActiveLeads': totalActiveLeads,
      'executionTime': executionTime,
      'timestamp': timestamp,
      'isFast': isFast,
      'filtersApplied': filtersApplied?.toJson(),
    };
  }
}
class FiltersApplied {
  String? salesIsActivate;
  String? leadIsActive;

  FiltersApplied({
    this.salesIsActivate,
    this.leadIsActive,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(
      salesIsActivate: json['salesisactivate'],
      leadIsActive: json['leadisactive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesisactivate': salesIsActivate,
      'leadisactive': leadIsActive,
    };
  }
}
