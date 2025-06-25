class StageResponse {
  final int? results;
  final Pagination? pagination;
  final List<StageDatas>? data;

  StageResponse({
    this.results,
    this.pagination,
    this.data,
  });

  factory StageResponse.fromJson(Map<String, dynamic> json) {
    return StageResponse(
      results: json['results'] as int?,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => StageDatas.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
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
      currentPage: json['currentPage'] as int?,
      limit: json['limit'] as int?,
      numberOfPages: json['NumberOfPages'] as int?,
    );
  }
}

class StageDatas {
  final String? id;
  final String? name;
  final String? slug;
  final String? stageIsActivate;
  final StageType? stagetype;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  StageDatas({
    this.id,
    this.name,
    this.slug,
    this.stageIsActivate,
    this.stagetype,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory StageDatas.fromJson(Map<String, dynamic> json) {
    final createdStr = json['createdAt'] as String?;
    final updatedStr = json['updatedAt'] as String?;

    return StageDatas(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      stageIsActivate: json['stageisactivate'] as String?,
      stagetype: json['stagetype'] != null
          ? StageType.fromJson(json['stagetype'] as Map<String, dynamic>)
          : null,
      comment: json['Comment'] as String?,
      createdAt: createdStr != null ? DateTime.tryParse(createdStr) : null,
      updatedAt: updatedStr != null ? DateTime.tryParse(updatedStr) : null,
      v: json['__v'] as int?,
    );
  }
}

class StageType {
  final String? id;
  final String? name;

  StageType({
    this.id,
    this.name,
  });

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(
      id: json['_id'] as String?,
      name: json['name'] as String?,
    );
  }
}
