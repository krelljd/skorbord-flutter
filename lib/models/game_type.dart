class GameType {
  final String id;
  final String name;
  final int? winCondition;
  final int? lossCondition;
  final bool isWinCondition;
  final bool isFavorited;

  GameType({
    required this.id,
    required this.name,
    this.winCondition,
    this.lossCondition,
    this.isWinCondition = true,
    this.isFavorited = false,
  });

  factory GameType.fromJson(Map<String, dynamic> json) => GameType(
        id: json['id'] as String,
        name: json['name'] as String,
        winCondition: json['winCondition'] as int?,
        lossCondition: json['lossCondition'] as int?,
        isWinCondition: json['isWinCondition'] as bool? ?? true,
        isFavorited: json['isFavorited'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'winCondition': winCondition,
        'lossCondition': lossCondition,
        'isWinCondition': isWinCondition,
        'isFavorited': isFavorited,
      };
}
