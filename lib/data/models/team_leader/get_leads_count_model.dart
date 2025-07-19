// Dart model classes with all fields made nullable

class TeamLeaderResponse {
  final bool? success;
  final User? teamLeader;
  final int? totalSales;
  final int? totalReviewerLeads;
  final List<SalesData>? data;

  TeamLeaderResponse({
    this.success,
    this.teamLeader,
    this.totalSales,
    this.totalReviewerLeads,
    this.data,
  });

  factory TeamLeaderResponse.fromJson(Map<String, dynamic> json) =>
      TeamLeaderResponse(
        success: json['success'],
        teamLeader:
            json['teamLeader'] != null
                ? User.fromJson(json['teamLeader'])
                : null,
        totalSales: json['totalSales'],
        totalReviewerLeads: json['totalReviewerLeads'],
        data:
            json['data'] != null
                ? List<SalesData>.from(
                  json['data'].map((x) => SalesData.fromJson(x)),
                )
                : null,
      );
}

class User {
  final String? id;
  final String? name;
  final String? email;

  User({this.id, this.name, this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'] ?? json['id'],
    name: json['name'],
    email: json['email'],
  );
}

class SalesData {
  final String? salesID;
  final String? salesName;
  final int? totalLeads;
  final bool? isReviewer;
  final List<Stage>? stages;

  SalesData({
    this.salesID,
    this.salesName,
    this.totalLeads,
    this.isReviewer,
    this.stages,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) => SalesData(
    salesID: json['salesID'],
    salesName: json['salesName'],
    totalLeads: json['totalLeads'],
    isReviewer: json['isReviewer'],
    stages:
        json['stages'] != null
            ? List<Stage>.from(json['stages'].map((x) => Stage.fromJson(x)))
            : null,
  );
}

class Stage {
  final String? stageName;
  final int? count;
  final List<Lead>? leads;

  Stage({this.stageName, this.count, this.leads});

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    stageName: json['stageName'],
    count: json['count'],
    leads:
        json['leads'] != null
            ? List<Lead>.from(json['leads'].map((x) => Lead.fromJson(x)))
            : null,
  );
}

class Lead {
  final String? whatsappnumber;
  final String? secondphonenumber;
  final String? jobdescription;
  final String? id;
  final String? name;
  final String? leadisactive;
  final String? email;
  final String? phone;
  final Project? project;
  final Sales? sales;
  final String? notes;
  final String? date;
  final bool? assign;
  final StageData? stage;
  final Chanel? chanel;
  final CommunicationWay? communicationway;
  final String? leedtype;
  final int? budget;
  final int? revenue;
  final int? unitPrice;
  final bool? review;
  final String? dayonly;
  final String? lastStageDateUpdated;
  final String? lastdateassign;
  final String? lastcommentdate;
  final User? addby;
  final User? updatedby;
  final Campaign? campaign;
  final int? duplicateCount;
  final int? relatedLeadsCount;
  final List<LeadVersion>? allVersions;
  final int? totalSubmissions;
  final String? stagedateupdated;
  final List? mergeHistory;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

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
    this.notes,
    this.date,
    this.assign,
    this.stage,
    this.chanel,
    this.communicationway,
    this.leedtype,
    this.budget,
    this.revenue,
    this.unitPrice,
    this.review,
    this.dayonly,
    this.lastStageDateUpdated,
    this.lastdateassign,
    this.lastcommentdate,
    this.addby,
    this.updatedby,
    this.campaign,
    this.duplicateCount,
    this.relatedLeadsCount,
    this.allVersions,
    this.totalSubmissions,
    this.stagedateupdated,
    this.mergeHistory,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
    whatsappnumber: json['whatsappnumber'],
    secondphonenumber: json['phonenumber2'],
    jobdescription: json['jobdescription'],
    id: json['_id'],
    name: json['name'],
    leadisactive: json['leadisactive'],
    email: json['email'],
    phone: json['phone'],
    project: json['project'] != null ? Project.fromJson(json['project']) : null,
    sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
    notes: json['notes'],
    date: json['date'],
    assign: json['assign'],
    stage: json['stage'] != null ? StageData.fromJson(json['stage']) : null,
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
    dayonly: json['dayonly'],
    lastStageDateUpdated: json['last_stage_date_updated'],
    lastdateassign: json['lastdateassign'],
    lastcommentdate: json['lastcommentdate'],
    addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    updatedby:
        json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
    campaign:
        json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
    duplicateCount: json['duplicateCount'],
    relatedLeadsCount: json['relatedLeadsCount'],
    allVersions:
        json['allVersions'] != null
            ? List<LeadVersion>.from(
              json['allVersions'].map((x) => LeadVersion.fromJson(x)),
            )
            : null,
    totalSubmissions: json['totalSubmissions'],
    stagedateupdated: json['stagedateupdated'],
    mergeHistory: json['mergeHistory'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    v: json['__v'],
  );
}

class Project {
  final String? id;
  final String? name;
  final Developer? developer;
  final City? city;

  Project({this.id, this.name, this.developer, this.city});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['_id'],
    name: json['name'],
    developer:
        json['developer'] != null
            ? Developer.fromJson(json['developer'])
            : null,
    city: json['city'] != null ? City.fromJson(json['city']) : null,
  );
}

class Developer {
  final String? id;
  final String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) =>
      Developer(id: json['_id'], name: json['name']);
}

class City {
  final String? id;
  final String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) =>
      City(id: json['_id'], name: json['name']);
}

class Sales {
  final String? id;
  final String? name;
  final List<City>? city;
  final User? userlog;
  final User? Manager;
  final User? teamleader;

  Sales({
    this.id,
    this.name,
    this.city,
    this.userlog,
    this.Manager,
    this.teamleader,
  });

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
    id: json['_id'],
    name: json['name'],
    city:
        json['city'] != null
            ? List<City>.from(json['city'].map((x) => City.fromJson(x)))
            : null,
    userlog: json['userlog'] != null ? User.fromJson(json['userlog']) : null,
    Manager: json['Manager'] != null ? User.fromJson(json['Manager']) : null,
    teamleader:
        json['teamleader'] != null ? User.fromJson(json['teamleader']) : null,
  );
}

class StageData {
  final String? id;
  final String? name;
  final Stagetype? stagetype;

  StageData({this.id, this.name, this.stagetype});

  factory StageData.fromJson(Map<String, dynamic> json) => StageData(
    id: json['_id'],
    name: json['name'],
    stagetype:
        json['stagetype'] != null
            ? Stagetype.fromJson(json['stagetype'])
            : null,
  );
}

class Stagetype {
  final String? id;
  final String? name;

  Stagetype({this.id, this.name});

  factory Stagetype.fromJson(Map<String, dynamic> json) =>
      Stagetype(id: json['_id'], name: json['name']);
}

class Chanel {
  final String? id;
  final String? name;
  final String? code;

  Chanel({this.id, this.name, this.code});

  factory Chanel.fromJson(Map<String, dynamic> json) =>
      Chanel(id: json['_id'], name: json['name'], code: json['code']);
}

class CommunicationWay {
  final String? id;
  final String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) =>
      CommunicationWay(id: json['_id'], name: json['name']);
}

class Campaign {
  final String? id;
  final String? name;
  final String? date;
  final int? cost;
  final bool? isactivate;
  final User? addby;
  final User? updatedby;

  Campaign({
    this.id,
    this.name,
    this.date,
    this.cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json['_id'],
    name: json['CampainName'],
    date: json['Date'],
    cost: json['Cost'],
    isactivate: json['isactivate'],
    addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    updatedby:
        json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
  );
}

class LeadVersion {
  final String? name;
  final String? email;
  final String? phone;
  final Project? project;
  final Chanel? chanel;
  final Campaign? campaign;
  final String? notes;
  final int? budget;
  final int? unitPrice;
  final String? leedtype;
  final CommunicationWay? communicationway;
  final User? addby;
  final String? recordedAt;
  final int? versionNumber;

  LeadVersion({
    this.name,
    this.email,
    this.phone,
    this.project,
    this.chanel,
    this.campaign,
    this.notes,
    this.budget,
    this.unitPrice,
    this.leedtype,
    this.communicationway,
    this.addby,
    this.recordedAt,
    this.versionNumber,
  });

  factory LeadVersion.fromJson(Map<String, dynamic> json) => LeadVersion(
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    project: json['project'] != null ? Project.fromJson(json['project']) : null,
    chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
    campaign:
        json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
    notes: json['notes'],
    budget: json['budget'],
    unitPrice: json['unit_price'],
    leedtype: json['leedtype'],
    communicationway:
        json['communicationway'] != null
            ? CommunicationWay.fromJson(json['communicationway'])
            : null,
    addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    recordedAt: json['recordedAt'],
    versionNumber: json['versionNumber'],
  );
}
