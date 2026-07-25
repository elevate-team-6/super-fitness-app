import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  Future<void> _playVideo() async {
    final url =
        YoutubeUrl.watchUrlOf(exercise.shortYoutubeDemonstrationLink) ??
        YoutubeUrl.watchUrlOf(exercise.inDepthYoutubeExplanationLink);

    if (url == null) return;

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo =
        YoutubeUrl.videoIdOf(exercise.shortYoutubeDemonstrationLink) != null ||
        YoutubeUrl.videoIdOf(exercise.inDepthYoutubeExplanationLink) != null;

    return GestureDetector(
      onTap: onTap ?? (hasVideo ? _playVideo : null),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 20.r : 0),
            topRight: Radius.circular(isFirst ? 20.r : 0),
            bottomLeft: Radius.circular(isLast ? 20.r : 0),
            bottomRight: Radius.circular(isLast ? 20.r : 0),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: SizedBox(
                width: 76.w,
                height: 76.w,
                child: CustomCachedImage(
                  borderRadius: BorderRadius.circular(14.r),
                  imageUrl:
                      YoutubeUrl.thumbnailUrlOf(
                        exercise.shortYoutubeDemonstrationLink,
                      ) ??
                      "http://fake.com",
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: AppColors.black70,
                    child: Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                      size: 24.r,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exercise,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.white16700,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${exercise.mechanics} • ${exercise.laterality}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.white13400,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    exercise.primeMoverMuscle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.white13400,
                  ),
                ],
              ),
            ),
            if (hasVideo) ...[
              SizedBox(width: 8.w),
              Container(
                width: 34.r,
                height: 34.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.black,
                  size: 28.r,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
