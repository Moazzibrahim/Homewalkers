class DevelopersModel {
  final int results;
  final Pagination pagination;
  final List<DeveloperData> data;

  DevelopersModel({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory DevelopersModel.fromJson(Map<String, dynamic> json) {
    return DevelopersModel(
      results: json['results'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<DeveloperData>.from(json['data'].map((x) => DeveloperData.fromJson(x))),
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

class DeveloperData {
  final String id;
  final String name;
  final String slug;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String isDeveloperActivate;

  DeveloperData({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.isDeveloperActivate,
  });

  factory DeveloperData.fromJson(Map<String, dynamic> json) {
    return DeveloperData(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      isDeveloperActivate: json['isdeveloperactivate'],
    );
  }
}
