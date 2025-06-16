class CancelReasonResponse {
  final int? results;
  final Pagination? pagination;
  final List<CancelReason>? data;

  CancelReasonResponse({
    this.results,
    this.pagination,
    this.data,
  });

  factory CancelReasonResponse.fromJson(Map<String, dynamic> json) {
    return CancelReasonResponse(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? List<CancelReason>.from(
              json['data'].map((x) => CancelReason.fromJson(x)))
          : [],
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
      currentPage: json['currentPage'],
      limit: json['limit'],
      numberOfPages: json['NumberOfPages'],
    );
  }
}

class CancelReason {
  final String? id;
  final String? cancelReason;
  final String? slug;
  final String? isCancelReasonActivate;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  CancelReason({
    this.id,
    this.cancelReason,
    this.slug,
    this.isCancelReasonActivate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CancelReason.fromJson(Map<String, dynamic> json) {
    return CancelReason(
      id: json['_id'],
      cancelReason: json['cancelreason'],
      slug: json['slug'],
      isCancelReasonActivate: json['iscancelreasonactivate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
