// ignore_for_file: non_constant_identifier_names, file_names

DateTime? parseServerDate(String? value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    try {
      final parts = value.split('GMT')[0].trim();
      return DateTime.parse(parts);
    } catch (_) {
      return null;
    }
  }
}

class Leadsadminmodelwithpagination {
  bool? success;
  int? results;
  Pagination? pagination;
  List<LeadDataWithPagination>? data;

  Leadsadminmodelwithpagination({
    this.success,
    this.results,
    this.pagination,
    this.data,
  });

  factory Leadsadminmodelwithpagination.fromJson(Map<String, dynamic> json) =>
      Leadsadminmodelwithpagination(
        success: json['success'] as bool?,
        results: json['results'] as int?,
        pagination:
            json['pagination'] != null
                ? Pagination.fromJson(json['pagination'])
                : null,
        data:
            json['data'] != null
                ? List<LeadDataWithPagination>.from(
                  (json['data'] as List).map(
                    (x) => LeadDataWithPagination.fromJson(x),
                  ),
                )
                : null,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'results': results,
    'pagination': pagination?.toJson(),
    'data': data?.map((x) => x.toJson()).toList(),
  };
}

class Pagination {
  int? currentPage;
  int? limit;
  int? numberOfPages;
  int? totalItems;
  int? totalAllLeads;
  int? totalLeadsActive;
  int? totalLeadsInactive;
  int? numberOfPagesInactive;
  int? activePercentage;
  int? inactivePercentage;
  int? next;

  Pagination({
    this.currentPage,
    this.limit,
    this.numberOfPages,
    this.totalItems,
    this.totalAllLeads,
    this.totalLeadsActive,
    this.totalLeadsInactive,
    this.numberOfPagesInactive,
    this.activePercentage,
    this.inactivePercentage,
    this.next,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json['currentPage'] as int?,
    limit: json['limit'] as int?,
    numberOfPages: json['NumberOfPages'] as int?,
    totalItems: json['totalItems'] as int?,
    totalAllLeads: json['totalAllLeads'] as int?,
    totalLeadsActive: json['totalLeadsActive'] as int?,
    totalLeadsInactive: json['totalLeadsInactive'] as int?,
    numberOfPagesInactive: json['NumberOfPagesInactive'] as int?,
    activePercentage: json['activePercentage'] as int?,
    inactivePercentage: json['inactivePercentage'] as int?,
    next: json['next'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'currentPage': currentPage,
    'limit': limit,
    'NumberOfPages': numberOfPages,
    'totalItems': totalItems,
    'totalAllLeads': totalAllLeads,
    'totalLeadsActive': totalLeadsActive,
    'totalLeadsInactive': totalLeadsInactive,
    'NumberOfPagesInactive': numberOfPagesInactive,
    'activePercentage': activePercentage,
    'inactivePercentage': inactivePercentage,
    'next': next,
  };
}

class LeadDataWithPagination {
  String? id;
  String? name;
  String? leadisactive;
  String? whatsappnumber;
  String? phonenumber2;
  String? jobdescription;
  String? email;
  String? phone;
  Project? project;
  Sales? sales;
  bool? assign;
  bool? ignoredublicate;
  Chanel? chanel;
  CommunicationWay? communicationway;
  String? leedtype;
  bool? assigntype;
  bool? resetcreationdate;
  num? budget;
  num? revenue;
  num? unit_price;
  num? Eoi;
  num? Reservation;
  bool? review;
  String? unitnumber;
  num? commissionratio;
  num? commissionmoney;
  num? cashbackratio;
  num? cashbackmoney;
  DateTime? stagedateupdated;
  DateTime? lastdateassign;
  DateTime? lastcommentdate;
  User? addby;
  User? updatedby;
  Campaign? campaign;
  int? duplicateCount;
  int? relatedLeadsCount;
  List<AllVersion>? allVersions;
  int? totalSubmissions;
  DateTime? date;
  List<dynamic>? mergeHistory;
  DateTime? createdAt;
  DateTime? updatedAt;
  Stage? stage;
  DateTime? last_stage_date_updated;
  LastComment? lastComment;

  LeadDataWithPagination({
    this.id,
    this.name,
    this.leadisactive,
    this.whatsappnumber,
    this.phonenumber2,
    this.jobdescription,
    this.email,
    this.phone,
    this.project,
    this.sales,
    this.assign,
    this.ignoredublicate,
    this.chanel,
    this.communicationway,
    this.leedtype,
    this.assigntype,
    this.resetcreationdate,
    this.budget,
    this.revenue,
    this.unit_price,
    this.Eoi,
    this.Reservation,
    this.review,
    this.unitnumber,
    this.commissionratio,
    this.commissionmoney,
    this.cashbackratio,
    this.cashbackmoney,
    this.stagedateupdated,
    this.lastdateassign,
    this.lastcommentdate,
    this.addby,
    this.updatedby,
    this.campaign,
    this.duplicateCount,
    this.relatedLeadsCount,
    this.allVersions,
    this.totalSubmissions,
    this.date,
    this.mergeHistory,
    this.createdAt,
    this.updatedAt,
    this.stage,
    this.last_stage_date_updated,
    this.lastComment,
  });

  factory LeadDataWithPagination.fromJson(
    Map<String, dynamic> json,
  ) => LeadDataWithPagination(
    id: json['_id'] as String?,
    name: json['name'] as String?,
    leadisactive: json['leadisactive'] as String?,
    whatsappnumber: json['whatsappnumber'] as String?,
    phonenumber2: json['phonenumber2'] as String?,
    jobdescription: json['jobdescription'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    project: json['project'] != null ? Project.fromJson(json['project']) : null,
    sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
    assign: json['assign'] as bool?,
    ignoredublicate: json['ignoredublicate'] as bool?,
    chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
    communicationway:
        json['communicationway'] != null
            ? CommunicationWay.fromJson(json['communicationway'])
            : null,
    leedtype: json['leedtype'] as String?,
    assigntype: json['assigntype'] as bool?,
    resetcreationdate: json['resetcreationdate'] as bool?,
    budget: json['budget'] as num?,
    revenue: json['revenue'] as num?,
    unit_price: json['unit_price'] as num?,
    Eoi: json['Eoi'] as num?,
    Reservation: json['Reservation'] as num?,
    review: json['review'] as bool?,
    unitnumber: json['unitnumber'] as String?,
    commissionratio: json['commissionratio'] as num?,
    commissionmoney: json['commissionmoney'] as num?,
    cashbackratio: json['cashbackratio'] as num?,
    cashbackmoney: json['cashbackmoney'] as num?,
    stagedateupdated: parseServerDate(json['stagedateupdated']),
    lastdateassign: parseServerDate(json['lastdateassign']),
    lastcommentdate: parseServerDate(json['lastcommentdate']),
    addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    updatedby:
        json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
    campaign:
        json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
    duplicateCount: json['duplicateCount'] as int?,
    relatedLeadsCount: json['relatedLeadsCount'] as int?,
    allVersions:
        json['allVersions'] != null
            ? List<AllVersion>.from(
              (json['allVersions'] as List).map((x) => AllVersion.fromJson(x)),
            )
            : null,
    totalSubmissions: json['totalSubmissions'] as int?,
    date: parseServerDate(json['date']),
    mergeHistory: json['mergeHistory'] as List<dynamic>?,
    createdAt: parseServerDate(json['createdAt']),
    updatedAt: parseServerDate(json['updatedAt']),
    stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
    last_stage_date_updated: parseServerDate(json['last_stage_date_updated']),
    lastComment:
        json['lastComment'] != null
            ? LastComment.fromJson(json['lastComment'])
            : null,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'leadisactive': leadisactive,
    'whatsappnumber': whatsappnumber,
    'phonenumber2': phonenumber2,
    'jobdescription': jobdescription,
    'email': email,
    'phone': phone,
    'project': project?.toJson(),
    'sales': sales?.toJson(),
    'assign': assign,
    'ignoredublicate': ignoredublicate,
    'chanel': chanel?.toJson(),
    'communicationway': communicationway?.toJson(),
    'leedtype': leedtype,
    'assigntype': assigntype,
    'resetcreationdate': resetcreationdate,
    'budget': budget,
    'revenue': revenue,
    'unit_price': unit_price,
    'Eoi': Eoi,
    'Reservation': Reservation,
    'review': review,
    'unitnumber': unitnumber,
    'commissionratio': commissionratio,
    'commissionmoney': commissionmoney,
    'cashbackratio': cashbackratio,
    'cashbackmoney': cashbackmoney,
    'stagedateupdated': stagedateupdated?.toIso8601String(),
    'lastdateassign': lastdateassign?.toIso8601String(),
    'lastcommentdate': lastcommentdate?.toIso8601String(),
    'addby': addby?.toJson(),
    'updatedby': updatedby?.toJson(),
    'campaign': campaign?.toJson(),
    'duplicateCount': duplicateCount,
    'relatedLeadsCount': relatedLeadsCount,
    'allVersions': allVersions?.map((x) => x.toJson()).toList(),
    'totalSubmissions': totalSubmissions,
    'date': date?.toIso8601String(),
    'mergeHistory': mergeHistory,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'stage': stage?.toJson(),
    'last_stage_date_updated': last_stage_date_updated?.toIso8601String(),
    'lastComment': lastComment?.toJson(),
  };
}

class Project {
  String? id;
  String? name;
  Developer? developer;
  City? city;
  num? startprice;

  Project({this.id, this.name, this.developer, this.city, this.startprice});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['_id'] as String?,
    name: json['name'] as String?,
    developer:
        json['developer'] != null
            ? Developer.fromJson(json['developer'])
            : null,
    city: json['city'] != null ? City.fromJson(json['city']) : null,
    startprice: json['startprice'] as num?,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'developer': developer?.toJson(),
    'city': city?.toJson(),
    'startprice': startprice,
  };
}

class Developer {
  String? id;
  String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) =>
      Developer(id: json['_id'] as String?, name: json['name'] as String?);

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class City {
  String? id;
  String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) =>
      City(id: json['_id'] as String?, name: json['name'] as String?);

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class Sales {
  String? id;
  String? name;
  List<City>? city;
  User? userlog;
  User? teamleader;
  User? Manager;

  Sales({
    this.id,
    this.name,
    this.city,
    this.userlog,
    this.teamleader,
    this.Manager,
  });

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
    id: json['_id'] as String?,
    name: json['name'] as String?,
    city:
        json['city'] != null
            ? List<City>.from(
              (json['city'] as List).map((x) => City.fromJson(x)),
            )
            : null,
    userlog: json['userlog'] != null ? User.fromJson(json['userlog']) : null,
    teamleader:
        json['teamleader'] != null ? User.fromJson(json['teamleader']) : null,
    Manager: json['Manager'] != null ? User.fromJson(json['Manager']) : null,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'city': city?.map((x) => x.toJson()).toList(),
    'userlog': userlog?.toJson(),
    'teamleader': teamleader?.toJson(),
    'Manager': Manager?.toJson(),
  };
}

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? profileImg;
  String? role;
  String? fcmToken;
  bool? isMarketer;
  List<dynamic>? channels;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
    this.fcmToken,
    this.isMarketer,
    this.channels,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'] as String?,
    name: json['name'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    profileImg: json['profileImg'] as String?,
    role: json['role'] as String?,
    fcmToken: json['fcmToken'] as String?,
    isMarketer: json['isMarketer'] as bool?,
    channels: json['channels'] as List<dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'profileImg': profileImg,
    'role': role,
    'fcmToken': fcmToken,
    'isMarketer': isMarketer,
    'channels': channels,
  };
}

class Chanel {
  String? id;
  String? name;
  String? code;

  Chanel({this.id, this.name, this.code});

  factory Chanel.fromJson(Map<String, dynamic> json) => Chanel(
    id: json['_id'] as String?,
    name: json['name'] as String?,
    code: json['code'] as String?,
  );

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'code': code};
}

class CommunicationWay {
  String? id;
  String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) =>
      CommunicationWay(
        id: json['_id'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class Campaign {
  String? id;
  String? CampainName;
  String? Date;
  num? Cost;
  bool? isactivate;
  User? addby;
  User? updatedby;

  Campaign({
    this.id,
    this.CampainName,
    this.Date,
    this.Cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json['_id'] as String?,
    CampainName: json['CampainName'] as String?,
    Date: json['Date'] as String?,
    Cost: json['Cost'] as num?,
    isactivate: json['isactivate'] as bool?,
    addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    updatedby:
        json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
  );

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

class AllVersion {
  String? name;
  String? email;
  String? phone;
  Project? project;
  Chanel? chanel;
  Campaign? campaign;
  String? leedtype;
  CommunicationWay? communicationway;
  User? addby;
  DateTime? recordedAt;
  int? versionNumber;

  AllVersion({
    this.name,
    this.email,
    this.phone,
    this.project,
    this.chanel,
    this.campaign,
    this.leedtype,
    this.communicationway,
    this.addby,
    this.recordedAt,
    this.versionNumber,
  });

  factory AllVersion.fromJson(Map<String, dynamic> json) => AllVersion(
    name: json['name'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    project: json['project'] != null ? Project.fromJson(json['project']) : null,
    chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
    campaign:
        json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
    leedtype: json['leedtype'] as String?,
    communicationway:
        json['communicationway'] != null
            ? CommunicationWay.fromJson(json['communicationway'])
            : null,
    addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    recordedAt: parseServerDate(json['recordedAt']),
    versionNumber: json['versionNumber'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'project': project?.toJson(),
    'chanel': chanel?.toJson(),
    'campaign': campaign?.toJson(),
    'leedtype': leedtype,
    'communicationway': communicationway?.toJson(),
    'addby': addby?.toJson(),
    'recordedAt': recordedAt?.toIso8601String(),
    'versionNumber': versionNumber,
  };
}

class Stage {
  String? id;
  String? name;
  StageType? stagetype;

  Stage({this.id, this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    id: json['_id'] as String?,
    name: json['name'] as String?,
    stagetype:
        json['stagetype'] != null
            ? StageType.fromJson(json['stagetype'])
            : null,
  );

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

  factory StageType.fromJson(Map<String, dynamic> json) =>
      StageType(id: json['_id'] as String?, name: json['name'] as String?);

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class LastComment {
  CommentDetails? firstcomment;
  CommentDetails? secondcomment;
  User? sales;
  DateTime? stageDate;
  DateTime? actionCreatedAt;
  DateTime? actionUpdatedAt;

  LastComment({
    this.firstcomment,
    this.secondcomment,
    this.sales,
    this.stageDate,
    this.actionCreatedAt,
    this.actionUpdatedAt,
  });

  factory LastComment.fromJson(Map<String, dynamic> json) => LastComment(
    firstcomment:
        json['firstcomment'] != null
            ? CommentDetails.fromJson(json['firstcomment'])
            : null,
    secondcomment:
        json['secondcomment'] != null
            ? CommentDetails.fromJson(json['secondcomment'])
            : null,
    sales: json['sales'] != null ? User.fromJson(json['sales']) : null,
    stageDate: parseServerDate(json['stageDate']),
    actionCreatedAt: parseServerDate(json['actionCreatedAt']),
    actionUpdatedAt: parseServerDate(json['actionUpdatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'firstcomment': firstcomment?.toJson(),
    'secondcomment': secondcomment?.toJson(),
    'sales': sales?.toJson(),
    'stageDate': stageDate?.toIso8601String(),
    'actionCreatedAt': actionCreatedAt?.toIso8601String(),
    'actionUpdatedAt': actionUpdatedAt?.toIso8601String(),
  };
}

class CommentDetails {
  String? text;
  DateTime? date;

  CommentDetails({this.text, this.date});

  factory CommentDetails.fromJson(Map<String, dynamic> json) => CommentDetails(
    text: json['text'] as String?,
    date: parseServerDate(json['date']),
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'date': date?.toIso8601String(),
  };
}
