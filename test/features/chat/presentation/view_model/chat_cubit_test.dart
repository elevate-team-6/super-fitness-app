import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/chat/domain/entities/chat_message_entity.dart';
import 'package:super_fitness/features/chat/domain/use_cases/create_session_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/delete_session_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/get_chat_history_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/get_chat_user_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/get_session_messages_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/update_session_title_use_case.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_cubit.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_event.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_state.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

import 'chat_cubit_test.mocks.dart';

@GenerateMocks([
  GetChatHistoryUseCase,
  GetSessionMessagesUseCase,
  SendMessageUseCase,
  CreateSessionUseCase,
  DeleteSessionUseCase,
  UpdateSessionTitleUseCase,
  GetChatUserUseCase,
  ProfileRepoContract,
])
void main() {
  late ChatCubit cubit;
  late MockGetChatHistoryUseCase mockGetHistory;
  late MockGetSessionMessagesUseCase mockGetMessages;
  late MockSendMessageUseCase mockSendMessage;
  late MockCreateSessionUseCase mockCreateSession;
  late MockDeleteSessionUseCase mockDeleteSession;
  late MockGetChatUserUseCase mockGetUser;
  late MockProfileRepoContract mockProfileRepo;

  setUp(() {
    mockGetHistory = MockGetChatHistoryUseCase();
    mockGetMessages = MockGetSessionMessagesUseCase();
    mockSendMessage = MockSendMessageUseCase();
    mockCreateSession = MockCreateSessionUseCase();
    mockDeleteSession = MockDeleteSessionUseCase();
    mockGetUser = MockGetChatUserUseCase();
    mockProfileRepo = MockProfileRepoContract();

    provideDummy<BaseResponse<List<Map<String, String>>>>(
      const SuccessBaseResponse([]),
    );
    provideDummy<BaseResponse<List<ChatMessageEntity>>>(
      const SuccessBaseResponse([]),
    );
    provideDummy<BaseResponse<void>>(const SuccessBaseResponse(null));
    provideDummy<BaseResponse<ChatMessageEntity>>(ErrorBaseResponse('dummy'));

    when(mockGetUser()).thenAnswer((_) async => null);
    when(mockProfileRepo.userStream).thenAnswer((_) => const Stream.empty());

    cubit = ChatCubit(
      mockGetHistory,
      mockGetMessages,
      mockSendMessage,
      mockCreateSession,
      mockDeleteSession,
      mockGetUser,
      mockProfileRepo,
    );
  });

  group('Reactive Profile Updates', () {
    const tUser = UserEntity(id: '1', firstName: 'Updated', lastName: 'Name');

    blocTest<ChatCubit, ChatState>(
      'updates user state when profileRepo.userStream emits a new user',
      build: () {
        when(mockProfileRepo.userStream).thenAnswer((_) => Stream.value(tUser));
        return ChatCubit(
          mockGetHistory,
          mockGetMessages,
          mockSendMessage,
          mockCreateSession,
          mockDeleteSession,
          mockGetUser,
          mockProfileRepo,
        );
      },
      expect: () => [
        isA<ChatState>().having(
          (s) => s.user,
          'initial user from load',
          isNull,
        ),
        isA<ChatState>().having(
          (s) => s.user,
          'updated user from stream',
          tUser,
        ),
      ],
    );
  });

  group('StartNewSessionEvent', () {
    blocTest<ChatCubit, ChatState>(
      'should clear session and messages in state',
      seed: () => const ChatState(currentSessionId: 'old-session'),
      build: () => cubit,
      act: (cubit) => cubit.doEvent(const StartNewSessionEvent()),
      expect: () => [
        isA<ChatState>().having(
          (s) => s.currentSessionId,
          'currentSessionId',
          isNull,
        ),
      ],
    );
  });

  group('LoadHistoryEvent', () {
    final tHistory = [
      {'id': '1', 'title': 'T1'},
    ];

    blocTest<ChatCubit, ChatState>(
      'should load history and update state',
      seed: () => const ChatState(historyStatus: BaseState(isLoading: false)),
      build: () => cubit,
      act: (cubit) {
        when(
          mockGetHistory(),
        ).thenAnswer((_) async => SuccessBaseResponse(tHistory));
        cubit.doEvent(const LoadHistoryEvent());
      },
      expect: () => [
        isA<ChatState>().having(
          (s) => s.historyStatus.isLoading,
          'loading',
          true,
        ),
        isA<ChatState>().having((s) => s.history, 'history', tHistory),
      ],
    );
  });

  group('SendMessageEvent', () {
    const tText = 'Hello';
    final tMessage = ChatMessageEntity(
      id: '1',
      text: tText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    blocTest<ChatCubit, ChatState>(
      'should handle first message by creating session then streaming',
      build: () => cubit,
      act: (cubit) {
        when(
          mockCreateSession(any, any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        when(
          mockGetHistory(),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        when(
          mockSendMessage(sessionId: anyNamed('sessionId'), message: tText),
        ).thenAnswer(
          (_) => Stream.fromIterable([SuccessBaseResponse(tMessage)]),
        );

        cubit.doEvent(const SendMessageEvent(tText));
      },
      expect: () => [
        isA<ChatState>().having(
          (s) => s.currentSessionId,
          'currentSessionId',
          isNotNull,
        ),
        // historyStatus.isLoading: true is already the case, so it's not emitted again.
        isA<ChatState>().having(
          (s) => s.historyStatus.isLoading,
          'history loaded',
          false,
        ),
        isA<ChatState>().having((s) => s.status, 'loading', ChatStatus.loading),
        isA<ChatState>().having(
          (s) => s.status,
          'streaming',
          ChatStatus.streaming,
        ),
        isA<ChatState>().having((s) => s.status, 'success', ChatStatus.success),
      ],
    );
  });

  group('DeleteSessionEvent', () {
    const tId = '1';

    blocTest<ChatCubit, ChatState>(
      'should call use case and reload history',
      seed: () => const ChatState(historyStatus: BaseState(isLoading: false)),
      build: () => cubit,
      act: (cubit) {
        when(
          mockDeleteSession(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        when(
          mockGetHistory(),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        cubit.doEvent(const DeleteSessionEvent(tId));
      },
      expect: () => [
        isA<ChatState>().having(
          (s) => s.historyStatus.isLoading,
          'history loading',
          true,
        ),
        isA<ChatState>().having(
          (s) => s.historyStatus.isLoading,
          'history loaded',
          false,
        ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'should emit DisplayErrorEvent when delete fails',
      build: () => cubit,
      act: (cubit) {
        when(
          mockDeleteSession(any),
        ).thenAnswer((_) async => const ErrorBaseResponse('Delete Failed'));
        cubit.doEvent(const DeleteSessionEvent(tId));
      },
      verify: (cubit) {
        expectLater(
          cubit.eventStream,
          emitsThrough(
            isA<DisplayErrorEvent>().having(
              (e) => e.errorMessage,
              'msg',
              'Delete Failed',
            ),
          ),
        );
      },
    );
  });
}
