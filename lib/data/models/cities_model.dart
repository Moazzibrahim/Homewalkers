class CityResponse {
  final int? results;
  final Pagination? pagination;
  final List<City>? data;

  CityResponse({this.results, this.pagination, this.data});

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => City.fromJson(e))
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
class City {
  final String? id;
  final String? name;
  final String? slug;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  City({
    this.id,
    this.name,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
