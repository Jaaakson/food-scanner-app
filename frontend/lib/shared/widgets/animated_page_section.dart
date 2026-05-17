import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedPageSection extends StatelessWidget {
  const AnimatedPageSection({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 18,
  });

  final Widget child;
  final Duration delay;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: offsetY / 100,
          end: 0,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        );
  }
}