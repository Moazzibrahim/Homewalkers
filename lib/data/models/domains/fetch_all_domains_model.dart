class CompaniesResponse {
  bool? success;
  List<CompanyData>? data;
  Pagination? pagination;

  CompaniesResponse({this.success, this.data, this.pagination});

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    return CompaniesResponse(
      success: json['success'],
      data:
          json['data'] != null
              ? List<CompanyData>.from(
                json['data'].map((x) => CompanyData.fromJson(x)),
              )
              : null,
      pagination:
          json['pagination'] != null
              ? Pagination.fromJson(json['pagination'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((x) => x.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class CompanyData {
  String? id;
  String? companyName;
  String? companyDomain;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  CompanyData({
    this.id,
    this.companyName,
    this.companyDomain,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      id: json['_id'],
      companyName: json['company_name'],
      companyDomain: json['company_domain'],
      isActive: json['is_active'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'company_name': companyName,
      'company_domain': companyDomain,
      'is_active': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
