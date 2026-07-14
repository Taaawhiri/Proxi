import 'dart:async';

import 'package:flutter/material.dart';

/// Staggered scale + fade entrance, used for list rows and map markers to
/// evoke a radar "ping" reveal as nearby users are discovered.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
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
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    return ScaleTransition(
      scale: curved,
      child: FadeTransition(opacity: _controller, child: widget.child),
    );
  }
}
