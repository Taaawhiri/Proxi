import 'dart:async';

import 'package:flutter/material.dart';

/// Staggered fade + slide-up entrance, used for list rows appearing in
/// sequence (e.g. the nearby-users list).
class StaggeredSlideFadeIn extends StatefulWidget {
  const StaggeredSlideFadeIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<StaggeredSlideFadeIn> createState() => _StaggeredSlideFadeInState();
}

class _StaggeredSlideFadeInState extends State<StaggeredSlideFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(curved),
        child: widget.child,
      ),
    );
  }
}
