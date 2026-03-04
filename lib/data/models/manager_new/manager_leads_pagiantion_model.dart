class CrmLeadsResponse {
  bool? success;
  String? message;
  CrmData? data;

  CrmLeadsResponse({this.success, this.message, this.data});

  factory CrmLeadsResponse.fromJson(Map<String, dynamic> json) {
    return CrmLeadsResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? CrmData.fromJson(json['data']) : null,
    );
  }
}

class CrmData {
  List<LeadManager>? leads;
  Pagination? pagination;
  Summary? summary;

  CrmData({this.leads, this.pagination, this.summary});

  factory CrmData.fromJson(Map<String, dynamic> json) {
    return CrmData(
      leads:
          json['leads'] is List
              ? (json['leads'] as List)
                  .map((e) => LeadManager.fromJson(e))
                  .toList()
              : [],

      pagination:
          json['pagination'] is Map<String, dynamic>
              ? Pagination.fromJson(json['pagination'])
              : null,

      summary:
          json['summary'] is Map<String, dynamic>
              ? Summary.fromJson(json['summary'])
              : null,
    );
  }
}

class LeadManager {
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

  Channel? chanel;
  CommunicationWay? communicationway;

  String? leedtype;
  bool? assigntype;
  bool? resetcreationdate;

  num? budget;
  num? revenue;
  num? unitPrice;
  num? commissionratio;
  num? commissionmoney;
  num? cashbackratio;
  num? cashbackmoney;

  String? unitnumber;

  String? stagedateupdated;
  String? lastdateassign;
  String? lastcommentdate;

  SimpleUser? addby;
  SimpleUser? updatedby;

  Campaign? campaign;

  num? duplicateCount;
  num? relatedLeadsCount;

  List<LeadVersion>? allVersions;

  num? totalSubmissions;

  String? date;
  String? createdAt;
  String? updatedAt;

  Stage? stage;

  String? lastStageDateUpdated;

  bool? data;
  bool? transferefromdata;

  LeadManager({this.id, this.name});

  factory LeadManager.fromJson(Map<String, dynamic> json) {
    return LeadManager(id: json['_id'], name: json['name'])
      ..leadisactive = json['leadisactive']
      ..whatsappnumber = json['whatsappnumber']
      ..phonenumber2 = json['phonenumber2']
      ..jobdescription = json['jobdescription']
      ..email = json['email']
      ..phone = json['phone']
      ..project =
          json['project'] != null ? Project.fromJson(json['project']) : null
      ..sales = json['sales'] != null ? Sales.fromJson(json['sales']) : null
      ..assign = json['assign']
      ..ignoredublicate = json['ignoredublicate']
      ..chanel =
          json['chanel'] != null ? Channel.fromJson(json['chanel']) : null
      ..communicationway =
          json['communicationway'] != null
              ? CommunicationWay.fromJson(json['communicationway'])
              : null
      ..leedtype = json['leedtype']
      ..assigntype = json['assigntype']
      ..resetcreationdate = json['resetcreationdate']
      ..budget = json['budget']
      ..revenue = json['revenue']
      ..unitPrice = json['unit_price']
      ..commissionratio = json['commissionratio']
      ..commissionmoney = json['commissionmoney']
      ..cashbackratio = json['cashbackratio']
      ..cashbackmoney = json['cashbackmoney']
      ..unitnumber = json['unitnumber']
      ..stagedateupdated = json['stagedateupdated']
      ..lastdateassign = json['lastdateassign']
      ..lastcommentdate = json['lastcommentdate']
      ..addby =
          json['addby'] != null ? SimpleUser.fromJson(json['addby']) : null
      ..updatedby =
          json['updatedby'] != null
              ? SimpleUser.fromJson(json['updatedby'])
              : null
      ..campaign =
          json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null
      ..duplicateCount = json['duplicateCount']
      ..relatedLeadsCount = json['relatedLeadsCount']
      ..allVersions =
          json['allVersions'] is List
              ? (json['allVersions'] as List)
                  .map((e) => LeadVersion.fromJson(e))
                  .toList()
              : json['allVersions'] is Map
              ? [LeadVersion.fromJson(json['allVersions'])]
              : []
      ..totalSubmissions = json['totalSubmissions']
      ..date = json['date']
      ..createdAt = json['createdAt']
      ..updatedAt = json['updatedAt']
      ..stage = json['stage'] != null ? Stage.fromJson(json['stage']) : null
      ..lastStageDateUpdated = json['last_stage_date_updated']
      ..data = json['data']
      ..transferefromdata = json['transferefromdata'];
  }
}

class Project {
  String? id;
  String? name;
  Developer? developer;
  City? city;
  num? startprice;

  Project({this.id, this.name});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(id: json['_id'], name: json['name'])
      ..developer =
          json['developer'] != null
              ? Developer.fromJson(json['developer'])
              : null
      ..city = json['city'] != null ? City.fromJson(json['city']) : null
      ..startprice = json['startprice'];
  }
}

class Developer {
  String? id;
  String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) =>
      Developer(id: json['_id'], name: json['name']);
}

class City {
  String? id;
  String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) =>
      City(id: json['_id'], name: json['name']);
}

class Sales {
  String? id;
  String? name;
  List<City>? city;
  SalesUser? userlog;
  SalesUser? teamleader;
  SalesUser? manager;

  Sales({this.id, this.name});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(id: json['_id'], name: json['name'])
      ..city =
          json['city'] is List
              ? (json['city'] as List).map((e) => City.fromJson(e)).toList()
              : json['city'] is Map
              ? [City.fromJson(json['city'])]
              : []
      ..userlog =
          json['userlog'] != null ? SalesUser.fromJson(json['userlog']) : null
      ..teamleader =
          json['teamleader'] != null
              ? SalesUser.fromJson(json['teamleader'])
              : null
      ..manager =
          json['Manager'] != null ? SalesUser.fromJson(json['Manager']) : null;
  }
}

class SalesUser {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? profileImg;
  String? role;
  String? fcmToken;

  SalesUser({this.id, this.name});

  factory SalesUser.fromJson(Map<String, dynamic> json) =>
      SalesUser(id: json['_id'], name: json['name'])
        ..email = json['email']
        ..phone = json['phone']
        ..profileImg = json['profileImg']
        ..role = json['role']
        ..fcmToken = json['fcmToken'];
}

class Channel {
  String? id;
  String? name;
  String? code;

  Channel({this.id, this.name});

  factory Channel.fromJson(Map<String, dynamic> json) =>
      Channel(id: json['_id'], name: json['name'])..code = json['code'];
}

class CommunicationWay {
  String? id;
  String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) =>
      CommunicationWay(id: json['_id'], name: json['name']);
}

class Campaign {
  String? id;
  String? campainName;
  String? date;
  num? cost;
  bool? isactivate;
  SimpleUser? addby;
  SimpleUser? updatedby;

  Campaign({this.id});

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      Campaign(id: json['_id'])
        ..campainName = json['CampainName']
        ..date = json['Date']
        ..cost = json['Cost']
        ..isactivate = json['isactivate']
        ..addby =
            json['addby'] != null ? SimpleUser.fromJson(json['addby']) : null
        ..updatedby =
            json['updatedby'] != null
                ? SimpleUser.fromJson(json['updatedby'])
                : null;
}

class SimpleUser {
  String? id;
  String? name;
  String? email;
  String? role;

  SimpleUser({this.id, this.name});

  factory SimpleUser.fromJson(Map<String, dynamic> json) =>
      SimpleUser(id: json['_id'], name: json['name'])
        ..email = json['email']
        ..role = json['role'];
}

class LeadVersion {
  String? name;
  String? email;
  String? phone;
  Project? project;
  Channel? chanel;
  Campaign? campaign;
  String? leedtype;
  CommunicationWay? communicationway;
  SimpleUser? addby;
  String? recordedAt;
  num? versionNumber;

  LeadVersion({this.name});

  factory LeadVersion.fromJson(Map<String, dynamic> json) =>
      LeadVersion(name: json['name'])
        ..email = json['email']
        ..phone = json['phone']
        ..project =
            json['project'] != null ? Project.fromJson(json['project']) : null
        ..chanel =
            json['chanel'] != null ? Channel.fromJson(json['chanel']) : null
        ..campaign =
            json['campaign'] != null
                ? Campaign.fromJson(json['campaign'])
                : null
        ..leedtype = json['leedtype']
        ..communicationway =
            json['communicationway'] != null
                ? CommunicationWay.fromJson(json['communicationway'])
                : null
        ..addby =
            json['addby'] != null ? SimpleUser.fromJson(json['addby']) : null
        ..recordedAt = json['recordedAt']
        ..versionNumber = json['versionNumber'];
}

class Pagination {
  num? currentPage;
  num? limit;
  num? totalPages;
  num? totalItems;
  bool? hasNextPage;
  bool? hasPrevPage;
  num? nextPage;

  Pagination();

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      Pagination()
        ..currentPage = json['currentPage']
        ..limit = json['limit']
        ..totalPages = json['totalPages']
        ..totalItems = json['totalItems']
        ..hasNextPage = json['hasNextPage']
        ..hasPrevPage = json['hasPrevPage']
        ..nextPage = json['nextPage'];
}

class Summary {
  String? managerEmail;
  num? totalSales;
  List<String>? salesIds;
  String? dataType;
  FiltersApplied? filtersApplied;

  Summary();

  factory Summary.fromJson(Map<String, dynamic> json) =>
      Summary()
        ..managerEmail = json['managerEmail']
        ..totalSales = json['totalSales']
        ..salesIds =
            json['salesIds'] != null
                ? List<String>.from(json['salesIds'])
                : null
        ..dataType = json['dataType']
        ..filtersApplied =
            json['filtersApplied'] != null
                ? FiltersApplied.fromJson(json['filtersApplied'])
                : null;
}

class FiltersApplied {
  bool? sales;
  bool? stage;
  bool? project;
  bool? developer;
  bool? channel;
  bool? campaign;
  String? leadisactive;
  String? keyword;

  String? createdFrom;
  String? createdTo;
  String? stageDateFrom;
  String? stageDateTo;

  FiltersApplied();

  factory FiltersApplied.fromJson(Map<String, dynamic> json) =>
      FiltersApplied()
        ..sales = json['sales']
        ..stage = json['stage']
        ..project = json['project']
        ..developer = json['developer']
        ..channel = json['channel']
        ..campaign = json['campaign']
        ..createdFrom = json['createdFrom']
        ..createdTo = json['createdTo']
        ..stageDateFrom = json['stageDateFrom']
        ..stageDateTo = json['stageDateTo']
        ..leadisactive = json['leadisactive']
        ..keyword = json['keyword'];
}

class Stage {
  String? id;
  String? name;
  StageType? stagetype;

  Stage();

  factory Stage.fromJson(Map<String, dynamic> json) =>
      Stage()
        ..id = json['_id']
        ..name = json['name']
        ..stagetype =
            json['stagetype'] != null
                ? StageType.fromJson(json['stagetype'])
                : null;
}

class StageType {
  String? id;
  String? name;

  StageType();

  factory StageType.fromJson(Map<String, dynamic> json) =>
      StageType()
        ..id = json['_id']
        ..name = json['name'];
}
