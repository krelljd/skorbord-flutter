import 'dart:async';
import '../models/game_type.dart';
import '../models/player.dart';
import '../models/game.dart';

// Mock API Service
class MockApiService {
  // Simulate network delay
  Future<T> _delayed<T>(T result) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return result;
  }

  // GET /api/game-types
  Future<List<GameType>> getGameTypes() async {
    return _delayed([
      GameType(id: 'uno', name: 'Uno', winCondition: 0, isWinCondition: false),
      GameType(id: 'cribbage', name: 'Cribbage', winCondition: 121),
    ]);
  }

  // GET /api/games/:id
  Future<Game> getGame(String id) async {
    return _delayed(
      Game(
        id: id,
        gameTypeId: 'uno',
        players: [
          Player(id: 'p1', name: 'Alice', score: 10),
          Player(id: 'p2', name: 'Bob', score: 15, isWinner: true),
        ],
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        finalizedAt: null,
      ),
    );
  }

  // POST /api/games
  Future<Game> createGame(String gameTypeId, List<Player> players) async {
    return _delayed(
      Game(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        gameTypeId: gameTypeId,
        players: players,
        status: 'active',
        createdAt: DateTime.now(),
        finalizedAt: null,
      ),
    );
  }

  // PATCH /api/games/:id
  Future<Game> updateGame(Game game) async {
    // In a real backend, this would persist changes
    return _delayed(game);
  }

  // GET /api/games/:id/players
  Future<List<Player>> getPlayers(String gameId) async {
    final game = await getGame(gameId);
    return _delayed(game.players);
  }

  // POST /api/games/:id/players
  Future<Player> addPlayer(String gameId, Player player) async {
    // In a real backend, this would add the player to the game
    return _delayed(player);
  }

  // PATCH /api/games/:id/players/:playerId
  Future<Player> updatePlayer(String gameId, Player player) async {
    // In a real backend, this would update the player in the game
    return _delayed(player);
  }
}
