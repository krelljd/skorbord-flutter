import 'package:flutter/material.dart';

/// ConnectionStatus: Real-time connection indicator widget.
class ConnectionStatus extends StatelessWidget {
  final bool connected;
  final String? message;

  const ConnectionStatus({
    super.key,
    required this.connected,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          connected ? Icons.wifi : Icons.wifi_off,
          color: connected ? Colors.green : Colors.red,
          size: 20,
        ),
        if (message != null) ...[
          const SizedBox(width: 8),
          Text(
            message!,
            style: TextStyle(
              color: connected ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
      ],
    );
  }
}
