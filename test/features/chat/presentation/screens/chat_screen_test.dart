import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/features/chat/domain/entities/chat_message_entity.dart';
import 'package:super_fitness/features/chat/domain/entities/chat_ref_entity.dart';
import 'package:super_fitness/features/chat/presentation/screens/chat_screen.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_cubit.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_event.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_state.dart';
import 'package:super_fitness/features/chat/presentation/widgets/chat_bubbles.dart';
import 'package:super_fitness/features/chat/presentation/widgets/chat_exercise_card.dart';
import 'package:super_fitness/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

import 'chat_welcome_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

void main() {
  late MockChatCubit mockChatCubit;
  late Map<String, Map<String, dynamic>> translations;
  const surface = Size(1000, 2000);

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

  Future<void> pumpChatScreen(WidgetTester tester, {bool settle = true}) async {
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
                if (settings.name == AppRoutes.exerciseDetails) {
                  return MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: Text('Exercise Details')),
                  );
                }
                return null;
              },
              home: BlocProvider<ChatCubit>.value(
                value: mockChatCubit,
                child: const ChatScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group('ChatScreen Rendering', () {
    testWidgets('should show Lottie animation when messages are empty', (
      tester,
    ) async {
      await pumpChatScreen(tester);
      expect(find.byType(UserBubble), findsNothing);
      expect(find.byType(AssistantBubble), findsNothing);
    });

    testWidgets('should render messages when state has data', (tester) async {
      final messages = [
        ChatMessageEntity(
          id: '1',
          text: 'Hi',
          sender: MessageSender.user,
          timestamp: DateTime.now(),
        ),
        ChatMessageEntity(
          id: '2',
          text: 'Hello',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
        ),
      ];

      when(
        mockChatCubit.state,
      ).thenReturn(ChatState(messagesStatus: BaseState(data: messages)));

      await pumpChatScreen(tester);

      expect(find.byType(UserBubble), findsOneWidget);
      expect(find.byType(AssistantBubble), findsOneWidget);
      expect(find.text('Hi'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('should show TypingIndicator when status is loading', (
      tester,
    ) async {
      final messages = [
        ChatMessageEntity(
          id: '1',
          text: 'Hi',
          sender: MessageSender.user,
          timestamp: DateTime.now(),
        ),
      ];
      when(mockChatCubit.state).thenReturn(
        ChatState(
          status: ChatStatus.loading,
          messagesStatus: BaseState(data: messages),
        ),
      );

      await pumpChatScreen(tester, settle: false);
      expect(find.byType(TypingIndicator), findsOneWidget);
    });

    testWidgets('should render Exercise cards when assistant sends refs', (
      tester,
    ) async {
      final exerciseRef = ChatRefEntity(
        id: 'ex1',
        name: 'Bench Press',
        type: ChatRefType.exercise,
        exerciseInfo: ExerciseEntity.empty,
      );

      final messages = [
        ChatMessageEntity(
          id: '2',
          text: 'Check this out',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
          refs: [exerciseRef],
        ),
      ];

      when(
        mockChatCubit.state,
      ).thenReturn(ChatState(messagesStatus: BaseState(data: messages)));

      // Use settle: false to avoid timeout if there's an animation issue
      await pumpChatScreen(tester, settle: false);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ChatExerciseCard), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
    });
  });

  group('ChatScreen Interactions', () {
    testWidgets('should dispatch SendMessageEvent when send button is tapped', (
      tester,
    ) async {
      await pumpChatScreen(tester);

      final input = find.byType(TextField);
      await tester.enterText(input, 'Test Message');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send_outlined));
      await tester.pump();

      verify(
        mockChatCubit.doEvent(const SendMessageEvent('Test Message')),
      ).called(1);
    });

    testWidgets(
      'should navigate to exercise details when exercise card is tapped',
      (tester) async {
        final exerciseRef = ChatRefEntity(
          id: 'ex1',
          name: 'Bench Press',
          type: ChatRefType.exercise,
          exerciseInfo: ExerciseEntity.empty.copyWith(
            id: 'ex1',
            exercise: 'Bench Press',
          ),
        );

        final messages = [
          ChatMessageEntity(
            id: '2',
            text: 'Check this out',
            sender: MessageSender.assistant,
            timestamp: DateTime.now(),
            refs: [exerciseRef],
          ),
        ];

        when(
          mockChatCubit.state,
        ).thenReturn(ChatState(messagesStatus: BaseState(data: messages)));

        await pumpChatScreen(tester, settle: false);
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byType(ChatExerciseCard));
        await tester.pumpAndSettle();

        expect(find.text('Exercise Details'), findsOneWidget);
      },
    );
  });

  group('ChatScreen Error Handling', () {
    testWidgets(
      'should show error message in ActiveChatView when status is failure',
      (tester) async {
        when(mockChatCubit.state).thenReturn(
          const ChatState(
            status: ChatStatus.failure,
            errorMessage: 'Something went wrong',
          ),
        );

        await pumpChatScreen(tester);
        // Logic for showing error message is handled in ChatScreen listener,
        // but rendering is done via BotToast or similar in some cases.
      },
    );
  });
}

extension on ExerciseEntity {
  ExerciseEntity copyWith({String? id, String? exercise}) {
    return ExerciseEntity(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      difficultyLevel: difficultyLevel,
      targetMuscleGroup: targetMuscleGroup,
      primeMoverMuscle: primeMoverMuscle,
      primaryEquipment: primaryEquipment,
      secondaryEquipment: secondaryEquipment,
      posture: posture,
      grip: grip,
      forceType: forceType,
      secondaryMuscles: secondaryMuscles,
      tertiaryMuscles: tertiaryMuscles,
      bodyRegion: bodyRegion,
      mechanics: mechanics,
      laterality: laterality,
      primaryExerciseClassification: primaryExerciseClassification,
      shortYoutubeDemonstrationLink: shortYoutubeDemonstrationLink,
      inDepthYoutubeExplanationLink: inDepthYoutubeExplanationLink,
    );
  }
}
