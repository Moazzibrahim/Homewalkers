class User {
  final String id;
  final String name;
  final String slug;
  final String email;
  final String phone;
  final String profileImg;
  final String role;
  final bool active;
  final String createdAt;
  final String updatedAt;
  final int tokenVersion;
  final bool openComments;
  final bool closeDoneDealComments;

  User({
    required this.id,
    required this.name,
    required this.slug,
    required this.email,
    required this.phone,
    required this.profileImg,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.tokenVersion,
    required this.openComments,
    required this.closeDoneDealComments,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id'],
        name: json['name'],
        slug: json['slug'],
        email: json['email'],
        phone: json['phone'],
        profileImg: json['profileImg'],
        role: json['role'],
        active: json['active'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        tokenVersion: json['tokenVersion'],
        openComments: json['opencomments'],
        closeDoneDealComments: json['CloseDoneDealcomments'],
      );
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'],
        user: User.fromJson(json['data']),
      );
}
