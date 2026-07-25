import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class DetailsFoodSection extends StatelessWidget {
  final String title;
  final Widget child;

  const DetailsFoodSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.white20500),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }
}
