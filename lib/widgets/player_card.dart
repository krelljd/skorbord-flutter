import 'package:flutter/material.dart';
import '../models/player.dart';
import 'touch_button.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int playerIndex;
  final VoidCallback? onLongPress;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement10;
  final VoidCallback? onDecrement10;

  const PlayerCard({
    super.key,
    required this.player,
    required this.playerIndex,
    this.onLongPress,
    this.onIncrement,
    this.onDecrement,
    this.onIncrement10,
    this.onDecrement10,
  });

  Color _playerColor(ThemeData theme, String playerId) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
    ];
    // Use a hash of the playerId to select a color index
    int hash = playerId.codeUnits.fold(0, (prev, c) => prev + c);
    return colors[hash % colors.length];
  }

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isPulsing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 1.0,
      upperBound: 1.08,
    );
    _scaleAnim = _animController.drive(Tween(begin: 1.0, end: 1.08));
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _pulse() {
    if (!_isPulsing) {
      setState(() => _isPulsing = true);
      _animController.forward(from: 0.0).then((_) {
        setState(() => _isPulsing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final highlight = player.isWinner;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playerColor = widget._playerColor(theme, player.id);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Semantics(
        button: true,
        label:
            'Player: ${player.name}, score: ${player.score}${highlight ? ', winner' : ''}',
        selected: highlight,
        focusable: true,
        child: FocusableActionDetector(
          autofocus: false,
          enabled: true,
          onShowFocusHighlight: (focused) => {},
          child: Material(
            color: highlight
                ? colorScheme.secondary.withAlpha((0.15 * 255).round())
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            elevation: highlight ? 6 : 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onLongPress: widget.onLongPress,
              focusColor: colorScheme.primary.withAlpha((0.2 * 255).round()),
              child: Container(
                constraints: const BoxConstraints(minHeight: 140),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardHeight = constraints.maxHeight;
                    final buttonSize = cardHeight;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Icon, Name, Score
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    highlight
                                        ? Icons.emoji_events
                                        : Icons.person,
                                    color: playerColor,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      player.name,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: highlight
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: playerColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                player.score.toString(),
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: playerColor,
                                  fontSize: 52, // Even larger for prominence
                                ),
                                semanticsLabel: 'Score: ${player.score}',
                              ),
                            ],
                          ),
                        ),
                        // Right: Two perfectly square buttons, height = card height, with margin
                        const SizedBox(width: 16),
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            margin: const EdgeInsets.only(
                                right: 8), // margin from card edge
                            height: buttonSize,
                            width: buttonSize * 2 + 8, // account for spacing
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  width: buttonSize - 8,
                                  height: buttonSize - 8,
                                  child: TouchButton(
                                    minSize: buttonSize - 8,
                                    color: playerColor,
                                    semanticsLabel:
                                        'Decrease score. Long-press to decrease by 10.',
                                    onTap: widget.onDecrement,
                                    onLongPress: () {
                                      if (widget.onDecrement10 != null) {
                                        widget.onDecrement10!();
                                      }
                                      _pulse();
                                    },
                                    child: const Icon(Icons.remove, size: 32),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  width: buttonSize - 8,
                                  height: buttonSize - 8,
                                  child: TouchButton(
                                    minSize: buttonSize - 8,
                                    color: playerColor,
                                    semanticsLabel:
                                        'Increase score. Long-press to increase by 10.',
                                    onTap: widget.onIncrement,
                                    onLongPress: () {
                                      if (widget.onIncrement10 != null) {
                                        widget.onIncrement10!();
                                      }
                                      _pulse();
                                    },
                                    child: const Icon(Icons.add, size: 32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
