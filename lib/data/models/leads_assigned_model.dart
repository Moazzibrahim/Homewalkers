class LeadAssignedModel {
  final int? results;
  final Pagination? pagination;
  final List<AssignmentData>? data;

  LeadAssignedModel({
    this.results,
    this.pagination,
    this.data,
  });

  factory LeadAssignedModel.fromJson(Map<String, dynamic> json) => LeadAssignedModel(
        results: json['results'],
        pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
        data: json['data'] != null
            ? List<AssignmentData>.from(json['data'].map((x) => AssignmentData.fromJson(x)))
            : null,
      );
}


class Pagination {
  final int? currentPage;
  final int? limit;
  final int? numberOfPages;

  Pagination({
    this.currentPage,
    this.limit,
    this.numberOfPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json['currentPage'],
        limit: json['limit'],
        numberOfPages: json['NumberOfPages'],
      );
}


class AssignmentData {
  final String? id;
  final Lead? lead;
  final String? dateAssigned;
  final BasicInfo? assignedFrom;
  final SalesInfo? assignedTo;
  final bool? clearHistory;
  final String? assignDateTime;
  final String? createdAt;
  final String? updatedAt;

  AssignmentData({
    this.id,
    this.lead,
    this.dateAssigned,
    this.assignedFrom,
    this.assignedTo,
    this.clearHistory,
    this.assignDateTime,
    this.createdAt,
    this.updatedAt,
  });

  factory AssignmentData.fromJson(Map<String, dynamic> json) => AssignmentData(
        id: json['_id'],
        lead: json['LeadId'] != null ? Lead.fromJson(json['LeadId']) : null,
        dateAssigned: json['date_Assigned'],
        assignedFrom: json['Assigned_From'] != null ? BasicInfo.fromJson(json['Assigned_From']) : null,
        assignedTo: json['Assigned_to'] != null ? SalesInfo.fromJson(json['Assigned_to']) : null,
        clearHistory: json['clearHistory'],
        assignDateTime: json['assignDateTime'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );
}


class Lead {
  final String? id;
  final String? name;
  final Project? project;
  final SalesInfo? sales;
  final Stage? stage;
  final Channel? channel;
  final CommunicationWay? communicationWay;
  final UserInfo? addBy;
  final UserInfo? updatedBy;
  final Campaign? campaign;
  final List<LeadVersion>? allVersions;
  final List<dynamic>? mergeHistory;

  Lead({
    this.id,
    this.name,
    this.project,
    this.sales,
    this.stage,
    this.channel,
    this.communicationWay,
    this.addBy,
    this.updatedBy,
    this.campaign,
    this.allVersions,
    this.mergeHistory,
  });

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['_id'],
        name: json['name'],
        project: json['project'] != null ? Project.fromJson(json['project']) : null,
        sales: json['sales'] != null ? SalesInfo.fromJson(json['sales']) : null,
        stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
        channel: json['chanel'] != null ? Channel.fromJson(json['chanel']) : null,
        communicationWay: json['communicationway'] != null
            ? CommunicationWay.fromJson(json['communicationway'])
            : null,
        addBy: json['addby'] != null ? UserInfo.fromJson(json['addby']) : null,
        updatedBy: json['updatedby'] != null ? UserInfo.fromJson(json['updatedby']) : null,
        campaign: json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
        allVersions: json['allVersions'] != null
            ? List<LeadVersion>.from(json['allVersions'].map((x) => LeadVersion.fromJson(x)))
            : null,
        mergeHistory: json['mergeHistory'],
      );
}

class Project {
  final String? id;
  final String? name;
  final BasicInfo? developer;
  final BasicInfo? city;

  Project({
    this.id,
    this.name,
    this.developer,
    this.city,
  });

  factory Project.fromJson(Map<String, dynamic>? json) => Project(
        id: json?['_id'],
        name: json?['name'],
        developer: json?['developer'] != null ? BasicInfo.fromJson(json!['developer']) : null,
        city: json?['city'] != null ? BasicInfo.fromJson(json!['city']) : null,
      );
}

class SalesInfo extends BasicInfo {
  final List<BasicInfo>? city;
  final UserInfo? userlog;
  final UserInfo? teamleader;
  final UserInfo? manager;

  SalesInfo({
    String? id,
    String? name,
    this.city,
    this.userlog,
    this.teamleader,
    this.manager,
  }) : super(id: id ?? '', name: name ?? '');

  factory SalesInfo.fromJson(Map<String, dynamic>? json) => SalesInfo(
        id: json?['_id'],
        name: json?['name'],
        city: json?['city'] != null
            ? List<BasicInfo>.from(json!['city'].map((x) => BasicInfo.fromJson(x)))
            : null,
        userlog: json?['userlog'] != null ? UserInfo.fromJson(json!['userlog']) : null,
        teamleader: json?['teamleader'] != null ? UserInfo.fromJson(json!['teamleader']) : null,
        manager: json?['Manager'] != null ? UserInfo.fromJson(json!['Manager']) : null,
      );
}

class BasicInfo {
  final String? id;
  final String? name;

  BasicInfo({this.id, this.name});

  factory BasicInfo.fromJson(Map<String, dynamic>? json) => BasicInfo(
        id: json?['_id'],
        name: json?['name'],
      );
}

class UserInfo extends BasicInfo {
  final String? email;
  final String? phone;
  final String? profileImg;
  final String? role;

  UserInfo({
    super.id,
    super.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic>? json) => UserInfo(
        id: json?['_id'],
        name: json?['name'],
        email: json?['email'],
        phone: json?['phone'],
        profileImg: json?['profileImg'],
        role: json?['role'],
      );
}

class Stage {
  final String? id;
  final String? name;
  final BasicInfo? stageType;

  Stage({this.id, this.name, this.stageType});

  factory Stage.fromJson(Map<String, dynamic>? json) => Stage(
        id: json?['_id'],
        name: json?['name'],
        stageType: json?['stagetype'] != null ? BasicInfo.fromJson(json!['stagetype']) : null,
      );
}

class Channel {
  final String? id;
  final String? name;
  final String? code;

  Channel({this.id, this.name, this.code});

  factory Channel.fromJson(Map<String, dynamic>? json) => Channel(
        id: json?['_id'],
        name: json?['name'],
        code: json?['code'],
      );
}

class CommunicationWay {
  final String? id;
  final String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic>? json) => CommunicationWay(
        id: json?['_id'],
        name: json?['name'],
      );
}

class Campaign {
  final String? id;
  final String? campainName;
  final String? date;
  final int? cost;
  final bool? isActivate;
  final UserInfo? addby;
  final UserInfo? updatedby;

  Campaign({
    this.id,
    this.campainName,
    this.date,
    this.cost,
    this.isActivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic>? json) => Campaign(
        id: json?['_id'],
        campainName: json?['CampainName'],
        date: json?['Date'],
        cost: json?['Cost'],
        isActivate: json?['isactivate'],
        addby: json?['addby'] != null ? UserInfo.fromJson(json!['addby']) : null,
        updatedby: json?['updatedby'] != null ? UserInfo.fromJson(json!['updatedby']) : null,
      );
}

class LeadVersion {
  final Project? project;
  final Channel? channel;
  final Campaign? campaign;
  final CommunicationWay? communicationway;
  final UserInfo? addby;

  LeadVersion({
    this.project,
    this.channel,
    this.campaign,
    this.communicationway,
    this.addby,
  });

  factory LeadVersion.fromJson(Map<String, dynamic>? json) => LeadVersion(
        project: json?['project'] != null ? Project.fromJson(json!['project']) : null,
        channel: json?['chanel'] != null ? Channel.fromJson(json!['chanel']) : null,
        campaign: json?['campaign'] != null ? Campaign.fromJson(json!['campaign']) : null,
        communicationway: json?['communicationway'] != null ? CommunicationWay.fromJson(json!['communicationway']) : null,
        addby: json?['addby'] != null ? UserInfo.fromJson(json!['addby']) : null,
      );
}
