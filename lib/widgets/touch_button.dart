import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable, accessible, touch-optimized button for Skorbord.
/// - Minimum 44x44px touch target (48px recommended for comfort)
/// - Visual feedback within 100ms
/// - Haptic feedback (where supported)
/// - Focus and loading states
/// - ARIA roles/labels via semantics
/// - Long-press support (300ms)
class TouchButton extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final bool loading;
  final String? semanticsLabel;
  final double minSize;
  final Color? color;
  final bool enabled;
  final Widget child;

  const TouchButton({
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.loading = false,
    this.semanticsLabel,
    this.minSize = 48.0, // 44px minimum, 48px recommended
    this.color,
    this.enabled = true,
    required this.child,
  });

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (onTap != null) onTap!();
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (onLongPress != null) onLongPress!();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    const borderRadius =
        BorderRadius.all(Radius.circular(12)); // Rounded rectangle
    return Semantics(
      button: true,
      label: semanticsLabel,
      enabled: enabled,
      focusable: true,
      child: FocusableActionDetector(
        enabled: enabled,
        onShowFocusHighlight: (focused) {},
        onShowHoverHighlight: (hovered) {},
        focusNode: FocusNode(),
        shortcuts: const <LogicalKeySet, Intent>{},
        actions: const <Type, Action<Intent>>{},
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          child: Material(
            color: enabled
                ? effectiveColor
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: borderRadius,
            child: GestureDetector(
              onDoubleTap: enabled && !loading ? onDoubleTap : null,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: enabled && !loading ? _handleTap : null,
                onLongPress: enabled && !loading ? _handleLongPress : null,
                focusColor: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha((0.2 * 255).round()),
                splashColor: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withAlpha((0.12 * 255).round()),
                highlightColor: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withAlpha((0.08 * 255).round()),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: enabled ? 1.0 : 0.5,
                  child: Center(
                    child: loading
                        ? SizedBox(
                            width: minSize / 2,
                            height: minSize / 2,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
