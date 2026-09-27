class ProjectsModel {
  final num? results;
  final Pagination? pagination;
  final List<ProjectData>? data;

  ProjectsModel({this.results, this.pagination, this.data});

  factory ProjectsModel.fromJson(Map<String, dynamic> json) {
    return ProjectsModel(
      results: json['results'] as num?,
      pagination:
          json['pagination'] != null
              ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
              : null,
      data:
          json['data'] != null
              ? List<ProjectData>.from(
                (json['data'] as List).map(
                  (x) => ProjectData.fromJson(x as Map<String, dynamic>),
                ),
              )
              : null,
    );
  }
}

class Pagination {
  final num? currentPage;
  final num? limit;
  final num? numberOfPages;
  final num? totalItems; // إجمالي عدد العناصر
  final num? next; // رقم الصفحة الجاية (ممكن ميبقاش موجود لو دي آخر صفحة)

  Pagination({
    this.currentPage,
    this.limit,
    this.numberOfPages,
    this.totalItems,
    this.next,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] as num?,
      limit: json['limit'] as num?,
      numberOfPages: json['NumberOfPages'] as num?,
      totalItems: json['totalItems'] as num?,
      next: json['next'] as num?,
    );
  }
}

class ProjectData {
  final String? id;
  final String? name;
  final num? startPrice;
  final Developer? developer;
  final City? city;
  final String? area;
  final String? createdAt;
  final String? updatedAt;
  final num? v;
  final String? isProjectActivate;

  ProjectData({
    this.id,
    this.name,
    this.startPrice,
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
      id: json['_id'] as String?,
      name: json['name'] as String?,
      startPrice: json['startprice'] as num?,
      developer:
          json['developer'] != null
              ? Developer.fromJson(json['developer'] as Map<String, dynamic>)
              : null,
      city:
          json['city'] != null
              ? City.fromJson(json['city'] as Map<String, dynamic>)
              : null,
      area: json['area'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as num?,
      isProjectActivate: json['isprojectactivate'] as String?,
    );
  }
}

class Developer {
  final String? id;
  final String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(id: json['_id'] as String?, name: json['name'] as String?);
  }
}

class City {
  final String? id;
  final String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['_id'] as String?, name: json['name'] as String?);
  }
}
