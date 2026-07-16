import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/services/facebook_auth_service.dart';
import 'package:super_fitness/config/services/google_auth_service.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_state.dart';

import 'login_cubit_test.mocks.dart';

@GenerateMocks([
  SignInUseCase,
  SecureCacheHelper,
  GoogleAuthService,
  FacebookAuthService,
])
void main() {
  late MockSignInUseCase mockUseCase;
  late MockSecureCacheHelper mockCache;
  late MockGoogleAuthService mockGoogleAuthService;
  late MockFacebookAuthService mockFacebookAuthService;
  late LoginCubit cubit;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const fakeUser = UserEntity(
    id: 'u1',
    firstName: 'Ahmed',
    lastName: 'Emam',
    email: 'test@test.com',
    gender: 'male',
    age: 25,
    weight: 90,
    height: 183,
    activityLevel: 'level1',
    goal: 'Gain weight',
  );

  const fakeEntity = SignInEntity(
    message: 'success',
    token: 'fake_token',
    user: fakeUser,
  );

  setUp(() {
    mockUseCase = MockSignInUseCase();
    mockCache = MockSecureCacheHelper();
    mockGoogleAuthService = MockGoogleAuthService();
    mockFacebookAuthService = MockFacebookAuthService();
    cubit = LoginCubit(
      mockUseCase,
      mockCache,
      mockGoogleAuthService,
      mockFacebookAuthService,
    );

    when(
      mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});

    provideDummy<BaseResponse<SignInEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  group('TogglePasswordVisibilityEvent', () {
    blocTest<LoginCubit, LoginState>(
      'toggles obscurePassword from true to false',
      build: () => cubit,
      act: (cubit) => cubit.doIntent(const TogglePasswordVisibilityEvent()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.obscurePassword,
          'obscurePassword',
          false,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'toggles back to obscured on a second tap',
      build: () => cubit,
      act: (cubit) => cubit
        ..doIntent(const TogglePasswordVisibilityEvent())
        ..doIntent(const TogglePasswordVisibilityEvent()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.obscurePassword,
          'obscurePassword',
          false,
        ),
        isA<LoginState>().having(
          (s) => s.obscurePassword,
          'obscurePassword',
          true,
        ),
      ],
    );
  });

  group('LoginEvent', () {
    test(
      'emits loading then success side effects on valid credentials',
      () async {
        when(
          mockUseCase(request),
        ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplaySuccessEvent>(),
            isA<NavigateEvent>(),
          ]),
        );

        cubit.doIntent(const LoginEvent(request));
        await expectation;

        verify(mockUseCase(request)).called(1);
      },
    );

    test('caches the token, the full user data and the user id', () async {
      when(
        mockUseCase(request),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<NavigateEvent>()),
      );

      cubit.doIntent(const LoginEvent(request));
      await expectation;

      verify(
        mockCache.writeData(key: AppKeys.tokenKey, value: 'fake_token'),
      ).called(1);
      verify(
        mockCache.writeData(key: AppKeys.userIdKey, value: 'u1'),
      ).called(1);
      // The whole user object is persisted as JSON (acceptance criteria).
      final userJson =
          verify(
                mockCache.writeData(
                  key: AppKeys.userDataKey,
                  value: captureAnyNamed('value'),
                ),
              ).captured.single
              as String;
      expect(userJson, contains('Ahmed'));
      expect(userJson, contains('Gain weight'));
      expect(userJson, contains('183'));
    });

    test('does not cache an empty token', () async {
      when(mockUseCase(request)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const SignInEntity(message: 'success', token: '', user: fakeUser),
        ),
      );

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<NavigateEvent>()),
      );

      cubit.doIntent(const LoginEvent(request));
      await expectation;

      verifyNever(
        mockCache.writeData(key: AppKeys.tokenKey, value: anyNamed('value')),
      );
    });

    test('skips the user cache when the response has no user', () async {
      when(mockUseCase(request)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const SignInEntity(message: 'success', token: 'fake_token'),
        ),
      );

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<NavigateEvent>()),
      );

      cubit.doIntent(const LoginEvent(request));
      await expectation;

      verify(
        mockCache.writeData(key: AppKeys.tokenKey, value: 'fake_token'),
      ).called(1);
      verifyNever(
        mockCache.writeData(key: AppKeys.userDataKey, value: anyNamed('value')),
      );
    });

    test(
      'emits loading then failure side effects on wrong credentials',
      () async {
        when(
          mockUseCase(request),
        ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplayErrorEvent>().having(
              (e) => e.errorMessage,
              'errorMessage',
              'invalid credentials',
            ),
          ]),
        );

        cubit.doIntent(const LoginEvent(request));
        await expectation;
      },
    );

    test('caches nothing and never navigates when sign-in fails', () async {
      when(
        mockUseCase(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<DisplayErrorEvent>()),
      );

      cubit.doIntent(const LoginEvent(request));
      await expectation;

      verifyNever(
        mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
      );
    });
  });
}
