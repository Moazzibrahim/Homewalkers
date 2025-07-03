// ignore_for_file: non_constant_identifier_names
class NotificationModel {
  final int? results;
  final Pagination? pagination;
  final List<NotificationItem>? data;

  NotificationModel({this.results, this.pagination, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      results: json['results'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List?)
          ?.map((e) => NotificationItem.fromJson(e))
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

class NotificationItem {
  final String? id;
  final String? message;
  final User? receiver;
  final Lead? lead;
  final String? typenotification;
  final User? userdoaction;
  final bool? isRead;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  NotificationItem({
    this.id,
    this.message,
    this.receiver,
    this.lead,
    this.typenotification,
    this.userdoaction,
    this.isRead,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'],
      message: json['message'],
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      lead: json['lead'] != null ? Lead.fromJson(json['lead']) : null,
      typenotification: json['typenotification'],
      userdoaction: json['userdoaction'] != null
          ? User.fromJson(json['userdoaction'])
          : null,
      isRead: json['isRead'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImg;
  final String? role;
  final String? phone;
  final String? fcmToken;

  User({
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
    this.phone,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profileImg: json['profileImg'],
      role: json['role'],
      phone: json['phone'],
      fcmToken: json['fcmToken'],
    );
  }
}

class Lead {
  final String? id;
  final String? name;
  final String? email;
  final Project? project;
  final Sales? sales;
  final Stage? stage;
  final Chanel? chanel;
  final CommunicationWay? communicationway;
  final User? addby;
  final User? updatedby;
  final Campaign? campaign;
  final List<AllVersion>? allVersions;
  final List? mergeHistory;

  Lead({
    this.id,
    this.name,
    this.email,
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

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
      chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
      communicationway: json['communicationway'] != null
          ? CommunicationWay.fromJson(json['communicationway'])
          : null,
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
      campaign:
          json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      allVersions: (json['allVersions'] as List?)
          ?.map((e) => AllVersion.fromJson(e))
          .toList(),
      mergeHistory: json['mergeHistory'],
    );
  }
}

class Project {
  final String? id;
  final String? name;
  final SimpleObj? developer;
  final SimpleObj? city;

  Project({this.id, this.name, this.developer, this.city});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'],
      name: json['name'],
      developer: json['developer'] != null
          ? SimpleObj.fromJson(json['developer'])
          : null,
      city:
          json['city'] != null ? SimpleObj.fromJson(json['city']) : null,
    );
  }
}

class SimpleObj {
  final String? id;
  final String? name;

  SimpleObj({this.id, this.name});

  factory SimpleObj.fromJson(Map<String, dynamic> json) {
    return SimpleObj(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Chanel {
  final String? id;
  final String? name;
  final String? code;

  Chanel({this.id, this.name, this.code});

  factory Chanel.fromJson(Map<String, dynamic> json) {
    return Chanel(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class CommunicationWay {
  final String? id;
  final String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) {
    return CommunicationWay(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class StageType {
  final String? id;
  final String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Stage {
  final String? id;
  final String? name;
  final StageType? stagetype;

  Stage({this.id, this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['_id'],
      name: json['name'],
      stagetype: json['stagetype'] != null
          ? StageType.fromJson(json['stagetype'])
          : null,
    );
  }
}

class Campaign {
  final String? id;
  final String? CampainName;
  final String? Date;
  final int? Cost;
  final bool? isactivate;
  final User? addby;
  final User? updatedby;

  Campaign({
    this.id,
    this.CampainName,
    this.Date,
    this.Cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['_id'],
      CampainName: json['CampainName'],
      Date: json['Date'],
      Cost: json['Cost'],
      isactivate: json['isactivate'],
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
      updatedby: json['updatedby'] != null
          ? User.fromJson(json['updatedby'])
          : null,
    );
  }
}

class Sales {
  final String? id;
  final String? name;
  final List<SimpleObj>? city;
  final User? userlog;
  final User? teamleader;
  final User? manager;

  Sales({
    this.id,
    this.name,
    this.city,
    this.userlog,
    this.teamleader,
    this.manager,
  });

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      id: json['_id'],
      name: json['name'],
      city: (json['city'] as List?)
          ?.map((e) => SimpleObj.fromJson(e))
          .toList(),
      userlog: json['userlog'] != null ? User.fromJson(json['userlog']) : null,
      teamleader:
          json['teamleader'] != null ? User.fromJson(json['teamleader']) : null,
      manager: json['Manager'] != null ? User.fromJson(json['Manager']) : null,
    );
  }
}

class AllVersion {
  final Project? project;
  final Chanel? chanel;
  final Campaign? campaign;
  final CommunicationWay? communicationway;
  final User? addby;

  AllVersion({
    this.project,
    this.chanel,
    this.campaign,
    this.communicationway,
    this.addby,
  });

  factory AllVersion.fromJson(Map<String, dynamic> json) {
    return AllVersion(
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
      campaign:
          json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      communicationway: json['communicationway'] != null
          ? CommunicationWay.fromJson(json['communicationway'])
          : null,
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    );
  }
}
