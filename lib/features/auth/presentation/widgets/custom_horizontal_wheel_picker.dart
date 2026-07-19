import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class CustomHorizontalWheelPicker extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int selectedValue;
  final ValueChanged<int> onValueChanged;
  final String unit;

  const CustomHorizontalWheelPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.selectedValue,
    required this.onValueChanged,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(unit, style: AppTextStyles.primary16500),
        SizedBox(height: 8.h),
        SizedBox(
          height: 90.h,
          child: RotatedBox(
            quarterTurns: -1,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 70,
              diameterRatio: 3,
              perspective: 0.003,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                onValueChanged(minValue + index);
              },
              controller: FixedExtentScrollController(
                initialItem: selectedValue - minValue,
              ),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final value = minValue + index;
                  final isSelected = value == selectedValue;
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Center(
                      child: Text(
                        '$value',
                        style: isSelected
                            ? AppTextStyles.primary31500.copyWith(
                                fontSize: 44.sp,
                                fontWeight: FontWeight.w800,
                              )
                            : AppTextStyles.white24500.copyWith(
                                fontSize: 33.sp,
                                fontWeight: FontWeight.w800,
                              ),
                      ),
                    ),
                  );
                },
                childCount: maxValue - minValue + 1,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        CustomPaint(
          size: Size(15.w, 10.h),
          painter: TrianglePainter(color: AppColors.primary),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
