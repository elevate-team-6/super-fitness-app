import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';

/// Temporary landing screen used to verify a successful login: it reads the
/// cached user back from local storage and renders it. Replace with the real
/// main layout later.
class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  Future<UserModel?> _loadCachedUser() async {
    final raw = await getIt<SecureCacheHelper>().readData(
      key: AppKeys.userDataKey,
    );
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // TODO: confirm the background asset name.
      backgroundImage: AppImages.authBackground,
      body: FutureBuilder<UserModel?>(
        future: _loadCachedUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: CustomGlassContainer(
                borderRadius: BorderRadius.circular(24.r),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 56.r,
                    ),
                    SizedBox(height: 12.h),
                    Text('Login successful', style: AppTextStyles.white24700),
                    SizedBox(height: 24.h),

                    if (user == null)
                      Text(
                        'No cached user found.',
                        style: AppTextStyles.white16500,
                      )
                    else ...[
                      // Avatar
                      if (user.photo != null && user.photo!.isNotEmpty)
                        CustomCachedImage(
                          imageUrl: user.photo!,
                          width: 88.r,
                          height: 88.r,
                          borderRadius: BorderRadius.circular(44.r),
                        ),
                      SizedBox(height: 12.h),
                      Text(
                        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                        style: AppTextStyles.white24700,
                      ),
                      Text(user.email ?? '', style: AppTextStyles.white16500),
                      SizedBox(height: 20.h),

                      // Quick stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _stat('Age', '${user.age ?? '-'}'),
                          _stat('Weight', '${user.weight ?? '-'} kg'),
                          _stat('Height', '${user.height ?? '-'} cm'),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      _row('Gender', user.gender),
                      _row('Activity', user.activityLevel),
                      _row('Goal', user.goal),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.white24700),
        SizedBox(height: 4.h),
        Text(label, style: AppTextStyles.white16500),
      ],
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.white16500),
          Text(value, style: AppTextStyles.white16500),
        ],
      ),
    );
  }
}
