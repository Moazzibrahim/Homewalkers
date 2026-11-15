// WhatsApp (Unifonic) chat models — match the API shapes in the PDF

String _s(dynamic v) => v?.toString() ?? '';
DateTime? _d(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();
Map<String, dynamic>? _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

// ---------- Time helpers ----------
String waHm(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final p = d.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $p';
}

bool waSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String waDayLabel(DateTime d) {
  final now = DateTime.now();
  if (waSameDay(d, now)) return 'Today';
  if (waSameDay(d, now.subtract(const Duration(days: 1)))) return 'Yesterday';
  return '${d.day}/${d.month}/${d.year}';
}

// ---------- Permissions: GET /inbox/me ----------
class WaPermissions {
  final String role;
  final bool all, canFilter, canAssign, canTemplate;
  const WaPermissions({
    required this.role,
    required this.all,
    required this.canFilter,
    required this.canAssign,
    required this.canTemplate,
  });

  factory WaPermissions.fromJson(Map<String, dynamic> j) {
    final role = _s(j['role']).toLowerCase();
    return WaPermissions(
      role: _s(j['role']),
      all: j['all'] == true,
      canFilter: j['canFilter'] == true,
      canAssign: j['canAssign'] == true,
      // لو الـ backend بيرجّع canTemplate نستخدمه، وإلا نحسبها من الـ role (admin / manager بس)
      canTemplate:
          j.containsKey('canTemplate')
              ? j['canTemplate'] == true
              : (role == 'admin' || role == 'manager'),
    );
  }
}

// ---------- Sales users (filter & assign): GET /inbox/sales ----------
class WaSalesOption {
  final String id, label;
  final bool active;
  const WaSalesOption(this.id, this.label, {this.active = true});

  factory WaSalesOption.fromJson(Map<String, dynamic> j) {
    bool? flag(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      if (s == '1' || s == 'true' || s == 'active') return true;
      if (s == '0' || s == 'false' || s == 'inactive') return false;
      return null;
    }

    final active =
        flag(j['active']) ?? flag(j['isActive']) ?? flag(j['status']) ?? true;
    return WaSalesOption(_s(j['id']), _s(j['label']), active: active);
  }
}

class WaLead {
  final String id, name, phone, stage, project, salesId, salesName, interest;
  const WaLead({
    required this.id,
    required this.name,
    required this.phone,
    required this.stage,
    required this.project,
    required this.salesId,
    required this.salesName,
    this.interest = '',
  });

  factory WaLead.fromJson(Map<String, dynamic> j) => WaLead(
    id: _s(j['id']),
    name: _s(j['name']),
    phone: _s(j['phone']),
    stage: _s(j['stage']),
    project: _s(j['project']),
    salesId: _s(j['salesId']),
    salesName: _s(j['salesName']),
    interest: _s(j['interest']),
  );
}

class WaLastMessage {
  final String text, type, direction, status;
  final DateTime? at;
  const WaLastMessage({
    required this.text,
    required this.type,
    required this.direction,
    required this.status,
    this.at,
  });

  factory WaLastMessage.fromJson(Map<String, dynamic> j) => WaLastMessage(
    text: _s(j['text']),
    type: _s(j['type']),
    direction: _s(j['direction']),
    status: _s(j['status']),
    at: _d(j['at']),
  );
}

// ---------- Conversation ----------
class WaConversation {
  final String id, phone, name, leadId, leadName, senderId;
  final int unread;
  final WaLastMessage? lastMessage;
  final DateTime? lastInboundAt, windowEndsAt;
  final bool windowOpen;
  final WaLead? lead;

  const WaConversation({
    required this.id,
    required this.phone,
    required this.name,
    required this.leadId,
    required this.leadName,
    required this.senderId,
    required this.unread,
    required this.windowOpen,
    this.lastMessage,
    this.lastInboundAt,
    this.windowEndsAt,
    this.lead,
  });

  factory WaConversation.fromJson(Map<String, dynamic> j) => WaConversation(
    id: _s(j['id']),
    phone: _s(j['phone']),
    name: _s(j['name']),
    leadId: _s(j['leadId']),
    leadName: _s(j['leadName']),
    senderId: _s(j['senderId']),
    unread: (j['unread'] as num?)?.toInt() ?? 0,
    lastMessage:
        _m(j['lastMessage']) == null
            ? null
            : WaLastMessage.fromJson(_m(j['lastMessage'])!),
    lastInboundAt: _d(j['lastInboundAt']),
    windowOpen: j['windowOpen'] == true,
    windowEndsAt: _d(j['windowEndsAt']),
    lead: _m(j['lead']) == null ? null : WaLead.fromJson(_m(j['lead'])!),
  );

  /// Display name: lead name, then WhatsApp name, then the phone number
  String get title {
    if (leadName.isNotEmpty) return leadName;
    if (name.isNotEmpty && name != 'Unknown') return name;
    return '+$phone';
  }

  /// Is the 24h window still open? Also checked locally against windowEndsAt
  bool get isWindowOpen {
    if (!windowOpen) return false;
    final e = windowEndsAt;
    return e == null || e.isAfter(DateTime.now());
  }

  DateTime get sortTime =>
      lastMessage?.at ??
      lastInboundAt ??
      DateTime.fromMillisecondsSinceEpoch(0);

  WaConversation copyWith({
    String? name,
    String? leadId,
    String? leadName,
    int? unread,
    WaLastMessage? lastMessage,
    DateTime? lastInboundAt,
    bool? windowOpen,
    DateTime? windowEndsAt,
    WaLead? lead,
  }) => WaConversation(
    id: id,
    phone: phone,
    name: name ?? this.name,
    leadId: leadId ?? this.leadId,
    leadName: leadName ?? this.leadName,
    senderId: senderId,
    unread: unread ?? this.unread,
    windowOpen: windowOpen ?? this.windowOpen,
    lastMessage: lastMessage ?? this.lastMessage,
    lastInboundAt: lastInboundAt ?? this.lastInboundAt,
    windowEndsAt: windowEndsAt ?? this.windowEndsAt,
    lead: lead ?? this.lead,
  );

  /// Socket events and /read do not return lead — keep the existing one
  WaConversation withLeadFrom(WaConversation old) =>
      lead != null
          ? this
          : copyWith(
            lead: old.lead,
            leadId: leadId.isEmpty ? old.leadId : null,
            leadName: leadName.isEmpty ? old.leadName : null,
          );
}

class WaConversationsPage {
  final List<WaConversation> rows;
  final int total, page, pages;
  const WaConversationsPage(this.rows, this.total, this.page, this.pages);

  factory WaConversationsPage.fromJson(Map<String, dynamic> j) =>
      WaConversationsPage(
        (j['rows'] as List? ?? [])
            .map((e) => WaConversation.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        (j['total'] as num?)?.toInt() ?? 0,
        (j['page'] as num?)?.toInt() ?? 1,
        (j['pages'] as num?)?.toInt() ?? 1,
      );
}

// ---------- Message ----------
class WaMedia {
  final String url, fileName;
  const WaMedia(this.url, this.fileName);
}

class WaMessage {
  final String id, conversationId, direction, type, text;
  final String templateName, source, userName, status, error;
  final WaMedia? media;
  final Map<String, dynamic>? location;
  final DateTime at;

  const WaMessage({
    required this.id,
    required this.conversationId,
    required this.direction,
    required this.type,
    required this.text,
    required this.templateName,
    required this.source,
    required this.userName,
    required this.status,
    required this.error,
    required this.at,
    this.media,
    this.location,
  });

  factory WaMessage.fromJson(Map<String, dynamic> j) {
    final media = _m(j['media']);
    return WaMessage(
      id: _s(j['id']),
      conversationId: _s(j['conversationId']),
      direction: _s(j['direction']),
      type: _s(j['type']),
      text: _s(j['text']),
      templateName: _s(j['templateName']),
      source: _s(j['source']),
      userName: _s(j['userName']),
      status: _s(j['status']),
      error: _s(j['error']),
      media:
          media == null
              ? null
              : WaMedia(_s(media['url']), _s(media['fileName'])),
      location: _m(j['location']),
      at: _d(j['at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool get isOut => direction == 'out';
}

class WaMessagesPage {
  final List<WaMessage> rows;
  final bool hasMore;
  const WaMessagesPage(this.rows, this.hasMore);
}

class WaUpload {
  final String url, type, fileName;
  const WaUpload(this.url, this.type, this.fileName);
}

// ---------- Template ----------
class WaTemplate {
  final String name, language, category, headerFormat, headerText, bodyText;
  final String footer;
  final List<String> bodyExamples, quickReplies;

  /// null = no media — otherwise image | video | document
  final String? needsMedia;
  final int headerVars, bodyVars;

  const WaTemplate({
    required this.name,
    required this.language,
    required this.category,
    required this.headerFormat,
    required this.headerText,
    required this.bodyText,
    required this.footer,
    required this.bodyExamples,
    required this.quickReplies,
    required this.needsMedia,
    required this.headerVars,
    required this.bodyVars,
  });

  factory WaTemplate.fromJson(Map<String, dynamic> j) {
    final header = _m(j['header']) ?? {};
    final body = _m(j['body']) ?? {};
    final needs = _m(j['needs']) ?? {};
    return WaTemplate(
      name: _s(j['name']),
      language: _s(j['language']),
      category: _s(j['category']),
      headerFormat: _s(header['format']),
      headerText: _s(header['text']),
      bodyText: _s(body['text']),
      footer: _s(j['footer']),
      bodyExamples: (body['examples'] as List? ?? []).map(_s).toList(),
      quickReplies: (j['quickReplies'] as List? ?? []).map(_s).toList(),
      needsMedia: needs['media']?.toString(),
      headerVars: (needs['headerVars'] as num?)?.toInt() ?? 0,
      bodyVars: (needs['bodyVars'] as num?)?.toInt() ?? 0,
    );
  }

  /// Text preview: replaces {{1}} {{2}} with the values
  String renderBody(List<String> vars) {
    var t = bodyText;
    for (var i = 0; i < vars.length; i++) {
      final ph = '{{${i + 1}}}';
      t = t.replaceAll(ph, vars[i].isEmpty ? ph : vars[i]);
    }
    return t;
  }
}
