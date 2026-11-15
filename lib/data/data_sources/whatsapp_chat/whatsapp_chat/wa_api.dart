import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'package:http_parser/http_parser.dart';
import 'wa_config.dart';
import 'wa_models.dart';

/// Unified API error (server `error` / `message` + `code`)
class WaApiException implements Exception {
  final int status;
  final String message;
  final String? code;
  WaApiException(this.status, this.message, [this.code]);

  /// The docs mention both codes (window_closed in Postman / closed_window in the PDF) — we handle both
  bool get windowClosed => code == 'window_closed' || code == 'closed_window';
  bool get forbidden => status == 403;

  @override
  String toString() => message;
}

/// Chat (inbox) endpoints only — no other Unifonic endpoints
class WaChatApi {
  final http.Client _client;
  WaChatApi({http.Client? client}) : _client = client ?? http.Client();

  String get _inbox => '${WaConfig.baseUrl()}/api/v1/messaging/inbox';

  Future<Map<String, String>> _headers({bool json = true}) async {
    final t = await WaConfig.token();
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
    };
  }

  int _maxBytes(MediaType m) {
    if (m.type == 'image') return 5 * 1024 * 1024;
    if (m.type == 'video' || m.type == 'audio') return 16 * 1024 * 1024;
    return 25 * 1024 * 1024; // documents
  }

  /// POST /api/v1/Signup/refresh-token — refresh the token once on a 401
  Future<bool> _refreshToken() async {
    try {
      final old = await WaConfig.token();
      if (old == null || old.isEmpty) return false;
      final res = await _client.post(
        Uri.parse('${WaConfig.baseUrl()}/api/v1/Signup/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'old_token': old,
          'deviceId': await WaConfig.deviceId(),
        }),
      );
      if (res.statusCode != 200) return false;
      final j = jsonDecode(utf8.decode(res.bodyBytes));
      final nt = j['access_token']?.toString();
      if (nt == null || nt.isEmpty) return false;
      await WaConfig.saveToken(nt);
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _decode(http.Response res) {
    if (res.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  dynamic _unwrap(http.Response res) {
    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    String msg = 'Something went wrong (${res.statusCode})';
    String? code;
    if (data is Map) {
      msg = (data['error'] ?? data['message'] ?? msg).toString();
      code = data['code']?.toString();
    }
    if (res.statusCode == 413) msg = 'File is too large for the server';
    throw WaApiException(res.statusCode, msg, code);
  }

  Future<dynamic> _call(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool retried = false,
  }) async {
    var uri = Uri.parse('$_inbox$path');
    if (query != null) {
      final q = <String, String>{};
      query.forEach((k, v) {
        if (v != null && v.toString().isNotEmpty) q[k] = v.toString();
      });
      if (q.isNotEmpty) uri = uri.replace(queryParameters: q);
    }
    final headers = await _headers();
    http.Response res;
    try {
      res =
          method == 'POST'
              ? await _client.post(
                uri,
                headers: headers,
                body: jsonEncode(body ?? {}),
              )
              : await _client.get(uri, headers: headers);
    } on SocketException {
      throw WaApiException(0, 'No internet connection');
    } on http.ClientException {
      throw WaApiException(0, 'Could not reach the server');
    }
    if (res.statusCode == 401 && !retried && await _refreshToken()) {
      return _call(method, path, query: query, body: body, retried: true);
    }
    return _unwrap(res);
  }

  // ---------------- Read ----------------

  Future<WaPermissions> getMe() async => WaPermissions.fromJson(
    Map<String, dynamic>.from(await _call('GET', '/me')),
  );

  Future<List<WaSalesOption>> getSales() async {
    final r = await _call('GET', '/sales', query: {'active': '1'}) as List;
    return r
        .map((e) => WaSalesOption.fromJson(Map<String, dynamic>.from(e)))
        .where((x) => x.active)
        .toList();
  }

  /// salesId: '' = all | 'none' = unassigned (admin only) | sales id
  Future<WaConversationsPage> getConversations({
    int page = 1,
    int limit = 30,
    String q = '',
    bool unreadOnly = false,
    String salesId = '',
  }) async {
    final r = await _call(
      'GET',
      '/conversations',
      query: {
        'page': page,
        'limit': limit,
        'q': q.trim(),
        'unread': unreadOnly ? '1' : null,
        'salesId': salesId,
      },
    );
    return WaConversationsPage.fromJson(Map<String, dynamic>.from(r));
  }

  Future<WaConversation> getConversation(String id) async =>
      WaConversation.fromJson(
        Map<String, dynamic>.from(await _call('GET', '/conversations/$id')),
      );

  /// Messages come oldest → newest. before = ISO time of the oldest message you have
  Future<WaMessagesPage> getMessages(
    String id, {
    int limit = 50,
    DateTime? before,
  }) async {
    final r = await _call(
      'GET',
      '/conversations/$id/messages',
      query: {'limit': limit, 'before': before?.toUtc().toIso8601String()},
    );
    final m = Map<String, dynamic>.from(r);
    return WaMessagesPage(
      (m['rows'] as List? ?? [])
          .map((e) => WaMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      m['hasMore'] == true,
    );
  }

  Future<WaConversation> markRead(String id) async => WaConversation.fromJson(
    Map<String, dynamic>.from(await _call('POST', '/conversations/$id/read')),
  );

  // ---------------- Send ----------------

  Future<WaMessage> sendText(String id, String text) async =>
      WaMessage.fromJson(
        Map<String, dynamic>.from(
          await _call(
            'POST',
            '/conversations/$id/messages',
            body: {'type': 'text', 'text': text},
          ),
        ),
      );

  /// Upload a file (multipart) — returns a public url to use in sendMedia or as the template mediaUrl
  /// Map file extension -> MIME type (http would otherwise send application/octet-stream)
  MediaType _mime(String path) {
    final ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'mp4':
        return MediaType('video', 'mp4');
      case '3gp':
        return MediaType('video', '3gpp');
      case 'aac':
        return MediaType('audio', 'aac');
      case 'm4a':
        return MediaType('audio', 'mp4');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'amr':
        return MediaType('audio', 'amr');
      case 'ogg':
      case 'opus':
        return MediaType('audio', 'ogg');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
      case 'txt':
        return MediaType('text', 'plain');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Upload a file (multipart) — returns a public url to use in sendMedia or as the template mediaUrl
  Future<WaUpload> upload(String filePath, {bool retried = false}) async {
    final size = await File(filePath).length();
    final mime = _mime(filePath);
    final max = _maxBytes(mime);
    if (size > max) {
      throw WaApiException(
        0,
        'File is too large (${(size / 1048576).toStringAsFixed(1)} MB). '
        'Maximum is ${max ~/ 1048576} MB for this file type',
      );
    }
    // 🔍 DEBUG: what are we actually sending?
    dev.log('📤 [WA upload] path=$filePath');
    dev.log(
      '📤 [WA upload] size=${(size / 1024).toStringAsFixed(1)} KB  mime=$mime',
    );

    final req = http.MultipartRequest('POST', Uri.parse('$_inbox/upload'));
    req.headers.addAll(await _headers(json: false));
    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType:
            mime, // explicit, so the server sees image/jpeg, not octet-stream
      ),
    );

    http.Response res;
    try {
      res = await http.Response.fromStream(await _client.send(req));
    } on SocketException {
      throw WaApiException(0, 'No internet connection');
    } on http.ClientException {
      throw WaApiException(0, 'Could not reach the server');
    }

    // 🔍 DEBUG: what did the server answer?
    dev.log('📥 [WA upload] status=${res.statusCode}');
    dev.log('📥 [WA upload] body=${utf8.decode(res.bodyBytes)}');

    if (res.statusCode == 401 && !retried && await _refreshToken()) {
      return upload(filePath, retried: true);
    }
    final m = Map<String, dynamic>.from(_unwrap(res));
    return WaUpload(
      m['url'].toString(),
      (m['type'] ?? 'file').toString(),
      (m['fileName'] ?? '').toString(),
    );
  }

  /// type: image | video | audio | file (url comes from upload)
  Future<WaMessage> sendMedia(
    String id, {
    required String type,
    required String url,
    String? fileName,
    String? caption,
  }) async {
    return WaMessage.fromJson(
      Map<String, dynamic>.from(
        await _call(
          'POST',
          '/conversations/$id/messages',
          body: {
            'type': type,
            'url': url,
            if (type == 'file' && fileName != null && fileName.isNotEmpty)
              'fileName': fileName,
            if (caption != null && caption.trim().isNotEmpty)
              'text': caption.trim(),
          },
        ),
      ),
    );
  }

  // ---------------- Templates (after the 24h window closes) ----------------

  Future<List<WaTemplate>> getTemplates(String id) async {
    final r = await _call('GET', '/conversations/$id/templates') as List;
    return r
        .map((e) => WaTemplate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<WaMessage> sendTemplate(
    String id, {
    required String name,
    required String language,
    List<String> bodyVars = const [],
    List<String> headerVars = const [],
    String? mediaUrl,
  }) async {
    return WaMessage.fromJson(
      Map<String, dynamic>.from(
        await _call(
          'POST',
          '/conversations/$id/messages',
          body: {
            'type': 'template',
            'name': name,
            'language': language,
            'values': {
              if (bodyVars.isNotEmpty) 'bodyVars': bodyVars,
              if (headerVars.isNotEmpty) 'headerVars': headerVars,
              if (mediaUrl != null && mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
            },
          },
        ),
      ),
    );
  }

  // ---------------- Assign to sales (Admin / Manager / Team Leader) ----------------

  /// Returns { assigned, already, noLead, notAllowed, salesName } — up to 500 conversations
  Future<Map<String, dynamic>> assign(
    List<String> conversationIds,
    String salesId,
  ) async => Map<String, dynamic>.from(
    await _call(
      'POST',
      '/assign',
      body: {'conversationIds': conversationIds, 'salesId': salesId},
    ),
  );
}
