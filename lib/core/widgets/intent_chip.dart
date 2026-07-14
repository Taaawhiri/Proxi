import 'package:flutter/material.dart';

import '../../features/auth/domain/user_intent.dart';

/// Small badge showing a user's current intent (e.g. "Aperto a conoscenze").
class IntentChip extends StatelessWidget {
  const IntentChip({super.key, required this.intent, this.dense = false});

  final UserIntent intent;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 12, vertical: dense ? 3 : 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(intent.icon, size: dense ? 12 : 16, color: colorScheme.onSecondaryContainer),
          SizedBox(width: dense ? 4 : 6),
          Text(
            intent.label,
            style: TextStyle(
              fontSize: dense ? 11 : 13,
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
