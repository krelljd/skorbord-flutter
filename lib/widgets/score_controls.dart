import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'touch_button.dart';

/// ScoreControls for Skorbord: +1, -1, +10, -10, undo, gesture support.
/// - Uses TouchButton for all actions
/// - Thumb zone layout (bottom 50% of screen)
/// - Immediate/optimistic feedback
/// - Long-press for rapid changes
class ScoreControls extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement10;
  final VoidCallback onDecrement10;
  final VoidCallback? onUndo;
  final bool canUndo;

  const ScoreControls({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.onIncrement10,
    required this.onDecrement10,
    this.onUndo,
    this.canUndo = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = math.max(MediaQuery.of(context).size.width * 0.16, 48.0);
    final colorScheme = Theme.of(context).colorScheme;
    // Optimistic UI: parent should update score immediately on tap
    return Semantics(
      container: true,
      label: 'Score controls',
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TouchButton(
              onTap: onDecrement10,
              onLongPress: onDecrement10,
              semanticsLabel: 'Decrease by 10',
              minSize: buttonSize,
              child: Text('-10',
                  style: TextStyle(fontSize: 20, color: colorScheme.onPrimary)),
            ),
            TouchButton(
              onTap: onDecrement,
              onLongPress: onDecrement10,
              onDoubleTap: () =>
                  onDecrement(), // Quick -5 (if desired, can be customized)
              semanticsLabel: 'Decrease by 1',
              minSize: buttonSize,
              child: Icon(Icons.remove, size: 28, color: colorScheme.onPrimary),
            ),
            TouchButton(
              onTap: onIncrement,
              onLongPress: onIncrement10,
              onDoubleTap: () =>
                  onIncrement(), // Quick +5 (if desired, can be customized)
              semanticsLabel: 'Increase by 1',
              minSize: buttonSize,
              child: Icon(Icons.add, size: 28, color: colorScheme.onPrimary),
            ),
            TouchButton(
              onTap: onIncrement10,
              onLongPress: onIncrement10,
              semanticsLabel: 'Increase by 10',
              minSize: buttonSize,
              child: Text('+10',
                  style: TextStyle(fontSize: 20, color: colorScheme.onPrimary)),
            ),
            if (onUndo != null)
              TouchButton(
                onTap: canUndo ? onUndo : null,
                semanticsLabel: 'Undo',
                minSize: buttonSize,
                enabled: canUndo,
                child: Icon(Icons.undo, size: 24, color: colorScheme.onPrimary),
              ),
          ],
        ),
      ),
    );
  }
}
