class ChannelModelresponse {
  final int results;
  final Pagination pagination;
  final List<ChannelModel> data;

  ChannelModelresponse({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory ChannelModelresponse.fromJson(Map<String, dynamic> json) {
    return ChannelModelresponse(
      results: json['results'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<ChannelModel>.from(json['data'].map((item) => ChannelModel.fromJson(item))),
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

class ChannelModel {
  final String id;
  final String name;
  final String slug;
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ChannelModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      code: json['code'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}
