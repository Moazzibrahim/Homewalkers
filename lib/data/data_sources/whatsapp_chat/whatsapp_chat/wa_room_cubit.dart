import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'wa_api.dart';
import 'wa_models.dart';
import 'wa_socket.dart';

class WaRoomState {
  final WaConversation conversation;

  /// Oldest → newest
  final List<WaMessage> messages;
  final bool loading, loadingOlder, hasMore, sending, templatesLoading;
  final List<WaTemplate> templates;
  final String? error;

  const WaRoomState({
    required this.conversation,
    this.messages = const [],
    this.loading = true,
    this.loadingOlder = false,
    this.hasMore = false,
    this.sending = false,
    this.templatesLoading = false,
    this.templates = const [],
    this.error,
  });

  WaRoomState copyWith({
    WaConversation? conversation,
    List<WaMessage>? messages,
    bool? loading,
    bool? loadingOlder,
    bool? hasMore,
    bool? sending,
    bool? templatesLoading,
    List<WaTemplate>? templates,
    String? error,
    bool clearError = false,
  }) =>
      WaRoomState(
        conversation: conversation ?? this.conversation,
        messages: messages ?? this.messages,
        loading: loading ?? this.loading,
        loadingOlder: loadingOlder ?? this.loadingOlder,
        hasMore: hasMore ?? this.hasMore,
        sending: sending ?? this.sending,
        templatesLoading: templatesLoading ?? this.templatesLoading,
        templates: templates ?? this.templates,
        error: clearError ? null : (error ?? this.error),
      );
}

class WaRoomCubit extends Cubit<WaRoomState> {
  final WaChatApi _api;
  StreamSubscription? _upSub, _reSub;

  WaRoomCubit(this._api, WaConversation conversation)
      : super(WaRoomState(conversation: conversation)) {
    _upSub = WaSocketService.instance.updates.listen(_onUpdate);
    _reSub = WaSocketService.instance.resyncs.listen((_) => _syncLatest());
  }

  String get _id => state.conversation.id;

  // ---------- Open conversation ----------
  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final page = await _api.getMessages(_id, limit: 50);
      emit(state.copyWith(
          loading: false, messages: page.rows, hasMore: page.hasMore));
    } on WaApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return;
    }
    // Fresh conversation data (lead + window) — fine if this fails
    try {
      final c = await _api.getConversation(_id);
      emit(state.copyWith(conversation: c.withLeadFrom(state.conversation)));
    } catch (_) {}
    markRead();
  }

  Future<void> markRead() async {
    try {
      final c = await _api.markRead(_id);
      emit(state.copyWith(conversation: c.withLeadFrom(state.conversation)));
    } catch (_) {}
  }

  /// Load older: before = `at` of the oldest message we have
  Future<void> loadOlder() async {
    if (state.loadingOlder || !state.hasMore || state.messages.isEmpty) return;
    emit(state.copyWith(loadingOlder: true));
    try {
      final page = await _api.getMessages(_id,
          limit: 50, before: state.messages.first.at);
      var msgs = state.messages;
      for (final m in page.rows) {
        msgs = _upsert(msgs, m);
      }
      emit(state.copyWith(
          loadingOlder: false, messages: msgs, hasMore: page.hasMore));
    } on WaApiException catch (e) {
      emit(state.copyWith(loadingOlder: false, error: e.message));
    }
  }

  // When the socket reconnects — fetch the latest messages so nothing is missed
  Future<void> _syncLatest() async {
    try {
      final page = await _api.getMessages(_id, limit: 50);
      var msgs = state.messages;
      for (final m in page.rows) {
        msgs = _upsert(msgs, m);
      }
      emit(state.copyWith(messages: msgs));
      final c = await _api.getConversation(_id);
      emit(state.copyWith(conversation: c.withLeadFrom(state.conversation)));
    } catch (_) {}
  }

  // ---------- Send ----------
  /// Returns true if sent (so the UI can clear the field)
  Future<bool> sendText(String text) async {
    final t = text.trim();
    if (t.isEmpty || state.sending) return false;
    emit(state.copyWith(sending: true, clearError: true));
    try {
      final m = await _api.sendText(_id, t);
      emit(state.copyWith(sending: false, messages: _upsert(state.messages, m)));
      return true;
    } on WaApiException catch (e) {
      _fail(e);
      return false;
    }
  }

  /// Upload, then send as media (the type comes from the upload response)
  Future<bool> sendFile(String path, {String? caption}) async {
    if (state.sending) return false;
    emit(state.copyWith(sending: true, clearError: true));
    try {
      final up = await _api.upload(path);
      final m = await _api.sendMedia(_id,
          type: up.type,
          url: up.url,
          fileName: up.fileName,
          caption: caption);
      emit(state.copyWith(sending: false, messages: _upsert(state.messages, m)));
      return true;
    } on WaApiException catch (e) {
      _fail(e);
      return false;
    }
  }

  // ---------- Templates ----------
  Future<void> loadTemplates() async {
    if (state.templates.isNotEmpty) return;
    emit(state.copyWith(templatesLoading: true));
    try {
      final t = await _api.getTemplates(_id);
      emit(state.copyWith(templatesLoading: false, templates: t));
    } on WaApiException catch (e) {
      emit(state.copyWith(templatesLoading: false, error: e.message));
    }
  }

  /// Upload header media (if the template needs.media) — returns the url or null
  Future<String?> uploadOnly(String path) async {
    try {
      return (await _api.upload(path)).url;
    } on WaApiException catch (e) {
      emit(state.copyWith(error: e.message));
      return null;
    }
  }

  Future<bool> sendTemplate(
    WaTemplate t, {
    List<String> bodyVars = const [],
    List<String> headerVars = const [],
    String? mediaUrl,
  }) async {
    if (state.sending) return false;
    emit(state.copyWith(sending: true, clearError: true));
    try {
      final m = await _api.sendTemplate(_id,
          name: t.name,
          language: t.language,
          bodyVars: bodyVars,
          headerVars: headerVars,
          mediaUrl: mediaUrl);
      emit(state.copyWith(sending: false, messages: _upsert(state.messages, m)));
      return true;
    } on WaApiException catch (e) {
      _fail(e);
      return false;
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));

  void _fail(WaApiException e) {
    // Window closed -> disable typing and show the template button
    final conv = e.windowClosed
        ? state.conversation.copyWith(windowOpen: false)
        : state.conversation;
    emit(state.copyWith(sending: false, error: e.message, conversation: conv));
  }

  // ---------- Socket: new message / status change ----------
  void _onUpdate(WaSocketUpdate u) {
    final c = u.conversation;
    if (c == null || c.id != _id) return;
    final merged = c.withLeadFrom(state.conversation);
    var msgs = state.messages;
    final m = u.message;
    if (m != null) msgs = _upsert(msgs, m);
    emit(state.copyWith(conversation: merged, messages: msgs));
    // Inbound message while the chat is open -> mark read
    if (m != null && m.direction == 'in' && merged.unread > 0) markRead();
  }

  /// Upsert by id (the same message arrives from the POST and the socket) + sort by time
  List<WaMessage> _upsert(List<WaMessage> list, WaMessage m) {
    final out = [...list];
    final i = out.indexWhere((x) => x.id == m.id);
    if (i >= 0) {
      out[i] = m;
    } else {
      out.add(m);
    }
    out.sort((a, b) => a.at.compareTo(b.at));
    return out;
  }

  @override
  Future<void> close() {
    _upSub?.cancel();
    _reSub?.cancel();
    return super.close();
  }
}
