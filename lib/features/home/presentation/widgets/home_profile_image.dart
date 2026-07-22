import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

class HomeProfileImage extends StatelessWidget {
  final String? userPhoto;
  final bool isLoading;

  const HomeProfileImage({super.key, this.userPhoto, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppShimmer(
        width: 40.w,
        height: 40.w,
        borderRadius: BorderRadius.circular(20.r),
      );
    }

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        color: AppColors.black80,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: userPhoto != null && userPhoto!.isNotEmpty
          ? Image.network(
              userPhoto!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: SvgPicture.asset(
        AppIcons.person,
        width: 24.w,
        height: 24.w,
        colorFilter: const ColorFilter.mode(AppColors.black40, BlendMode.srcIn),
      ),
    );
  }
}
