class CommunicationWayResponse {
  final int? results;
  final Pagination? pagination;
  final List<CommunicationWay>? data;

  CommunicationWayResponse({this.results, this.pagination, this.data});

  factory CommunicationWayResponse.fromJson(Map<String, dynamic> json) {
    return CommunicationWayResponse(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CommunicationWay.fromJson(e))
          .toList(),
    );
  }
}

class Pagination {
  final int? currentPage;
  final int? limit;
  final int? numberOfPages;

  Pagination({this.currentPage, this.limit, this.numberOfPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      limit: json['limit'],
      numberOfPages: json['NumberOfPages'],
    );
  }
}

class CommunicationWay {
  final String? id;
  final String? name;
  final String? slug;
  final String? isCommunicationWayActivate;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  CommunicationWay({
    this.id,
    this.name,
    this.slug,
    this.isCommunicationWayActivate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CommunicationWay.fromJson(Map<String, dynamic> json) {
    return CommunicationWay(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      isCommunicationWayActivate: json['iscommunicationwayactivate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
