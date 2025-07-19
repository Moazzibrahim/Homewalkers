class AllUsersModel {
  int? results;
  Pagination? pagination;
  List<Lead>? data;

  AllUsersModel({this.results, this.pagination, this.data});

  factory AllUsersModel.fromJson(Map<String, dynamic> json) {
    return AllUsersModel(
      results: json['results'],
      pagination:
          json['pagination'] != null
              ? Pagination.fromJson(json['pagination'])
              : null,
      data:
          json['data'] != null
              ? List<Lead>.from(json['data'].map((e) => Lead.fromJson(e)))
              : null,
    );
  }
}

class Pagination {
  int? currentPage;
  int? limit;
  int? numberOfPages;

  Pagination({this.currentPage, this.limit, this.numberOfPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      limit: json['limit'],
      numberOfPages: json['NumberOfPages'],
    );
  }
}

class Lead {
  final String? whatsappnumber;
  final String? secondphonenumber;
  final String? jobdescription;
  String? id;
  String? name;
  String? leadisactive;
  String? email;
  String? phone;
  Project? project;
  Sales? sales;
  bool? assign;
  Chanel? chanel;
  CommunicationWay? communicationway;
  String? leedtype;
  num? budget;
  num? revenue;
  num? unitPrice;
  bool? review;
  String? unitnumber;
  num? commissionratio;
  num? commissionmoney;
  num? cashbackratio;
  num? cashbackmoney;
  String? stagedateupdated;
  String? lastdateassign;
  String? lastcommentdate;
  UserInfo? addby;
  UserInfo? updatedby;
  Campaign? campaign;
  int? duplicateCount;
  int? relatedLeadsCount;
  List<LeadVersion>? allVersions;
  int? totalSubmissions;
  String? date;
  List<dynamic>? mergeHistory;
  String? createdAt;
  String? updatedAt;
  int? v;
  Stage? stage;
  String? notes;
  String? dayonly;
  String? lastStageDateUpdated;
  List<LeadStage>? leadStages;
  List<LeadAssign>? leadAssigns;

  Lead({
    this.whatsappnumber,
    this.secondphonenumber,
    this.jobdescription,
    this.id,
    this.name,
    this.leadisactive,
    this.email,
    this.phone,
    this.project,
    this.sales,
    this.assign,
    this.chanel,
    this.communicationway,
    this.leedtype,
    this.budget,
    this.revenue,
    this.unitPrice,
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
    this.v,
    this.stage,
    this.notes,
    this.dayonly,
    this.lastStageDateUpdated,
    this.leadStages,
    this.leadAssigns,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      whatsappnumber: json['whatsappnumber'],
      secondphonenumber: json['phonenumber2'],
      jobdescription: json['jobdescription'],
      id: json['_id'],
      name: json['name'],
      leadisactive: json['leadisactive'],
      email: json['email'],
      phone: json['phone'],
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      assign: json['assign'],
      chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
      communicationway:
          json['communicationway'] != null
              ? CommunicationWay.fromJson(json['communicationway'])
              : null,
      leedtype: json['leedtype'],
      budget: json['budget'],
      revenue: json['revenue'],
      unitPrice: json['unit_price'],
      review: json['review'],
      unitnumber: json['unitnumber'],
      commissionratio: json['commissionratio'],
      commissionmoney: json['commissionmoney'],
      cashbackratio: json['cashbackratio'],
      cashbackmoney: json['cashbackmoney'],
      stagedateupdated: json['stagedateupdated'],
      lastdateassign: json['lastdateassign'],
      lastcommentdate: json['lastcommentdate'],
      addby: json['addby'] != null ? UserInfo.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null
              ? UserInfo.fromJson(json['updatedby'])
              : null,
      campaign:
          json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      duplicateCount: json['duplicateCount'],
      relatedLeadsCount: json['relatedLeadsCount'],
      allVersions:
          json['allVersions'] != null
              ? List<LeadVersion>.from(
                json['allVersions'].map((e) => LeadVersion.fromJson(e)),
              )
              : null,
      totalSubmissions: json['totalSubmissions'],
      date: json['date'],
      mergeHistory: json['mergeHistory'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
      notes: json['notes'],
      dayonly: json['dayonly'],
      lastStageDateUpdated: json['last_stage_date_updated'],
      leadStages:
          json['leadStages'] != null
              ? List<LeadStage>.from(
                json['leadStages'].map((e) => LeadStage.fromJson(e)),
              )
              : null,
      leadAssigns:
          json['leadAssigns'] != null
              ? List<LeadAssign>.from(
                json['leadAssigns'].map((e) => LeadAssign.fromJson(e)),
              )
              : null,
    );
  }
}

class Project {
  String? id;
  String? name;
  Developer? developer;
  City? city;

  Project({this.id, this.name, this.developer, this.city});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'],
      name: json['name'],
      developer:
          json['developer'] != null
              ? Developer.fromJson(json['developer'])
              : null,
      city: json['city'] != null ? City.fromJson(json['city']) : null,
    );
  }
}

class Developer {
  String? id;
  String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(id: json['_id'], name: json['name']);
  }
}

class City {
  String? id;
  String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['_id'], name: json['name']);
  }
}

class Sales {
  String? id;
  String? name;
  List<City>? city;
  UserInfo? userlog;
  UserInfo? teamleader;
  UserInfo? manager;

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
      city:
          json['city'] != null
              ? List<City>.from(json['city'].map((e) => City.fromJson(e)))
              : null,
      userlog:
          json['userlog'] != null ? UserInfo.fromJson(json['userlog']) : null,
      teamleader:
          json['teamleader'] != null
              ? UserInfo.fromJson(json['teamleader'])
              : null,
      manager:
          json['Manager'] != null ? UserInfo.fromJson(json['Manager']) : null,
    );
  }
}

class UserInfo {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? profileImg;
  String? role;
  String? fcmtoken;

  UserInfo({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
    this.fcmtoken,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImg: json['profileImg'],
      role: json['role'],
      fcmtoken: json['fcmToken'],
    );
  }
}

class Chanel {
  String? id;
  String? name;
  String? code;

  Chanel({this.id, this.name, this.code});

  factory Chanel.fromJson(Map<String, dynamic> json) {
    return Chanel(id: json['_id'], name: json['name'], code: json['code']);
  }
}

class CommunicationWay {
  String? id;
  String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) {
    return CommunicationWay(id: json['_id'], name: json['name']);
  }
}

class Campaign {
  String? id;
  String? campainName;
  String? date;
  num? cost;
  bool? isactivate;
  UserInfo? addby;
  UserInfo? updatedby;

  Campaign({
    this.id,
    this.campainName,
    this.date,
    this.cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['_id'],
      campainName: json['CampainName'],
      date: json['Date'],
      cost: json['Cost'],
      isactivate: json['isactivate'],
      addby: json['addby'] != null ? UserInfo.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null
              ? UserInfo.fromJson(json['updatedby'])
              : null,
    );
  }
}

class LeadVersion {
  String? name;
  String? email;
  String? phone;
  Project? project;
  Chanel? chanel;
  Campaign? campaign;
  String? leedtype;
  CommunicationWay? communicationway;
  UserInfo? addby;
  String? recordedAt;
  int? versionNumber;
  String? notes;
  num? budget;
  num? unitPrice;

  LeadVersion({
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
    this.notes,
    this.budget,
    this.unitPrice,
  });

  factory LeadVersion.fromJson(Map<String, dynamic> json) {
    return LeadVersion(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
      campaign:
          json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      leedtype: json['leedtype'],
      communicationway:
          json['communicationway'] != null
              ? CommunicationWay.fromJson(json['communicationway'])
              : null,
      addby: json['addby'] != null ? UserInfo.fromJson(json['addby']) : null,
      recordedAt: json['recordedAt'],
      versionNumber: json['versionNumber'],
      notes: json['notes'],
      budget: json['budget'],
      unitPrice: json['unit_price'],
    );
  }
}

class Stage {
  String? id;
  String? name;
  StageType? stagetype;

  Stage({this.id, this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['_id'],
      name: json['name'],
      stagetype:
          json['stagetype'] != null
              ? StageType.fromJson(json['stagetype'])
              : null,
    );
  }
}

class StageType {
  String? id;
  String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(id: json['_id'], name: json['name']);
  }
}

// الكلاسات الجديدة التي تمت إضافتها
class LeadStage {
  String? id;
  Lead? leadId;
  String? date;
  Stage? stage;
  Sales? sales;
  String? dateselectedforstage; // <--- هذا هو الحقل الذي سألت عنه
  String? createdAt;
  String? updatedAt;
  int? v;

  LeadStage({
    this.id,
    this.leadId,
    this.date,
    this.stage,
    this.sales,
    this.dateselectedforstage,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LeadStage.fromJson(Map<String, dynamic> json) {
    return LeadStage(
      id: json['_id'],
      leadId: json['LeadId'] != null ? Lead.fromJson(json['LeadId']) : null,
      date: json['date'],
      stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      dateselectedforstage:
          json['dateselectedforstage'], // <--- هنا يتم التعامل معه
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class LeadAssign {
  String? id;
  Lead? leadId;
  String? dateAssigned; // <--- هذا هو حقل 'date_Assigned'
  AssignedFrom? assignedFrom;
  Sales? assignedTo; // <--- هذا هو حقل 'Assigned_to'
  bool? clearHistory;
  String? assignDateTime;
  String? createdAt;
  String? updatedAt;
  int? v;

  LeadAssign({
    this.id,
    this.leadId,
    this.dateAssigned,
    this.assignedFrom,
    this.assignedTo,
    this.clearHistory,
    this.assignDateTime,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LeadAssign.fromJson(Map<String, dynamic> json) {
    return LeadAssign(
      id: json['_id'],
      leadId: json['LeadId'] != null ? Lead.fromJson(json['LeadId']) : null,
      dateAssigned: json['date_Assigned'], // <--- هنا يتم التعامل معه
      assignedFrom:
          json['Assigned_From'] != null
              ? AssignedFrom.fromJson(json['Assigned_From'])
              : null,
      assignedTo:
          json['Assigned_to'] != null
              ? Sales.fromJson(json['Assigned_to'])
              : null, // <--- هنا يتم التعامل معه
      clearHistory: json['clearHistory'],
      assignDateTime: json['assignDateTime'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class AssignedFrom {
  String? id;
  String? name;

  AssignedFrom({this.id, this.name});

  factory AssignedFrom.fromJson(Map<String, dynamic> json) {
    return AssignedFrom(id: json['_id'], name: json['name']);
  }
}
