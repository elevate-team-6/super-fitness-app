import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/features/home/presentation/widgets/recommendation_section.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [RecommendationSection()],
        ),
      ),
    );
  }
}
