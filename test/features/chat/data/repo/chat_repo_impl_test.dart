import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/services/crashlytics_service.dart';
import 'package:super_fitness/core/data/local/sqlite/catalog_local_data_source.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/chat/data/data_sources/contracts/chat_history_data_source_contract.dart';
import 'package:super_fitness/features/chat/data/data_sources/contracts/chat_local_data_source_contract.dart';
import 'package:super_fitness/features/chat/data/data_sources/contracts/chat_remote_data_source_contract.dart';
import 'package:super_fitness/features/chat/data/models/chat_event_model.dart';
import 'package:super_fitness/features/chat/data/models/chat_models.dart';
import 'package:super_fitness/features/chat/data/repo/chat_repo_impl.dart';
import 'package:super_fitness/features/chat/domain/entities/chat_message_entity.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';

import 'chat_repo_impl_test.mocks.dart';

@GenerateMocks([
  ChatRemoteDataSourceContract,
  CatalogLocalDataSource,
  ChatLocalDataSourceContract,
  ChatHistoryDataSourceContract,
  CrashlyticsService,
])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<UserEntity?>>(
      const SuccessBaseResponse<UserEntity?>(null),
    );
    provideDummy<BaseResponse<ChatSessionModel?>>(
      const SuccessBaseResponse<ChatSessionModel?>(null),
    );
    provideDummy<BaseResponse<void>>(const SuccessBaseResponse<void>(null));
    provideDummy<BaseResponse<List<ChatSessionModel>>>(
      const SuccessBaseResponse<List<ChatSessionModel>>([]),
    );
    provideDummy<BaseResponse<List<ExerciseModel>>>(
      const SuccessBaseResponse<List<ExerciseModel>>([]),
    );
  });

  late MockChatRemoteDataSourceContract mockRemoteDataSource;
  late MockCatalogLocalDataSource mockLocalDataSource;
  late MockChatLocalDataSourceContract mockChatLocalDataSource;
  late MockChatHistoryDataSourceContract mockChatHistoryDataSource;
  late MockCrashlyticsService mockCrashlyticsService;
  late ChatRepoImpl repo;

  setUp(() {
    mockRemoteDataSource = MockChatRemoteDataSourceContract();
    mockLocalDataSource = MockCatalogLocalDataSource();
    mockChatLocalDataSource = MockChatLocalDataSourceContract();
    mockChatHistoryDataSource = MockChatHistoryDataSourceContract();
    mockCrashlyticsService = MockCrashlyticsService();

    when(
      mockChatLocalDataSource.getCachedUser(),
    ).thenAnswer((_) async => const SuccessBaseResponse(null));

    repo = ChatRepoImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockChatLocalDataSource,
      mockChatHistoryDataSource,
      mockCrashlyticsService,
    );
  });

  const tSessionId = 'session_123';
  const tMessage = 'I want to lose weight';

  group('sendMessage', () {
    test('should execute parallel IO and background sync', () async {
      // arrange
      when(
        mockChatHistoryDataSource.getSession(any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));
      when(
        mockChatHistoryDataSource.saveSession(any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));
      when(
        mockChatHistoryDataSource.updateSessionMessages(any, any),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));

      final tEvent = ChatEventModel(type: 'token', content: 'Sure');
      when(
        mockRemoteDataSource.getChatResponseStream(
          history: anyNamed('history'),
          userContext: anyNamed('userContext'),
        ),
      ).thenAnswer((_) => Stream.fromIterable([SuccessBaseResponse(tEvent)]));

      // act
      final stream = repo.sendMessage(sessionId: tSessionId, message: tMessage);
      await stream.toList();

      // assert
      // Verify parallel call to get session and user cache
      verify(mockChatLocalDataSource.getCachedUser()).called(1);
      verify(mockChatHistoryDataSource.getSession(tSessionId)).called(1);

      // Verify background sync triggered
      verify(mockChatHistoryDataSource.saveSession(any)).called(1);
    });

    test(
      'should record error to crashlytics when remote stream fails',
      () async {
        // arrange
        when(
          mockChatHistoryDataSource.getSession(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        when(
          mockChatHistoryDataSource.saveSession(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));

        when(
          mockRemoteDataSource.getChatResponseStream(
            history: anyNamed('history'),
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
        verify(mockCrashlyticsService.recordError(any, any)).called(1);
      },
    );
  });

  group('getChatHistory', () {
    test('should return history from history data source', () async {
      // arrange
      final tSessions = [
        ChatSessionModel(
          id: '1',
          title: 'S1',
          messages: [],
          lastUpdatedAt: DateTime.now(),
        ),
      ];
      when(
        mockChatHistoryDataSource.getSessions(),
      ).thenAnswer((_) async => SuccessBaseResponse(tSessions));

      // act
      final result = await repo.getChatHistory();

      // assert
      expect(result, isA<SuccessBaseResponse<List<Map<String, String>>>>());
      verify(mockChatHistoryDataSource.getSessions()).called(1);
    });
  });
}
