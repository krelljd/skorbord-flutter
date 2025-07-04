import 'package:flutter/material.dart';

/// A large, animated score display for Skorbord.
/// - Uses viewport-based font sizing (8vw)
/// - Animates on score change
class ScoreDisplay extends StatefulWidget {
  final int score;
  final bool highlight;
  final Duration animationDuration;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.highlight = false,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void didUpdateWidget(covariant ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width * 0.08;
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Score: ${widget.score}',
      liveRegion: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 + 0.15 * _controller.value;
          final color =
              widget.highlight ? colorScheme.secondary : colorScheme.primary;
          return Transform.scale(
            scale: scale,
            child: Text(
              widget.score.toString(),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: color,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: colorScheme.shadow.withAlpha((0.3 * 255).toInt()),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
