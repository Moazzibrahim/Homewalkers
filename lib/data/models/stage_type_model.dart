class StageTypeResponse {
  final int? results;
  final Pagination? pagination;
  final List<StageDatam>? data;

  StageTypeResponse({
    this.results,
    this.pagination,
    this.data,
  });

  factory StageTypeResponse.fromJson(Map<String, dynamic> json) {
    return StageTypeResponse(
      results: json['results'] as int?,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => StageDatam.fromJson(item))
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
class StageDatam {
  final String? id;
  final String? name;
  final String? slug;
  final String? comment;
  final String? isStageTypeActivate;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  StageDatam({
    this.id,
    this.name,
    this.slug,
    this.comment,
    this.isStageTypeActivate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory StageDatam.fromJson(Map<String, dynamic> json) {
    return StageDatam(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?, // nullable field, not always present
      comment: json['Comment'] as String?,
      isStageTypeActivate: json['isstagetypeactivate'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }
}
