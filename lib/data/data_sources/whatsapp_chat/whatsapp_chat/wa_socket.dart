import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'wa_config.dart';
import 'wa_models.dart';

class WaSocketUpdate {
  final WaConversation? conversation;

  /// New message or status update (same id). null for read/assign
  final WaMessage? message;
  const WaSocketUpdate(this.conversation, this.message);
}

/// Socket.io singleton — emits wa:join with the token; the server picks rooms by role.
/// Note: the PDF sometimes says update:wa / revoke:wa, but the actual events are wa:update / wa:revoke.
class WaSocketService {
  WaSocketService._();
  static final WaSocketService instance = WaSocketService._();

  io.Socket? _socket;
  bool _joinedOnce = false;

  final _updates = StreamController<WaSocketUpdate>.broadcast();
  final _revokes = StreamController<String>.broadcast();
  final _resyncs = StreamController<void>.broadcast();

  Stream<WaSocketUpdate> get updates => _updates.stream;

  /// Conversation was reassigned -> remove it
  Stream<String> get revokes => _revokes.stream;

  /// Fires after every reconnect (e.g. back from background) -> refresh the list and the open chat
  Stream<void> get resyncs => _resyncs.stream;

  Future<void> connect() async {
    if (_socket != null) {
      if (_socket!.disconnected) _socket!.connect();
      return;
    }
    final token = await WaConfig.token();
    if (token == null || token.isEmpty) return;

    final s = io.io(
      WaConfig.baseUrl(),
      io.OptionBuilder().setTransports(['websocket']).enableReconnection().build(),
    );

    s.onConnect((_) async {
      // re-read the token in case it was refreshed
      final t = await WaConfig.token() ?? token;
      s.emitWithAck('wa:join', t, ack: (_) {});
      if (_joinedOnce) _resyncs.add(null);
      _joinedOnce = true;
    });

    s.on('wa:update', (data) {
      if (data is! Map) return;
      final c = data['conversation'];
      final m = data['message'];
      _updates.add(WaSocketUpdate(
        c is Map ? WaConversation.fromJson(Map<String, dynamic>.from(c)) : null,
        m is Map ? WaMessage.fromJson(Map<String, dynamic>.from(m)) : null,
      ));
    });

    s.on('wa:revoke', (data) {
      if (data is Map && data['conversationId'] != null) {
        _revokes.add(data['conversationId'].toString());
      }
    });

    _socket = s;
  }

  /// Call on logout or when the domain changes
  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _joinedOnce = false;
  }
}
