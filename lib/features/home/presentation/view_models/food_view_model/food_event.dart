import 'package:equatable/equatable.dart';

sealed class FoodEvents extends Equatable {
  const FoodEvents();

  @override
  List<Object?> get props => [];
}

class GetMealsCategoriesEvent extends FoodEvents {
  final String? initialCategory;

  const GetMealsCategoriesEvent({this.initialCategory});

  @override
  List<Object?> get props => [initialCategory];
}

class ChangeCategoryEvent extends FoodEvents {
  final String category;

  const ChangeCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
