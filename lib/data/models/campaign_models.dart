class CampaignResponse {
  final int? results;
  final Pagination? pagination;
  final List<CampaignData>? data;

  CampaignResponse({this.results, this.pagination, this.data});

  factory CampaignResponse.fromJson(Map<String, dynamic> json) {
    return CampaignResponse(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List?)
          ?.map((item) => CampaignData.fromJson(item))
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
class CampaignData {
  final String? id;
  final String? campainName;
  final String? date;
  final int? cost;
  final bool? isActivate;
  final UserInfo? addBy;
  final UserInfo? updatedBy;
  final String? campaignIsActivateDelete;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  CampaignData({
    this.id,
    this.campainName,
    this.date,
    this.cost,
    this.isActivate,
    this.addBy,
    this.updatedBy,
    this.campaignIsActivateDelete,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    return CampaignData(
      id: json['_id'],
      campainName: json['CampainName'],
      date: json['Date'],
      cost: json['Cost'],
      isActivate: json['isactivate'],
      addBy:
          json['addby'] != null ? UserInfo.fromJson(json['addby']) : null,
      updatedBy: json['updatedby'] != null
          ? UserInfo.fromJson(json['updatedby'])
          : null,
      campaignIsActivateDelete: json['campaignisactivatedelete'],
      endDate: json['endDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
class UserInfo {
  final String? id;
  final String? name;
  final String? email;
  final String? role;

  UserInfo({this.id, this.name, this.email, this.role});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}
