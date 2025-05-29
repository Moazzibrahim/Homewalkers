class RegionsModel {
  final int results;
  final Pagination pagination;
  final List<City> data;

  RegionsModel({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory RegionsModel.fromJson(Map<String, dynamic> json) {
    return RegionsModel(
      results: json['results'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<City>.from(json['data'].map((x) => City.fromJson(x))),
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

class City {
  final String id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  City({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}
