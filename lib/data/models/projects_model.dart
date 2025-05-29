class ProjectsModel {
  final int results;
  final Pagination pagination;
  final List<ProjectData> data;

  ProjectsModel({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory ProjectsModel.fromJson(Map<String, dynamic> json) {
    return ProjectsModel(
      results: json['results'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<ProjectData>.from(json['data'].map((x) => ProjectData.fromJson(x))),
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

class ProjectData {
  final String id;
  final String name;
  final Developer developer;
  final City city;
  final String area;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String isProjectActivate;

  ProjectData({
    required this.id,
    required this.name,
    required this.developer,
    required this.city,
    required this.area,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.isProjectActivate,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      id: json['_id'],
      name: json['name'],
      developer: Developer.fromJson(json['developer']),
      city: City.fromJson(json['city']),
      area: json['area'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      isProjectActivate: json['isprojectactivate'],
    );
  }
}

class Developer {
  final String id;
  final String name;

  Developer({
    required this.id,
    required this.name,
  });

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'],
      name: json['name'],
    );
  }
}
