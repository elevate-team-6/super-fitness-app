import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/api/api_client/home_api_client.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meal_nutrition_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';

@Injectable(as: HomeRemoteDataSourceContract)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSourceContract {
  final HomeApiClient _apiClient;

  const HomeRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<MealsResponseModel>> getMealsByCategory(String category) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getMealsByCategory(category),
    );
  }

  @override
  Future<BaseResponse<DetailsFoodResponseModel>> getDetailsFood(String id) {
    return ErrorHandler.handleApiCall(() => _apiClient.getDetailsFood(id));
  }

  @override
  Future<BaseResponse<MealNutritionModel>> estimateNutrition(
    DetailsFoodEntity meal,
  ) {
    if (AppKeys.groqApiKey.isEmpty) {
      return Future.value(
        const ErrorBaseResponse(AppStrings.nutritionUnavailable),
      );
    }

    return ErrorHandler.handleApiCall(() async {
      final response = await _apiClient.generateNutrition(
        '${AppKeys.bearerPrefix} ${AppKeys.groqApiKey}',
        _buildNutritionBody(meal),
      );

      final content = response.content;
      if (content == null) throw const FormatException('empty Groq response');

      return MealNutritionModel.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Groq request assembly (OpenAI chat-completions format)
  // ---------------------------------------------------------------------------

  static const _nutritionSystemInstruction =
      'You are a nutrition estimator. Given a recipe and its ingredient list, '
      'estimate the total macronutrients for the ENTIRE recipe as written — '
      'the sum of every ingredient, not a single serving. Interpret free-text '
      'measures ("2 tbsp", "a pinch", "Juice of 1") using standard conversions. '
      'Ignore ingredients with no quantity that contribute negligible amounts, '
      'such as garnishes. Return numbers only, no ranges and no units.';

  Map<String, dynamic> _buildNutritionBody(DetailsFoodEntity meal) => {
    ApiParameters.model: AppEndPoints.groqModel,
    ApiParameters.messages: [
      {
        ApiParameters.role: ApiParameters.systemRole,
        ApiParameters.content: _nutritionSystemInstruction,
      },
      {
        ApiParameters.role: ApiParameters.userRole,
        ApiParameters.content: _buildNutritionPrompt(meal),
      },
    ],
    ApiParameters.temperature: 0,
    ApiParameters.responseFormat: {
      ApiParameters.type: ApiParameters.jsonSchemaType,
      ApiParameters.jsonSchemaType: {
        ApiParameters.name: _nutritionSchemaName,
        ApiParameters.strict: true,
        ApiParameters.schema: _nutritionSchema,
      },
    },
  };

  String _buildNutritionPrompt(DetailsFoodEntity meal) {
    final buffer = StringBuffer('Meal: ${meal.name}');

    if (meal.category.isNotEmpty) buffer.write('\nCategory: ${meal.category}');
    if (meal.area.isNotEmpty) buffer.write('\nCuisine: ${meal.area}');

    buffer.write('\nIngredients:');
    for (final ingredient in meal.ingredients) {
      buffer.write(
        ingredient.measure.isEmpty
            ? '\n- ${ingredient.name}'
            : '\n- ${ingredient.measure} ${ingredient.name}',
      );
    }

    return buffer.toString();
  }

  static const _nutritionSchemaName = 'meal_nutrition';

  static const _nutritionSchema = {
    ApiParameters.type: 'object',
    ApiParameters.properties: {
      ApiParameters.caloriesKcal: {ApiParameters.type: 'number'},
      ApiParameters.proteinG: {ApiParameters.type: 'number'},
      ApiParameters.carbsG: {ApiParameters.type: 'number'},
      ApiParameters.fatG: {ApiParameters.type: 'number'},
    },
    ApiParameters.required: [
      ApiParameters.caloriesKcal,
      ApiParameters.proteinG,
      ApiParameters.carbsG,
      ApiParameters.fatG,
    ],
    ApiParameters.additionalProperties: false,
  };
}
