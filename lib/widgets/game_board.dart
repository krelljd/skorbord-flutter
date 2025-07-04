import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../api/socket_service.dart';
import '../api/app_state.dart';
import 'player_card.dart';
import '../models/game.dart';
import '../models/player.dart';

/// GameBoard: Responsive for 2–6 players, scrollable for 5+, connection status
class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final socketService = Provider.of<SocketService>(context);
    final game = appState.game;
    final players = appState.players;
    final isWinner = players.any((p) => p.isWinner == true);
    final playerCount = players.length;
    final isOnline = socketService.connected;

    if (game == null) {
      // Show create new game form
      return _CreateGameForm();
    }

    return Semantics(
      container: true,
      label: 'Game board',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Game: ${game.gameTypeId}',
                    style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      color: isOnline ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: playerCount <= 4
                ? GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: playerCount,
                    itemBuilder: (context, idx) {
                      final player = players[idx];
                      return PlayerCard(
                        player: player,
                        playerIndex: idx,
                        onIncrement: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score + 1,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                        onDecrement: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score - 1,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                        onIncrement10: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score + 10,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                        onDecrement10: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score - 10,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                      );
                    },
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    itemCount: playerCount,
                    separatorBuilder: (context, idx) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final player = players[idx];
                      return PlayerCard(
                        player: player,
                        playerIndex: idx,
                        onIncrement: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score + 1,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                        onDecrement: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score - 1,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                        onIncrement10: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score + 10,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                        onDecrement10: () {
                          appState.updatePlayer(
                            Player(
                              id: player.id,
                              name: player.name,
                              score: player.score - 10,
                              isWinner: player.isWinner,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (isWinner)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: LottieBuilder.asset(
                      'assets/animations/confetti.json',
                      repeat: false,
                      fit: BoxFit.contain,
                      addRepaintBoundary: true,
                    ),
                  ),
                  Text(
                    '🎉 Winner! 🎉',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
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

class _CreateGameForm extends StatefulWidget {
  @override
  State<_CreateGameForm> createState() => _CreateGameFormState();
}

class _CreateGameFormState extends State<_CreateGameForm> {
  final _formKey = GlobalKey<FormState>();
  final _gameTypeController = TextEditingController();
  final List<TextEditingController> _playerControllers = [
    TextEditingController()
  ];

  @override
  void dispose() {
    _gameTypeController.dispose();
    for (final c in _playerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPlayerField() {
    setState(() {
      _playerControllers.add(TextEditingController());
    });
  }

  void _removePlayerField(int idx) {
    setState(() {
      if (_playerControllers.length > 1) {
        _playerControllers.removeAt(idx);
      }
    });
  }

  void _createGame(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final gameType = _gameTypeController.text.trim();
    final players = _playerControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 players required.')),
      );
      return;
    }
    final now = DateTime.now();
    final game = Game(
      id: now.microsecondsSinceEpoch.toString(),
      gameTypeId: gameType.isEmpty ? 'default' : gameType,
      players: [
        for (final name in players)
          Player(
              id: name + now.microsecondsSinceEpoch.toString(),
              name: name,
              score: 0),
      ],
      status: 'active',
      createdAt: now,
      finalizedAt: null,
    );
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.setGame(game);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Create New Game',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gameTypeController,
                    decoration: const InputDecoration(labelText: 'Game Type'),
                  ),
                  const SizedBox(height: 16),
                  ..._playerControllers.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final controller = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                                labelText: 'Player ${idx + 1} Name'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter a name'
                                : null,
                          ),
                        ),
                        if (_playerControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removePlayerField(idx),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Player'),
                        onPressed: _addPlayerField,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _createGame(context),
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
