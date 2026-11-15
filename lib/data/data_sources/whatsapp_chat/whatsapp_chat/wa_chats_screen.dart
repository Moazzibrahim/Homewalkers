// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'wa_api.dart';
import 'wa_chat_room_screen.dart';
import 'wa_inbox_cubit.dart';
import 'wa_models.dart';
class WaColors {
  // Light
  static const bgLight = Color(0xFFEFEAE2);
  static const outLight = Color(0xFFD9FDD3);
  static const inLight = Colors.white;
  static const headerLight = Color(0xFF008069);
  // Dark
  static const bgDark = Color(0xFF0B141A);
  static const outDark = Color(0xFF005C4B);
  static const inDark = Color(0xFF202C33);
  static const headerDark = Color(0xFF202C33);
  // Shared
  static const green = Color(0xFF00A884);
  static const unread = Color(0xFF25D366);
  static const tickBlue = Color(0xFF53BDEB);

  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;
}

/// One page for all roles:
/// - Sales: own conversations only (no filter, no assign)
/// - Team Leader / Manager: their team + sales filter + assign
/// - Admin: everything + "Unassigned" + assign
/// - Any other role (Marketer): the server returns 403, so we show a "no access" message
/// Usage: Navigator.push(context, MaterialPageRoute(builder: (_) => const WhatsAppChatsScreen()));
class WhatsAppChatsScreen extends StatelessWidget {
  const WhatsAppChatsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => WaInboxCubit(WaChatApi())..init(),
    child: const _ChatsView(),
  );
}

class _ChatsView extends StatefulWidget {
  const _ChatsView();
  @override
  State<_ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<_ChatsView> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String? _assignTo; // sales user selected for assignment

  @override
  void initState() {
    super.initState();
    // pagination: near the end of the list -> fetch the next page
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<WaInboxCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => context.read<WaInboxCubit>().setQuery(v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaInboxCubit, WaInboxState>(
      listenWhen:
          (p, c) =>
              c.error != null &&
              p.error != c.error &&
              c.status == WaInboxStatus.ready,
      listener: (ctx, s) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(s.error!)));
        ctx.read<WaInboxCubit>().clearError();
      },
      builder: (ctx, s) {
        final dark = WaColors.isDark(ctx);
        return Scaffold(
          backgroundColor: dark ? WaColors.bgDark : Colors.white,
          appBar: _appBar(ctx, s),
          body: _body(ctx, s),
          bottomNavigationBar: s.selecting ? _assignBar(ctx, s) : null,
        );
      },
    );
  }

  // ---------------- AppBar ----------------
  PreferredSizeWidget _appBar(BuildContext ctx, WaInboxState s) {
    final cubit = ctx.read<WaInboxCubit>();
    final dark = WaColors.isDark(ctx);
    if (s.selecting) {
      return AppBar(
        backgroundColor: dark ? WaColors.headerDark : WaColors.headerLight,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: cubit.clearSelection,
        ),
        title: Text('${s.selected.length} selected'),
        actions: [
          TextButton(
            onPressed: cubit.selectAll,
            child: const Text('Select all'),
          ),
        ],
      );
    }
    return AppBar(
      title: Text(
        'WhatsApp Chats'
        '${s.status == WaInboxStatus.ready ? ' (${s.total})' : ''}',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => cubit.load(silent: true),
        ),
      ],
    );
  }

  // ---------------- Body ----------------
  Widget _body(BuildContext ctx, WaInboxState s) {
    final cubit = ctx.read<WaInboxCubit>();

    if (s.status == WaInboxStatus.loading && s.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.status == WaInboxStatus.forbidden) {
      return _Message(
        icon: Icons.lock_outline,
        text: 'You do not have access to WhatsApp chats',
      );
    }
    if (s.status == WaInboxStatus.error) {
      return _Message(
        icon: Icons.error_outline,
        text: s.error ?? 'Something went wrong',
        action: ElevatedButton(
          onPressed: cubit.init,
          child: const Text('Try again'),
        ),
      );
    }

    final perms = s.permissions;
    return Column(
      children: [
        // --- Search ---
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name or number',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              isDense: true,
              filled: true,
              fillColor:
                  WaColors.isDark(ctx)
                      ? WaColors.inDark
                      : const Color(0xFFF0F2F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // --- All / Unread filter + sales filter (only for roles with canFilter) ---
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              _chip(
                ctx,
                'All',
                !s.unreadOnly,
                () => cubit.setUnreadOnly(false),
              ),
              SizedBox(width: 6.w),
              _chip(
                ctx,
                'Unread',
                s.unreadOnly,
                () => cubit.setUnreadOnly(true),
              ),
              if (perms?.canFilter == true) ...[
                SizedBox(width: 10.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: s.salesFilter,
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All sales'),
                      ),
                      // "Unassigned" for admin only (all = true)
                      if (perms?.all == true)
                        const DropdownMenuItem(
                          value: 'none',
                          child: Text('Unassigned'),
                        ),
                      ...s.sales.map(
                        (x) => DropdownMenuItem(
                          value: x.id,
                          child: Text(x.label, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (v) => cubit.setSalesFilter(v ?? ''),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 0),
          child: Wrap(
            spacing: 6.w,
            children: [
              for (final o in const [
                ['', 'Any'],
                ['interested', 'Interested'],
                ['not_interested', 'Not interested'],
              ])
                _chip(
                  ctx,
                  o[1],
                  s.interest == o[0],
                  () => cubit.setInterest(o[0]),
                ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        // --- List ---
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cubit.load(silent: true),
            child:
                s.conversations.isEmpty
                    ? ListView(
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Text(
                            'No conversations',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    )
                    : ListView.separated(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          s.conversations.length + (s.loadingMore ? 1 : 0),
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            indent: 72.w,
                            color:
                                WaColors.isDark(ctx)
                                    ? Colors.white10
                                    : Colors.black12,
                          ),
                      itemBuilder: (_, i) {
                        if (i >= s.conversations.length) {
                          return Padding(
                            padding: EdgeInsets.all(12.r),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final c = s.conversations[i];
                        return _ConversationTile(
                          c: c,
                          selecting: s.selecting,
                          selected: s.selected.contains(c.id),
                          // assignment only for roles with canAssign
                          onLongPress:
                              perms?.canAssign == true
                                  ? () => cubit.toggleSelect(c.id)
                                  : null,
                          onTap: () {
                            if (s.selecting) {
                              cubit.toggleSelect(c.id);
                            } else {
                              cubit.markReadLocal(c.id);
                              Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder:
                                      (_) => WhatsAppChatRoomScreen(
                                        conversation: c,
                                        canTemplate: perms?.canTemplate == true,
                                      ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext ctx,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final dark = WaColors.isDark(ctx);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: dark ? WaColors.outDark : const Color(0xFFD9FDD3),
      backgroundColor: dark ? WaColors.inDark : const Color(0xFFF0F2F5),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      labelStyle: TextStyle(
        fontSize: 13.sp,
        color:
            selected
                ? (dark ? Colors.white : const Color(0xFF008069))
                : (dark ? Colors.white70 : Colors.black54),
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ---------------- Assign bar ----------------
  Widget _assignBar(BuildContext ctx, WaInboxState s) {
    final cubit = ctx.read<WaInboxCubit>();
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: WaColors.isDark(ctx) ? WaColors.headerDark : Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _assignTo,
                isExpanded: true,
                hint: const Text('Choose sales'),
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                items:
                    s.sales
                        .map(
                          (x) => DropdownMenuItem(
                            value: x.id,
                            child: Text(x.label),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _assignTo = v),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WaColors.green,
                foregroundColor: Colors.white,
              ),
              // باقي الكود
              onPressed:
                  (_assignTo == null || s.assigning)
                      ? null
                      : () => _confirmAssign(ctx, s),
              child:
                  s.assigning
                      ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text('Assign (${s.selected.length})'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAssign(BuildContext ctx, WaInboxState s) async {
    final cubit = ctx.read<WaInboxCubit>();
    final name = s.sales.firstWhere((x) => x.id == _assignTo).label;
    final ok = await showDialog<bool>(
      context: ctx,
      builder:
          (d) => AlertDialog(
            title: const Text('Assign conversations'),
            content: Text(
              'Assign ${s.selected.length} conversation(s) (their leads) to $name?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(d, true),
                child: const Text('Assign'),
              ),
            ],
          ),
    );
    if (ok != true) return;
    final r = await cubit.assign(_assignTo!);
    if (r == null || !ctx.mounted) return;
    // assigned = moved · already = already theirs · noLead = no lead · notAllowed = out of scope
    final extra = [
      if ((r['already'] ?? 0) != 0) '${r['already']} already assigned',
      if ((r['noLead'] ?? 0) != 0) '${r['noLead']} without a lead',
      if ((r['notAllowed'] ?? 0) != 0) '${r['notAllowed']} not allowed',
    ].join(' · ');
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          'Assigned ${r['assigned']} conversation(s)${extra.isEmpty ? '' : ' ($extra)'}',
        ),
      ),
    );
    setState(() => _assignTo = null);
  }
}

// ======================= Conversation tile =======================
class _ConversationTile extends StatelessWidget {
  final WaConversation c;
  final bool selecting, selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _ConversationTile({
    required this.c,
    required this.selecting,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  String _preview() {
    final m = c.lastMessage;
    if (m == null) return '';
    final t = m.text.trim();
    if (t.isNotEmpty) return t;
    switch (m.type) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'audio':
        return '🎤 Audio';
      case 'file':
        return '📄 File';
      case 'location':
        return '📍 Location';
      default:
        return '';
    }
  }

  String _time() {
    final d = c.lastMessage?.at;
    if (d == null) return '';
    return waSameDay(d, DateTime.now()) ? waHm(d) : '${d.day}/${d.month}';
  }

  @override
  Widget build(BuildContext context) {
    final dark = WaColors.isDark(context);
    final lead = c.lead;
    final m = c.lastMessage;
    final titleColor = dark ? Colors.white : Colors.black87;
    final subColor = dark ? Colors.white60 : Colors.black54;

    return Material(
      color: selected ? WaColors.green.withOpacity(.12) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selecting)
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 8.w, top: 10.h),
                  child: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? WaColors.green : Colors.grey,
                  ),
                ),
              CircleAvatar(
                radius: 24.r,
                backgroundColor:
                    dark ? const Color(0xFF2A3942) : const Color(0xFFDFE5E7),
                child: Text(
                  c.title.replaceAll('+', '').trim().isEmpty
                      ? '?'
                      : c.title.replaceAll('+', '').trim()[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: dark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: titleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _time(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: c.unread > 0 ? WaColors.unread : subColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        if (m != null && m.direction == 'out')
                          Padding(
                            padding: EdgeInsetsDirectional.only(end: 3.w),
                            child: Icon(
                              m.status == 'sent' || m.status == 'accepted'
                                  ? Icons.check
                                  : Icons.done_all,
                              size: 16.sp,
                              color:
                                  m.status == 'read'
                                      ? WaColors.tickBlue
                                      : Colors.grey,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            _preview(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14.sp, color: subColor),
                          ),
                        ),
                        if (c.unread > 0)
                          Container(
                            margin: EdgeInsetsDirectional.only(start: 6.w),
                            constraints: BoxConstraints(
                              minWidth: 20.r,
                              minHeight: 20.r,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            decoration: const BoxDecoration(
                              color: WaColors.unread,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${c.unread}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (lead != null) ...[
                      SizedBox(height: 5.h),
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          if (lead.salesName.isNotEmpty)
                            _Tag(lead.salesName, Colors.blue),
                          if (lead.project.isNotEmpty)
                            _Tag(lead.project, Colors.grey),
                          if (lead.stage.isNotEmpty)
                            _Tag(lead.stage, WaColors.green),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
    decoration: BoxDecoration(
      color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10.sp, color: color.withOpacity(.95)),
    ),
  );
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;
  const _Message({required this.icon, required this.text, this.action});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.sp, color: Colors.grey),
          SizedBox(height: 10.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp),
          ),
          if (action != null) ...[SizedBox(height: 12.h), action!],
        ],
      ),
    ),
  );
}
