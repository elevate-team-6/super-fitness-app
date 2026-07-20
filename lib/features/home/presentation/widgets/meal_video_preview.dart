import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';

/// The meal photo doubling as the video poster. Tapping the play button opens
/// the player; [onPlay] is null for recipes with no video, which turns the
/// overlay into a "no video" note instead.
class MealVideoPreview extends StatelessWidget {
  final String thumbnail;
  final VoidCallback? onPlay;

  const MealVideoPreview({super.key, required this.thumbnail, this.onPlay});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomCachedImage(
              imageUrl: thumbnail,
              // Static rather than a spinner — an endless animation makes
              // `pumpAndSettle` hang in widget tests.
              placeholder: const ColoredBox(color: AppColors.black80),
            ),
            // Darkened so the white play glyph stays legible on bright photos.
            const ColoredBox(color: Color(0x59000000)),
            Center(child: onPlay != null ? _buildPlayButton() : _buildNoVideo()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Semantics(
      button: true,
      label: AppStrings.watchVideo.tr(),
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.white,
            size: 32.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildNoVideo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        AppStrings.noVideoAvailable.tr(),
        textAlign: TextAlign.center,
        style: AppTextStyles.white2013500,
      ),
    );
  }
}
