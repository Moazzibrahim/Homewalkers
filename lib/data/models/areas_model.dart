class AreaResponse {
  final int? results;
  final Pagination? pagination;
  final List<AreaData>? data;

  AreaResponse({
    this.results,
    this.pagination,
    this.data,
  });

  factory AreaResponse.fromJson(Map<String, dynamic> json) {
    return AreaResponse(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AreaData.fromJson(e))
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
      currentPage: json['currentPage'],
      limit: json['limit'],
      numberOfPages: json['NumberOfPages'],
    );
  }
}
class AreaData {
  final String? id;
  final String? areaName;
  final String? slug;
  final Region? region;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  AreaData({
    this.id,
    this.areaName,
    this.slug,
    this.region,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AreaData.fromJson(Map<String, dynamic> json) {
    return AreaData(
      id: json['_id'],
      areaName: json['Areaname'],
      slug: json['slug'],
      region: json['Region'] != null ? Region.fromJson(json['Region']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
class Region {
  final String? id;
  final String? name;

  Region({
    this.id,
    this.name,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['_id'],
      name: json['name'],
    );
  }
}
