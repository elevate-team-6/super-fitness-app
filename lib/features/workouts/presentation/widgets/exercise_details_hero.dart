import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseDetailsHero extends StatelessWidget {
  final ExerciseEntity exercise;

  const ExerciseDetailsHero({super.key, required this.exercise});

  Future<void> _playVideo() async {
    final url =
        YoutubeUrl.watchUrlOf(exercise.shortYoutubeDemonstrationLink) ??
        YoutubeUrl.watchUrlOf(exercise.inDepthYoutubeExplanationLink);

    if (url == null) return;

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        YoutubeUrl.thumbnailUrlOf(exercise.shortYoutubeDemonstrationLink) ??
        YoutubeUrl.thumbnailUrlOf(exercise.inDepthYoutubeExplanationLink);

    return GestureDetector(
      onTap: _playVideo,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 250.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomCachedImage(
              imageUrl: thumbnailUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: AppColors.white,
              size: 40.r,
            ),
          ),
        ],
      ),
    );
  }
}
