import 'package:flutter/material.dart';

class AnimatedStateSwitcher extends StatelessWidget {
  static const Duration _duration = Duration(milliseconds: 250);

  final Widget child;

  const AnimatedStateSwitcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
