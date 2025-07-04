class Player {
  final String id;
  final String name;
  final int score;
  final bool isWinner;

  Player({
    required this.id,
    required this.name,
    required this.score,
    this.isWinner = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        score: json['score'] as int,
        isWinner: json['isWinner'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
        'isWinner': isWinner,
      };
}
