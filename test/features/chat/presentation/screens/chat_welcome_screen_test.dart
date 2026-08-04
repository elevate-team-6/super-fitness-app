import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/chat/presentation/screens/chat_welcome_screen.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_cubit.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_event.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_state.dart';
import 'package:super_fitness/features/chat/presentation/widgets/chat_welcome_view.dart';

import 'chat_welcome_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([ChatCubit])
void main() {
  late MockChatCubit mockChatCubit;
  late Map<String, Map<String, dynamic>> translations;
  const surface = Size(700, 1400);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      AppConstants.englishCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.englishCode}.json',
                ),
              )
              as Map<String, dynamic>,
      AppConstants.arabicCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.arabicCode}.json',
                ),
              )
              as Map<String, dynamic>,
    };
  });

  setUp(() {
    mockChatCubit = MockChatCubit();

    when(mockChatCubit.state).thenReturn(const ChatState());
    when(mockChatCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockChatCubit.eventStream).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpWelcomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: AppConstants.translationsPath,
        fallbackLocale: const Locale('en'),
        assetLoader: _InMemoryAssetLoader(translations),
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: surface,
            builder: (_, _) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              builder: BotToastInit(),
              onGenerateRoute: (settings) {
                if (settings.name == AppRoutes.chat) {
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Text('Chat Page')),
                  );
                }
                return null;
              },
              home: BlocProvider<ChatCubit>.value(
                value: mockChatCubit,
                child: const ChatWelcomeScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ChatWelcomeScreen Rendering', () {
    testWidgets('should render WelcomeView and core elements', (tester) async {
      await pumpWelcomeScreen(tester);

      expect(find.byType(ChatWelcomeView), findsOneWidget);
      expect(find.text(AppStrings.smartCoach.tr()), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, AppStrings.getStarted.tr()),
        findsOneWidget,
      );
    });

    testWidgets('should display Athlete if no user name is present', (
      tester,
    ) async {
      when(mockChatCubit.state).thenReturn(const ChatState(user: null));
      await pumpWelcomeScreen(tester);

      expect(
        find.text(AppStrings.hi.tr(args: [AppStrings.athlete.tr()])),
        findsOneWidget,
      );
    });
  });

  group('ChatWelcomeScreen Interactions', () {
    testWidgets('should open drawer when menu icon is tapped', (tester) async {
      await pumpWelcomeScreen(tester);

      final scaffoldFinder = find.byType(Scaffold);
      final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder.first);
      expect(scaffoldState.isDrawerOpen, isFalse);

      await tester.tap(find.byType(SvgPicture));
      await tester.pumpAndSettle();

      expect(scaffoldState.isDrawerOpen, isTrue);
    });

    testWidgets(
      'should dispatch StartNewSessionEvent and navigate when Get Started is tapped',
      (tester) async {
        await pumpWelcomeScreen(tester);

        await tester.tap(
          find.widgetWithText(ElevatedButton, AppStrings.getStarted.tr()),
        );
        await tester.pumpAndSettle();

        verify(mockChatCubit.doEvent(const StartNewSessionEvent())).called(1);
        expect(find.text('Chat Page'), findsOneWidget);
      },
    );
  });
}
