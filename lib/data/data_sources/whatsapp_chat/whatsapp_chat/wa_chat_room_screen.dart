// ignore_for_file: deprecated_member_use

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'wa_api.dart';
import 'wa_models.dart';
import 'wa_room_cubit.dart';

Future<void> _open(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

class _WaColors {
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
}

class _ChatBackground extends StatelessWidget {
  final Widget child;
  const _ChatBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: dark ? _WaColors.bgDark : _WaColors.bgLight,
      child: CustomPaint(painter: _DoodlePainter(dark), child: child),
    );
  }
}

class _DoodlePainter extends CustomPainter {
  final bool dark;
  _DoodlePainter(this.dark);

  static const _icons = [
    Icons.chat_bubble_outline,
    Icons.favorite_border,
    Icons.star_border,
    Icons.home_outlined,
    Icons.phone_outlined,
    Icons.camera_alt_outlined,
    Icons.location_on_outlined,
    Icons.music_note_outlined,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const step = 64.0;
    final color = (dark ? Colors.white : Colors.black).withOpacity(
      dark ? .04 : .05,
    );
    var i = 0;
    for (double y = 12; y < size.height; y += step) {
      final offset = ((y ~/ step) % 2 == 0) ? 0.0 : step / 2;
      for (double x = 12 + offset; x < size.width; x += step) {
        final icon = _icons[i++ % _icons.length];
        final tp = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 26,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: color,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(x + 13, y + 13);
        canvas.rotate(((i % 5) - 2) * 0.12);
        tp.paint(canvas, const Offset(-13, -13));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter old) => old.dark != dark;
}

class WhatsAppChatRoomScreen extends StatelessWidget {
  final WaConversation conversation;
  final bool canTemplate;
  const WhatsAppChatRoomScreen({
    super.key,
    required this.conversation,
    this.canTemplate = false,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => WaRoomCubit(WaChatApi(), conversation)..load(),
    child: _RoomView(canTemplate: canTemplate),
  );
}

class _RoomView extends StatefulWidget {
  final bool canTemplate;
  const _RoomView({required this.canTemplate});
  @override
  State<_RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<_RoomView> {
  final _scroll = ScrollController();
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    // List is reversed: maxScrollExtent = oldest message -> load older
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<WaRoomCubit>().loadOlder();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _text.text;
    _text.clear();
    final ok = await context.read<WaRoomCubit>().sendText(t);
    if (!ok && mounted) _text.text = t; // restore the text if sending failed
  }

  // Attachment = upload, then send as media
  Future<void> _attach() async {
    final r = await FilePicker.pickFiles();
    final path = r.firstOrNull?.path; // null if the picker was cancelled
    if (path == null || !mounted) return;
    await context.read<WaRoomCubit>().sendFile(path);
  }

  void _openTemplates() {
    final cubit = context.read<WaRoomCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // بيبعد الـ sheet عن النوتش من فوق
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder:
          (_) =>
              BlocProvider.value(value: cubit, child: const _TemplateSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaRoomCubit, WaRoomState>(
      listenWhen: (p, c) => c.error != null && p.error != c.error,
      listener: (ctx, s) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(s.error!)));
        ctx.read<WaRoomCubit>().clearError();
      },
      builder: (ctx, s) {
        final conv = s.conversation;
        final lead = conv.lead;
        // Newest at the bottom: the list is reversed, so we reverse the order
        final items = s.messages.reversed.toList();
        final dark = Theme.of(ctx).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: dark ? _WaColors.bgDark : _WaColors.bgLight,
          appBar: AppBar(
            backgroundColor:
                dark ? _WaColors.headerDark : _WaColors.headerLight,
            foregroundColor: Colors.white,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv.title,
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
                Text(
                  '+${conv.phone}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          body: _ChatBackground(
            child: Column(
              children: [
                // Lead tags (sales · project · stage)
                if (lead != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    color: Colors.grey.withOpacity(.08),
                    child: Wrap(
                      spacing: 8.w,
                      children: [
                        if (lead.salesName.isNotEmpty)
                          Text(
                            lead.salesName,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.blue,
                            ),
                          ),
                        if (lead.project.isNotEmpty)
                          Text(
                            '· ${lead.project}',
                            style: TextStyle(fontSize: 11.sp),
                          ),
                        if (lead.stage.isNotEmpty)
                          Text(
                            '· ${lead.stage}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child:
                      s.loading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            controller: _scroll,
                            reverse: true,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            itemCount: items.length + (s.loadingOlder ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i >= items.length) {
                                return Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final m = items[i];
                              // Date separator: above the oldest message of each day
                              final older =
                                  i + 1 < items.length ? items[i + 1] : null;
                              final showDate =
                                  older == null || !waSameDay(older.at, m.at);
                              return Column(
                                children: [
                                  if (showDate) _DateChip(waDayLabel(m.at)),
                                  _Bubble(m: m),
                                ],
                              );
                            },
                          ),
                ),
                _composer(ctx, s),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _composer(BuildContext ctx, WaRoomState s) {
    final conv = s.conversation;
    // Window closed -> templates only
    if (!conv.isWindowOpen) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(10.r),
          color: Colors.orange.withOpacity(.12),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.orange),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.canTemplate
                      ? 'More than 24 hours have passed since the last customer message — WhatsApp only allows an approved template until the customer replies.'
                      : 'More than 24 hours have passed since the last customer message. You can reply once the customer writes again.',
                  style: TextStyle(fontSize: 11.sp),
                ),
              ),
              if (widget.canTemplate) ...[
                SizedBox(width: 8.w),
                ElevatedButton.icon(
                  onPressed: _openTemplates,
                  icon: const Icon(Icons.article_outlined, size: 18),
                  label: const Text('Send template'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    final end = conv.windowEndsAt;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (end != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                'You can reply normally until ${end.day}/${end.month} ${waHm(end)}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ),
          Container(
            color: Colors.transparent,
            padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(ctx).brightness == Brightness.dark
                              ? _WaColors.inDark
                              : Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.canTemplate)
                          IconButton(
                            onPressed: _openTemplates,
                            icon: const Icon(
                              Icons.article_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        Expanded(
                          child: TextField(
                            controller: _text,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 4096,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Type a message',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: widget.canTemplate ? 0 : 14.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: s.sending ? null : _attach,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: const Color(0xFF00A884),
                  child:
                      s.sending
                          ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : IconButton(
                            onPressed: _send,
                            icon: const Icon(Icons.send, color: Colors.white),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= Bubble =======================
class _Bubble extends StatelessWidget {
  final WaMessage m;
  const _Bubble({required this.m});

  static final _imgExt = RegExp(
    r'\.(jpe?g|png|webp|gif)(\?.*)?$',
    caseSensitive: false,
  );

  Widget _tick() {
    switch (m.status) {
      case 'sending':
        return Icon(Icons.access_time, size: 13.sp, color: Colors.grey);
      case 'sent':
      case 'accepted':
        return Icon(Icons.check, size: 13.sp, color: Colors.grey);
      case 'delivered':
        return Icon(Icons.done_all, size: 13.sp, color: Colors.grey);
      case 'read':
        return Icon(
          Icons.done_all,
          size: 14.sp,
          color: const Color(0xFF53BDEB),
        );
      case 'failed':
        return Icon(Icons.error_outline, size: 13.sp, color: Colors.red);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _media() {
    final media = m.media;
    if (media == null || media.url.isEmpty) return const SizedBox.shrink();
    final isImage =
        m.type == 'image' || m.type == 'sticker' || _imgExt.hasMatch(media.url);
    if (isImage) {
      return GestureDetector(
        onTap: () => _open(media.url),
        child: Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              media.url,
              width: 220.w,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 220.w,
                    height: 100.h,
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image),
                  ),
            ),
          ),
        ),
      );
    }
    final icon =
        m.type == 'video'
            ? Icons.play_circle_outline
            : m.type == 'audio'
            ? Icons.audiotrack
            : Icons.insert_drive_file_outlined;
    return InkWell(
      onTap: () => _open(media.url),
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.05),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                media.fileName.isNotEmpty ? media.fileName : m.type,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final out = m.isOut;
    final loc = m.location;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor =
        out
            ? (dark ? _WaColors.outDark : _WaColors.outLight)
            : (dark ? _WaColors.inDark : _WaColors.inLight);
    final textColor = dark ? Colors.white : Colors.black87;
    final metaColor = dark ? Colors.white54 : Colors.black45;

    return Align(
      alignment:
          out
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.80.sw),
        margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: CustomPaint(
          painter: _TailPainter(color: bubbleColor, out: out),
          child: Container(
            padding: EdgeInsets.fromLTRB(9.w, 6.h, 9.w, 4.h),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(out ? 10.r : 0),
                topRight: Radius.circular(out ? 0 : 10.r),
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (out && m.userName.isNotEmpty)
                  Text(
                    m.userName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          dark
                              ? Colors.tealAccent.shade100
                              : const Color(0xFF06A884),
                    ),
                  ),
                if (m.templateName.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 12.sp,
                        color: metaColor,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        m.templateName,
                        style: TextStyle(fontSize: 10.sp, color: metaColor),
                      ),
                    ],
                  ),
                _media(),
                if (loc != null)
                  InkWell(
                    onTap:
                        () => _open(
                          'https://maps.google.com/?q=${loc['latitude']},${loc['longitude']}',
                        ),
                    child: Text(
                      '📍 ${loc['name'] ?? loc['address'] ?? 'Location'}',
                      style: TextStyle(fontSize: 13.sp, color: Colors.blue),
                    ),
                  ),
                if (m.text.trim().isNotEmpty)
                  Text(
                    m.text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                if (m.status == 'failed' && m.error.isNotEmpty)
                  Text(
                    m.error,
                    style: TextStyle(fontSize: 10.sp, color: Colors.red),
                  ),
                SizedBox(height: 2.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        waHm(m.at),
                        style: TextStyle(fontSize: 10.sp, color: metaColor),
                      ),
                      if (out) ...[SizedBox(width: 3.w), _tick()],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  const _DateChip(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      // _DateChip: بدّل الـ Container
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF182229)
                : Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: Text(label, style: TextStyle(fontSize: 11.sp)),
    ),
  );
}

class _TailPainter extends CustomPainter {
  final Color color;
  final bool out;
  _TailPainter({required this.color, required this.out});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final path = Path();
    if (out) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width + 7, 0);
      path.lineTo(size.width, 9);
    } else {
      path.moveTo(0, 0);
      path.lineTo(-7, 0);
      path.lineTo(0, 9);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _TailPainter old) =>
      old.color != color || old.out != out;
}

// ======================= Send template =======================
// Pick template -> fill {{1}} {{2}} -> (media if needs.media) -> preview -> send
class _TemplateSheet extends StatefulWidget {
  const _TemplateSheet();
  @override
  State<_TemplateSheet> createState() => _TemplateSheetState();
}

class _TemplateSheetState extends State<_TemplateSheet> {
  WaTemplate? _tpl;
  List<TextEditingController> _header = [], _body = [];
  String? _mediaUrl, _mediaName;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    context.read<WaRoomCubit>().loadTemplates();
  }

  @override
  void dispose() {
    for (final c in [..._header, ..._body]) {
      c.dispose();
    }
    super.dispose();
  }

  void _select(WaTemplate t) {
    for (final c in [..._header, ..._body]) {
      c.dispose();
    }
    List<TextEditingController> make(int n) => List.generate(
      n,
      (_) => TextEditingController()..addListener(() => setState(() {})),
    );
    setState(() {
      _tpl = t;
      _header = make(t.headerVars);
      _body = make(t.bodyVars);
      _mediaUrl = null;
      _mediaName = null;
    });
  }

  Future<void> _pickMedia() async {
    final type =
        _tpl?.needsMedia == 'image'
            ? FileType.image
            : _tpl?.needsMedia == 'video'
            ? FileType.video
            : FileType.any;
    final r = await FilePicker.pickFiles(type: type);
    final file = r.firstOrNull; // null if the picker was cancelled
    final path = file?.path;
    if (path == null || !mounted) return;
    setState(() => _uploading = true);
    final url = await context.read<WaRoomCubit>().uploadOnly(path);
    if (!mounted) return;
    setState(() {
      _uploading = false;
      _mediaUrl = url;
      _mediaName = url == null ? null : file!.name;
    });
  }

  Future<void> _send() async {
    final t = _tpl!;
    final bodyVals = _body.map((c) => c.text.trim()).toList();
    final headerVals = _header.map((c) => c.text.trim()).toList();
    if ([...bodyVals, ...headerVals].any((v) => v.isEmpty) ||
        (t.needsMedia != null && _mediaUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill in all fields (and the media if required)'),
        ),
      );
      return;
    }
    final ok = await context.read<WaRoomCubit>().sendTemplate(
      t,
      bodyVars: bodyVals,
      headerVars: headerVals,
      mediaUrl: _mediaUrl,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaRoomCubit, WaRoomState>(
      builder: (ctx, s) {
        final t = _tpl;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.w,
              right: 16.w,
              top: 12.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Send an approved template',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  if (s.templatesLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (s.templates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No templates available for this number'),
                    )
                  else ...[
                    DropdownButtonFormField<WaTemplate>(
                      value: t,
                      isExpanded: true,
                      hint: const Text('Choose a template'),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items:
                          s.templates
                              .map(
                                (x) => DropdownMenuItem(
                                  value: x,
                                  child: Text('${x.name} (${x.language})'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => v == null ? null : _select(v),
                    ),
                    if (t != null) ...[
                      SizedBox(height: 10.h),
                      // Header media: image / video / document
                      if (t.needsMedia != null) ...[
                        OutlinedButton.icon(
                          onPressed: _uploading ? null : _pickMedia,
                          icon:
                              _uploading
                                  ? SizedBox(
                                    width: 14.r,
                                    height: 14.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.upload_file),
                          label: Text(
                            _mediaName ??
                                'Upload ${t.needsMedia} for the header',
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      for (var i = 0; i < _header.length; i++)
                        _field(_header[i], 'Header value {{${i + 1}}}'),
                      for (var i = 0; i < _body.length; i++)
                        _field(
                          _body[i],
                          'Value {{${i + 1}}}'
                          '${i < t.bodyExamples.length ? '  (e.g. ${t.bodyExamples[i]})' : ''}',
                        ),
                      // Text preview
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCF8C6),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          t.renderBody(
                            _body.map((c) => c.text.trim()).toList(),
                          ),
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                      if (t.quickReplies.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Wrap(
                            spacing: 6.w,
                            children:
                                t.quickReplies
                                    .map(
                                      (q) => Chip(
                                        label: Text(
                                          q,
                                          style: TextStyle(fontSize: 11.sp),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: s.sending ? null : _send,
                              icon:
                                  s.sending
                                      ? SizedBox(
                                        width: 14.r,
                                        height: 14.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.send),
                              label: const Text('Send'),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ],
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(TextEditingController c, String label) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
