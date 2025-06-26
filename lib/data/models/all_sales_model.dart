class AllSalesModel {
  final int? results;
  final Pagination? pagination;
  final List<SalesData>? data;

  AllSalesModel({
    this.results,
    this.pagination,
    this.data,
  });

  factory AllSalesModel.fromJson(Map<String, dynamic> json) {
    return AllSalesModel(
      results: json['results'],
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      data: json['data'] != null
          ? List<SalesData>.from(json['data'].map((item) => SalesData.fromJson(item)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'results': results,
        'pagination': pagination?.toJson(),
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class Pagination {
  final int? currentPage;
  final int? limit;
  final int? numberOfPages;

  Pagination({
    this.currentPage,
    this.limit,
    this.numberOfPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      limit: json['limit'],
      numberOfPages: json['NumberOfPages'],
    );
  }

  Map<String, dynamic> toJson() => {
        'currentPage': currentPage,
        'limit': limit,
        'NumberOfPages': numberOfPages,
      };
}

class SalesData {
  final String? id;
  final String? name;
  final List<City>? city;
  final String? notes;
  final UserLogsModel? userlog;
  final DateTime? lastAssigned;
  final int? maxLeadsPerProject;
  final int? assignedLeads;
  final TeamLeaderModel? teamleader;
  final Manager? manager;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? salesIsActivate;

  SalesData({
    this.id,
    this.name,
    this.city,
    this.notes,
    this.userlog,
    this.lastAssigned,
    this.maxLeadsPerProject,
    this.assignedLeads,
    this.teamleader,
    this.manager,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.salesIsActivate,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      id: json['_id'],
      name: json['name'],
      city: json['city'] != null
          ? List<City>.from(json['city'].map((x) => City.fromJson(x)))
          : null,
      notes: json['notes'],
      userlog: json['userlog'] != null ? UserLogsModel.fromJson(json['userlog']) : null,
      lastAssigned: json['lastAssigned'] != null ? DateTime.parse(json['lastAssigned']) : null,
      maxLeadsPerProject: json['maxLeadsPerProject'],
      assignedLeads: json['assignedLeads'],
      teamleader: json['teamleader'] != null ? TeamLeaderModel.fromJson(json['teamleader']) : null,
      manager: json['Manager'] != null ? Manager.fromJson(json['Manager']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
      salesIsActivate: json['salesisactivate'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'city': city?.map((e) => e.toJson()).toList(),
        'notes': notes,
        'userlog': userlog?.toJson(),
        'lastAssigned': lastAssigned?.toIso8601String(),
        'maxLeadsPerProject': maxLeadsPerProject,
        'assignedLeads': assignedLeads,
        'teamleader': teamleader?.toJson(),
        'Manager': manager?.toJson(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        '__v': v,
        'salesisactivate': salesIsActivate,
      };
}

class City {
  final String? id;
  final String? name;

  City({
    this.id,
    this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };
}

class UserLogsModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImg;
  final String? role;
  final String? fcmtoken;

  UserLogsModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
    this.fcmtoken,
  });

  factory UserLogsModel.fromJson(Map<String, dynamic> json) {
    return UserLogsModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImg: json['profileImg'],
      role: json['role'],
      fcmtoken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImg': profileImg,
        'role': role,
        'fcmToken': fcmtoken,
      };
}

class TeamLeaderModel {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImg;
  final String? role;

  TeamLeaderModel({
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
  });

  factory TeamLeaderModel.fromJson(Map<String, dynamic> json) {
    return TeamLeaderModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profileImg: json['profileImg'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'profileImg': profileImg,
        'role': role,
      };
}

class Manager {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImg;
  final String? role;

  Manager({
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profileImg: json['profileImg'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'profileImg': profileImg,
        'role': role,
      };
}
