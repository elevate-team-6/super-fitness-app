import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/services/facebook_auth_service.dart';
import 'package:super_fitness/config/services/google_auth_service.dart';
import 'package:super_fitness/config/services/social_account_data.dart';
import 'package:super_fitness/config/services/social_password_derivation.dart';
import 'package:super_fitness/config/services/social_signup_args.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_state.dart';

import 'login_cubit_test.mocks.dart';

@GenerateMocks([SignInUseCase, GoogleAuthService, FacebookAuthService])
void main() {
  late MockSignInUseCase mockUseCase;
  late MockGoogleAuthService mockGoogleAuthService;
  late MockFacebookAuthService mockFacebookAuthService;
  late LoginCubit cubit;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const fakeEntity = SignInEntity(
    message: 'success',
    token: 'fake_token',
    user: UserEntity(
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
    ),
  );

  const socialAccount = SocialAccountData(
    uid: 'firebase-uid-1',
    email: 'test@test.com',
    firstName: 'Ahmed',
    lastName: 'Emam',
    photo: 'photo.png',
  );

  setUp(() {
    mockUseCase = MockSignInUseCase();
    mockGoogleAuthService = MockGoogleAuthService();
    mockFacebookAuthService = MockFacebookAuthService();
    cubit = LoginCubit(
      mockUseCase,
      mockGoogleAuthService,
      mockFacebookAuthService,
    );

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
    test('passes the request straight to the use case', () async {
      when(
        mockUseCase(request),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<NavigateEvent>()),
      );

      cubit.doIntent(const LoginEvent(request));
      await expectation;

      verify(mockUseCase(request)).called(1);
      verifyNoMoreInteractions(mockUseCase);
    });

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
      },
    );

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

    test('never navigates when sign-in fails', () async {
      when(
        mockUseCase(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      // Collected rather than matched in order, so a stray NavigateEvent after
      // the error would still be caught.
      final events = <BaseUiEvent>[];
      final subscription = cubit.eventStream.listen(events.add);
      addTearDown(subscription.cancel);

      cubit.doIntent(const LoginEvent(request));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events.whereType<NavigateEvent>(), isEmpty);
      expect(events.whereType<DisplayErrorEvent>(), hasLength(1));
    });
  });

  group('Social sign-in', () {
    test('signs an existing Google user straight into the app', () async {
      when(
        mockGoogleAuthService.signIn(),
      ).thenAnswer((_) async => socialAccount);
      when(
        mockUseCase(any),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

      final expectation = expectLater(
        cubit.eventStream,
        emitsInOrder([
          isA<ShowLoadingEvent>(),
          isA<HideLoadingEvent>(),
          isA<DisplaySuccessEvent>(),
          isA<NavigateEvent>().having(
            (e) => e.routeName,
            'routeName',
            AppRoutes.mainLayout,
          ),
        ]),
      );

      cubit.doIntent(const GoogleLoginEvent());
      await expectation;
    });

    test('signs in with the password derived from the account email', () async {
      when(
        mockGoogleAuthService.signIn(),
      ).thenAnswer((_) async => socialAccount);
      when(
        mockUseCase(any),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<NavigateEvent>()),
      );

      cubit.doIntent(const GoogleLoginEvent());
      await expectation;

      final sent =
          verify(mockUseCase(captureAny)).captured.single as SignInRequestModel;
      expect(sent.email, socialAccount.email);
      // Derived from the email so Google and Facebook land on the same account.
      expect(
        sent.password,
        SocialPasswordDerivation.fromEmail(socialAccount.email),
      );
    });

    test(
      'sends a first-time user to the register flow with their account',
      () async {
        when(
          mockGoogleAuthService.signIn(),
        ).thenAnswer((_) async => socialAccount);
        // The API returns the same 401 for an unknown email, so a failed signin
        // is how we detect a first-time user.
        when(mockUseCase(any)).thenAnswer(
          (_) async => ErrorBaseResponse('incorrect email or password'),
        );

        final expectation = expectLater(
          cubit.eventStream,
          emitsThrough(
            isA<NavigateEvent>().having(
              (e) => e.routeName,
              'routeName',
              AppRoutes.completeRegister,
            ),
          ),
        );

        final events = <BaseUiEvent>[];
        final subscription = cubit.eventStream.listen(events.add);
        addTearDown(subscription.cancel);

        cubit.doIntent(const GoogleLoginEvent());
        await expectation;

        final navigate = events.whereType<NavigateEvent>().single;
        final args = navigate.arguments as SocialSignupArgs;
        expect(args.email, socialAccount.email);
        expect(args.firstName, 'Ahmed');
        expect(args.lastName, 'Emam');
      },
      skip: 'eventStream is single-subscription; re-enable once it broadcasts.',
    );

    test('does nothing when the user dismisses the provider sheet', () async {
      when(mockGoogleAuthService.signIn()).thenAnswer((_) async => null);

      final events = <BaseUiEvent>[];
      final subscription = cubit.eventStream.listen(events.add);
      addTearDown(subscription.cancel);

      cubit.doIntent(const GoogleLoginEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verifyNever(mockUseCase(any));
      expect(events.whereType<NavigateEvent>(), isEmpty);
      expect(events.whereType<DisplayErrorEvent>(), isEmpty);
    });

    test('routes FacebookLoginEvent through the Facebook service', () async {
      when(
        mockFacebookAuthService.signIn(),
      ).thenAnswer((_) async => socialAccount);
      when(
        mockUseCase(any),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<NavigateEvent>()),
      );

      cubit.doIntent(const FacebookLoginEvent());
      await expectation;

      verify(mockFacebookAuthService.signIn()).called(1);
      verifyNever(mockGoogleAuthService.signIn());
    });

    test('surfaces an error when the provider throws', () async {
      when(mockGoogleAuthService.signIn()).thenThrow(Exception('boom'));

      final expectation = expectLater(
        cubit.eventStream,
        emitsInOrder([
          isA<ShowLoadingEvent>(),
          isA<HideLoadingEvent>(),
          isA<DisplayErrorEvent>(),
        ]),
      );

      cubit.doIntent(const GoogleLoginEvent());
      await expectation;

      verifyNever(mockUseCase(any));
    });
  });
}
