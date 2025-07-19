
class LeadResponse {
  final bool? success;
  final int? count;
  final List<LeadData>? data;

  LeadResponse({this.success, this.count, this.data});

  factory LeadResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LeadResponse();
    return LeadResponse(
      success: json['success'],
      count: json['count'],
      data: (json['data'] as List?)?.map((x) => LeadData.fromJson(x)).toList(),
    );
  }
}

class LeadData {
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
  final Stage? stage;
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
  final List<dynamic>? mergeHistory;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  LeadData({
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

  factory LeadData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LeadData();
    return LeadData(
      whatsappnumber: json['whatsappnumber'],
      secondphonenumber: json['phonenumber2'],
      jobdescription: json['jobdescription'],
      id: json['_id'],
      name: json['name'],
      leadisactive: json['leadisactive'],
      email: json['email'],
      phone: json['phone'],
      project: Project.fromJson(json['project']),
      sales: Sales.fromJson(json['sales']),
      notes: json['notes'],
      date: json['date'],
      assign: json['assign'],
      stage: Stage.fromJson(json['stage']),
      chanel: Chanel.fromJson(json['chanel']),
      communicationway: CommunicationWay.fromJson(json['communicationway']),
      leedtype: json['leedtype'],
      budget: json['budget'],
      revenue: json['revenue'],
      unitPrice: json['unit_price'],
      review: json['review'],
      dayonly: json['dayonly'],
      lastStageDateUpdated: json['last_stage_date_updated'],
      lastdateassign: json['lastdateassign'],
      lastcommentdate: json['lastcommentdate'],
      addby: User.fromJson(json['addby']),
      updatedby: User.fromJson(json['updatedby']),
      campaign: Campaign.fromJson(json['campaign']),
      duplicateCount: json['duplicateCount'],
      relatedLeadsCount: json['relatedLeadsCount'],
      allVersions: (json['allVersions'] as List?)?.map((x) => LeadVersion.fromJson(x)).toList(),
      totalSubmissions: json['totalSubmissions'],
      stagedateupdated: json['stagedateupdated'],
      mergeHistory: json['mergeHistory'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class Project {
  final String? id;
  final String? name;
  final Developer? developer;
  final City? city;

  Project({this.id, this.name, this.developer, this.city});

  factory Project.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Project();
    return Project(
      id: json['_id'],
      name: json['name'],
      developer: json['developer'] != null
          ? Developer.fromJson(json['developer'])
          : null,
      city: json['city'] != null ? City.fromJson(json['city']) : null,
    );
  }
}

class Developer {
  final String? id;
  final String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Developer();
    return Developer(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Sales {
  final String? id;
  final String? name;
  final List<City>? city;
  final User? userlog;
  final User? manager;
  final User? teamleader;

  Sales({this.id, this.name, this.city, this.userlog, this.manager, this.teamleader});

  factory Sales.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Sales();
    return Sales(
      id: json['_id'],
      name: json['name'],
      city: (json['city'] as List?)?.map((x) => City.fromJson(x)).toList(),
      userlog: User.fromJson(json['userlog']),
      manager: User.fromJson(json['Manager']),
      teamleader: User.fromJson(json['teamleader']),
    );
  }
}

class City {
  final String? id;
  final String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic>? json) {
    if (json == null) return City();
    return City(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? fcmtokenn;

  User({this.id, this.name,this.email,this.role,this.fcmtokenn});

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) return User();
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      fcmtokenn: json['fcmToken'],
    );
  }
}

class Stage {
  final String? id;
  final String? name;
  final String? color;
  final StageType? stageType;

  Stage({this.id, this.name, this.color, this.stageType});

  factory Stage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Stage();
    return Stage(
      id: json['_id'],
      name: json['name'],
      color: json['color'],
      stageType: StageType.fromJson(json['stage_type']),
    );
  }
}

class StageType {
  final String? id;
  final String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StageType();
    return StageType(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Chanel {
  final String? id;
  final String? name;

  Chanel({this.id, this.name});

  factory Chanel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Chanel();
    return Chanel(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class CommunicationWay {
  final String? id;
  final String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CommunicationWay();
    return CommunicationWay(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class Campaign {
  final String? id;
  final String? name;
  final String? campaoignType;

  Campaign({this.id, this.name,this.campaoignType});

  factory Campaign.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Campaign();
    return Campaign(
      id: json['_id'],
      name: json['name'],
      campaoignType: json['CampainName'],
    );
  }
}

class LeadVersion {
  final String? name;
  final String? email;
  final String? phone;
  final String? projectName;
  final String? developerName;
  final String? cityName;
  final String? channelName;
  final String? campaignName;
  final String? addedByName;
  final String? communicationWay;
  final String? versionDate;

  LeadVersion({
    this.name,
    this.email,
    this.phone,
    this.projectName,
    this.developerName,
    this.cityName,
    this.channelName,
    this.campaignName,
    this.addedByName,
    this.communicationWay,
    this.versionDate,
  });

  factory LeadVersion.fromJson(Map<String, dynamic> json) {
    return LeadVersion(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      projectName: json['project']?['name'],
      developerName: json['project']?['developer']?['name'],
      cityName: json['project']?['city']?['name'],
      channelName: json['chanel']?['name'],
      campaignName: json['campaign']?['CampainName'],
      addedByName: json['addby']?['name'],
      communicationWay: json['communicationway']?['name'],
      versionDate: json['recordedAt'],
    );
  }
}




