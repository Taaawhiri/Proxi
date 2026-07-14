import 'dart:io';

import 'package:flutter/material.dart';

/// Circular avatar that shows a custom photo when available, falling back
/// to initials on a tonal background otherwise.
class ProxiAvatar extends StatelessWidget {
  const ProxiAvatar({
    super.key,
    required this.initials,
    this.avatarPath,
    this.radius = 20,
    this.backgroundColor,
  });

  final String initials;
  final String? avatarPath;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    if (path != null && path.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(path)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(initials, style: TextStyle(fontSize: radius * 0.6)),
    );
  }
}
