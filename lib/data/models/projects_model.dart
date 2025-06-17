class ProjectsModel {
  final int? results;
  final Pagination? pagination;
  final List<ProjectData>? data;

  ProjectsModel({
    this.results,
    this.pagination,
    this.data,
  });

  factory ProjectsModel.fromJson(Map<String, dynamic> json) {
    return ProjectsModel(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? List<ProjectData>.from(
              json['data'].map((x) => ProjectData.fromJson(x)))
          : null,
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

class ProjectData {
  final String? id;
  final String? name;
  final Developer? developer;
  final City? city;
  final String? area;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? isProjectActivate;

  ProjectData({
    this.id,
    this.name,
    this.developer,
    this.city,
    this.area,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isProjectActivate,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      id: json['_id'],
      name: json['name'],
      developer: json['developer'] != null
          ? Developer.fromJson(json['developer'])
          : null,
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      area: json['area'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      isProjectActivate: json['isprojectactivate'],
    );
  }
}

class Developer {
  final String? id;
  final String? name;

  Developer({
    this.id,
    this.name,
  });

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class City {
  final String? id;
  final String? name;

  City({
    this.id,
    this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'],
      name: json['name'],
    );
  }
}
