import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_routes.dart';

class LoadingDialog extends StatefulWidget {
  final double speed;

  const LoadingDialog({super.key, this.speed = 17.5});

  static bool _isShowing = false;

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();

  static void show({BuildContext? context, double speed = 3}) {
    final ctx = context ?? AppRoutes.navigatorKey.currentContext;

    if (ctx == null || _isShowing) return;

    _isShowing = true;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (_) => LoadingDialog(speed: speed),
    ).then((_) {
      _isShowing = false;
    });
  }

  static void hide({BuildContext? context}) {
    final ctx = context ?? AppRoutes.navigatorKey.currentContext;

    if (ctx == null || !_isShowing) return;

    Navigator.of(ctx, rootNavigator: true).pop();

    _isShowing = false;
  }
}

class CustomLoading extends StatelessWidget {
  final double? width;
  final double? height;

  const CustomLoading({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width ?? 100.w,
        height: height ?? 100.h,
        child: Lottie.asset(AppLottie.loading, fit: BoxFit.contain),
      ),
    );
  }
}

class _LoadingDialogState extends State<LoadingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          // Blur effect on the entire screen
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          // Loading dialog in the center
          Center(
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 150.w,
                    height: 150.h,
                    child: Lottie.asset(
                      AppLottie.loading,
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller.duration = Duration(
                          milliseconds:
                              (composition.duration.inMilliseconds /
                                      widget.speed)
                                  .round(),
                        );
                        _controller.repeat();
                      },
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Loading, please wait...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
