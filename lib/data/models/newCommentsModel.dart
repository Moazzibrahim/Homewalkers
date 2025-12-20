// ignore_for_file: file_names

class NewCommentsModel {
  bool? success;
  List<Commentt>? comments;
  UserInfo? userInfo;
  FilterInfo? filter;
  AssignmentInfo? assignmentInfo;
  DebugInfo? debug;
  int? totalComments;
  int? showing;
  Pagination? pagination;
  Performance? performance;

  NewCommentsModel({
    this.success,
    this.comments,
    this.userInfo,
    this.filter,
    this.assignmentInfo,
    this.debug,
    this.totalComments,
    this.showing,
    this.pagination,
    this.performance,
  });

  factory NewCommentsModel.fromJson(Map<String, dynamic> json) {
    return NewCommentsModel(
      success: json['success'],
      comments:
          (json['comments'] as List?)?.map((e) => Commentt.fromJson(e)).toList(),
      userInfo:
          json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
      filter:
          json['filter'] != null ? FilterInfo.fromJson(json['filter']) : null,
      assignmentInfo:
          json['assignmentInfo'] != null
              ? AssignmentInfo.fromJson(json['assignmentInfo'])
              : null,
      debug: json['debug'] != null ? DebugInfo.fromJson(json['debug']) : null,
      totalComments: json['totalComments'],
      showing: json['showing'],
      pagination:
          json['pagination'] != null
              ? Pagination.fromJson(json['pagination'])
              : null,
      performance:
          json['performance'] != null
              ? Performance.fromJson(json['performance'])
              : null,
    );
  }
}

class Commentt {
  Sales? sales;
  CommentText? firstcomment;
  CommentText? secondcomment;
  String? id;
  DateTime? stageDate;
  List<dynamic>? replies;

  Commentt({
    this.sales,
    this.firstcomment,
    this.secondcomment,
    this.id,
    this.stageDate,
    this.replies,
  });

  factory Commentt.fromJson(Map<String, dynamic> json) {
    return Commentt(
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      firstcomment:
          json['firstcomment'] != null
              ? CommentText.fromJson(json['firstcomment'])
              : null,
      secondcomment:
          json['secondcomment'] != null
              ? CommentText.fromJson(json['secondcomment'])
              : null,
      id: json['_id'],
      stageDate:
          json['stageDate'] != null
              ? DateTime.tryParse(json['stageDate'])
              : null,
      replies: json['replies'] as List?,
    );
  }
}

class Sales {
  String? id;
  String? name;
  String? profileImg;
  String? email;
  String? role;

  Sales({this.id, this.name, this.profileImg, this.email, this.role});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      id: json['_id'],
      name: json['name'],
      profileImg: json['profileImg'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class CommentText {
  String? text;
  DateTime? date;

  CommentText({this.text, this.date});

  factory CommentText.fromJson(Map<String, dynamic> json) {
    return CommentText(
      text: json['text'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    );
  }
}

class UserInfo {
  String? id;
  String? role;
  String? name;
  String? email;

  UserInfo({this.id, this.role, this.name, this.email});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class FilterInfo {
  bool? applied;
  String? reason;
  dynamic dateFilter;
  String? logic;

  FilterInfo({this.applied, this.reason, this.dateFilter, this.logic});

  factory FilterInfo.fromJson(Map<String, dynamic> json) {
    return FilterInfo(
      applied: json['applied'],
      reason: json['reason'],
      dateFilter: json['dateFilter'],
      logic: json['logic'],
    );
  }
}

class AssignmentInfo {
  AssignmentInfo();

  factory AssignmentInfo.fromJson(Map<String, dynamic> json) {
    return AssignmentInfo();
  }
}

class DebugInfo {
  String? userRole;
  bool? conditionsMet;

  DebugInfo({this.userRole, this.conditionsMet});

  factory DebugInfo.fromJson(Map<String, dynamic> json) {
    return DebugInfo(
      userRole: json['userRole'],
      conditionsMet: json['conditionsMet'],
    );
  }
}

class Pagination {
  int? page;
  int? limit;
  int? totalPages;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.page,
    this.limit,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      hasNext: json['hasNext'],
      hasPrev: json['hasPrev'],
    );
  }
}

class Performance {
  int? totalQueries;
  bool? optimized;

  Performance({this.totalQueries, this.optimized});

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      totalQueries: json['totalQueries'],
      optimized: json['optimized'],
    );
  }
}
