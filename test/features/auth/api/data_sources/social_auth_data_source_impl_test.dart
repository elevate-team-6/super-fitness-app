import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/services/facebook_auth_service.dart';
import 'package:super_fitness/config/services/google_auth_service.dart';
import 'package:super_fitness/features/auth/api/data_sources/social_auth_data_source_impl.dart';
import 'package:super_fitness/features/auth/data/models/response/social_account_model.dart';

import 'social_auth_data_source_impl_test.mocks.dart';

@GenerateMocks([GoogleAuthService, FacebookAuthService])
void main() {
  late MockGoogleAuthService mockGoogleAuthService;
  late MockFacebookAuthService mockFacebookAuthService;
  late SocialAuthDataSourceImpl dataSource;

  setUp(() {
    mockGoogleAuthService = MockGoogleAuthService();
    mockFacebookAuthService = MockFacebookAuthService();
    dataSource = SocialAuthDataSourceImpl(
      mockGoogleAuthService,
      mockFacebookAuthService,
    );
  });

  group('signInWithGoogle', () {
    const tSocialAccount = SocialAccountModel(
      uid: 'uid',
      email: 'test@gmail.com',
      firstName: 'First',
      lastName: 'Last',
    );

    test('should return SocialAccountModel when successful', () async {
      when(
        mockGoogleAuthService.signIn(),
      ).thenAnswer((_) async => tSocialAccount);

      final result = await dataSource.signInWithGoogle();

      expect(result, equals(tSocialAccount));
      verify(mockGoogleAuthService.signIn()).called(1);
    });

    test('should return null when cancelled', () async {
      when(mockGoogleAuthService.signIn()).thenAnswer((_) async => null);

      final result = await dataSource.signInWithGoogle();

      expect(result, isNull);
      verify(mockGoogleAuthService.signIn()).called(1);
    });
  });

  group('signInWithFacebook', () {
    const tSocialAccount = SocialAccountModel(
      uid: 'uid',
      email: 'test@facebook.com',
      firstName: 'First',
      lastName: 'Last',
    );

    test('should return SocialAccountModel when successful', () async {
      when(
        mockFacebookAuthService.signIn(),
      ).thenAnswer((_) async => tSocialAccount);

      final result = await dataSource.signInWithFacebook();

      expect(result, equals(tSocialAccount));
      verify(mockFacebookAuthService.signIn()).called(1);
    });

    test('should return null when cancelled', () async {
      when(mockFacebookAuthService.signIn()).thenAnswer((_) async => null);

      final result = await dataSource.signInWithFacebook();

      expect(result, isNull);
      verify(mockFacebookAuthService.signIn()).called(1);
    });
  });
}
