import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';
import 'package:super_fitness/features/profile/domain/use_cases/upload_profile_photo_use_case.dart';

import 'upload_profile_photo_use_case_test.mocks.dart';

@GenerateMocks([ProfileRepoContract])
void main() {
  late MockProfileRepoContract repo;
  late UploadProfilePhotoUseCase useCase;

  final dummyFile = File('test_path/photo.png');

  setUpAll(() {
    provideDummy<BaseResponse<String>>(const SuccessBaseResponse(null));
  });

  setUp(() {
    repo = MockProfileRepoContract();
    useCase = UploadProfilePhotoUseCase(repo);
  });

  group('UploadProfilePhotoUseCase', () {
    test('returns success response from repository unchanged', () async {
      const expectedResponse = SuccessBaseResponse<String>('success');
      when(
        repo.uploadPhoto(dummyFile),
      ).thenAnswer((_) async => expectedResponse);

      final result = await useCase(dummyFile);

      expect(result, equals(expectedResponse));
      verify(repo.uploadPhoto(dummyFile)).called(1);
    });

    test('returns error response from repository unchanged', () async {
      const expectedResponse = ErrorBaseResponse<String>('Upload failed');
      when(
        repo.uploadPhoto(dummyFile),
      ).thenAnswer((_) async => expectedResponse);

      final result = await useCase(dummyFile);

      expect(result, equals(expectedResponse));
      verify(repo.uploadPhoto(dummyFile)).called(1);
    });
  });
}
