// ==================== Response Models ====================

class RequestLeadsResponse {
  final String status;
  final String message;
  final RequestLeadsData? data;
  final String? requestLogId;

  RequestLeadsResponse({
    required this.status,
    required this.message,
    this.data,
    this.requestLogId,
  });

  factory RequestLeadsResponse.fromJson(Map<String, dynamic> json) {
    return RequestLeadsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      requestLogId: json['requestLogId'],
      data: json['data'] != null 
          ? RequestLeadsData.fromJson(json['data'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class RequestLeadsData {
  final List<Lead> leads;
  final RequestSummary summary;

  RequestLeadsData({
    required this.leads,
    required this.summary,
  });

  factory RequestLeadsData.fromJson(Map<String, dynamic> json) {
    return RequestLeadsData(
      leads: (json['leads'] as List)
          .map((lead) => Lead.fromJson(lead))
          .toList(),
      summary: RequestSummary.fromJson(json['summary']),
    );
  }
}

class RequestSummary {
  final int requested;
  final int transferred;
  final int availableInPool;
  final int takenBefore;
  final int totalTaken;
  final int maxAllowed;
  final int remaining;

  RequestSummary({
    required this.requested,
    required this.transferred,
    required this.availableInPool,
    required this.takenBefore,
    required this.totalTaken,
    required this.maxAllowed,
    required this.remaining,
  });

  factory RequestSummary.fromJson(Map<String, dynamic> json) {
    return RequestSummary(
      requested: json['requested'] ?? 0,
      transferred: json['transferred'] ?? 0,
      availableInPool: json['availableInPool'] ?? 0,
      takenBefore: json['takenBefore'] ?? 0,
      totalTaken: json['totalTaken'] ?? 0,
      maxAllowed: json['maxAllowed'] ?? 0,
      remaining: json['remaining'] ?? 0,
    );
  }
}

// ==================== Lead Model (Full) ====================

class Lead {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? whatsappnumber;
  final String? phonenumber2;
  final String? jobdescription;
  final String? leadisactive;
  final Project? project;
  final Sales? sales;
  final Stage? stage;
  final Chanel? chanel;
  final CommunicationWay? communicationway;
  final String leedtype;
  final AddBy? addby;
  final UpdatedBy? updatedby;
  final Campaign? campaign;
  final bool assign;
  final bool ignoredublicate;
  final bool assigntype;
  final bool resetcreationdate;
  final int budget;
  final int revenue;
  final int commissionratio;
  final int commissionmoney;
  final int cashbackmoney;
  final int duplicateCount;
  final int relatedLeadsCount;
  final int totalSubmissions;
  final String? unitnumber;
  final String stagedateupdated;
  final String lastdateassign;
  final String lastcommentdate;
  final String date;
  final String createdAt;
  final String updatedAt;
  final bool data;
  final bool transferefromdata;
  final List<dynamic> allVersions;
  final List<dynamic> mergeHistory;

  Lead({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.whatsappnumber,
    this.phonenumber2,
    this.jobdescription,
    this.leadisactive,
    this.project,
    this.sales,
    this.stage,
    this.chanel,
    this.communicationway,
    required this.leedtype,
    this.addby,
    this.updatedby,
    this.campaign,
    required this.assign,
    required this.ignoredublicate,
    required this.assigntype,
    required this.resetcreationdate,
    required this.budget,
    required this.revenue,
    required this.commissionratio,
    required this.commissionmoney,
    required this.cashbackmoney,
    required this.duplicateCount,
    required this.relatedLeadsCount,
    required this.totalSubmissions,
    this.unitnumber,
    required this.stagedateupdated,
    required this.lastdateassign,
    required this.lastcommentdate,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
    required this.transferefromdata,
    required this.allVersions,
    required this.mergeHistory,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      whatsappnumber: json['whatsappnumber'],
      phonenumber2: json['phonenumber2'],
      jobdescription: json['jobdescription'],
      leadisactive: json['leadisactive'],
      project: json['project'] != null ? Project.fromJson(json['project']) : null,
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
      chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
      communicationway: json['communicationway'] != null 
          ? CommunicationWay.fromJson(json['communicationway']) 
          : null,
      leedtype: json['leedtype'] ?? '',
      addby: json['addby'] != null ? AddBy.fromJson(json['addby']) : null,
      updatedby: json['updatedby'] != null ? UpdatedBy.fromJson(json['updatedby']) : null,
      campaign: json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      assign: json['assign'] ?? false,
      ignoredublicate: json['ignoredublicate'] ?? false,
      assigntype: json['assigntype'] ?? false,
      resetcreationdate: json['resetcreationdate'] ?? false,
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      commissionratio: json['commissionratio'] ?? 0,
      commissionmoney: json['commissionmoney'] ?? 0,
      cashbackmoney: json['cashbackmoney'] ?? 0,
      duplicateCount: json['duplicateCount'] ?? 0,
      relatedLeadsCount: json['relatedLeadsCount'] ?? 0,
      totalSubmissions: json['totalSubmissions'] ?? 0,
      unitnumber: json['unitnumber'],
      stagedateupdated: json['stagedateupdated'] ?? '',
      lastdateassign: json['lastdateassign'] ?? '',
      lastcommentdate: json['lastcommentdate'] ?? '',
      date: json['date'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      data: json['data'] ?? false,
      transferefromdata: json['transferefromdata'] ?? false,
      allVersions: json['allVersions'] ?? [],
      mergeHistory: json['mergeHistory'] ?? [],
    );
  }

  String get formattedPhone => phone;
  String get displayName => name;
  String get leadStage => stage?.name ?? leedtype;
}

// ==================== Sub Models ====================

class Project {
  final String id;
  final String name;
  final Developer? developer;
  final City? city;
  final int startprice;

  Project({
    required this.id,
    required this.name,
    this.developer,
    this.city,
    required this.startprice,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      developer: json['developer'] != null ? Developer.fromJson(json['developer']) : null,
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      startprice: json['startprice'] ?? 0,
    );
  }
}

class Developer {
  final String id;
  final String name;

  Developer({required this.id, required this.name});

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Stage {
  final String id;
  final String name;
  final StageType? stagetype;

  Stage({required this.id, required this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      stagetype: json['stagetype'] != null ? StageType.fromJson(json['stagetype']) : null,
    );
  }
}

class StageType {
  final String id;
  final String name;

  StageType({required this.id, required this.name});

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Chanel {
  final String id;
  final String name;
  final String code;

  Chanel({required this.id, required this.name, required this.code});

  factory Chanel.fromJson(Map<String, dynamic> json) {
    return Chanel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class CommunicationWay {
  final String id;
  final String name;

  CommunicationWay({required this.id, required this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) {
    return CommunicationWay(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Sales {
  final String id;
  final String name;
  final UserLog? userlog;
  final TeamLeader? teamleader;
  final Manager? manager;

  Sales({
    required this.id,
    required this.name,
    this.userlog,
    this.teamleader,
    this.manager,
  });

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      userlog: json['userlog'] != null ? UserLog.fromJson(json['userlog']) : null,
      teamleader: json['teamleader'] != null ? TeamLeader.fromJson(json['teamleader']) : null,
      manager: json['Manager'] != null ? Manager.fromJson(json['Manager']) : null,
    );
  }
}

class UserLog {
  final String id;
  final String name;
  final String email;
  final String role;

  UserLog({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserLog.fromJson(Map<String, dynamic> json) {
    return UserLog(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class TeamLeader {
  final String id;
  final String name;
  final String email;

  TeamLeader({required this.id, required this.name, required this.email});

  factory TeamLeader.fromJson(Map<String, dynamic> json) {
    return TeamLeader(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Manager {
  final String id;
  final String name;
  final String email;

  Manager({required this.id, required this.name, required this.email});

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class AddBy {
  final String id;
  final String name;
  final String email;
  final String? role;
  final bool? isMarketer;

  AddBy({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.isMarketer,
  });

  factory AddBy.fromJson(Map<String, dynamic> json) {
    return AddBy(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      isMarketer: json['isMarketer'],
    );
  }
}

class UpdatedBy {
  final String id;
  final String name;
  final String email;
  final String role;

  UpdatedBy({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UpdatedBy.fromJson(Map<String, dynamic> json) {
    return UpdatedBy(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class Campaign {
  final String id;
  final String campainName;

  Campaign({required this.id, required this.campainName});

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['_id'] ?? '',
      campainName: json['CampainName'] ?? '',
    );
  }
}