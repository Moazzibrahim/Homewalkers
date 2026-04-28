
// ==================== Main Response Model ====================

class GetAllRequestsResponse {
  final String status;
  final int results;
  final List<RequestLog> data;
  final PaginationInfo pagination;

  GetAllRequestsResponse({
    required this.status,
    required this.results,
    required this.data,
    required this.pagination,
  });

  factory GetAllRequestsResponse.fromJson(Map<String, dynamic> json) {
    return GetAllRequestsResponse(
      status: json['status'] ?? '',
      results: json['results'] ?? 0,
      data: (json['data'] as List?)
              ?.map((item) => RequestLog.fromJson(item))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'results': results,
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  bool get isSuccess => status == 'success';
}

// ==================== Pagination Model ====================

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 20,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}

// ==================== Request Log Model ====================

class RequestLog {
  final String id;
  final SalesInfo salesid;
  final UserInfo userid;
  final int requestedlimit;
  final int actualtransferredcount;
  final String status;
  final List<LeadBasicInfo> leadsids;
  final String? error;
  final SalesInfo transferfrom;
  final SalesInfo transferto;
  final int maxallowedlimit;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RequestLog({
    required this.id,
    required this.salesid,
    required this.userid,
    required this.requestedlimit,
    required this.actualtransferredcount,
    required this.status,
    required this.leadsids,
    this.error,
    required this.transferfrom,
    required this.transferto,
    required this.maxallowedlimit,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RequestLog.fromJson(Map<String, dynamic> json) {
    return RequestLog(
      id: json['_id'] ?? '',
      salesid: SalesInfo.fromJson(json['salesid'] ?? {}),
      userid: UserInfo.fromJson(json['userid'] ?? {}),
      requestedlimit: json['requestedlimit'] ?? 0,
      actualtransferredcount: json['actualtransferredcount'] ?? 0,
      status: json['status'] ?? '',
      leadsids: (json['leadsids'] as List?)
              ?.map((lead) => LeadBasicInfo.fromJson(lead))
              .toList() ??
          [],
      error: json['error'],
      transferfrom: SalesInfo.fromJson(json['transferfrom'] ?? {}),
      transferto: SalesInfo.fromJson(json['transferto'] ?? {}),
      maxallowedlimit: json['maxallowedlimit'] ?? 0,
      notes: json['notes'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'salesid': salesid.toJson(),
      'userid': userid.toJson(),
      'requestedlimit': requestedlimit,
      'actualtransferredcount': actualtransferredcount,
      'status': status,
      'leadsids': leadsids.map((e) => e.toJson()).toList(),
      'error': error,
      'transferfrom': transferfrom.toJson(),
      'transferto': transferto.toJson(),
      'maxallowedlimit': maxallowedlimit,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
  
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
  }
}

// ==================== Sales Info Model ====================

class SalesInfo {
  final String id;
  final String name;
  final List<CityInfo> city;
  final UserLogInfo? userlog;
  final int? assignedLeads;
  final SalesInfo? teamleader;
  final SalesInfo? manager;

  SalesInfo({
    required this.id,
    required this.name,
    required this.city,
    this.userlog,
    this.assignedLeads,
    this.teamleader,
    this.manager,
  });

  factory SalesInfo.fromJson(Map<String, dynamic> json) {
    return SalesInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      city: (json['city'] as List?)
              ?.map((c) => CityInfo.fromJson(c))
              .toList() ??
          [],
      userlog: json['userlog'] != null ? UserLogInfo.fromJson(json['userlog']) : null,
      assignedLeads: json['assignedLeads'],
      teamleader: json['teamleader'] != null ? SalesInfo.fromJson(json['teamleader']) : null,
      manager: json['Manager'] != null ? SalesInfo.fromJson(json['Manager']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'city': city.map((e) => e.toJson()).toList(),
      'userlog': userlog?.toJson(),
      'assignedLeads': assignedLeads,
      'teamleader': teamleader?.toJson(),
      'Manager': manager?.toJson(),
    };
  }
}

// ==================== User Info Model ====================

class UserInfo {
  final String id;
  final String name;
  final String email;
  final String role;
  final int? requestedleadslimit;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.requestedleadslimit,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      requestedleadslimit: json['requestedleadslimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'requestedleadslimit': requestedleadslimit,
    };
  }
}

// ==================== User Log Info Model ====================

class UserLogInfo {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImg;
  final String role;
  final String? fcmToken;

  UserLogInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImg,
    required this.role,
    this.fcmToken,
  });

  factory UserLogInfo.fromJson(Map<String, dynamic> json) {
    return UserLogInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImg: json['profileImg'],
      role: json['role'] ?? '',
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImg': profileImg,
      'role': role,
      'fcmToken': fcmToken,
    };
  }
}

// ==================== City Info Model ====================

class CityInfo {
  final String id;
  final String name;

  CityInfo({required this.id, required this.name});

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

// ==================== Lead Basic Info Model ====================

class LeadBasicInfo {
  final String id;
  final String name;
  final String phone;
  final ProjectBasicInfo? project;
  final SalesInfo? sales;
  final StageBasicInfo? stage;
  final ChanelBasicInfo? chanel;
  final CommunicationWayBasicInfo? communicationway;
  final int budget;
  final AddByBasicInfo? addby;
  final UpdatedByBasicInfo? updatedby;
  final CampaignBasicInfo? campaign;
  final List<dynamic> allVersions;
  final List<dynamic> mergeHistory;

  LeadBasicInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.project,
    this.sales,
    this.stage,
    this.chanel,
    this.communicationway,
    required this.budget,
    this.addby,
    this.updatedby,
    this.campaign,
    required this.allVersions,
    required this.mergeHistory,
  });

  factory LeadBasicInfo.fromJson(Map<String, dynamic> json) {
    return LeadBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      project: json['project'] != null ? ProjectBasicInfo.fromJson(json['project']) : null,
      sales: json['sales'] != null ? SalesInfo.fromJson(json['sales']) : null,
      stage: json['stage'] != null ? StageBasicInfo.fromJson(json['stage']) : null,
      chanel: json['chanel'] != null ? ChanelBasicInfo.fromJson(json['chanel']) : null,
      communicationway: json['communicationway'] != null 
          ? CommunicationWayBasicInfo.fromJson(json['communicationway']) 
          : null,
      budget: json['budget'] ?? 0,
      addby: json['addby'] != null ? AddByBasicInfo.fromJson(json['addby']) : null,
      updatedby: json['updatedby'] != null ? UpdatedByBasicInfo.fromJson(json['updatedby']) : null,
      campaign: json['campaign'] != null ? CampaignBasicInfo.fromJson(json['campaign']) : null,
      allVersions: json['allVersions'] ?? [],
      mergeHistory: json['mergeHistory'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'project': project?.toJson(),
      'sales': sales?.toJson(),
      'stage': stage?.toJson(),
      'chanel': chanel?.toJson(),
      'communicationway': communicationway?.toJson(),
      'budget': budget,
      'addby': addby?.toJson(),
      'updatedby': updatedby?.toJson(),
      'campaign': campaign?.toJson(),
      'allVersions': allVersions,
      'mergeHistory': mergeHistory,
    };
  }
}

// ==================== Project Basic Info Model ====================

class ProjectBasicInfo {
  final String id;
  final String name;
  final DeveloperBasicInfo? developer;
  final CityInfo? city;
  final int startprice;

  ProjectBasicInfo({
    required this.id,
    required this.name,
    this.developer,
    this.city,
    required this.startprice,
  });

  factory ProjectBasicInfo.fromJson(Map<String, dynamic> json) {
    return ProjectBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      developer: json['developer'] != null ? DeveloperBasicInfo.fromJson(json['developer']) : null,
      city: json['city'] != null ? CityInfo.fromJson(json['city']) : null,
      startprice: json['startprice'] ?? 0,
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

// ==================== Developer Basic Info Model ====================

class DeveloperBasicInfo {
  final String id;
  final String name;

  DeveloperBasicInfo({required this.id, required this.name});

  factory DeveloperBasicInfo.fromJson(Map<String, dynamic> json) {
    return DeveloperBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

// ==================== Stage Basic Info Model ====================

class StageBasicInfo {
  final String id;
  final String name;
  final StageTypeBasicInfo? stagetype;

  StageBasicInfo({required this.id, required this.name, this.stagetype});

  factory StageBasicInfo.fromJson(Map<String, dynamic> json) {
    return StageBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      stagetype: json['stagetype'] != null 
          ? StageTypeBasicInfo.fromJson(json['stagetype']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'stagetype': stagetype?.toJson(),
    };
  }
}

// ==================== Stage Type Basic Info Model ====================

class StageTypeBasicInfo {
  final String id;
  final String name;

  StageTypeBasicInfo({required this.id, required this.name});

  factory StageTypeBasicInfo.fromJson(Map<String, dynamic> json) {
    return StageTypeBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

// ==================== Chanel Basic Info Model ====================

class ChanelBasicInfo {
  final String id;
  final String name;
  final String code;

  ChanelBasicInfo({required this.id, required this.name, required this.code});

  factory ChanelBasicInfo.fromJson(Map<String, dynamic> json) {
    return ChanelBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
    };
  }
}

// ==================== Communication Way Basic Info Model ====================

class CommunicationWayBasicInfo {
  final String id;
  final String name;

  CommunicationWayBasicInfo({required this.id, required this.name});

  factory CommunicationWayBasicInfo.fromJson(Map<String, dynamic> json) {
    return CommunicationWayBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

// ==================== Add By Basic Info Model ====================

class AddByBasicInfo {
  final String id;
  final String name;
  final String email;
  final String? role;
  final List<ChannelInfo>? channels;

  AddByBasicInfo({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.channels,
  });

  factory AddByBasicInfo.fromJson(Map<String, dynamic> json) {
    return AddByBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      channels: json['channels'] != null
          ? (json['channels'] as List)
              .map((c) => ChannelInfo.fromJson(c))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'channels': channels?.map((e) => e.toJson()).toList(),
    };
  }
}

// ==================== Updated By Basic Info Model ====================

class UpdatedByBasicInfo {
  final String id;
  final String name;
  final String email;
  final String? role;

  UpdatedByBasicInfo({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory UpdatedByBasicInfo.fromJson(Map<String, dynamic> json) {
    return UpdatedByBasicInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

// ==================== Campaign Basic Info Model ====================

class CampaignBasicInfo {
  final String id;
  final String campainName;
  final String? date;
  final int? cost;
  final bool? isactivate;
  final AddByBasicInfo? addby;
  final UpdatedByBasicInfo? updatedby;

  CampaignBasicInfo({
    required this.id,
    required this.campainName,
    this.date,
    this.cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory CampaignBasicInfo.fromJson(Map<String, dynamic> json) {
    return CampaignBasicInfo(
      id: json['_id'] ?? '',
      campainName: json['CampainName'] ?? '',
      date: json['Date'],
      cost: json['Cost'],
      isactivate: json['isactivate'],
      addby: json['addby'] != null ? AddByBasicInfo.fromJson(json['addby']) : null,
      updatedby: json['updatedby'] != null ? UpdatedByBasicInfo.fromJson(json['updatedby']) : null,
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

// ==================== Channel Info Model ====================

class ChannelInfo {
  final String id;
  final String name;
  final String code;
  final String? active;

  ChannelInfo({
    required this.id,
    required this.name,
    required this.code,
    this.active,
  });

  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    return ChannelInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'active': active,
    };
  }
}