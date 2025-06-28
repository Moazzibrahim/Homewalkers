class AllUsersModelForAddUsers {
  final int? results;
  final Pagination? pagination;
  final List<UserData>? data;

  AllUsersModelForAddUsers({
    this.results,
    this.pagination,
    this.data,
  });

  factory AllUsersModelForAddUsers.fromJson(Map<String, dynamic> json) {
    return AllUsersModelForAddUsers(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => UserData.fromJson(item))
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

class UserData {
  final String? id;
  final String? name;
  final String? slug;
  final String? email;
  final String? phone;
  final String? password;
  final String? role;
  final bool? active;
  final bool? opencomments;
  final bool? closeDoneDealcomments;
  final int? tokenVersion;
  final String? fcmToken;
  final String? profileImg;
  final String? createdAt;
  final String? updatedAt;
  final String? passwordChangedAt;
  final int? v;

  UserData({
    this.id,
    this.name,
    this.slug,
    this.email,
    this.phone,
    this.password,
    this.role,
    this.active,
    this.opencomments,
    this.closeDoneDealcomments,
    this.tokenVersion,
    this.fcmToken,
    this.profileImg,
    this.createdAt,
    this.updatedAt,
    this.passwordChangedAt,
    this.v,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      role: json['role'],
      active: json['active'],
      opencomments: json['opencomments'],
      closeDoneDealcomments: json['CloseDoneDealcomments'],
      tokenVersion: json['tokenVersion'],
      fcmToken: json['fcmToken'],
      profileImg: json['profileImg'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      passwordChangedAt: json['passwordChangedAt'],
      v: json['__v'],
    );
  }
}
