

class NewCommentsModel {
  final bool success;
  final List<NewComment> comments;
  final UserInfo userInfo;
  final FilterInfo filter;
  final AssignmentInfo assignmentInfo;
  final DebugInfo debug;
  final int totalComments;
  final int showing;
  final Pagination pagination;
  final Performance performance;

  NewCommentsModel({
    required this.success,
    required this.comments,
    required this.userInfo,
    required this.filter,
    required this.assignmentInfo,
    required this.debug,
    required this.totalComments,
    required this.showing,
    required this.pagination,
    required this.performance,
  });

  factory NewCommentsModel.fromJson(Map<String, dynamic> json) => NewCommentsModel(
        success: json['success'] as bool? ?? false,
        comments: (json['comments'] as List<dynamic>?)
                ?.map((e) => NewComment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        userInfo: UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>? ?? {}),
        filter: FilterInfo.fromJson(json['filter'] as Map<String, dynamic>? ?? {}),
        assignmentInfo: AssignmentInfo.fromJson(json['assignmentInfo'] as Map<String, dynamic>? ?? {}),
        debug: DebugInfo.fromJson(json['debug'] as Map<String, dynamic>? ?? {}),
        totalComments: (json['totalComments'] as int?) ?? 0,
        showing: (json['showing'] as int?) ?? 0,
        pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
        performance: Performance.fromJson(json['performance'] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'comments': comments.map((e) => e.toJson()).toList(),
        'userInfo': userInfo.toJson(),
        'filter': filter.toJson(),
        'assignmentInfo': assignmentInfo.toJson(),
        'debug': debug.toJson(),
        'totalComments': totalComments,
        'showing': showing,
        'pagination': pagination.toJson(),
        'performance': performance.toJson(),
      };
}

class NewComment {
  final Sales sales;
  final CommentItem? firstcomment;
  final CommentItem? secondcomment;
  final Stage? stage;
  final String id;
  final DateTime? stageDate;
  final List<dynamic> replies;

  NewComment({
    required this.sales,
    this.firstcomment,
    this.secondcomment,
    this.stage,
    required this.id,
    this.stageDate,
    required this.replies,
  });

  factory NewComment.fromJson(Map<String, dynamic> json) => NewComment(
        sales: Sales.fromJson(json['sales'] as Map<String, dynamic>? ?? {}),
        firstcomment: json['firstcomment'] != null
            ? CommentItem.fromJson(json['firstcomment'] as Map<String, dynamic>)
            : null,
        secondcomment: json['secondcomment'] != null
            ? CommentItem.fromJson(json['secondcomment'] as Map<String, dynamic>)
            : null,
        stage: json['stage'] != null
            ? Stage.fromJson(json['stage'] as Map<String, dynamic>)
            : null,
        id: (json['_id'] as String?) ?? '',
        stageDate: json['stageDate'] != null
            ? DateTime.tryParse(json['stageDate'] as String)
            : null,
        replies: (json['replies'] as List<dynamic>?) ?? [],
      );

  Map<String, dynamic> toJson() => {
        'sales': sales.toJson(),
        'firstcomment': firstcomment?.toJson(),
        'secondcomment': secondcomment?.toJson(),
        'stage': stage?.toJson(),
        '_id': id,
        'stageDate': stageDate?.toIso8601String(),
        'replies': replies,
      };
}

class Sales {
  final String id;
  final String? name;
  final String? profileImg;
  final String? email;
  final String? role;

  Sales({
    required this.id,
    this.name,
    this.profileImg,
    this.email,
    this.role,
  });

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
        id: (json['_id'] as String?) ?? '',
        name: json['name'] as String?,
        profileImg: json['profileImg'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'profileImg': profileImg,
        'email': email,
        'role': role,
      };
}

class CommentItem {
  final String? text;
  final DateTime? date;

  CommentItem({
    this.text,
    this.date,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) => CommentItem(
        text: json['text'] as String?,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'date': date?.toIso8601String(),
      };
}

class Stage {
  final String id;
  final String? name;

  Stage({
    required this.id,
    this.name,
  });

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
        id: (json['_id'] as String?) ?? '',
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };
}

class UserInfo {
  final String? id;
  final String? role;
  final String? name;
  final String? email;

  UserInfo({
    this.id,
    this.role,
    this.name,
    this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json['id'] as String?,
        role: json['role'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'name': name,
        'email': email,
      };
}

class FilterInfo {
  final bool? applied;
  final String? reason;
  final dynamic dateFilter;
  final String? logic;

  FilterInfo({
    this.applied,
    this.reason,
    this.dateFilter,
    this.logic,
  });

  factory FilterInfo.fromJson(Map<String, dynamic> json) => FilterInfo(
        applied: json['applied'] as bool?,
        reason: json['reason'] as String?,
        dateFilter: json['dateFilter'],
        logic: json['logic'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'applied': applied,
        'reason': reason,
        'dateFilter': dateFilter,
        'logic': logic,
      };
}

class AssignmentInfo {
  final DateTime? assignDateTime;
  final bool? clearHistory;
  final AssignedBy? assignedBy;

  AssignmentInfo({
    this.assignDateTime,
    this.clearHistory,
    this.assignedBy,
  });

  factory AssignmentInfo.fromJson(Map<String, dynamic> json) => AssignmentInfo(
        assignDateTime: json['assignDateTime'] != null
            ? DateTime.tryParse(json['assignDateTime'] as String)
            : null,
        clearHistory: json['clearHistory'] as bool?,
        assignedBy: json['assignedBy'] != null
            ? AssignedBy.fromJson(json['assignedBy'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'assignDateTime': assignDateTime?.toIso8601String(),
        'clearHistory': clearHistory,
        'assignedBy': assignedBy?.toJson(),
      };
}

class AssignedBy {
  final String? id;
  final String? name;
  final String? role;

  AssignedBy({
    this.id,
    this.name,
    this.role,
  });

  factory AssignedBy.fromJson(Map<String, dynamic> json) => AssignedBy(
        id: json['id'] as String?,
        name: json['name'] as String?,
        role: json['role'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
      };
}

class DebugInfo {
  final bool? assignmentFound;
  final String? assignedFromRole;
  final String? userRole;
  final bool? conditionsMet;

  DebugInfo({
    this.assignmentFound,
    this.assignedFromRole,
    this.userRole,
    this.conditionsMet,
  });

  factory DebugInfo.fromJson(Map<String, dynamic> json) => DebugInfo(
        assignmentFound: json['assignmentFound'] as bool?,
        assignedFromRole: json['assignedFromRole'] as String?,
        userRole: json['userRole'] as String?,
        conditionsMet: json['conditionsMet'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'assignmentFound': assignmentFound,
        'assignedFromRole': assignedFromRole,
        'userRole': userRole,
        'conditionsMet': conditionsMet,
      };
}

class Pagination {
  final int? page;
  final int? limit;
  final int? totalPages;
  final bool? hasNext;
  final bool? hasPrev;

  Pagination({
    this.page,
    this.limit,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json['page'] as int?,
        limit: json['limit'] as int?,
        totalPages: json['totalPages'] as int?,
        hasNext: json['hasNext'] as bool?,
        hasPrev: json['hasPrev'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
        'hasNext': hasNext,
        'hasPrev': hasPrev,
      };
}

class Performance {
  final int? totalQueries;
  final bool? optimized;

  Performance({
    this.totalQueries,
    this.optimized,
  });

  factory Performance.fromJson(Map<String, dynamic> json) => Performance(
        totalQueries: json['totalQueries'] as int?,
        optimized: json['optimized'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'totalQueries': totalQueries,
        'optimized': optimized,
      };
}