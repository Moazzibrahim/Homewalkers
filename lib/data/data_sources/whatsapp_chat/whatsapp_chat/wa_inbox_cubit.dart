import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'wa_api.dart';
import 'wa_models.dart';
import 'wa_socket.dart';

enum WaInboxStatus { loading, ready, forbidden, error }

class WaInboxState {
  final WaInboxStatus status;
  final WaPermissions? permissions;
  final List<WaConversation> conversations;
  final List<WaSalesOption> sales;
  final int page, pages, total;
  final bool loadingMore, assigning, unreadOnly;
  final String query;
  final String interest;

  /// '' = all | 'none' = unassigned (admin) | sales id
  final String salesFilter;
  final Set<String> selected;
  final String? error;

  const WaInboxState({
    this.status = WaInboxStatus.loading,
    this.permissions,
    this.conversations = const [],
    this.sales = const [],
    this.page = 1,
    this.pages = 1,
    this.total = 0,
    this.interest = '',
    this.loadingMore = false,
    this.assigning = false,
    this.unreadOnly = false,
    this.query = '',
    this.salesFilter = '',
    this.selected = const {},
    this.error,
  });

  bool get selecting => selected.isNotEmpty;

  WaInboxState copyWith({
    WaInboxStatus? status,
    WaPermissions? permissions,
    List<WaConversation>? conversations,
    List<WaSalesOption>? sales,
    int? page,
    int? pages,
    int? total,
    bool? loadingMore,
    bool? assigning,
    bool? unreadOnly,
    String? query,
    String? salesFilter,
    Set<String>? selected,
    String? error,
    bool clearError = false,
    String? interest,
  }) => WaInboxState(
    status: status ?? this.status,
    permissions: permissions ?? this.permissions,
    conversations: conversations ?? this.conversations,
    sales: sales ?? this.sales,
    page: page ?? this.page,
    pages: pages ?? this.pages,
    total: total ?? this.total,
    loadingMore: loadingMore ?? this.loadingMore,
    assigning: assigning ?? this.assigning,
    unreadOnly: unreadOnly ?? this.unreadOnly,
    query: query ?? this.query,
    salesFilter: salesFilter ?? this.salesFilter,
    selected: selected ?? this.selected,
    error: clearError ? null : (error ?? this.error),
    interest: interest ?? this.interest,
  );
}

/// One cubit for all roles — the server decides the scope, /inbox/me decides the sales filter and assign button
class WaInboxCubit extends Cubit<WaInboxState> {
  final WaChatApi _api;
  StreamSubscription? _upSub, _revSub, _reSub;
  int _req = 0; // ignore stale responses when filters change quickly

  WaInboxCubit(this._api) : super(const WaInboxState()) {
    final sock = WaSocketService.instance;
    _upSub = sock.updates.listen(_onUpdate);
    _revSub = sock.revokes.listen(_onRevoke);
    _reSub = sock.resyncs.listen((_) => load(silent: true));
  }

  // ---------- Initial load: permissions -> sales -> conversations -> socket ----------
  Future<void> init() async {
    emit(state.copyWith(status: WaInboxStatus.loading, clearError: true));
    try {
      final me =
          await _api
              .getMe(); // 403 if the role has no chat access (e.g. Marketer)
      var sales = <WaSalesOption>[];
      if (me.canFilter || me.canAssign) sales = await _api.getSales();
      emit(state.copyWith(permissions: me, sales: sales));
      await WaSocketService.instance.connect();
      await load();
    } on WaApiException catch (e) {
      emit(
        state.copyWith(
          status: e.forbidden ? WaInboxStatus.forbidden : WaInboxStatus.error,
          error: e.message,
        ),
      );
    }
  }

  bool _matchInterest(WaConversation c) {
    if (state.interest.isEmpty) return true;
    final st = (c.lead?.stage ?? '').toLowerCase().replaceAll(
      RegExp(r'[\s_\-]'),
      '',
    );
    return state.interest == 'interested'
        ? st == 'interested'
        : st == 'notinterested';
  }

  // لو الفلتر شغال والنتيجة قليلة، كمّل تحميل صفحات
  Future<void> _fillIfNeeded() async {
    while (state.interest.isNotEmpty &&
        state.status == WaInboxStatus.ready &&
        state.conversations.length < 20 &&
        state.page < state.pages) {
      final before = state.page;
      await loadMore();
      if (state.page == before) break;
    }
  }

  void setInterest(String v) {
    if (v == state.interest) return;
    emit(state.copyWith(interest: v));
    load(silent: true);
  }

  // ---------- Load first page ----------
  Future<void> load({bool silent = false}) async {
    final id = ++_req;
    if (!silent) {
      emit(state.copyWith(status: WaInboxStatus.loading, clearError: true));
    }
    try {
      final p = await _api.getConversations(
        page: 1,
        q: state.query,
        unreadOnly: state.unreadOnly,
        salesId: state.salesFilter,
      );
      if (id != _req) return;
      emit(
        state.copyWith(
          status: WaInboxStatus.ready,
          conversations: p.rows.where(_matchInterest).toList(),
          page: p.page,
          pages: p.pages,
          total: p.total,
          selected: <String>{},
          loadingMore: false,
          clearError: true,
        ),
      );
      await _fillIfNeeded();
    } on WaApiException catch (e) {
      if (id != _req) return;
      if (silent && state.conversations.isNotEmpty) {
        emit(state.copyWith(error: e.message));
      } else {
        emit(
          state.copyWith(
            status: e.forbidden ? WaInboxStatus.forbidden : WaInboxStatus.error,
            error: e.message,
          ),
        );
      }
    }
  }

  // ---------- pagination (filters are sent with every page) ----------
  Future<void> loadMore() async {
    if (state.loadingMore ||
        state.status != WaInboxStatus.ready ||
        state.page >= state.pages) {
      return;
    }
    final id = _req;
    emit(state.copyWith(loadingMore: true));
    try {
      final p = await _api.getConversations(
        page: state.page + 1,
        q: state.query,
        unreadOnly: state.unreadOnly,
        salesId: state.salesFilter,
      );
      if (id != _req) return;
      final known = state.conversations.map((c) => c.id).toSet();
      emit(
        state.copyWith(
          conversations: [
            ...state.conversations,
            ...p.rows.where((c) => !known.contains(c.id) && _matchInterest(c)),
          ],
          page: p.page,
          pages: p.pages,
          total: p.total,
          loadingMore: false,
        ),
      );
    } on WaApiException catch (e) {
      emit(state.copyWith(loadingMore: false, error: e.message));
    }
  }

  // ---------- Filters ----------
  void setQuery(String q) {
    if (q == state.query) return;
    emit(state.copyWith(query: q));
    load(silent: true);
  }

  void setUnreadOnly(bool v) {
    emit(state.copyWith(unreadOnly: v));
    load(silent: true);
  }

  void setSalesFilter(String v) {
    emit(state.copyWith(salesFilter: v));
    load(silent: true);
  }

  void clearError() => emit(state.copyWith(clearError: true));

  // ---------- Multi-select (for assign) ----------
  void toggleSelect(String id) {
    final s = {...state.selected};
    s.contains(id) ? s.remove(id) : s.add(id);
    emit(state.copyWith(selected: s));
  }

  void selectAll() => emit(
    state.copyWith(selected: state.conversations.map((c) => c.id).toSet()),
  );

  void clearSelection() => emit(state.copyWith(selected: <String>{}));

  /// Returns { assigned, already, noLead, notAllowed, salesName } or null on failure
  Future<Map<String, dynamic>?> assign(String salesId) async {
    if (state.selected.isEmpty || state.assigning) return null;
    emit(state.copyWith(assigning: true));
    try {
      final r = await _api.assign(state.selected.toList(), salesId);
      emit(state.copyWith(assigning: false, selected: <String>{}));
      await load(silent: true);
      return r;
    } on WaApiException catch (e) {
      emit(state.copyWith(assigning: false, error: e.message));
      return null;
    }
  }

  /// Reset the unread counter locally when a conversation opens (the read call is sent from the chat room)
  void markReadLocal(String id) {
    emit(
      state.copyWith(
        conversations:
            state.conversations
                .map((c) => c.id == id ? c.copyWith(unread: 0) : c)
                .toList(),
      ),
    );
  }

  // ---------- Socket ----------
  void _onUpdate(WaSocketUpdate u) {
    final conv = u.conversation;
    if (conv == null || state.status != WaInboxStatus.ready) return;
    final list = [...state.conversations];
    final i = list.indexWhere((c) => c.id == conv.id);
    if (i < 0) {
      // New conversation not in the list (lead may not be linked yet) -> refetch the first page
      load(silent: true);
      return;
    }
    list[i] = conv.withLeadFrom(list[i]);
    list.sort((a, b) => b.sortTime.compareTo(a.sortTime)); // newest first
    emit(state.copyWith(conversations: list));
  }

  void _onRevoke(String conversationId) {
    final list =
        state.conversations.where((c) => c.id != conversationId).toList();
    final sel = {...state.selected}..remove(conversationId);
    emit(
      state.copyWith(
        conversations: list,
        selected: sel,
        total: state.total > 0 ? state.total - 1 : 0,
      ),
    );
  }

  @override
  Future<void> close() {
    _upSub?.cancel();
    _revSub?.cancel();
    _reSub?.cancel();
    return super.close();
  }
}
