import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_routes.dart';
import '../../../../features/home/presentation/widgets/meal_card.dart';
import '../../domain/entities/chat_ref_entity.dart';
import 'chat_exercise_card.dart';

class RefCarousel extends StatelessWidget {
  final List<ChatRefEntity> refs;

  const RefCarousel({super.key, required this.refs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h, // Reverted to original height
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: refs.length,
        clipBehavior: Clip.none,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final ref = refs[index];
          if (ref.type == ChatRefType.exercise) {
            return ChatExerciseCard(
              ref: ref,
              onTap: () {
                if (ref.exerciseInfo != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.exerciseDetails,
                    arguments: ref.exerciseInfo,
                  );
                }
              },
            );
          } else {
            return _buildMealCard(context, ref);
          }
        },
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, ChatRefEntity ref) {
    return Opacity(
      opacity: ref.isSnapshot ? 0.7 : 1.0,
      child: MealCard(
        name: ref.name,
        image: ref.image ?? '',
        onTap: ref.isSnapshot
            ? () {}
            : () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.detailsFood,
                  arguments: DetailsFoodArgs(
                    mealId: ref.id,
                    mealName: ref.name,
                  ),
                );
              },
      ),
    );
  }
}
