import 'package:flutter/material.dart';

class Pressable extends StatefulWidget {
  static const double _pressedScale = 0.96;
  static const Duration _duration = Duration(milliseconds: 120);

  final Widget child;
  final VoidCallback? onTap;

  const Pressable({super.key, required this.child, this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: isEnabled ? (_) => _setPressed(true) : null,
      onTapUp: isEnabled ? (_) => _setPressed(false) : null,
      onTapCancel: isEnabled ? () => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _isPressed ? Pressable._pressedScale : 1,
        duration: Pressable._duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
