class StageResponse {
  final int results;
  final Pagination pagination;
  final List<StageData> data;

  StageResponse({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory StageResponse.fromJson(Map<String, dynamic> json) {
    return StageResponse(
      results: json['results'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<StageData>.from(json['data'].map((x) => StageData.fromJson(x))),
    );
  }
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
}

class StageData {
  final String id;
  final String name;
  final String slug;
  final String stageIsActivate;
  final StageType stagetype;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  StageData({
    required this.id,
    required this.name,
    required this.slug,
    required this.stageIsActivate,
    required this.stagetype,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory StageData.fromJson(Map<String, dynamic> json) {
    return StageData(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      stageIsActivate: json['stageisactivate'],
      stagetype: StageType.fromJson(json['stagetype']),
      comment: json['Comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}

class StageType {
  final String id;
  final String name;

  StageType({
    required this.id,
    required this.name,
  });

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(
      id: json['_id'],
      name: json['name'],
    );
  }
}
