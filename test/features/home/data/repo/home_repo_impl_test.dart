import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_category_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscles_by_group_response.dart';
import 'package:super_fitness/features/home/data/repo/home_repo_impl.dart';
import 'package:super_fitness/features/home/domain/entities/home_user_entity.dart';
import 'package:super_fitness/features/home/domain/entities/muscle_entity.dart';

import 'home_repo_impl_test.mocks.dart';

@GenerateMocks([HomeRemoteDataSourceContract, SecureCacheHelper])
void main() {
  provideDummy<BaseResponse<ExerciseResponse>>(
    const SuccessBaseResponse(ExerciseResponse()),
  );
  provideDummy<BaseResponse<MuscleResponse>>(
    const SuccessBaseResponse(MuscleResponse()),
  );
  provideDummy<BaseResponse<MusclesByGroupResponse>>(
    const SuccessBaseResponse(MusclesByGroupResponse()),
  );
  provideDummy<BaseResponse<MealCategoryResponse>>(
    const SuccessBaseResponse(MealCategoryResponse()),
  );

  late HomeRepoImpl repo;
  late MockHomeRemoteDataSourceContract mockRemoteDataSource;
  late MockSecureCacheHelper mockCacheHelper;

  setUp(() {
    mockRemoteDataSource = MockHomeRemoteDataSourceContract();
    mockCacheHelper = MockSecureCacheHelper();
    repo = HomeRepoImpl(mockRemoteDataSource, mockCacheHelper);
  });

  group('getCachedUserData', () {
    test(
      'should return SuccessBaseResponse with UserEntity when cache has data',
      () async {
        // arrange
        when(
          mockCacheHelper.readData(key: AppKeys.userNameKey),
        ).thenAnswer((_) async => 'Test User');
        when(
          mockCacheHelper.readData(key: AppKeys.userImageKey),
        ).thenAnswer((_) async => 'image_url');

        // act
        final result = await repo.getCachedUserData();

        // assert
        expect(result, isA<SuccessBaseResponse<HomeUserEntity>>());
        final data = (result as SuccessBaseResponse<HomeUserEntity>).data;
        expect(data?.name, 'Test User');
        expect(data?.image, 'image_url');
      },
    );
  });

  group('getRandomMuscles', () {
    const tModel = MuscleModel(id: '1', name: 'Muscle 1');
    const tResponse = MuscleResponse(muscles: [tModel]);

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getRandomMuscles(language: anyNamed('language')),
        ).thenAnswer((_) async => const SuccessBaseResponse(tResponse));

        // act
        final result = await repo.getRandomMuscles();

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
        final data = (result as SuccessBaseResponse<List<MuscleEntity>>).data;
        expect(data?.length, 1);
        expect(data?.first.name, 'Muscle 1');
      },
    );
  });
}
