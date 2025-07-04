import 'player.dart';

class Game {
  final String id;
  final String gameTypeId;
  final List<Player> players;
  final String status; // e.g. "active", "finished"
  final DateTime createdAt;
  final DateTime? finalizedAt;

  Game({
    required this.id,
    required this.gameTypeId,
    required this.players,
    required this.status,
    required this.createdAt,
    this.finalizedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as String,
        gameTypeId: json['gameTypeId'] as String,
        players: (json['players'] as List)
            .map((p) => Player.fromJson(p as Map<String, dynamic>))
            .toList(),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        finalizedAt: json['finalizedAt'] != null
            ? DateTime.parse(json['finalizedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameTypeId': gameTypeId,
        'players': players.map((p) => p.toJson()).toList(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'finalizedAt': finalizedAt?.toIso8601String(),
      };
}
