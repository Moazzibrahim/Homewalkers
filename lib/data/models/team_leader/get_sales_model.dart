class SalesTeamModel {
  bool? success;
  int? count;
  List<SalesTeamData>? data;

  SalesTeamModel({this.success, this.count, this.data});

  factory SalesTeamModel.fromJson(Map<String, dynamic> json) {
    return SalesTeamModel(
      success: json['success'],
      count: json['count'],
      data: (json['data'] as List?)
          ?.map((e) => SalesTeamData.fromJson(e))
          .toList(),
    );
  }
}

class SalesTeamData {
  int? assignedLeads;
  String? id;
  String? name;
  List<City>? city;
  String? notes;
  UserInfo? userlog;
  String? lastAssigned;
  int? maxLeadsPerProject;
  String? createdAt;
  String? updatedAt;
  int? v;
  UserInfo? manager;
  UserInfo? teamleader;
  String? salesisactivate;

  SalesTeamData({
    this.assignedLeads,
    this.id,
    this.name,
    this.city,
    this.notes,
    this.userlog,
    this.lastAssigned,
    this.maxLeadsPerProject,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.manager,
    this.teamleader,
    this.salesisactivate,
  });

  factory SalesTeamData.fromJson(Map<String, dynamic> json) {
    return SalesTeamData(
      assignedLeads: json['assignedLeads'],
      id: json['_id'],
      name: json['name'],
      city: (json['city'] as List?)
          ?.map((e) => City.fromJson(e))
          .toList(),
      notes: json['notes'],
      userlog:
          json['userlog'] != null ? UserInfo.fromJson(json['userlog']) : null,
      lastAssigned: json['lastAssigned'],
      maxLeadsPerProject: json['maxLeadsPerProject'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      manager:
          json['Manager'] != null ? UserInfo.fromJson(json['Manager']) : null,
      teamleader: json['teamleader'] != null
          ? UserInfo.fromJson(json['teamleader'])
          : null,
      salesisactivate: json['salesisactivate'],
    );
  }
}

class City {
  String? id;
  String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class UserInfo {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? profileImg;
  String? role;

  UserInfo({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImg: json['profileImg'],
      role: json['role'],
    );
  }
}
