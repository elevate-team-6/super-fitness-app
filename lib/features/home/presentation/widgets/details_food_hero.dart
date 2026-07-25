import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';

class DetailsFoodHero extends StatelessWidget {
  final String thumbnail;
  final String name;
  final VoidCallback? onPlay;
  final VoidCallback onBack;

  final Widget? footer;

  const DetailsFoodHero({
    super.key,
    required this.thumbnail,
    required this.name,
    required this.onBack,
    this.onPlay,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomCachedImage(
            imageUrl: thumbnail,
            placeholder: const ColoredBox(color: AppColors.black80),
          ),
          const _HeroScrim(),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: _BackButton(onTap: onBack),
              ),
            ),
          ),
          if (onPlay != null)
            Align(
              alignment: Alignment.center,
              child: _WatchVideoButton(onTap: onPlay!),
            ),
          PositionedDirectional(
            start: 24.w,
            end: 24.w,
            bottom: 16.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.white24500,
                ),
                if (footer != null) ...[SizedBox(height: 16.h), footer!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroScrim extends StatelessWidget {
  const _HeroScrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x99000000), Color(0x40000000), Color(0xE6000000)],
          stops: [0, 0.45, 1],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            AppIcons.back,
            width: 12.w,
            height: 12.w,
            matchTextDirection: true,
          ),
        ),
      ),
    );
  }
}

class _WatchVideoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _WatchVideoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.watchVideo.tr(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.black,
            size: 32.sp,
          ),
        ),
      ),
    );
  }
}
