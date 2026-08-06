import 'package:flutter/material.dart';

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  static final Animatable<Offset> _slideUp = Tween<Offset>(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.fastOutSlowIn));

  static final Animatable<double> _scaleIn = Tween<double>(
    begin: 0.92,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.fastOutSlowIn));

  static final Animatable<double> _fadeIn = CurveTween(curve: Curves.easeIn);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(_fadeIn),
      child: ScaleTransition(
        scale: animation.drive(_scaleIn),
        child: SlideTransition(
          position: animation.drive(_slideUp),
          child: child,
        ),
      ),
    );
  }
}
