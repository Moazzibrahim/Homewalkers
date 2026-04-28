// To parse this JSON data, do
//
// final Salesleadsmodelwithpagination = SalesleadsmodelwithpaginationFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

Salesleadsmodelwithpagination SalesleadsmodelwithpaginationFromJson(
  String str,
) => Salesleadsmodelwithpagination.fromJson(json.decode(str));

String SalesleadsmodelwithpaginationToJson(
  Salesleadsmodelwithpagination data,
) => json.encode(data.toJson());

class Salesleadsmodelwithpagination {
  bool? success;
  String? requestedEmail;
  SalesInfo? salesInfo;
  SearchInfo? searchInfo;
  num? results;
  Pagination? pagination;
  List<LeadPagination>? data;
  DebugInfo? debugInfo;

  Salesleadsmodelwithpagination({
    this.success,
    this.requestedEmail,
    this.salesInfo,
    this.searchInfo,
    this.results,
    this.pagination,
    this.data,
    this.debugInfo,
  });

  factory Salesleadsmodelwithpagination.fromJson(Map<String, dynamic> json) =>
      Salesleadsmodelwithpagination(
        success: json["success"],
        requestedEmail: json["requestedEmail"],
        salesInfo:
            json["salesInfo"] == null
                ? null
                : SalesInfo.fromJson(json["salesInfo"]),
        searchInfo:
            json["searchInfo"] == null
                ? null
                : SearchInfo.fromJson(json["searchInfo"]),
        results: json["results"],
        pagination:
            json["pagination"] == null
                ? null
                : Pagination.fromJson(json["pagination"]),
        data:
            json["data"] == null
                ? []
                : List<LeadPagination>.from(
                  json["data"]!.map((x) => LeadPagination.fromJson(x)),
                ),
        debugInfo:
            json["debugInfo"] == null
                ? null
                : DebugInfo.fromJson(json["debugInfo"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "requestedEmail": requestedEmail,
    "salesInfo": salesInfo?.toJson(),
    "searchInfo": searchInfo?.toJson(),
    "results": results,
    "pagination": pagination?.toJson(),
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "debugInfo": debugInfo?.toJson(),
  };
}

class SalesInfo {
  String? id;
  String? name;
  String? email;
  String? role;
  String? salesName;
  String? matchType;
  bool? hasLeads;
  num? totalOriginalLeads;
  num? totalDataCenterLeads;
  num? totalLeads;
  LeadTypes? leadTypes;

  SalesInfo({
    this.id,
    this.name,
    this.email,
    this.role,
    this.salesName,
    this.matchType,
    this.hasLeads,
    this.totalOriginalLeads,
    this.totalDataCenterLeads,
    this.totalLeads,
    this.leadTypes,
  });

  factory SalesInfo.fromJson(Map<String, dynamic> json) => SalesInfo(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    role: json["role"],
    salesName: json["salesName"],
    matchType: json["matchType"],
    hasLeads: json["hasLeads"],
    totalOriginalLeads: json["totalOriginalLeads"],
    totalDataCenterLeads: json["totalDataCenterLeads"],
    totalLeads: json["totalLeads"],
    leadTypes:
        json["leadTypes"] == null
            ? null
            : LeadTypes.fromJson(json["leadTypes"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "role": role,
    "salesName": salesName,
    "matchType": matchType,
    "hasLeads": hasLeads,
    "totalOriginalLeads": totalOriginalLeads,
    "totalDataCenterLeads": totalDataCenterLeads,
    "totalLeads": totalLeads,
    "leadTypes": leadTypes?.toJson(),
  };
}

class LeadTypes {
  num? original;
  num? dataCenter;
  num? transferred;
  num? inDataCenter;

  LeadTypes({
    this.original,
    this.dataCenter,
    this.transferred,
    this.inDataCenter,
  });

  factory LeadTypes.fromJson(Map<String, dynamic> json) => LeadTypes(
    original: json["original"],
    dataCenter: json["dataCenter"],
    transferred: json["transferred"],
    inDataCenter: json["inDataCenter"],
  );

  Map<String, dynamic> toJson() => {
    "original": original,
    "dataCenter": dataCenter,
    "transferred": transferred,
    "inDataCenter": inDataCenter,
  };
}

class SearchInfo {
  bool? hasKeyword;
  num? resultsCount;
  num? baseResultsCount;
  Filters? filters;

  SearchInfo({
    this.hasKeyword,
    this.resultsCount,
    this.baseResultsCount,
    this.filters,
  });

  factory SearchInfo.fromJson(Map<String, dynamic> json) => SearchInfo(
    hasKeyword: json["hasKeyword"],
    resultsCount: json["resultsCount"],
    baseResultsCount: json["baseResultsCount"],
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
  );

  Map<String, dynamic> toJson() => {
    "hasKeyword": hasKeyword,
    "resultsCount": resultsCount,
    "baseResultsCount": baseResultsCount,
    "filters": filters?.toJson(),
  };
}

class Filters {
  List<dynamic>? stages;
  List<dynamic>? projects;
  List<dynamic>? developers;
  List<dynamic>? channels;
  List<dynamic>? campaigns;
  String? createdFrom;
  String? createdTo;
  String? stageDateFrom;
  String? stageDateTo;
  String? data;
  String? transferefromdata;

  Filters({
    this.stages,
    this.projects,
    this.developers,
    this.channels,
    this.campaigns,
    this.createdFrom,
    this.createdTo,
    this.stageDateFrom,
    this.stageDateTo,
    this.data,
    this.transferefromdata,
  });

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    stages:
        json["stages"] == null
            ? []
            : List<dynamic>.from(json["stages"]!.map((x) => x)),
    projects:
        json["projects"] == null
            ? []
            : List<dynamic>.from(json["projects"]!.map((x) => x)),
    developers:
        json["developers"] == null
            ? []
            : List<dynamic>.from(json["developers"]!.map((x) => x)),
    channels:
        json["channels"] == null
            ? []
            : List<dynamic>.from(json["channels"]!.map((x) => x)),
    campaigns:
        json["campaigns"] == null
            ? []
            : List<dynamic>.from(json["campaigns"]!.map((x) => x)),
    createdFrom: json["createdFrom"],
    createdTo: json["createdTo"],
    stageDateFrom: json["stageDateFrom"],
    stageDateTo: json["stageDateTo"],
    data: json["data"],
    transferefromdata: json["transferefromdata"],
  );

  Map<String, dynamic> toJson() => {
    "stages": stages == null ? [] : List<dynamic>.from(stages!.map((x) => x)),
    "projects":
        projects == null ? [] : List<dynamic>.from(projects!.map((x) => x)),
    "developers":
        developers == null ? [] : List<dynamic>.from(developers!.map((x) => x)),
    "channels":
        channels == null ? [] : List<dynamic>.from(channels!.map((x) => x)),
    "campaigns":
        campaigns == null ? [] : List<dynamic>.from(campaigns!.map((x) => x)),
    "createdFrom": createdFrom,
    "createdTo": createdTo,
    "stageDateFrom": stageDateFrom,
    "stageDateTo": stageDateTo,
    "data": data,
    "transferefromdata": transferefromdata,
  };
}

class Pagination {
  num? currentPage;
  num? limit;
  num? numberOfPages;
  num? totalItems;
  num? totalAllLeads;
  num? totalDataCenterLeads;
  num? totalOriginalLeads;
  num? totalTransferredFromData;
  num? totalInDataCenter;
  bool? hasKeywordSearch;
  String? keyword;
  FiltersApplied? filtersApplied;
  num? baseResultsCount;
  num? searchResultsCount;
  num? next;

  Pagination({
    this.currentPage,
    this.limit,
    this.numberOfPages,
    this.totalItems,
    this.totalAllLeads,
    this.totalDataCenterLeads,
    this.totalOriginalLeads,
    this.totalTransferredFromData,
    this.totalInDataCenter,
    this.hasKeywordSearch,
    this.keyword,
    this.filtersApplied,
    this.baseResultsCount,
    this.searchResultsCount,
    this.next,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    limit: json["limit"],
    numberOfPages: json["NumberOfPages"],
    totalItems: json["totalItems"],
    totalAllLeads: json["totalAllLeads"],
    totalDataCenterLeads: json["totalDataCenterLeads"],
    totalOriginalLeads: json["totalOriginalLeads"],
    totalTransferredFromData: json["totalTransferredFromData"],
    totalInDataCenter: json["totalInDataCenter"],
    hasKeywordSearch: json["hasKeywordSearch"],
    keyword: json["keyword"],
    filtersApplied:
        json["filtersApplied"] == null
            ? null
            : FiltersApplied.fromJson(json["filtersApplied"]),
    baseResultsCount: json["baseResultsCount"],
    searchResultsCount: json["searchResultsCount"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "limit": limit,
    "NumberOfPages": numberOfPages,
    "totalItems": totalItems,
    "totalAllLeads": totalAllLeads,
    "totalDataCenterLeads": totalDataCenterLeads,
    "totalOriginalLeads": totalOriginalLeads,
    "totalTransferredFromData": totalTransferredFromData,
    "totalInDataCenter": totalInDataCenter,
    "hasKeywordSearch": hasKeywordSearch,
    "keyword": keyword,
    "filtersApplied": filtersApplied?.toJson(),
    "baseResultsCount": baseResultsCount,
    "searchResultsCount": searchResultsCount,
    "next": next,
  };
}

class FiltersApplied {
  num? stages;
  num? projects;
  num? developers;
  num? channels;
  num? campaigns;
  num? creationDate;
  num? stageDate;
  num? data;
  num? transferefromdata;

  FiltersApplied({
    this.stages,
    this.projects,
    this.developers,
    this.channels,
    this.campaigns,
    this.creationDate,
    this.stageDate,
    this.data,
    this.transferefromdata,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) => FiltersApplied(
    stages: json["stages"],
    projects: json["projects"],
    developers: json["developers"],
    channels: json["channels"],
    campaigns: json["campaigns"],
    creationDate: json["creationDate"],
    stageDate: json["stageDate"],
    data: json["data"],
    transferefromdata: json["transferefromdata"],
  );

  Map<String, dynamic> toJson() => {
    "stages": stages,
    "projects": projects,
    "developers": developers,
    "channels": channels,
    "campaigns": campaigns,
    "creationDate": creationDate,
    "stageDate": stageDate,
    "data": data,
    "transferefromdata": transferefromdata,
  };
}

class LeadPagination {
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
  bool? resetcreationdate;
  num? budget;
  num? revenue;
  dynamic unitPrice;
  dynamic eoi;
  dynamic reservation;
  bool? review;
  String? unitnumber;
  dynamic commissionratio;
  num? commissionmoney;
  dynamic cashbackratio;
  num? cashbackmoney;
  String? stagedateupdated;
  String? lastdateassign;
  String? lastcommentdate;
  Addby? addby;
  Addby? updatedby;
  Campaign? campaign;
  num? duplicateCount;
  num? relatedLeadsCount;
  List<AllVersion>? allVersions;
  num? totalSubmissions;
  String? date;
  List<dynamic>? mergeHistory;
  String? createdAt;
  String? updatedAt;
  num? v;
  Stage? stage;
  String? lastStageDateUpdated;
  bool? data;
  bool? transferefromdata;
  Developer? developer;
  EmailVerification? emailVerification;
  String? leadType;
  String? transferStatus;
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

  LeadPagination({
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
    this.unitPrice,
    this.eoi,
    this.reservation,
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
    this.lastStageDateUpdated,
    this.data,
    this.transferefromdata,
    this.developer,
    this.emailVerification,
    this.leadType,
    this.transferStatus,
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
  });

  factory LeadPagination.fromJson(Map<String, dynamic> json) => LeadPagination(
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
    leedtype: json["leedtype"],
    assigntype: json["assigntype"],
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
    stagedateupdated: json["stagedateupdated"],
    lastdateassign: json["lastdateassign"],
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
    date: json["date"],
    mergeHistory:
        json["mergeHistory"] == null
            ? []
            : List<dynamic>.from(json["mergeHistory"]!.map((x) => x)),
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    stage: json["stage"] == null ? null : Stage.fromJson(json["stage"]),
    lastStageDateUpdated: json["last_stage_date_updated"],
    data: json["data"],
    transferefromdata: json["transferefromdata"],
    developer:
        json["developer"] == null
            ? null
            : Developer.fromJson(json["developer"]),
    emailVerification:
        json["emailVerification"] == null
            ? null
            : EmailVerification.fromJson(json["emailVerification"]),
    leadType: json["leadType"],
    transferStatus: json["transferStatus"],
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
    "stagedateupdated": stagedateupdated,
    "lastdateassign": lastdateassign,
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
    "date": date,
    "mergeHistory":
        mergeHistory == null
            ? []
            : List<dynamic>.from(mergeHistory!.map((x) => x)),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "stage": stage?.toJson(),
    "last_stage_date_updated": lastStageDateUpdated,
    "data": data,
    "transferefromdata": transferefromdata,
    "developer": developer?.toJson(),
    "emailVerification": emailVerification?.toJson(),
    "leadType": leadType,
    "transferStatus": transferStatus,
    
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
  String? fcmToken;

  Addby({
    this.channels,
    this.id,
    this.name,
    this.email,
    this.role,
    this.isMarketer,
    this.phone,
    this.profileImg,
    this.fcmToken,
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
    fcmToken: json["fcmToken"],
  );

  Map<String, dynamic> toJson() => {
    "channels":
        channels == null ? [] : List<dynamic>.from(channels!.map((x) => x)),
    "_id": id,
    "id": id,
    "name": name,
    "email": email,
    "role": role,
    "isMarketer": isMarketer,
    "phone": phone,
    "profileImg": profileImg,
    "fcmToken": fcmToken,
  };
}

class Campaign {
  String? id;
  String? campainName;
  String? date;
  num? cost;
  bool? isactivate;
  Addby? addby;
  Addby? updatedby;

  Campaign({
    this.id,
    this.campainName,
    this.date,
    this.cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json["_id"],
    campainName: json["CampainName"],
    date: json["Date"],
    cost: json["Cost"],
    isactivate: json["isactivate"],
    addby: json["addby"] == null ? null : Addby.fromJson(json["addby"]),
    updatedby:
        json["updatedby"] == null ? null : Addby.fromJson(json["updatedby"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "CampainName": campainName,
    "Date": date,
    "Cost": cost,
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

class EmailVerification {
  String? requestedEmail;
  String? salesEmail;
  bool? isMatch;

  EmailVerification({this.requestedEmail, this.salesEmail, this.isMatch});

  factory EmailVerification.fromJson(Map<String, dynamic> json) =>
      EmailVerification(
        requestedEmail: json["requestedEmail"],
        salesEmail: json["salesEmail"],
        isMatch: json["isMatch"],
      );

  Map<String, dynamic> toJson() => {
    "requestedEmail": requestedEmail,
    "salesEmail": salesEmail,
    "isMatch": isMatch,
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
    id: json["_id"],
    name: json["name"],
    developer:
        json["developer"] == null
            ? null
            : Developer.fromJson(json["developer"]),
    city: json["city"] == null ? null : City.fromJson(json["city"]),
    startprice: json["startprice"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "developer": developer?.toJson(),
    "city": city?.toJson(),
    "startprice": startprice,
  };
}

class City {
  String? id;
  String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) =>
      City(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Sales {
  String? id;
  String? name;
  List<City>? city;
  Addby? userlog;
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
    userlog: json["userlog"] == null ? null : Addby.fromJson(json["userlog"]),
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

class Teamleader {
  List<dynamic>? channels;
  String? id;
  String? name;
  String? email;
  String? profileImg;
  String? role;
  String? fcmToken;
  bool? isMarketer;

  Teamleader({
    this.channels,
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
    this.fcmToken,
    this.isMarketer,
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

class Stage {
  String? id;
  String? name;
  Stagetype? stagetype;

  Stage({this.id, this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    id: json["_id"],
    name: json["name"],
    stagetype:
        json["stagetype"] == null
            ? null
            : Stagetype.fromJson(json["stagetype"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "stagetype": stagetype?.toJson(),
  };
}

class Stagetype {
  String? id;
  String? name;

  Stagetype({this.id, this.name});

  factory Stagetype.fromJson(Map<String, dynamic> json) =>
      Stagetype(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
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
  String? recordedAt;
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
    recordedAt: json["recordedAt"],
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
    "recordedAt": recordedAt,
    "versionNumber": versionNumber,
  };
}

class DebugInfo {
  num? baseQueryCount;
  num? searchQueryCount;
  num? sampleLeadsCount;
  String? queryUsed;
  SearchQuery? searchQuery;
  LeadTypes? leadTypes;

  DebugInfo({
    this.baseQueryCount,
    this.searchQueryCount,
    this.sampleLeadsCount,
    this.queryUsed,
    this.searchQuery,
    this.leadTypes,
  });

  factory DebugInfo.fromJson(Map<String, dynamic> json) => DebugInfo(
    baseQueryCount: json["baseQueryCount"],
    searchQueryCount: json["searchQueryCount"],
    sampleLeadsCount: json["sampleLeadsCount"],
    queryUsed: json["queryUsed"],
    searchQuery:
        json["searchQuery"] == null
            ? null
            : SearchQuery.fromJson(json["searchQuery"]),
    leadTypes:
        json["leadTypes"] == null
            ? null
            : LeadTypes.fromJson(json["leadTypes"]),
  );

  Map<String, dynamic> toJson() => {
    "baseQueryCount": baseQueryCount,
    "searchQueryCount": searchQueryCount,
    "sampleLeadsCount": sampleLeadsCount,
    "queryUsed": queryUsed,
    "searchQuery": searchQuery?.toJson(),
    "leadTypes": leadTypes?.toJson(),
  };
}

class SearchQuery {
  List<And>? and;

  SearchQuery({this.and});

  factory SearchQuery.fromJson(Map<String, dynamic> json) => SearchQuery(
    and:
        json["\$and"] == null
            ? []
            : List<And>.from(json["\$and"]!.map((x) => And.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "\$and": and == null ? [] : List<dynamic>.from(and!.map((x) => x.toJson())),
  };
}

class And {
  String? sales;
  Or? or;
  bool? data;
  bool? transferefromdata;

  And({this.sales, this.or, this.data, this.transferefromdata});

  factory And.fromJson(Map<String, dynamic> json) {
    // Handle different structures in the $and array
    if (json.containsKey("sales")) {
      return And(sales: json["sales"]);
    } else if (json.containsKey("\$or")) {
      return And(or: Or.fromJson(json["\$or"]));
    } else if (json.containsKey("data")) {
      return And(data: json["data"]);
    } else if (json.containsKey("transferefromdata")) {
      return And(transferefromdata: json["transferefromdata"]);
    }
    return And();
  }

  Map<String, dynamic> toJson() {
    if (sales != null) {
      return {"sales": sales};
    } else if (or != null) {
      return {"\$or": or?.toJson()};
    } else if (data != null) {
      return {"data": data};
    } else if (transferefromdata != null) {
      return {"transferefromdata": transferefromdata};
    }
    return {};
  }
}

class Or {
  List<Map<String, String>>? conditions;

  Or({this.conditions});

  factory Or.fromJson(List<dynamic> json) {
    List<Map<String, String>> conditions = [];
    for (var item in json) {
      if (item is Map<String, dynamic>) {
        Map<String, String> map = {};
        item.forEach((key, value) {
          map[key] = value.toString();
        });
        conditions.add(map);
      }
    }
    return Or(conditions: conditions);
  }

  List<Map<String, String>> toJson() => conditions ?? [];
}
