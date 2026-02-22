// ignore_for_file: file_names, non_constant_identifier_names

class MeetingcommentsModel {
  String? status;
  num? results;
  Pagination? pagination;
  List<LeadHistoryData>? data;

  MeetingcommentsModel({this.status, this.results, this.pagination, this.data});

  factory MeetingcommentsModel.fromJson(Map<String, dynamic> json) {
    return MeetingcommentsModel(
      status: json['status'],
      results: json['results'],
      pagination:
          json['pagination'] != null
              ? Pagination.fromJson(json['pagination'])
              : null,
      data:
          json['data'] != null
              ? List<LeadHistoryData>.from(
                json['data'].map((x) => LeadHistoryData.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'results': results,
    'pagination': pagination?.toJson(),
    'data': data?.map((x) => x.toJson()).toList(),
  };
}

class Pagination {
  num? page;
  num? limit;
  num? totalPages;
  num? totalResults;
  num? nextPage;
  dynamic prevPage; // Changed to dynamic because it can be null
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
    this.nextPage,
    this.prevPage,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      totalResults: json['totalResults'],
      nextPage: json['nextPage'],
      prevPage: json['prevPage'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
    'totalResults': totalResults,
    'nextPage': nextPage,
    'prevPage': prevPage,
    'hasNextPage': hasNextPage,
    'hasPrevPage': hasPrevPage,
  };
}

class LeadHistoryData {
  String? id;
  LeadModel? lead;
  StageModel? stage;
  String? stageDate;
  String? comment;
  UserModel? commentBy;
  String? salesdeveloperName;
  List<dynamic>? replies;
  String? createdAt;
  String? updatedAt;
  num? v;

  LeadHistoryData({
    this.id,
    this.lead,
    this.stage,
    this.stageDate,
    this.comment,
    this.commentBy,
    this.salesdeveloperName,
    this.replies,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LeadHistoryData.fromJson(Map<String, dynamic> json) {
    return LeadHistoryData(
      id: json['_id'],
      lead: json['lead'] != null ? LeadModel.fromJson(json['lead']) : null,
      stage: json['stage'] != null ? StageModel.fromJson(json['stage']) : null,
      stageDate: json['stageDate'],
      comment: json['comment'],
      commentBy:
          json['commentBy'] != null
              ? UserModel.fromJson(json['commentBy'])
              : null,
      salesdeveloperName: json['salesdeveloperName'],
      replies: json['replies'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'lead': lead?.toJson(),
    'stage': stage?.toJson(),
    'stageDate': stageDate,
    'comment': comment,
    'commentBy': commentBy?.toJson(),
    'salesdeveloperName': salesdeveloperName,
    'replies': replies,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': v,
  };
}

class LeadModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  ProjectModel? project;
  dynamic sales; // Changed to dynamic because it can be null
  StageModel? stage;
  ChannelModel? chanel;
  CommunicationWayModel? communicationway;
  UserModel? addby;
  UserModel? updatedby;
  CampaignModel? campaign;
  List<AllVersionModel>? allVersions;
  List<dynamic>?
  mergeHistory; // Changed to List<dynamic> because it's empty array

  LeadModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.project,
    this.sales,
    this.stage,
    this.chanel,
    this.communicationway,
    this.addby,
    this.updatedby,
    this.campaign,
    this.allVersions,
    this.mergeHistory,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      project:
          json['project'] != null
              ? ProjectModel.fromJson(json['project'])
              : null,
      sales: json['sales'],
      stage: json['stage'] != null ? StageModel.fromJson(json['stage']) : null,
      chanel:
          json['chanel'] != null ? ChannelModel.fromJson(json['chanel']) : null,
      communicationway:
          json['communicationway'] != null
              ? CommunicationWayModel.fromJson(json['communicationway'])
              : null,
      addby: json['addby'] != null ? UserModel.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null
              ? UserModel.fromJson(json['updatedby'])
              : null,
      campaign:
          json['campaign'] != null
              ? CampaignModel.fromJson(json['campaign'])
              : null,
      allVersions:
          json['allVersions'] != null
              ? List<AllVersionModel>.from(
                json['allVersions'].map((x) => AllVersionModel.fromJson(x)),
              )
              : null,
      mergeHistory: json['mergeHistory'] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'project': project?.toJson(),
    'sales': sales,
    'stage': stage?.toJson(),
    'chanel': chanel?.toJson(),
    'communicationway': communicationway?.toJson(),
    'addby': addby?.toJson(),
    'updatedby': updatedby?.toJson(),
    'campaign': campaign?.toJson(),
    'allVersions': allVersions?.map((x) => x.toJson()).toList(),
    'mergeHistory': mergeHistory,
  };
}

class ProjectModel {
  String? id;
  String? name;
  DeveloperModel? developer;
  CityModel? city;
  num? startprice;

  ProjectModel({
    this.id,
    this.name,
    this.developer,
    this.city,
    this.startprice,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'],
      name: json['name'],
      developer:
          json['developer'] != null
              ? DeveloperModel.fromJson(json['developer'])
              : null,
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      startprice: json['startprice'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'developer': developer?.toJson(),
    'city': city?.toJson(),
    'startprice': startprice,
  };
}

class DeveloperModel {
  String? id;
  String? name;

  DeveloperModel({this.id, this.name});

  factory DeveloperModel.fromJson(Map<String, dynamic> json) {
    return DeveloperModel(id: json['_id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class CityModel {
  String? id;
  String? name;

  CityModel({this.id, this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['_id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class StageModel {
  String? id;
  String? name;
  StageType? stagetype;

  StageModel({this.id, this.name, this.stagetype});

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      id: json['_id'],
      name: json['name'],
      stagetype:
          json['stagetype'] != null
              ? StageType.fromJson(json['stagetype'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'stagetype': stagetype?.toJson(),
  };
}

class StageType {
  String? id;
  String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(id: json['_id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class UserModel {
  String? id;
  String? name;
  String? email;
  String? profileImg;
  String? role;

  UserModel({this.id, this.name, this.email, this.profileImg, this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profileImg: json['profileImg'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'profileImg': profileImg,
    'role': role,
  };
}

// New Models for additional fields in the response

class ChannelModel {
  String? id;
  String? name;
  String? code;

  ChannelModel({this.id, this.name, this.code});

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'code': code};
}

class CommunicationWayModel {
  String? id;
  String? name;

  CommunicationWayModel({this.id, this.name});

  factory CommunicationWayModel.fromJson(Map<String, dynamic> json) {
    return CommunicationWayModel(id: json['_id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class CampaignModel {
  String? id;
  String? CampainName;
  String? Date;
  num? Cost;
  bool? isactivate;
  UserModel? addby;
  UserModel? updatedby;

  CampaignModel({
    this.id,
    this.CampainName,
    this.Date,
    this.Cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['_id'],
      CampainName: json['CampainName'],
      Date: json['Date'],
      Cost: json['Cost'],
      isactivate: json['isactivate'],
      addby: json['addby'] != null ? UserModel.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null
              ? UserModel.fromJson(json['updatedby'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'CampainName': CampainName,
    'Date': Date,
    'Cost': Cost,
    'isactivate': isactivate,
    'addby': addby?.toJson(),
    'updatedby': updatedby?.toJson(),
  };
}

class AllVersionModel {
  ProjectModel? project;
  ChannelModel? chanel;
  CampaignModel? campaign;
  CommunicationWayModel? communicationway;
  UserModel? addby;

  AllVersionModel({
    this.project,
    this.chanel,
    this.campaign,
    this.communicationway,
    this.addby,
  });

  factory AllVersionModel.fromJson(Map<String, dynamic> json) {
    return AllVersionModel(
      project:
          json['project'] != null
              ? ProjectModel.fromJson(json['project'])
              : null,
      chanel:
          json['chanel'] != null ? ChannelModel.fromJson(json['chanel']) : null,
      campaign:
          json['campaign'] != null
              ? CampaignModel.fromJson(json['campaign'])
              : null,
      communicationway:
          json['communicationway'] != null
              ? CommunicationWayModel.fromJson(json['communicationway'])
              : null,
      addby: json['addby'] != null ? UserModel.fromJson(json['addby']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'project': project?.toJson(),
    'chanel': chanel?.toJson(),
    'campaign': campaign?.toJson(),
    'communicationway': communicationway?.toJson(),
    'addby': addby?.toJson(),
  };
}
