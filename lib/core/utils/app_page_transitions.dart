import 'package:flutter/material.dart';

/// The push animation every route in the app shares: the incoming page fades
/// in while rising a short distance.
///
/// Vertical on purpose. The app ships in English and Arabic, and a horizontal
/// slide would have to flip direction with the locale to avoid pushing pages
/// in from the wrong edge.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  /// A nudge rather than the quarter-screen travel of Flutter's fade-upwards
  /// transition, which reads as heavy on screens this dark.
  static final Animatable<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  static final Animatable<double> _fadeIn = CurveTween(curve: Curves.easeOut);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 260);

  /// Shorter than the push: going back should feel like the screen is already
  /// on its way out.
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

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
      child: SlideTransition(position: animation.drive(_rise), child: child),
    );
  }
}
