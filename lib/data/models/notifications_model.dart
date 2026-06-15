// ignore_for_file: non_constant_identifier_names
class NotificationModel {
  final num? results;
  final Pagination? pagination;
  final List<NotificationItem>? data;

  NotificationModel({this.results, this.pagination, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      results: json['results'],
      pagination:
          json['pagination'] != null
              ? Pagination.fromJson(json['pagination'])
              : null,
      data:
          (json['data'] as List?)
              ?.map((e) => NotificationItem.fromJson(e))
              .toList(),
    );
  }
}

class Pagination {
  final num? totalResults; // ✅ أضفت
  final num? totalPages; // ✅ أضفت
  final num? currentPage;
  final num? limit;
  final bool? hasNextPage; // ✅ أضفت
  final bool? hasPrevPage; // ✅ أضفت
  final num? nextPage; // ✅ أضفت
  final num? prevPage; // ✅ أضفت
  final num? unreadCount; // ✅ أضفت
  final num? numberOfPages; // ✅ خلّيتها للتوافق مع الكود القديم

  Pagination({
    this.totalResults,
    this.totalPages,
    this.currentPage,
    this.limit,
    this.hasNextPage,
    this.hasPrevPage,
    this.nextPage,
    this.prevPage,
    this.unreadCount,
    this.numberOfPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalResults: json['totalResults'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      limit: json['limit'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
      nextPage: json['nextPage'],
      prevPage: json['prevPage'],
      unreadCount: json['unreadCount'],
      numberOfPages: json['NumberOfPages'], // القديم للتوافق
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
  final num? v;

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
      receiver:
          json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      lead: json['lead'] != null ? Lead.fromJson(json['lead']) : null,
      typenotification: json['typenotification'],
      userdoaction:
          json['userdoaction'] != null
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
  final List<FcmToken>? fcmTokens; // ✅ أضف هذا
  final List? channels;

  User({
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
    this.phone,
    this.fcmToken,
    this.fcmTokens,
    this.channels,
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
      fcmTokens:
          (json['fcmTokens'] as List?)
              ?.map((e) => FcmToken.fromJson(e))
              .toList(),
      channels: json['channels'],
    );
  }
}

// ✅ أضف هذا الكلاس
class FcmToken {
  final String? id;
  final String? token;
  final String? deviceId;
  final String? platform;
  final String? createdAt;
  final String? lastUsed;

  FcmToken({
    this.id,
    this.token,
    this.deviceId,
    this.platform,
    this.createdAt,
    this.lastUsed,
  });

  factory FcmToken.fromJson(Map<String, dynamic> json) {
    return FcmToken(
      id: json['_id'],
      token: json['token'],
      deviceId: json['deviceId'],
      platform: json['platform'],
      createdAt: json['createdAt'],
      lastUsed: json['lastUsed'],
    );
  }
}

class Lead {
  // Basic Info
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? whatsappnumber;
  final String? phonenumber2;
  final String? jobdescription;
  final String? notes;
  final String? date;
  
  // Status Flags
  final bool? assign;
  final bool? ignoredublicate;
  final bool? assigntype;
  final bool? data;
  final bool? transferefromdata;
  final bool? resetcreationdate;
  final String? leedtype;
  
  // Dates
  final String? last_stage_date_updated;
  final String? lastdateassign;
  final String? lastcommentdate;
  final String? stagedateupdated;
  final String? createdAt;
  final String? updatedAt;
  final String? dayonly;
  final num? v;
  
  // ✅ الأسئلة
  final String? question1_text;
  final String? question1_answer;
  final String? question2_text;
  final String? question2_answer;
  final String? question3_text;
  final String? question3_answer;
  final String? question4_text;
  final String? question4_answer;
  final String? question5_text;
  final String? question5_answer;
  
  // ✅ الحقول الإضافية
  final String? campaignRedirectLink;
  final num? totalSubmissions;
  final num? duplicateCount;
  final num? relatedLeadsCount;
  final bool? hidesalesnameonleadcomments;
  
  // ✅ الحقول المالية
  final num? budget;
  final num? revenue;
  final num? unit_price;
  final num? Eoi;
  final num? Reservation;
  final bool? review;
  final String? unitnumber;
  final num? commissionratio;
  final num? commissionmoney;
  final num? cashbackratio;
  final num? cashbackmoney;
  
  // Nested Objects
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
    this.phone,
    this.whatsappnumber,
    this.phonenumber2,
    this.jobdescription,
    this.notes,
    this.date,
    this.assign,
    this.ignoredublicate,
    this.assigntype,
    this.data,
    this.transferefromdata,
    this.resetcreationdate,
    this.leedtype,
    this.last_stage_date_updated,
    this.lastdateassign,
    this.lastcommentdate,
    this.stagedateupdated,
    this.createdAt,
    this.updatedAt,
    this.dayonly,
    this.v,
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
    this.campaignRedirectLink,
    this.totalSubmissions,
    this.duplicateCount,
    this.relatedLeadsCount,
    this.hidesalesnameonleadcomments,
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
      phone: json['phone'],
      whatsappnumber: json['whatsappnumber'],
      phonenumber2: json['phonenumber2'],
      jobdescription: json['jobdescription'],
      notes: json['notes'],
      date: json['date'],
      assign: json['assign'],
      ignoredublicate: json['ignoredublicate'],
      assigntype: json['assigntype'],
      data: json['data'],
      transferefromdata: json['transferefromdata'],
      resetcreationdate: json['resetcreationdate'],
      leedtype: json['leedtype'],
      last_stage_date_updated: json['last_stage_date_updated'],
      lastdateassign: json['lastdateassign'],
      lastcommentdate: json['lastcommentdate'],
      stagedateupdated: json['stagedateupdated'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      dayonly: json['dayonly'],
      v: json['__v'],
      question1_text: json['question1_text'],
      question1_answer: json['question1_answer'],
      question2_text: json['question2_text'],
      question2_answer: json['question2_answer'],
      question3_text: json['question3_text'],
      question3_answer: json['question3_answer'],
      question4_text: json['question4_text'],
      question4_answer: json['question4_answer'],
      question5_text: json['question5_text'],
      question5_answer: json['question5_answer'],
      campaignRedirectLink: json['campaignRedirectLink'],
      totalSubmissions: json['totalSubmissions'],
      duplicateCount: json['duplicateCount'],
      relatedLeadsCount: json['relatedLeadsCount'],
      hidesalesnameonleadcomments: json['hidesalesnameonleadcomments'],
      budget: json['budget'],
      revenue: json['revenue'],
      unit_price: json['unit_price'],
      Eoi: json['Eoi'],
      Reservation: json['Reservation'],
      review: json['review'],
      unitnumber: json['unitnumber'],
      commissionratio: json['commissionratio'],
      commissionmoney: json['commissionmoney'],
      cashbackratio: json['cashbackratio'],
      cashbackmoney: json['cashbackmoney'],
      project: json['project'] != null ? Project.fromJson(json['project']) : null,
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
      chanel: json['chanel'] != null ? Chanel.fromJson(json['chanel']) : null,
      communicationway: json['communicationway'] != null
          ? CommunicationWay.fromJson(json['communicationway'])
          : null,
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
      updatedby: json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
      campaign: json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
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
      developer:
          json['developer'] != null
              ? SimpleObj.fromJson(json['developer'])
              : null,
      city: json['city'] != null ? SimpleObj.fromJson(json['city']) : null,
    );
  }
}

class SimpleObj {
  final String? id;
  final String? name;

  SimpleObj({this.id, this.name});

  factory SimpleObj.fromJson(Map<String, dynamic> json) {
    return SimpleObj(id: json['_id'], name: json['name']);
  }
}

class Chanel {
  final String? id;
  final String? name;
  final String? code;

  Chanel({this.id, this.name, this.code});

  factory Chanel.fromJson(Map<String, dynamic> json) {
    return Chanel(id: json['_id'], name: json['name'], code: json['code']);
  }
}

class CommunicationWay {
  final String? id;
  final String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) {
    return CommunicationWay(id: json['_id'], name: json['name']);
  }
}

class StageType {
  final String? id;
  final String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(id: json['_id'], name: json['name']);
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
      stagetype:
          json['stagetype'] != null
              ? StageType.fromJson(json['stagetype'])
              : null,
    );
  }
}

class Campaign {
  final String? id;
  final String? CampainName;
  final String? Date;
  final num? Cost;
  final String? redirectLink; // ✅ أضف هذا
  final bool? isactivate;
  final User? addby;
  final User? updatedby;

  Campaign({
    this.id,
    this.CampainName,
    this.Date,
    this.Cost,
    this.redirectLink,
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
      redirectLink: json['redirectLink'],
      isactivate: json['isactivate'],
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
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
      city: (json['city'] as List?)?.map((e) => SimpleObj.fromJson(e)).toList(),
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
      communicationway:
          json['communicationway'] != null
              ? CommunicationWay.fromJson(json['communicationway'])
              : null,
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
    );
  }
}
