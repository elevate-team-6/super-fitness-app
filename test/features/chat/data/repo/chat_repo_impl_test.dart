import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/services/crashlytics_service.dart';
import 'package:super_fitness/core/data/local/sqlite/catalog_local_data_source.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/chat/data/data_sources/chat_local_data_source_contract.dart';
import 'package:super_fitness/features/chat/data/data_sources/chat_remote_data_source_contract.dart';
import 'package:super_fitness/features/chat/data/models/chat_event_model.dart';
import 'package:super_fitness/features/chat/data/models/hive/chat_hive_models.dart';
import 'package:super_fitness/features/chat/data/repo/chat_repo_impl.dart';
import 'package:super_fitness/features/chat/domain/entities/chat_message_entity.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';

import 'chat_repo_impl_test.mocks.dart';

@GenerateMocks([
  ChatRemoteDataSourceContract,
  CatalogLocalDataSource,
  SecureCacheHelper,
  ChatLocalDataSourceContract,
  CrashlyticsService,
])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<UserEntity?>>(
      const SuccessBaseResponse<UserEntity?>(null),
    );
    provideDummy<BaseResponse<ChatSessionHiveModel?>>(
      const SuccessBaseResponse<ChatSessionHiveModel?>(null),
    );
    provideDummy<BaseResponse<void>>(const SuccessBaseResponse<void>(null));
    provideDummy<BaseResponse<List<ChatSessionHiveModel>>>(
      const SuccessBaseResponse<List<ChatSessionHiveModel>>([]),
    );
    provideDummy<BaseResponse<List<ExerciseModel>>>(
      const SuccessBaseResponse<List<ExerciseModel>>([]),
    );
  });

  late MockChatRemoteDataSourceContract mockRemoteDataSource;
  late MockCatalogLocalDataSource mockLocalDataSource;
  late MockSecureCacheHelper mockCacheHelper;
  late MockChatLocalDataSourceContract mockChatLocalDataSource;
  late MockCrashlyticsService mockCrashlyticsService;
  late ChatRepoImpl repo;

  setUp(() {
    mockRemoteDataSource = MockChatRemoteDataSourceContract();
    mockLocalDataSource = MockCatalogLocalDataSource();
    mockCacheHelper = MockSecureCacheHelper();
    mockChatLocalDataSource = MockChatLocalDataSourceContract();
    mockCrashlyticsService = MockCrashlyticsService();

    when(
      mockCacheHelper.readData(key: anyNamed('key')),
    ).thenAnswer((_) async => null);

    when(
      mockChatLocalDataSource.getCachedUser(),
    ).thenAnswer((_) async => const SuccessBaseResponse(null));

    repo = ChatRepoImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockCacheHelper,
      mockChatLocalDataSource,
      mockCrashlyticsService,
    );

    when(
      mockChatLocalDataSource.getCachedUser(),
    ).thenAnswer((_) async => const SuccessBaseResponse<UserEntity?>(null));
  });

  const tSessionId = 'session_123';
  const tMessage = 'I want to lose weight';
  const tToken = 'valid_token';

  group('sendMessage', () {
    test('should execute defensive creation and stream responses', () async {
      // arrange
      when(
        mockCacheHelper.readData(key: AppKeys.tokenKey),
      ).thenAnswer((_) async => tToken);
      when(
        mockChatLocalDataSource.getSession(any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));
      when(
        mockChatLocalDataSource.saveSession(any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));
      when(
        mockChatLocalDataSource.updateSessionMessages(any, any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));

      final tEvent = ChatEventModel(type: 'token', content: 'You can ');
      when(
        mockRemoteDataSource.getChatResponseStream(
          message: anyNamed('message'),
          token: anyNamed('token'),
          userContext: anyNamed('userContext'),
        ),
      ).thenAnswer((_) => Stream.fromIterable([SuccessBaseResponse(tEvent)]));

      // act
      final stream = repo.sendMessage(sessionId: tSessionId, message: tMessage);

      // assert
      await expectLater(
        stream,
        emits(isA<SuccessBaseResponse<ChatMessageEntity>>()),
      );

      // Verify defensive session creation called because getSession returned null
      verify(
        mockChatLocalDataSource.saveSession(
          argThat(
            predicate((s) => s is ChatSessionHiveModel && s.id == tSessionId),
          ),
        ),
      ).called(1);
    });

    test(
      'should record error to crashlytics when remote stream fails',
      () async {
        // arrange
        when(
          mockCacheHelper.readData(key: AppKeys.tokenKey),
        ).thenAnswer((_) async => tToken);
        when(
          mockChatLocalDataSource.getSession(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        when(
          mockChatLocalDataSource.saveSession(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        when(
          mockChatLocalDataSource.updateSessionMessages(any, any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));

        when(
          mockRemoteDataSource.getChatResponseStream(
            message: anyNamed('message'),
            token: anyNamed('token'),
            userContext: anyNamed('userContext'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            const ErrorBaseResponse<ChatEventModel>('Stream Error'),
          ]),
        );

        // act
        final stream = repo.sendMessage(
          sessionId: tSessionId,
          message: tMessage,
        );
        final results = await stream.toList();

        // assert
        expect(results.last, isA<ErrorBaseResponse<ChatMessageEntity>>());
        verify(
          mockCrashlyticsService.recordError(
            'Stream Error',
            any,
            reason: anyNamed('reason'),
            information: anyNamed('information'),
          ),
        ).called(1);
      },
    );

    test(
      'should update local storage only on specific events (refs/done)',
      () async {
        // arrange
        when(
          mockCacheHelper.readData(key: AppKeys.tokenKey),
        ).thenAnswer((_) async => tToken);
        final tSession = ChatSessionHiveModel(
          id: tSessionId,
          title: 'T',
          messages: [],
          lastUpdatedAt: DateTime.now(),
        );
        when(
          mockChatLocalDataSource.getSession(any),
        ).thenAnswer((_) async => SuccessBaseResponse(tSession));
        when(
          mockChatLocalDataSource.updateSessionMessages(any, any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));

        final events = [
          ChatEventModel(type: 'token', content: 'T1'),
          ChatEventModel(type: 'refs', exerciseRefs: ['1']),
          ChatEventModel(type: 'done'),
        ];
        when(
          mockRemoteDataSource.getChatResponseStream(
            message: anyNamed('message'),
            token: anyNamed('token'),
            userContext: anyNamed('userContext'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable(events.map((e) => SuccessBaseResponse(e))),
        );

        when(
          mockLocalDataSource.getExercisesByIds(any),
        ).thenAnswer((_) async => []);

        // act
        final stream = repo.sendMessage(
          sessionId: tSessionId,
          message: tMessage,
        );
        await stream.toList();

        // assert
        // Should be called 1 (initial msg) + 1 (refs) + 1 (done) = 3 times.
        // The 'token' event should NOT trigger updateSessionMessages based on our optimization.
        verify(
          mockChatLocalDataSource.updateSessionMessages(tSessionId, any),
        ).called(3);
      },
    );
  });

  group('getChatHistory', () {
    test('should return mapped history list', () async {
      final tSessions = [
        ChatSessionHiveModel(
          id: '1',
          title: 'S1',
          messages: [],
          lastUpdatedAt: DateTime.now(),
        ),
      ];
      when(
        mockChatLocalDataSource.getSessions(),
      ).thenAnswer((_) async => SuccessBaseResponse(tSessions));

      final result = await repo.getChatHistory();

      expect(result, isA<SuccessBaseResponse<List<Map<String, String>>>>());
      final data =
          (result as SuccessBaseResponse<List<Map<String, String>>>).data!;
      expect(data.first['title'], 'S1');
    });
  });

  group('_hydrateRefs', () {
    test('should return hydrated refs when local data is found', () async {
      // arrange
      final tEvent = ChatEventModel(type: 'refs', exerciseRefs: const ['ex1']);

      const tLocalExercise = ExerciseModel(
        id: 'ex1',
        exercise: 'Local Exercise',
        shortYoutubeDemonstrationLink: 'http://youtube.com/v=123',
      );

      when(
        mockLocalDataSource.getExercisesByIds(['ex1']),
      ).thenAnswer((_) async => [tLocalExercise]);

      // act
      // Since _hydrateRefs is private, we test it through sendMessage if possible or use a trick.
      // But we can test it indirectly by observing the stream output of sendMessage when it emits refs.

      when(
        mockCacheHelper.readData(key: AppKeys.tokenKey),
      ).thenAnswer((_) async => tToken);
      when(
        mockChatLocalDataSource.getSession(any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));
      when(
        mockChatLocalDataSource.saveSession(any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));
      when(
        mockChatLocalDataSource.updateSessionMessages(any, any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));

      when(
        mockRemoteDataSource.getChatResponseStream(
          message: anyNamed('message'),
          token: anyNamed('token'),
          userContext: anyNamed('userContext'),
        ),
      ).thenAnswer((_) => Stream.fromIterable([SuccessBaseResponse(tEvent)]));

      // act
      final stream = repo.sendMessage(sessionId: tSessionId, message: tMessage);
      final results = await stream.toList();

      // assert
      final refMessage =
          (results.last as SuccessBaseResponse<ChatMessageEntity>).data;
      expect(refMessage?.refs.first.name, 'Local Exercise');
      expect(refMessage?.refs.first.isSnapshot, false);
      expect(refMessage?.refs.first.exerciseInfo?.id, 'ex1');
    });
  });
}
