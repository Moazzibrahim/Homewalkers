class AssignHistoryResponse {
  final int results;
  final AssignHistoryPagination pagination;
  final List<AssignHistoryItem> data;

  AssignHistoryResponse({
    required this.results,
    required this.pagination,
    required this.data,
  });

  factory AssignHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AssignHistoryResponse(
      results: json['results'] ?? 0,
      pagination: AssignHistoryPagination.fromJson(json['pagination'] ?? {}),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AssignHistoryItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistoryPagination {
  final int currentPage;
  final int limit;
  final int numberOfPages;

  AssignHistoryPagination({
    required this.currentPage,
    required this.limit,
    required this.numberOfPages,
  });

  factory AssignHistoryPagination.fromJson(Map<String, dynamic> json) {
    return AssignHistoryPagination(
      currentPage: json['currentPage'] ?? 1,
      limit: json['limit'] ?? 0,
      numberOfPages: json['NumberOfPages'] ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistoryItem {
  final String id;
  final AssignHistoryLead leadId;
  final String dateAssigned;
  final AssignHistoryUser assignedFrom;
  final AssignHistorySales assignedTo;
  final bool clearHistory;
  final String assignDateTime;
  final String createdAt;
  final String updatedAt;

  AssignHistoryItem({
    required this.id,
    required this.leadId,
    required this.dateAssigned,
    required this.assignedFrom,
    required this.assignedTo,
    required this.clearHistory,
    required this.assignDateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignHistoryItem.fromJson(Map<String, dynamic> json) {
    return AssignHistoryItem(
      id: json['_id'] ?? '',
      leadId: AssignHistoryLead.fromJson(json['LeadId'] ?? {}),
      dateAssigned: json['date_Assigned'] ?? '',
      assignedFrom: AssignHistoryUser.fromJson(json['Assigned_From'] ?? {}),
      assignedTo: AssignHistorySales.fromJson(json['Assigned_to'] ?? {}),
      clearHistory: json['clearHistory'] ?? false,
      assignDateTime: json['assignDateTime'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistoryLead {
  final String id;
  final String name;
  final AssignHistoryProject project;
  final AssignHistorySales sales;
  final AssignHistoryNameCode chanel;
  final AssignHistoryNameOnly communicationway;
  final AssignHistoryUserLog addby;
  final AssignHistoryUserLog updatedby;
  final AssignHistoryCampaign campaign;
  final AssignHistoryStage stage;

  AssignHistoryLead({
    required this.id,
    required this.name,
    required this.project,
    required this.sales,
    required this.chanel,
    required this.communicationway,
    required this.addby,
    required this.updatedby,
    required this.campaign,
    required this.stage,
  });

  factory AssignHistoryLead.fromJson(Map<String, dynamic> json) {
    return AssignHistoryLead(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      project: AssignHistoryProject.fromJson(json['project'] ?? {}),
      sales: AssignHistorySales.fromJson(json['sales'] ?? {}),
      chanel: AssignHistoryNameCode.fromJson(json['chanel'] ?? {}),
      communicationway: AssignHistoryNameOnly.fromJson(json['communicationway'] ?? {}),
      addby: AssignHistoryUserLog.fromJson(json['addby'] ?? {}),
      updatedby: AssignHistoryUserLog.fromJson(json['updatedby'] ?? {}),
      campaign: AssignHistoryCampaign.fromJson(json['campaign'] ?? {}),
      stage: AssignHistoryStage.fromJson(json['stage'] ?? {}),
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistoryProject {
  final String id;
  final String name;
  final int? startPrice;
  final AssignHistoryNameOnly developer;
  final AssignHistoryNameOnly city;

  AssignHistoryProject({
    required this.id,
    required this.name,
    this.startPrice,
    required this.developer,
    required this.city,
  });

  factory AssignHistoryProject.fromJson(Map<String, dynamic> json) {
    return AssignHistoryProject(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      startPrice: json['startprice'],
      developer: AssignHistoryNameOnly.fromJson(json['developer'] ?? {}),
      city: AssignHistoryNameOnly.fromJson(json['city'] ?? {}),
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistorySales {
  final String id;
  final String name;
  final List<AssignHistoryNameOnly> city;
  final AssignHistoryUserLog? userlog;
  final AssignHistoryUserLog? teamleader;
  final AssignHistoryUserLog? manager;

  AssignHistorySales({
    required this.id,
    required this.name,
    required this.city,
    this.userlog,
    this.teamleader,
    this.manager,
  });

  factory AssignHistorySales.fromJson(Map<String, dynamic> json) {
    return AssignHistorySales(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      city: (json['city'] as List<dynamic>?)
              ?.map((e) => AssignHistoryNameOnly.fromJson(e))
              .toList() ??
          [],
      userlog: json['userlog'] != null
          ? AssignHistoryUserLog.fromJson(json['userlog'])
          : null,
      teamleader: json['teamleader'] != null
          ? AssignHistoryUserLog.fromJson(json['teamleader'])
          : null,
      manager: json['Manager'] != null
          ? AssignHistoryUserLog.fromJson(json['Manager'])
          : null,
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistoryUserLog {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? profileImg;
  final String? role;
  final String? fcmToken;
  final bool isMarketer;

  AssignHistoryUserLog({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.profileImg,
    this.role,
    this.fcmToken,
    required this.isMarketer,
  });

  factory AssignHistoryUserLog.fromJson(Map<String, dynamic> json) {
    return AssignHistoryUserLog(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      profileImg: json['profileImg'],
      role: json['role'],
      fcmToken: json['fcmToken'],
      isMarketer: json['isMarketer'] ?? false,
    );
  }
}

// ─────────────────────────────────────────────
// ✅ مستخدم لـ Assigned_From اللي مش فيها citylist
class AssignHistoryUser {
  final String id;
  final String name;
  final bool isMarketer;

  AssignHistoryUser({
    required this.id,
    required this.name,
    required this.isMarketer,
  });

  factory AssignHistoryUser.fromJson(Map<String, dynamic> json) {
    return AssignHistoryUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      isMarketer: json['isMarketer'] ?? false,
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistoryCampaign {
  final String id;
  final String campaignName;
  final String? date;
  final num? cost;
  final String? redirectLink;
  final bool? isActivate;

  AssignHistoryCampaign({
    required this.id,
    required this.campaignName,
    this.date,
    this.cost,
    this.redirectLink,
    this.isActivate,
  });

  factory AssignHistoryCampaign.fromJson(Map<String, dynamic> json) {
    return AssignHistoryCampaign(
      id: json['_id'] ?? '',
      campaignName: json['CampainName'] ?? '',
      date: json['Date'],
      cost: json['Cost'],
      redirectLink: json['redirectLink'],
      isActivate: json['isactivate'],
    );
  }
}

// ─────────────────────────────────────────────
class AssignHistoryStage {
  final String id;
  final String name;
  final AssignHistoryNameOnly stageType;

  AssignHistoryStage({
    required this.id,
    required this.name,
    required this.stageType,
  });

  factory AssignHistoryStage.fromJson(Map<String, dynamic> json) {
    return AssignHistoryStage(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      stageType: AssignHistoryNameOnly.fromJson(json['stagetype'] ?? {}),
    );
  }
}

// ─────────────────────────────────────────────
// ✅ Reusable لأي object فيه _id و name بس
class AssignHistoryNameOnly {
  final String id;
  final String name;

  AssignHistoryNameOnly({required this.id, required this.name});

  factory AssignHistoryNameOnly.fromJson(Map<String, dynamic> json) {
    return AssignHistoryNameOnly(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// ✅ Reusable لـ chanel اللي فيها code كمان
class AssignHistoryNameCode {
  final String id;
  final String name;
  final String code;

  AssignHistoryNameCode({required this.id, required this.name, required this.code});

  factory AssignHistoryNameCode.fromJson(Map<String, dynamic> json) {
    return AssignHistoryNameCode(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}