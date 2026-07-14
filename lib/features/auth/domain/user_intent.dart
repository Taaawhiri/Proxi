import 'package:flutter/material.dart';

/// What a user is currently open to on Proxi, shown as a small badge to
/// nearby people.
enum UserIntent { openToMeet, friendship, networking, relationship, chatOnly }

extension UserIntentX on UserIntent {
  String get label => switch (this) {
        UserIntent.openToMeet => 'Aperto a conoscenze',
        UserIntent.friendship => 'Amicizia',
        UserIntent.networking => 'Networking',
        UserIntent.relationship => 'Cerco una relazione',
        UserIntent.chatOnly => 'Solo chat',
      };

  IconData get icon => switch (this) {
        UserIntent.openToMeet => Icons.emoji_people,
        UserIntent.friendship => Icons.diversity_3,
        UserIntent.networking => Icons.work_outline,
        UserIntent.relationship => Icons.favorite_border,
        UserIntent.chatOnly => Icons.chat_bubble_outline,
      };
}
