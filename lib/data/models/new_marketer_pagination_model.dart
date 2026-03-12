// To parse this JSON data, do
//
// final NewMarketerPaginationModel = NewMarketerPaginationModelFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:homewalkers_app/data/models/leadsAdminModelWithPagination.dart';

NewMarketerPaginationModel NewMarketerPaginationModelFromJson(String str) =>
    NewMarketerPaginationModel.fromJson(json.decode(str));

String NewMarketerPaginationModelToJson(NewMarketerPaginationModel data) =>
    json.encode(data.toJson());

class NewMarketerPaginationModel {
  bool? success;
  num? results;
  Pagination? pagination;
  List<Datum>? data;
  UserInfo? userInfo;

  NewMarketerPaginationModel({
    this.success,
    this.results,
    this.pagination,
    this.data,
    this.userInfo,
  });

  factory NewMarketerPaginationModel.fromJson(Map<String, dynamic> json) =>
      NewMarketerPaginationModel(
        success: json["success"],
        results: json["results"],
        pagination:
            json["pagination"] == null
                ? null
                : Pagination.fromJson(json["pagination"]),
        data:
            json["data"] == null
                ? []
                : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        userInfo:
            json["userInfo"] == null
                ? null
                : UserInfo.fromJson(json["userInfo"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "results": results,
    "pagination": pagination?.toJson(),
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "userInfo": userInfo?.toJson(),
  };
}

class Pagination {
  num? currentPage;
  num? limit;
  num? numberOfPages;
  num? totalItems;
  num? totalAllLeads;
  num? totalLeadsActive;
  num? totalLeadsInactive;
  num? numberOfPagesInactive;
  num? activePercentage;
  num? inactivePercentage;
  num? next;

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
    currentPage: json["currentPage"],
    limit: json["limit"],
    numberOfPages: json["NumberOfPages"],
    totalItems: json["totalItems"],
    totalAllLeads: json["totalAllLeads"],
    totalLeadsActive: json["totalLeadsActive"],
    totalLeadsInactive: json["totalLeadsInactive"],
    numberOfPagesInactive: json["NumberOfPagesInactive"],
    activePercentage: json["activePercentage"],
    inactivePercentage: json["inactivePercentage"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "limit": limit,
    "NumberOfPages": numberOfPages,
    "totalItems": totalItems,
    "totalAllLeads": totalAllLeads,
    "totalLeadsActive": totalLeadsActive,
    "totalLeadsInactive": totalLeadsInactive,
    "NumberOfPagesInactive": numberOfPagesInactive,
    "activePercentage": activePercentage,
    "inactivePercentage": inactivePercentage,
    "next": next,
  };
}

DateTime? _safeParseDate(dynamic value) {
  if (value == null) return null;

  try {
    return DateTime.parse(value);
  } catch (_) {
    try {
      final cleaned = value.toString().split(" GMT")[0];
      return DateTime.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}

class Datum {
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
  Communicationway? communicationway;
  String? leedtype;
  bool? assigntype;
  bool? data;
  bool? transferefromdata;
  bool? resetcreationdate;
  num? budget;
  num? revenue;
  num? unitPrice;
  num? eoi;
  num? reservation;
  bool? review;
  String? unitnumber;
  num? commissionratio;
  num? commissionmoney;
  num? cashbackratio;
  num? cashbackmoney;
  DateTime? stagedateupdated;
  DateTime? lastdateassign;
  String? lastcommentdate;
  Addby? addby;
  Addby? updatedby;
  Campaign? campaign;
  num? duplicateCount;
  num? relatedLeadsCount;
  List<AllVersion>? allVersions;
  String? campaignRedirectLink;
  String? question1_text;
  String? question1_answer;
  String? question2_text;
  String? question2_answer;
  String? question3_text;
  String? question3_answer;
  String? question4_text;
  String? question4_answer;
  String? question5_text;
  String? question5_answer;
  num? totalSubmissions;
  DateTime? date;
  List<dynamic>? mergeHistory;
  DateTime? createdAt;
  DateTime? updatedAt;
  Stage? stage;
  List<LeadStage>? leadStages;
  List<LeadAssign>? leadAssigns;
  LastComment? lastComment;

  Datum({
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
    this.data,
    this.transferefromdata,
    this.resetcreationdate,
    this.budget,
    this.revenue,
    this.unitPrice,
    this.eoi,
    this.reservation,
    this.review,
    this.campaignRedirectLink,
    this.question1_text,
    this.question1_answer,
    this.question2_text,
    this.question2_answer,
    this.question3_text,
    this.question3_answer,
    this.question4_text,
    this.question4_answer,
    this.question5_text,
    this.question5_answer,
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
    this.leadStages,
    this.leadAssigns,
    this.lastComment,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    leadisactive: json["leadisactive"],
    whatsappnumber: json["whatsappnumber"],
    phonenumber2: json["phonenumber2"],
    jobdescription: json["jobdescription"],
    email: json["email"],
    phone: json["phone"],
    project: json["project"] == null ? null : Project.fromJson(json["project"]),
    sales: json["sales"] == null ? null : Sales.fromJson(json["sales"]),
    assign: json["assign"],
    ignoredublicate: json["ignoredublicate"],
    chanel: json["chanel"] == null ? null : Chanel.fromJson(json["chanel"]),
    communicationway:
        json["communicationway"] == null
            ? null
            : Communicationway.fromJson(json["communicationway"]),
    campaignRedirectLink: json['campaignRedirectLink'] as String?,
    question1_text: json['question1_text'] as String?,
    question1_answer: json['question1_answer'] as String?,
    question2_text: json['question2_text'] as String?,
    question2_answer: json['question2_answer'] as String?,
    question3_text: json['question3_text'] as String?,
    question3_answer: json['question3_answer'] as String?,
    question4_text: json['question4_text'] as String?,
    question4_answer: json['question4_answer'] as String?,
    question5_text: json['question5_text'] as String?,
    question5_answer: json['question5_answer'] as String?,
    leedtype: json["leedtype"],
    assigntype: json["assigntype"],
    data: json["data"],
    transferefromdata: json["transferefromdata"],
    resetcreationdate: json["resetcreationdate"],
    budget: json["budget"],
    revenue: json["revenue"],
    unitPrice: json["unit_price"],
    eoi: json["Eoi"],
    reservation: json["Reservation"],
    review: json["review"],
    unitnumber: json["unitnumber"],
    commissionratio: json["commissionratio"],
    commissionmoney: json["commissionmoney"],
    cashbackratio: json["cashbackratio"],
    cashbackmoney: json["cashbackmoney"],
    stagedateupdated: _safeParseDate(json["stagedateupdated"]),
    lastdateassign: _safeParseDate(json["lastdateassign"]),
    lastcommentdate: json["lastcommentdate"],
    addby: json["addby"] == null ? null : Addby.fromJson(json["addby"]),
    updatedby:
        json["updatedby"] == null ? null : Addby.fromJson(json["updatedby"]),
    campaign:
        json["campaign"] == null ? null : Campaign.fromJson(json["campaign"]),
    duplicateCount: json["duplicateCount"],
    relatedLeadsCount: json["relatedLeadsCount"],
    allVersions:
        json["allVersions"] == null
            ? []
            : List<AllVersion>.from(
              json["allVersions"]!.map((x) => AllVersion.fromJson(x)),
            ),
    totalSubmissions: json["totalSubmissions"],
    date: _safeParseDate(json["date"]),

    mergeHistory:
        json["mergeHistory"] == null
            ? []
            : List<dynamic>.from(json["mergeHistory"]!.map((x) => x)),
    createdAt: _safeParseDate(json["createdAt"]),
    updatedAt: _safeParseDate(json["updatedAt"]),
    stage: json["stage"] == null ? null : Stage.fromJson(json["stage"]),
    leadStages:
        json["leadStages"] == null
            ? []
            : List<LeadStage>.from(
              json["leadStages"]!.map((x) => LeadStage.fromJson(x)),
            ),
    leadAssigns:
        json["leadAssigns"] == null
            ? []
            : List<LeadAssign>.from(
              json["leadAssigns"]!.map((x) => LeadAssign.fromJson(x)),
            ),
    lastComment:
        json["lastComment"] == null
            ? null
            : LastComment.fromJson(json["lastComment"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "leadisactive": leadisactive,
    "whatsappnumber": whatsappnumber,
    "phonenumber2": phonenumber2,
    "jobdescription": jobdescription,
    "email": email,
    "phone": phone,
    "project": project?.toJson(),
    "sales": sales?.toJson(),
    "assign": assign,
    "ignoredublicate": ignoredublicate,
    "chanel": chanel?.toJson(),
    "communicationway": communicationway?.toJson(),
    "leedtype": leedtype,
    "assigntype": assigntype,
    "data": data,
    "transferefromdata": transferefromdata,
    "resetcreationdate": resetcreationdate,
    "budget": budget,
    "revenue": revenue,
    "unit_price": unitPrice,
    "Eoi": eoi,
    "Reservation": reservation,
    "review": review,
    "unitnumber": unitnumber,
    "commissionratio": commissionratio,
    "commissionmoney": commissionmoney,
    "cashbackratio": cashbackratio,
    "cashbackmoney": cashbackmoney,
    "stagedateupdated": stagedateupdated?.toIso8601String(),
    "lastdateassign": lastdateassign?.toIso8601String(),
    "lastcommentdate": lastcommentdate,
    "addby": addby?.toJson(),
    "updatedby": updatedby?.toJson(),
    "campaign": campaign?.toJson(),
    "duplicateCount": duplicateCount,
    "relatedLeadsCount": relatedLeadsCount,
    "allVersions":
        allVersions == null
            ? []
            : List<dynamic>.from(allVersions!.map((x) => x.toJson())),
    "totalSubmissions": totalSubmissions,
    "date": date?.toIso8601String(),
    "mergeHistory":
        mergeHistory == null
            ? []
            : List<dynamic>.from(mergeHistory!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "stage": stage?.toJson(),
    "leadStages":
        leadStages == null
            ? []
            : List<dynamic>.from(leadStages!.map((x) => x.toJson())),
    "leadAssigns":
        leadAssigns == null
            ? []
            : List<dynamic>.from(leadAssigns!.map((x) => x.toJson())),
    "lastComment": lastComment?.toJson(),
  };
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

class Addby {
  List<dynamic>? channels;
  String? id;
  String? name;
  String? email;
  String? role;
  bool? isMarketer;
  String? phone;
  String? profileImg;

  Addby({
    this.channels,
    this.id,
    this.name,
    this.email,
    this.role,
    this.isMarketer,
    this.phone,
    this.profileImg,
  });

  factory Addby.fromJson(Map<String, dynamic> json) => Addby(
    channels:
        json["channels"] == null
            ? []
            : List<dynamic>.from(json["channels"]!.map((x) => x)),
    id: json["_id"] ?? json["id"],
    name: json["name"],
    email: json["email"],
    role: json["role"],
    isMarketer: json["isMarketer"],
    phone: json["phone"],
    profileImg: json["profileImg"],
  );

  Map<String, dynamic> toJson() => {
    "channels":
        channels == null ? [] : List<dynamic>.from(channels!.map((x) => x)),
    "_id": id,
    "name": name,
    "email": email,
    "role": role,
    "isMarketer": isMarketer,
    "phone": phone,
    "profileImg": profileImg,
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
  Communicationway? communicationway;
  Addby? addby;
  DateTime? recordedAt;
  num? versionNumber;

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
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    project: json["project"] == null ? null : Project.fromJson(json["project"]),
    chanel: json["chanel"] == null ? null : Chanel.fromJson(json["chanel"]),
    campaign:
        json["campaign"] == null ? null : Campaign.fromJson(json["campaign"]),
    leedtype: json["leedtype"],
    communicationway:
        json["communicationway"] == null
            ? null
            : Communicationway.fromJson(json["communicationway"]),
    addby: json["addby"] == null ? null : Addby.fromJson(json["addby"]),
    recordedAt:
        json["recordedAt"] == null ? null : DateTime.parse(json["recordedAt"]),
    versionNumber: json["versionNumber"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "phone": phone,
    "project": project?.toJson(),
    "chanel": chanel?.toJson(),
    "campaign": campaign?.toJson(),
    "leedtype": leedtype,
    "communicationway": communicationway?.toJson(),
    "addby": addby?.toJson(),
    "recordedAt": recordedAt?.toIso8601String(),
    "versionNumber": versionNumber,
  };
}

class Campaign {
  String? id;
  String? campainName;
  DateTime? date;
  num? cost;
  String? redirectLink;
  bool? isactivate;
  Addby? addby;
  Addby? updatedby;

  Campaign({
    this.id,
    this.campainName,
    this.date,
    this.cost,
    this.redirectLink,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json["_id"],
    campainName: json["CampainName"],
    date: json["Date"] == null ? null : DateTime.parse(json["Date"]),
    cost: json["Cost"],
    redirectLink: json["redirectLink"],
    isactivate: json["isactivate"],
    addby: json["addby"] == null ? null : Addby.fromJson(json["addby"]),
    updatedby:
        json["updatedby"] == null ? null : Addby.fromJson(json["updatedby"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "CampainName": campainName,
    "Date": date?.toIso8601String(),
    "Cost": cost,
    "redirectLink": redirectLink,
    "isactivate": isactivate,
    "addby": addby?.toJson(),
    "updatedby": updatedby?.toJson(),
  };
}

class Chanel {
  String? id;
  String? name;
  String? code;

  Chanel({this.id, this.name, this.code});

  factory Chanel.fromJson(Map<String, dynamic> json) =>
      Chanel(id: json["_id"], name: json["name"], code: json["code"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "code": code};
}

class City {
  String? id;
  String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) =>
      City(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Communicationway {
  String? id;
  String? name;

  Communicationway({this.id, this.name});

  factory Communicationway.fromJson(Map<String, dynamic> json) =>
      Communicationway(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Developer {
  String? id;
  String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) =>
      Developer(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class LeadAssign {
  String? id;
  LeadId? leadId;
  String? dateAssigned;
  AssignedFrom? assignedFrom;
  AssignedTo? assignedTo;
  bool? clearHistory;
  DateTime? assignDateTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  num? v;

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

  factory LeadAssign.fromJson(Map<String, dynamic> json) => LeadAssign(
    id: json["_id"],
    leadId: json["LeadId"] == null ? null : LeadId.fromJson(json["LeadId"]),
    dateAssigned: json["date_Assigned"],
    assignedFrom:
        json["Assigned_From"] == null
            ? null
            : AssignedFrom.fromJson(json["Assigned_From"]),
    assignedTo:
        json["Assigned_to"] == null
            ? null
            : AssignedTo.fromJson(json["Assigned_to"]),
    clearHistory: json["clearHistory"],
    assignDateTime:
        json["assignDateTime"] == null
            ? null
            : DateTime.parse(json["assignDateTime"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "LeadId": leadId?.toJson(),
    "date_Assigned": dateAssigned,
    "Assigned_From": assignedFrom?.toJson(),
    "Assigned_to": assignedTo?.toJson(),
    "clearHistory": clearHistory,
    "assignDateTime": assignDateTime?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class AssignedFrom {
  String? id;
  String? name;

  AssignedFrom({this.id, this.name});

  factory AssignedFrom.fromJson(Map<String, dynamic> json) =>
      AssignedFrom(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class AssignedTo {
  String? id;
  String? name;
  List<City>? city;
  Userlog? userlog;
  Teamleader? teamleader;
  Manager? manager;

  AssignedTo({
    this.id,
    this.name,
    this.city,
    this.userlog,
    this.teamleader,
    this.manager,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) => AssignedTo(
    id: json["_id"],
    name: json["name"],
    city:
        json["city"] == null
            ? []
            : List<City>.from(json["city"]!.map((x) => City.fromJson(x))),
    userlog: json["userlog"] == null ? null : Userlog.fromJson(json["userlog"]),
    teamleader:
        json["teamleader"] == null
            ? null
            : Teamleader.fromJson(json["teamleader"]),
    manager: json["Manager"] == null ? null : Manager.fromJson(json["Manager"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "city":
        city == null ? [] : List<dynamic>.from(city!.map((x) => x.toJson())),
    "userlog": userlog?.toJson(),
    "teamleader": teamleader?.toJson(),
    "Manager": manager?.toJson(),
  };
}

class LeadId {
  String? id;
  String? name;
  Project? project;
  Sales? sales;
  Chanel? chanel;
  Communicationway? communicationway;
  Addby? addby;
  Addby? updatedby;
  Campaign? campaign;
  List<AllVersion>? allVersions;
  List<dynamic>? mergeHistory;
  Stage? stage;

  LeadId({
    this.id,
    this.name,
    this.project,
    this.sales,
    this.chanel,
    this.communicationway,
    this.addby,
    this.updatedby,
    this.campaign,
    this.allVersions,
    this.mergeHistory,
    this.stage,
  });

  factory LeadId.fromJson(Map<String, dynamic> json) => LeadId(
    id: json["_id"],
    name: json["name"],
    project: json["project"] == null ? null : Project.fromJson(json["project"]),
    sales: json["sales"] == null ? null : Sales.fromJson(json["sales"]),
    chanel: json["chanel"] == null ? null : Chanel.fromJson(json["chanel"]),
    communicationway:
        json["communicationway"] == null
            ? null
            : Communicationway.fromJson(json["communicationway"]),
    addby: json["addby"] == null ? null : Addby.fromJson(json["addby"]),
    updatedby:
        json["updatedby"] == null ? null : Addby.fromJson(json["updatedby"]),
    campaign:
        json["campaign"] == null ? null : Campaign.fromJson(json["campaign"]),
    allVersions:
        json["allVersions"] == null
            ? []
            : List<AllVersion>.from(
              json["allVersions"]!.map((x) => AllVersion.fromJson(x)),
            ),
    mergeHistory:
        json["mergeHistory"] == null
            ? []
            : List<dynamic>.from(json["mergeHistory"]!.map((x) => x)),
    stage: json["stage"] == null ? null : Stage.fromJson(json["stage"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "project": project?.toJson(),
    "sales": sales?.toJson(),
    "chanel": chanel?.toJson(),
    "communicationway": communicationway?.toJson(),
    "addby": addby?.toJson(),
    "updatedby": updatedby?.toJson(),
    "campaign": campaign?.toJson(),
    "allVersions":
        allVersions == null
            ? []
            : List<dynamic>.from(allVersions!.map((x) => x.toJson())),
    "mergeHistory":
        mergeHistory == null
            ? []
            : List<dynamic>.from(mergeHistory!.map((x) => x)),
    "stage": stage?.toJson(),
  };
}

class LeadStage {
  String? id;
  LeadId? leadId;
  DateTime? date;
  Stage? stage;
  Sales? sales;
  DateTime? dateselectedforstage;
  DateTime? createdAt;
  DateTime? updatedAt;
  num? v;

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

  factory LeadStage.fromJson(Map<String, dynamic> json) => LeadStage(
    id: json["_id"],
    leadId: json["LeadId"] == null ? null : LeadId.fromJson(json["LeadId"]),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    stage: json["stage"] == null ? null : Stage.fromJson(json["stage"]),
    sales: json["sales"] == null ? null : Sales.fromJson(json["sales"]),
    dateselectedforstage:
        json["dateselectedforstage"] == null
            ? null
            : DateTime.parse(json["dateselectedforstage"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "LeadId": leadId?.toJson(),
    "date": date?.toIso8601String(),
    "stage": stage?.toJson(),
    "sales": sales?.toJson(),
    "dateselectedforstage": dateselectedforstage?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Manager {
  List<dynamic>? channels;
  String? id;
  String? name;
  String? email;
  String? profileImg;
  String? role;
  String? fcmToken;
  bool? isMarketer;

  Manager({
    this.channels,
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
    this.fcmToken,
    this.isMarketer,
  });

  factory Manager.fromJson(Map<String, dynamic> json) => Manager(
    channels:
        json["channels"] == null
            ? []
            : List<dynamic>.from(json["channels"]!.map((x) => x)),
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    profileImg: json["profileImg"],
    role: json["role"],
    fcmToken: json["fcmToken"],
    isMarketer: json["isMarketer"],
  );

  Map<String, dynamic> toJson() => {
    "channels":
        channels == null ? [] : List<dynamic>.from(channels!.map((x) => x)),
    "_id": id,
    "name": name,
    "email": email,
    "profileImg": profileImg,
    "role": role,
    "fcmToken": fcmToken,
    "isMarketer": isMarketer,
  };
}

class Project {
  String? id;
  String? name;
  num? startprice;
  Developer? developer;
  City? city;

  Project({this.id, this.name, this.startprice, this.developer, this.city});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json["_id"],
    name: json["name"],
    startprice: json["startprice"],
    developer:
        json["developer"] == null
            ? null
            : Developer.fromJson(json["developer"]),
    city: json["city"] == null ? null : City.fromJson(json["city"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "startprice": startprice,
    "developer": developer?.toJson(),
    "city": city?.toJson(),
  };
}

class Sales {
  String? id;
  String? name;
  List<City>? city;
  Userlog? userlog;
  Teamleader? teamleader;
  Manager? manager;

  Sales({
    this.id,
    this.name,
    this.city,
    this.userlog,
    this.teamleader,
    this.manager,
  });

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
    id: json["_id"],
    name: json["name"],
    city:
        json["city"] == null
            ? []
            : List<City>.from(json["city"]!.map((x) => City.fromJson(x))),
    userlog: json["userlog"] == null ? null : Userlog.fromJson(json["userlog"]),
    teamleader:
        json["teamleader"] == null
            ? null
            : Teamleader.fromJson(json["teamleader"]),
    manager: json["Manager"] == null ? null : Manager.fromJson(json["Manager"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "city":
        city == null ? [] : List<dynamic>.from(city!.map((x) => x.toJson())),
    "userlog": userlog?.toJson(),
    "teamleader": teamleader?.toJson(),
    "Manager": manager?.toJson(),
  };
}

class Stage {
  String? id;
  String? name;
  StageType? stagetype;

  Stage({this.id, this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    id: json["_id"],
    name: json["name"],
    stagetype:
        json["stagetype"] == null
            ? null
            : StageType.fromJson(json["stagetype"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "stagetype": stagetype?.toJson(),
  };
}

class StageType {
  String? id;
  String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic> json) =>
      StageType(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Teamleader {
  List<dynamic>? channels;
  String? id;
  String? name;
  String? email;
  String? profileImg;
  String? role;
  String? fcmToken;
  bool? isMarketer;
  String? phone;

  Teamleader({
    this.channels,
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
    this.fcmToken,
    this.isMarketer,
    this.phone,
  });

  factory Teamleader.fromJson(Map<String, dynamic> json) => Teamleader(
    channels:
        json["channels"] == null
            ? []
            : List<dynamic>.from(json["channels"]!.map((x) => x)),
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    profileImg: json["profileImg"],
    role: json["role"],
    fcmToken: json["fcmToken"],
    isMarketer: json["isMarketer"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "channels":
        channels == null ? [] : List<dynamic>.from(channels!.map((x) => x)),
    "_id": id,
    "name": name,
    "email": email,
    "profileImg": profileImg,
    "role": role,
    "fcmToken": fcmToken,
    "isMarketer": isMarketer,
    "phone": phone,
  };
}

class UserInfo {
  String? id;
  String? name;
  String? role;
  List<Chanel>? channels;
  num? channelCount;

  UserInfo({this.id, this.name, this.role, this.channels, this.channelCount});

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"],
    name: json["name"],
    role: json["role"],
    channels:
        json["channels"] == null
            ? []
            : List<Chanel>.from(
              json["channels"]!.map((x) => Chanel.fromJson(x)),
            ),
    channelCount: json["channelCount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "role": role,
    "channels":
        channels == null
            ? []
            : List<dynamic>.from(channels!.map((x) => x.toJson())),
    "channelCount": channelCount,
  };
}

class Userlog {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? profileImg;
  String? role;
  String? fcmToken;

  Userlog({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
    this.fcmToken,
  });

  factory Userlog.fromJson(Map<String, dynamic> json) => Userlog(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    profileImg: json["profileImg"],
    role: json["role"],
    fcmToken: json["fcmToken"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "profileImg": profileImg,
    "role": role,
    "fcmToken": fcmToken,
  };
}
