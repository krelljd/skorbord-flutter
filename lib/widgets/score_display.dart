import 'dart:async';
import 'package:flutter/material.dart';

/// A large, animated score display for Skorbord with running tally support.
/// - Uses viewport-based font sizing (8vw)
/// - Animates on score change
/// - Shows running tally during scoring sessions
class ScoreDisplay extends StatefulWidget {
  final int score;
  final bool highlight;
  final Duration animationDuration;
  final String scoreDisplayKey;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.scoreDisplayKey,
    this.highlight = false,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> with TickerProviderStateMixin {
  int? _lastScore;
  static final Map<String, int> _tallyMap = {};
  static final Map<String, DateTime> _lastUpdateMap = {};

  late AnimationController _controller;
  late AnimationController _tallyController;

  int _runningTally = 0;
  bool _showTally = false;
  Timer? _tallyTimer;

  @override
  void initState() {
    super.initState();
    _lastScore = widget.score;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _tallyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // _previousScore removed; no longer needed
  }

  @override
  void didUpdateWidget(covariant ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastScore != null && widget.score != _lastScore) {
      final key = widget.scoreDisplayKey;
      final now = DateTime.now();
      final lastUpdate = _lastUpdateMap[key];
      final withinWindow =
          lastUpdate != null && now.difference(lastUpdate) < const Duration(seconds: 3);
      final prevTally = _tallyMap[key] ?? 0;
      final scoreDiff = widget.score - _lastScore!;
      // Always show tally for every score change
      if (withinWindow) {
        _runningTally = prevTally + scoreDiff;
      } else {
        _runningTally = scoreDiff;
      }
      _tallyMap[key] = _runningTally;
      _lastUpdateMap[key] = now;
      _showTally = true;
      _tallyController.forward(from: 0);
      _tallyTimer?.cancel();
      _tallyTimer = Timer(const Duration(seconds: 3), () {
        _tallyMap.remove(key);
        _lastUpdateMap.remove(key);
        _hideTally();
      });
      _controller.forward(from: 0);
    }
    _lastScore = widget.score;
  }

  void _hideTally() {
    if (mounted) {
      setState(() {
        _showTally = false;
      });
      _tallyController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _runningTally = 0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tallyController.dispose();
    _tallyTimer?.cancel();
    // Clean up static maps
    _tallyMap.remove(widget.scoreDisplayKey);
    _lastUpdateMap.remove(widget.scoreDisplayKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically scale font size for 2, 3, or 4+ digit scores
    final baseFontSize = MediaQuery.of(context).size.width * 0.08;
    final digitCount = widget.score.abs().toString().length;
    double fontSize = baseFontSize;
    if (digitCount == 3) {
      fontSize = baseFontSize * 0.78;
    } else if (digitCount >= 4) {
      fontSize = baseFontSize * 0.65;
    }
    final tallyFontSize = fontSize * 0.22; // Smaller superscript size, more subtle
    final tallyTextColor = Colors.white.withAlpha((0.95 * 255).round());

    return Semantics(
      label: _showTally && _runningTally != 0
          ? 'Score: ${widget.score}, Change: ${_runningTally > 0 ? '+' : ''}$_runningTally'
          : 'Score: ${widget.score}',
      liveRegion: true,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main score display without color flash
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 + 0.15 * _controller.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(fontSize * 0.2),
                  ),
                  child: Text(
                    widget.score.toString(),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black.withAlpha((0.3 * 255).toInt()),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Running tally superscript
          if (_showTally && _runningTally != 0)
            Positioned(
              // Move tally slightly further right from the score
              top: fontSize * -0.02,
              right: fontSize * -0.25,
              child: AnimatedBuilder(
                animation: _tallyController,
                builder: (context, child) {
                  final opacity = _tallyController.value;
                  final scale = 0.85 + 0.15 * _tallyController.value;
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Text(
                        '${_runningTally > 0 ? '+' : ''}$_runningTally',
                        style: TextStyle(
                          fontSize: tallyFontSize,
                          fontWeight: FontWeight.bold,
                          color: tallyTextColor,
                          height: 1.0,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black.withAlpha((0.25 * 255).round()),
                              offset: const Offset(0.5, 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
