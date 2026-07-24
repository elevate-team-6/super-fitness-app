import 'dart:ui';

import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String backgroundImage;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final double blurSigma;
  final Color? overlayColor;

  const AppScaffold({
    super.key,
    required this.backgroundImage,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.drawer,
    this.extendBody = true,
    this.extendBodyBehindAppBar = true,
    this.blurSigma = 12.5,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final tint = Container(
      color: overlayColor ?? Colors.black.withValues(alpha: 0.2),
    );
    // Skipping the BackdropFilter entirely spares its GPU cost on screens
    // that only want the tint.
    final overlay = blurSigma <= 0
        ? tint
        : BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: tint,
          );

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(child: overlay),
          body,
        ],
      ),
    );
  }
}
