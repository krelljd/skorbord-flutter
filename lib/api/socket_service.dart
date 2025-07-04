import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Connection status for hybrid offline/online mode
enum SocketConnectionStatus { connecting, connected, disconnected, failed }

/// SocketService: WebSocket client for real-time updates.
class SocketService extends ChangeNotifier {
  late io.Socket _socket;
  final String url;
  SocketConnectionStatus _status = SocketConnectionStatus.disconnected;

  SocketService(this.url);

  void connect() {
    _status = SocketConnectionStatus.connecting;
    notifyListeners();
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .build(),
    );
    _socket.on('connect', (_) {
      _status = SocketConnectionStatus.connected;
      notifyListeners();
    });
    _socket.on('disconnect', (_) {
      _status = SocketConnectionStatus.disconnected;
      notifyListeners();
    });
    _socket.on('connect_error', (_) {
      _status = SocketConnectionStatus.failed;
      notifyListeners();
    });
    _socket.on('error', (_) {
      _status = SocketConnectionStatus.failed;
      notifyListeners();
    });
    _socket.connect();
  }

  void on(String event, Function(dynamic) handler) {
    _socket.on(event, handler);
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void disconnect() {
    _socket.disconnect();
    _status = SocketConnectionStatus.disconnected;
    notifyListeners();
  }

  SocketConnectionStatus get status => _status;
  bool get connected => _status == SocketConnectionStatus.connected;
}
