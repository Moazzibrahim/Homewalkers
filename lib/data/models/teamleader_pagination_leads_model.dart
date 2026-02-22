class TeamleaderPaginationLeadsModel {
  final bool? success;
  final String? requestedEmail;
  final TeamLeaderInfo? teamLeaderInfo;
  final SearchInfo? searchInfo;
  final num? results;
  final PaginationInfo? pagination;
  final List<LeadDataPagination>? data;
  final DebugInfo? debugInfo;

  TeamleaderPaginationLeadsModel({
    this.success,
    this.requestedEmail,
    this.teamLeaderInfo,
    this.searchInfo,
    this.results,
    this.pagination,
    this.data,
    this.debugInfo,
  });

  factory TeamleaderPaginationLeadsModel.fromJson(Map<String, dynamic> json) {
    return TeamleaderPaginationLeadsModel(
      success: json['success'] as bool?,
      requestedEmail: json['requestedEmail'] as String?,
      teamLeaderInfo:
          json['teamLeaderInfo'] != null
              ? TeamLeaderInfo.fromJson(json['teamLeaderInfo'])
              : null,
      searchInfo:
          json['searchInfo'] != null
              ? SearchInfo.fromJson(json['searchInfo'])
              : null,
      results: json['results'] as num?,
      pagination:
          json['pagination'] != null
              ? PaginationInfo.fromJson(json['pagination'])
              : null,
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((e) => LeadDataPagination.fromJson(e))
                  .toList()
              : null,
      debugInfo:
          json['debugInfo'] != null
              ? DebugInfo.fromJson(json['debugInfo'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'requestedEmail': requestedEmail,
      'teamLeaderInfo': teamLeaderInfo?.toJson(),
      'searchInfo': searchInfo?.toJson(),
      'results': results,
      'pagination': pagination?.toJson(),
      'data': data?.map((e) => e.toJson()).toList(),
      'debugInfo': debugInfo?.toJson(),
    };
  }
}

class TeamLeaderInfo {
  final String? email;
  final num? activeSalesCount;
  final List<String>? activeSalesIds;
  final List<String>? activeSalesNames;
  final bool? hasActiveLeads;
  final num? totalActiveLeads;
  final String? note;

  TeamLeaderInfo({
    this.email,
    this.activeSalesCount,
    this.activeSalesIds,
    this.activeSalesNames,
    this.hasActiveLeads,
    this.totalActiveLeads,
    this.note,
  });

  factory TeamLeaderInfo.fromJson(Map<String, dynamic> json) {
    return TeamLeaderInfo(
      email: json['email'] as String?,
      activeSalesCount: json['activeSalesCount'] as num?,
      activeSalesIds:
          json['activeSalesIds'] != null
              ? List<String>.from(json['activeSalesIds'])
              : null,
      activeSalesNames:
          json['activeSalesNames'] != null
              ? List<String>.from(json['activeSalesNames'])
              : null,
      hasActiveLeads: json['hasActiveLeads'] as bool?,
      totalActiveLeads: json['totalActiveLeads'] as num?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'activeSalesCount': activeSalesCount,
      'activeSalesIds': activeSalesIds,
      'activeSalesNames': activeSalesNames,
      'hasActiveLeads': hasActiveLeads,
      'totalActiveLeads': totalActiveLeads,
      'note': note,
    };
  }
}

class SearchInfo {
  final bool? hasKeyword;
  final String? leadisactive;
  final num? resultsCount;
  final num? baseResultsCount;
  final Filters? filters;

  SearchInfo({
    this.hasKeyword,
    this.leadisactive,
    this.resultsCount,
    this.baseResultsCount,
    this.filters,
  });

  factory SearchInfo.fromJson(Map<String, dynamic> json) {
    return SearchInfo(
      hasKeyword: json['hasKeyword'] as bool?,
      leadisactive: json['leadisactive'] as String?,
      resultsCount: json['resultsCount'] as num?,
      baseResultsCount: json['baseResultsCount'] as num?,
      filters:
          json['filters'] != null ? Filters.fromJson(json['filters']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasKeyword': hasKeyword,
      'leadisactive': leadisactive,
      'resultsCount': resultsCount,
      'baseResultsCount': baseResultsCount,
      'filters': filters?.toJson(),
    };
  }
}

class Filters {
  final List<dynamic>? stages;
  final List<dynamic>? projects;
  final List<dynamic>? developers;
  final List<dynamic>? channels;
  final List<dynamic>? campaigns;
  final dynamic createdFrom;
  final dynamic createdTo;
  final dynamic stageDateFrom;
  final dynamic stageDateTo;
  final dynamic specificSales;
  final bool? data;
  final bool? transferefromdata;
  final bool? salesActiveOnly;
  final bool? leadsActiveOnly;
  final bool? multiSalesFilter;

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
    this.specificSales,
    this.data,
    this.transferefromdata,
    this.salesActiveOnly,
    this.leadsActiveOnly,
    this.multiSalesFilter,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      stages: json['stages'] as List?,
      projects: json['projects'] as List?,
      developers: json['developers'] as List?,
      channels: json['channels'] as List?,
      campaigns: json['campaigns'] as List?,
      createdFrom: json['createdFrom'],
      createdTo: json['createdTo'],
      stageDateFrom: json['stageDateFrom'],
      stageDateTo: json['stageDateTo'],
      specificSales: json['specificSales'],
      data: _parseBool(json['data']),
      transferefromdata: _parseBool(json['transferefromdata']),
      salesActiveOnly: json['salesActiveOnly'] as bool?,
      leadsActiveOnly: json['leadsActiveOnly'] as bool?,
      multiSalesFilter: json['multiSalesFilter'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stages': stages,
      'projects': projects,
      'developers': developers,
      'channels': channels,
      'campaigns': campaigns,
      'createdFrom': createdFrom,
      'createdTo': createdTo,
      'stageDateFrom': stageDateFrom,
      'stageDateTo': stageDateTo,
      'specificSales': specificSales,
      'data': data,
      'transferefromdata': transferefromdata,
      'salesActiveOnly': salesActiveOnly,
      'leadsActiveOnly': leadsActiveOnly,
      'multiSalesFilter': multiSalesFilter,
    };
  }
}

class PaginationInfo {
  final num? currentPage;
  final num? limit;
  final num? numberOfPages;
  final num? totalItems;
  final num? totalAllLeads;
  final num? totalLeadsActive;
  final num? totalLeadsInactive;
  final num? numberOfPagesInactive;
  final num? activePercentage;
  final num? inactivePercentage;
  final num? totalLeadsForTeamLeader;
  final num? activeLeadsForTeamLeader;
  final bool? hasKeywordSearch;
  final String? keyword;
  final FiltersApplied? filtersApplied;
  final num? baseResultsCount;
  final num? searchResultsCount;
  final num? next;

  PaginationInfo({
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
    this.totalLeadsForTeamLeader,
    this.activeLeadsForTeamLeader,
    this.hasKeywordSearch,
    this.keyword,
    this.filtersApplied,
    this.baseResultsCount,
    this.searchResultsCount,
    this.next,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] as num?,
      limit: json['limit'] as num?,
      numberOfPages: json['NumberOfPages'] as num?,
      totalItems: json['totalItems'] as num?,
      totalAllLeads: json['totalAllLeads'] as num?,
      totalLeadsActive: json['totalLeadsActive'] as num?,
      totalLeadsInactive: json['totalLeadsInactive'] as num?,
      numberOfPagesInactive: json['NumberOfPagesInactive'] as num?,
      activePercentage: json['activePercentage'] as num?,
      inactivePercentage: json['inactivePercentage'] as num?,
      totalLeadsForTeamLeader: json['totalLeadsForTeamLeader'] as num?,
      activeLeadsForTeamLeader: json['activeLeadsForTeamLeader'] as num?,
      hasKeywordSearch: json['hasKeywordSearch'] as bool?,
      keyword: json['keyword'] as String?,
      filtersApplied:
          json['filtersApplied'] != null
              ? FiltersApplied.fromJson(json['filtersApplied'])
              : null,
      baseResultsCount: json['baseResultsCount'] as num?,
      searchResultsCount: json['searchResultsCount'] as num?,
      next: json['next'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'totalLeadsForTeamLeader': totalLeadsForTeamLeader,
      'activeLeadsForTeamLeader': activeLeadsForTeamLeader,
      'hasKeywordSearch': hasKeywordSearch,
      'keyword': keyword,
      'filtersApplied': filtersApplied?.toJson(),
      'baseResultsCount': baseResultsCount,
      'searchResultsCount': searchResultsCount,
      'next': next,
    };
  }
}

class FiltersApplied {
  final String? leadisactive;
  final num? stages;
  final num? projects;
  final num? developers;
  final num? channels;
  final num? campaigns;
  final num? creationDate;
  final num? stageDate;
  final num? data;
  final num? transferefromdata;
  final bool? salesActiveOnly;
  final bool? multiSales;

  FiltersApplied({
    this.leadisactive,
    this.stages,
    this.projects,
    this.developers,
    this.channels,
    this.campaigns,
    this.creationDate,
    this.stageDate,
    this.data,
    this.transferefromdata,
    this.salesActiveOnly,
    this.multiSales,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(
      leadisactive: json['leadisactive'] as String?,
      stages: json['stages'] as num?,
      projects: json['projects'] as num?,
      developers: json['developers'] as num?,
      channels: json['channels'] as num?,
      campaigns: json['campaigns'] as num?,
      creationDate: json['creationDate'] as num?,
      stageDate: json['stageDate'] as num?,
      data: json['data'] as num?,
      transferefromdata: json['transferefromdata'] as num?,
      salesActiveOnly: json['salesActiveOnly'] as bool?,
      multiSales: json['multiSales'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leadisactive': leadisactive,
      'stages': stages,
      'projects': projects,
      'developers': developers,
      'channels': channels,
      'campaigns': campaigns,
      'creationDate': creationDate,
      'stageDate': stageDate,
      'data': data,
      'transferefromdata': transferefromdata,
      'salesActiveOnly': salesActiveOnly,
      'multiSales': multiSales,
    };
  }
}

class LeadDataPagination {
  final String? id;
  final String? name;
  final bool? leadisactive;
  final String? whatsappnumber;
  final String? phonenumber2;
  final String? jobdescription;
  final String? email;
  final String? phone;
  final Project? project;
  final Sales? sales;
  final String? date;
  final bool? assign;
  final bool? ignoredublicate;
  final Stage? stage;
  final Channel? chanel;
  final CommunicationWay? communicationway;
  final String? leedtype;
  final bool? assigntype;
  final bool? data;
  final bool? transferefromdata;
  final bool? resetcreationdate;
  final num? budget;
  final num? revenue;
  final num? unitPrice;
  final num? eoi;
  final num? reservation;
  final bool? review;
  final String? unitnumber;
  final num? commissionratio;
  final num? commissionmoney;
  final num? cashbackratio;
  final num? cashbackmoney;
  final String? stagedateupdated;
  final String? dayonly;
  final String? lastStageDateUpdated;
  final String? lastdateassign;
  final User? addby;
  final User? updatedby;
  final Campaign? campaign;
  final num? duplicateCount;
  final num? relatedLeadsCount;
  final num? totalSubmissions;
  final String? lastcommentdate;
  final List<Version>? allVersions;
  final List<MergeHistory>? mergeHistory;
  final String? createdAt;
  final String? updatedAt;
  final num? v;
  final Developer? developer;
  final EmailVerification? emailVerification;

  LeadDataPagination({
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
    this.date,
    this.assign,
    this.ignoredublicate,
    this.stage,
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
    this.unitnumber,
    this.commissionratio,
    this.commissionmoney,
    this.cashbackratio,
    this.cashbackmoney,
    this.stagedateupdated,
    this.dayonly,
    this.lastStageDateUpdated,
    this.lastdateassign,
    this.addby,
    this.updatedby,
    this.campaign,
    this.duplicateCount,
    this.relatedLeadsCount,
    this.totalSubmissions,
    this.lastcommentdate,
    this.allVersions,
    this.mergeHistory,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.developer,
    this.emailVerification,
  });

  factory LeadDataPagination.fromJson(Map<String, dynamic> json) {
    return LeadDataPagination(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      leadisactive: _parseBool(json['leadisactive']),
      whatsappnumber: json['whatsappnumber'] as String?,
      phonenumber2: json['phonenumber2'] as String?,
      jobdescription: json['jobdescription'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      date: json['date'] as String?,
      assign: json['assign'] as bool?,
      ignoredublicate: json['ignoredublicate'] as bool?,
      stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
      chanel: json['chanel'] != null ? Channel.fromJson(json['chanel']) : null,
      communicationway:
          json['communicationway'] != null
              ? CommunicationWay.fromJson(json['communicationway'])
              : null,
      leedtype: json['leedtype'] as String?,
      assigntype: json['assigntype'] as bool?,
      data: _parseBool(json['data']),
      transferefromdata: _parseBool(json['transferefromdata']),
      resetcreationdate: json['resetcreationdate'] as bool?,
      budget: json['budget'] as num?,
      revenue: json['revenue'] as num?,
      unitPrice: json['unit_price'] as num?,
      eoi: json['Eoi'] as num?,
      reservation: json['Reservation'] as num?,
      review: json['review'] as bool?,
      unitnumber: json['unitnumber'] as String?,
      commissionratio: json['commissionratio'] as num?,
      commissionmoney: json['commissionmoney'] as num?,
      cashbackratio: json['cashbackratio'] as num?,
      cashbackmoney: json['cashbackmoney'] as num?,
      stagedateupdated: json['stagedateupdated'] as String?,
      dayonly: json['dayonly'] as String?,
      lastStageDateUpdated: json['last_stage_date_updated'] as String?,
      lastdateassign: json['lastdateassign'] as String?,
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
      campaign:
          json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      duplicateCount: json['duplicateCount'] as num?,
      relatedLeadsCount: json['relatedLeadsCount'] as num?,
      totalSubmissions: json['totalSubmissions'] as num?,
      lastcommentdate: json['lastcommentdate'] as String?,
      allVersions:
          json['allVersions'] != null
              ? (json['allVersions'] as List)
                  .map((e) => Version.fromJson(e))
                  .toList()
              : null,
      mergeHistory:
          json['mergeHistory'] != null
              ? (json['mergeHistory'] as List)
                  .map((e) => MergeHistory.fromJson(e))
                  .toList()
              : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as num?,
      developer:
          json['developer'] != null
              ? Developer.fromJson(json['developer'])
              : null,
      emailVerification:
          json['emailVerification'] != null
              ? EmailVerification.fromJson(json['emailVerification'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'leadisactive': leadisactive?.toString(),
      'whatsappnumber': whatsappnumber,
      'phonenumber2': phonenumber2,
      'jobdescription': jobdescription,
      'email': email,
      'phone': phone,
      'project': project?.toJson(),
      'sales': sales?.toJson(),
      'date': date,
      'assign': assign,
      'ignoredublicate': ignoredublicate,
      'stage': stage?.toJson(),
      'chanel': chanel?.toJson(),
      'communicationway': communicationway?.toJson(),
      'leedtype': leedtype,
      'assigntype': assigntype,
      'data': data,
      'transferefromdata': transferefromdata,
      'resetcreationdate': resetcreationdate,
      'budget': budget,
      'revenue': revenue,
      'unit_price': unitPrice,
      'Eoi': eoi,
      'Reservation': reservation,
      'review': review,
      'unitnumber': unitnumber,
      'commissionratio': commissionratio,
      'commissionmoney': commissionmoney,
      'cashbackratio': cashbackratio,
      'cashbackmoney': cashbackmoney,
      'stagedateupdated': stagedateupdated,
      'dayonly': dayonly,
      'last_stage_date_updated': lastStageDateUpdated,
      'lastdateassign': lastdateassign,
      'addby': addby?.toJson(),
      'updatedby': updatedby?.toJson(),
      'campaign': campaign?.toJson(),
      'duplicateCount': duplicateCount,
      'relatedLeadsCount': relatedLeadsCount,
      'totalSubmissions': totalSubmissions,
      'lastcommentdate': lastcommentdate,
      'allVersions': allVersions?.map((e) => e.toJson()).toList(),
      'mergeHistory': mergeHistory?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'developer': developer?.toJson(),
      'emailVerification': emailVerification?.toJson(),
    };
  }
}

class Project {
  final String? id;
  final String? name;
  final Developer? developer;
  final City? city;
  final num? startprice;

  Project({this.id, this.name, this.developer, this.city, this.startprice});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      developer:
          json['developer'] != null
              ? Developer.fromJson(json['developer'])
              : null,
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      startprice: json['startprice'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'developer': developer?.toJson(),
      'city': city?.toJson(),
      'startprice': startprice,
    };
  }
}

class Developer {
  final String? id;
  final String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(id: json['_id'] as String?, name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class City {
  final String? id;
  final String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['_id'] as String?, name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class Sales {
  final String? id;
  final String? name;
  final List<City>? city;
  final UserLog? userlog;
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
      id: json['_id'] as String?,
      name: json['name'] as String?,
      city:
          json['city'] != null
              ? (json['city'] as List).map((e) => City.fromJson(e)).toList()
              : null,
      userlog:
          json['userlog'] != null ? UserLog.fromJson(json['userlog']) : null,
      teamleader:
          json['teamleader'] != null ? User.fromJson(json['teamleader']) : null,
      manager: json['Manager'] != null ? User.fromJson(json['Manager']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'city': city?.map((e) => e.toJson()).toList(),
      'userlog': userlog?.toJson(),
      'teamleader': teamleader?.toJson(),
      'Manager': manager?.toJson(),
    };
  }
}

class UserLog {
  final List<dynamic>? channels;
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImg;
  final String? role;
  final String? fcmToken;
  final bool? isMarketer;

  UserLog({
    this.channels,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
    this.fcmToken,
    this.isMarketer,
  });

  factory UserLog.fromJson(Map<String, dynamic> json) {
    return UserLog(
      channels: json['channels'] as List?,
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileImg: json['profileImg'] as String?,
      role: json['role'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isMarketer: json['isMarketer'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channels': channels,
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImg': profileImg,
      'role': role,
      'fcmToken': fcmToken,
      'isMarketer': isMarketer,
    };
  }
}

class User {
  final List<Channel>? channels;
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImg;
  final String? role;
  final String? fcmToken;
  final bool? isMarketer;

  User({
    this.channels,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
    this.fcmToken,
    this.isMarketer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      channels:
          json['channels'] != null
              ? (json['channels'] as List)
                  .map((e) => Channel.fromJson(e))
                  .toList()
              : null,
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileImg: json['profileImg'] as String?,
      role: json['role'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isMarketer: json['isMarketer'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channels': channels?.map((e) => e.toJson()).toList(),
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImg': profileImg,
      'role': role,
      'fcmToken': fcmToken,
      'isMarketer': isMarketer,
    };
  }
}

class Channel {
  final String? id;
  final String? name;
  final String? code;
  final bool? active;

  Channel({this.id, this.name, this.code, this.active});

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      active: _parseBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'active': active?.toString(),
    };
  }
}

class Stage {
  final String? id;
  final String? name;
  final StageType? stagetype;

  Stage({this.id, this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      stagetype:
          json['stagetype'] != null
              ? StageType.fromJson(json['stagetype'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'stagetype': stagetype?.toJson()};
  }
}

class StageType {
  final String? id;
  final String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic> json) {
    return StageType(id: json['_id'] as String?, name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class CommunicationWay {
  final String? id;
  final String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) {
    return CommunicationWay(
      id: json['_id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class Campaign {
  final String? id;
  final String? campainName;
  final String? date;
  final num? cost;
  final bool? isactivate;
  final User? addby;
  final User? updatedby;

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
      id: json['_id'] as String?,
      campainName: json['CampainName'] as String?,
      date: json['Date'] as String?,
      cost: json['Cost'] as num?,
      isactivate: json['isactivate'] as bool?,
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
      updatedby:
          json['updatedby'] != null ? User.fromJson(json['updatedby']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'CampainName': campainName,
      'Date': date,
      'Cost': cost,
      'isactivate': isactivate,
      'addby': addby?.toJson(),
      'updatedby': updatedby?.toJson(),
    };
  }
}

class Version {
  final String? name;
  final String? email;
  final String? phone;
  final Project? project;
  final Channel? chanel;
  final Campaign? campaign;
  final num? budget;
  final num? revenue;
  final num? unitPrice;
  final String? leedtype;
  final CommunicationWay? communicationway;
  final User? addby;
  final String? recordedAt;
  final num? versionNumber;

  Version({
    this.name,
    this.email,
    this.phone,
    this.project,
    this.chanel,
    this.campaign,
    this.budget,
    this.revenue,
    this.unitPrice,
    this.leedtype,
    this.communicationway,
    this.addby,
    this.recordedAt,
    this.versionNumber,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      chanel: json['chanel'] != null ? Channel.fromJson(json['chanel']) : null,
      campaign:
          json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      budget: json['budget'] as num?,
      revenue: json['revenue'] as num?,
      unitPrice: json['unit_price'] as num?,
      leedtype: json['leedtype'] as String?,
      communicationway:
          json['communicationway'] != null
              ? CommunicationWay.fromJson(json['communicationway'])
              : null,
      addby: json['addby'] != null ? User.fromJson(json['addby']) : null,
      recordedAt: json['recordedAt'] as String?,
      versionNumber: json['versionNumber'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'project': project?.toJson(),
      'chanel': chanel?.toJson(),
      'campaign': campaign?.toJson(),
      'budget': budget,
      'revenue': revenue,
      'unit_price': unitPrice,
      'leedtype': leedtype,
      'communicationway': communicationway?.toJson(),
      'addby': addby?.toJson(),
      'recordedAt': recordedAt,
      'versionNumber': versionNumber,
    };
  }
}

class MergeHistory {
  final User? mergedBy;
  final MergedData? mergedData;
  final String? mergedAt;

  MergeHistory({this.mergedBy, this.mergedData, this.mergedAt});

  factory MergeHistory.fromJson(Map<String, dynamic> json) {
    return MergeHistory(
      mergedBy:
          json['mergedBy'] != null ? User.fromJson(json['mergedBy']) : null,
      mergedData:
          json['mergedData'] != null
              ? MergedData.fromJson(json['mergedData'])
              : null,
      mergedAt: json['mergedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mergedBy': mergedBy?.toJson(),
      'mergedData': mergedData?.toJson(),
      'mergedAt': mergedAt,
    };
  }
}

class MergedData {
  final String? name;
  final String? email;
  final String? phone;
  final String? project;
  final String? chanel;
  final String? campaign;

  MergedData({
    this.name,
    this.email,
    this.phone,
    this.project,
    this.chanel,
    this.campaign,
  });

  factory MergedData.fromJson(Map<String, dynamic> json) {
    return MergedData(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      project: json['project'] as String?,
      chanel: json['chanel'] as String?,
      campaign: json['campaign'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'project': project,
      'chanel': chanel,
      'campaign': campaign,
    };
  }
}

class EmailVerification {
  final String? requestedEmail;
  final String? teamLeaderEmail;
  final bool? isMatch;
  final bool? salesIsActive;
  final bool? leadIsActive;
  final bool? dataStatus;
  final bool? transferStatus;

  EmailVerification({
    this.requestedEmail,
    this.teamLeaderEmail,
    this.isMatch,
    this.salesIsActive,
    this.leadIsActive,
    this.dataStatus,
    this.transferStatus,
  });

  factory EmailVerification.fromJson(Map<String, dynamic> json) {
    return EmailVerification(
      requestedEmail: json['requestedEmail'] as String?,
      teamLeaderEmail: json['teamLeaderEmail'] as String?,
      isMatch: json['isMatch'] as bool?,
      salesIsActive: json['salesIsActive'] as bool?,
      leadIsActive: json['leadIsActive'] as bool?,
      dataStatus: json['dataStatus'] as bool?,
      transferStatus: json['transferStatus'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestedEmail': requestedEmail,
      'teamLeaderEmail': teamLeaderEmail,
      'isMatch': isMatch,
      'salesIsActive': salesIsActive,
      'leadIsActive': leadIsActive,
      'dataStatus': dataStatus,
      'transferStatus': transferStatus,
    };
  }
}

class DebugInfo {
  final num? baseQueryCount;
  final num? searchQueryCount;
  final num? sampleLeadsCount;
  final String? queryUsed;
  final Map<String, dynamic>? searchQuery;
  final List<String>? activeSalesIdsUsed;
  final List<ActiveSalesInfo>? allActiveSalesForTeamLeader;
  final bool? multiSalesRequested;
  final bool? dataFilterApplied;
  final bool? transferefromdataFilterApplied;

  DebugInfo({
    this.baseQueryCount,
    this.searchQueryCount,
    this.sampleLeadsCount,
    this.queryUsed,
    this.searchQuery,
    this.activeSalesIdsUsed,
    this.allActiveSalesForTeamLeader,
    this.multiSalesRequested,
    this.dataFilterApplied,
    this.transferefromdataFilterApplied,
  });

  factory DebugInfo.fromJson(Map<String, dynamic> json) {
    return DebugInfo(
      baseQueryCount: json['baseQueryCount'] as num?,
      searchQueryCount: json['searchQueryCount'] as num?,
      sampleLeadsCount: json['sampleLeadsCount'] as num?,
      queryUsed: json['queryUsed'] as String?,
      searchQuery: json['searchQuery'] as Map<String, dynamic>?,
      activeSalesIdsUsed:
          json['activeSalesIdsUsed'] != null
              ? List<String>.from(json['activeSalesIdsUsed'])
              : null,
      allActiveSalesForTeamLeader:
          json['allActiveSalesForTeamLeader'] != null
              ? (json['allActiveSalesForTeamLeader'] as List)
                  .map((e) => ActiveSalesInfo.fromJson(e))
                  .toList()
              : null,
      multiSalesRequested: json['multiSalesRequested'] as bool?,
      dataFilterApplied: json['dataFilterApplied'] as bool?,
      transferefromdataFilterApplied:
          json['transferefromdataFilterApplied'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseQueryCount': baseQueryCount,
      'searchQueryCount': searchQueryCount,
      'sampleLeadsCount': sampleLeadsCount,
      'queryUsed': queryUsed,
      'searchQuery': searchQuery,
      'activeSalesIdsUsed': activeSalesIdsUsed,
      'allActiveSalesForTeamLeader':
          allActiveSalesForTeamLeader?.map((e) => e.toJson()).toList(),
      'multiSalesRequested': multiSalesRequested,
      'dataFilterApplied': dataFilterApplied,
      'transferefromdataFilterApplied': transferefromdataFilterApplied,
    };
  }
}

class ActiveSalesInfo {
  final String? id;
  final String? name;
  final bool? salesisactivate;

  ActiveSalesInfo({this.id, this.name, this.salesisactivate});

  factory ActiveSalesInfo.fromJson(Map<String, dynamic> json) {
    return ActiveSalesInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      salesisactivate: _parseBool(json['salesisactivate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'salesisactivate': salesisactivate?.toString(),
    };
  }
}

// ✅ دالة مساعدة لتحويل أي قيمة إلى bool?
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value == 1;
  return null;
}
