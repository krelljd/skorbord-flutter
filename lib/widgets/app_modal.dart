import 'package:flutter/material.dart';

/// AppModal: Bottom slide-up modal with swipe-to-dismiss, focus trap, and large close button.
Future<T?> showAppModal<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 250),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => FocusScope(
        autofocus: true,
        canRequestFocus: true,
        child: Semantics(
          container: true,
          label: 'Modal dialog',
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 56),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: child,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
