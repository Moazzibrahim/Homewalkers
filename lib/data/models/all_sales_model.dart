class AllSalesModel {
  final int results;
  final Pagination pagination;
  final List<SalesData> data;

  AllSalesModel({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory AllSalesModel.fromJson(Map<String, dynamic> json) {
    return AllSalesModel(
      results: json['results'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<SalesData>.from(
          json['data'].map((item) => SalesData.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() => {
        'results': results,
        'pagination': pagination.toJson(),
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class Pagination {
  final int currentPage;
  final int limit;
  final int numberOfPages;

  Pagination({
    required this.currentPage,
    required this.limit,
    required this.numberOfPages,
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
  final String id;
  final String name;
  final List<City> city;
  final String notes;
  final UserLogsModel userlog;
  final DateTime lastAssigned;
  final int maxLeadsPerProject;
  final int assignedLeads;
  final TeamLeaderModel teamleader;
  final Manager manager;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v; // corresponds to __v
  final String salesIsActivate;

  SalesData({
    required this.id,
    required this.name,
    required this.city,
    required this.notes,
    required this.userlog,
    required this.lastAssigned,
    required this.maxLeadsPerProject,
    required this.assignedLeads,
    required this.teamleader,
    required this.manager,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.salesIsActivate,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      id: json['_id'],
      name: json['name'],
      city: List<City>.from(json['city'].map((x) => City.fromJson(x))),
      notes: json['notes'],
      userlog: UserLogsModel.fromJson(json['userlog']),
      lastAssigned: DateTime.parse(json['lastAssigned']),
      maxLeadsPerProject: json['maxLeadsPerProject'],
      assignedLeads: json['assignedLeads'],
      teamleader: TeamLeaderModel.fromJson(json['teamleader']),
      manager: Manager.fromJson(json['Manager']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
      salesIsActivate: json['salesisactivate'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'city': city.map((e) => e.toJson()).toList(),
        'notes': notes,
        'userlog': userlog.toJson(),
        'lastAssigned': lastAssigned.toIso8601String(),
        'maxLeadsPerProject': maxLeadsPerProject,
        'assignedLeads': assignedLeads,
        'teamleader': teamleader.toJson(),
        'Manager': manager.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        '__v': v,
        'salesisactivate': salesIsActivate,
      };
}

class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
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
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImg;
  final String role;

  UserLogsModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImg,
    required this.role,
  });

  factory UserLogsModel.fromJson(Map<String, dynamic> json) {
    return UserLogsModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImg: json['profileImg'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImg': profileImg,
        'role': role,
      };
}

class TeamLeaderModel { 
  final String id;
  final String name;
  final String email;
  final String profileImg;
  final String role;

  TeamLeaderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImg,
    required this.role,
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
  final String id;
  final String name;
  final String email;
  final String profileImg;
  final String role;

  Manager({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImg,
    required this.role,
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
