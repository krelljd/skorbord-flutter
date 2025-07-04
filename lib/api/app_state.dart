import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../models/player.dart';
import 'socket_service.dart';
import 'api_service.dart';
import 'offline_manager.dart';

/// AppState: Central state management for game data, hybrid offline/online.
class AppState extends ChangeNotifier {
  Game? _game;
  List<Player> _players = [];
  final SocketService socketService;
  final ApiService apiService;
  final OfflineManager offlineManager;

  AppState({
    required this.socketService,
    required this.apiService,
    required this.offlineManager,
  });

  Game? get game => _game;
  List<Player> get players => _players;

  bool get isOnline => socketService.status == SocketConnectionStatus.connected;

  Future<void> setGame(Game game) async {
    _game = game;
    _players = game.players;
    notifyListeners();
    if (!isOnline) {
      // Save to local storage for offline mode
      await offlineManager.saveGameState(
          'current_game', game.toJson().toString());
    }
  }

  Future<void> updatePlayer(Player player) async {
    final idx = _players.indexWhere((p) => p.id == player.id);
    if (idx != -1) {
      _players[idx] = player;
      notifyListeners();
      if (isOnline) {
        // TODO: emit update to backend via socket or REST
      } else {
        // Save updated game to local storage
        if (_game != null) {
          await offlineManager.saveGameState(
              'current_game', _game!.toJson().toString());
        }
      }
    }
  }

  Future<void> loadOfflineGame() async {
    final jsonStr = await offlineManager.loadGameState('current_game');
    if (jsonStr != null) {
      // Parse JSON string to Game
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        // ignore: unnecessary_cast
        (await Future.value(json.decode(jsonStr))) as Map<String, dynamic>,
      );
      _game = Game.fromJson(data);
      _players = _game!.players;
      notifyListeners();
    }
  }

  void reset() {
    _game = null;
    _players = [];
    notifyListeners();
  }
}
