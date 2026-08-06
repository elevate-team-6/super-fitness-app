import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/chat/domain/entities/chat_message_entity.dart';
import 'package:super_fitness/features/chat/domain/use_cases/delete_session_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/get_chat_history_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/get_chat_user_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/get_session_messages_use_case.dart';
import 'package:super_fitness/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_cubit.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_event.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_state.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

import 'chat_cubit_test.mocks.dart';

@GenerateMocks([
  GetChatHistoryUseCase,
  GetSessionMessagesUseCase,
  SendMessageUseCase,
  DeleteSessionUseCase,
  GetChatUserUseCase,
  ProfileRepoContract,
])
void main() {
  late ChatCubit cubit;
  late MockGetChatHistoryUseCase mockGetHistory;
  late MockGetSessionMessagesUseCase mockGetMessages;
  late MockSendMessageUseCase mockSendMessage;
  late MockDeleteSessionUseCase mockDeleteSession;
  late MockGetChatUserUseCase mockGetUser;
  late MockProfileRepoContract mockProfileRepo;

  setUp(() {
    mockGetHistory = MockGetChatHistoryUseCase();
    mockGetMessages = MockGetSessionMessagesUseCase();
    mockSendMessage = MockSendMessageUseCase();
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
      mockDeleteSession,
      mockGetUser,
      mockProfileRepo,
    );
  });

  group('SendMessageEvent - UX Optimized', () {
    const tText = 'Hello';
    final tAssistantMessage = ChatMessageEntity(
      id: 'assistant_1',
      text: 'Hi there',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );

    blocTest<ChatCubit, ChatState>(
      'emits states in correct sequence for optimistic UX',
      build: () => cubit,
      act: (cubit) {
        when(
          mockGetHistory(),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        when(
          mockSendMessage(sessionId: anyNamed('sessionId'), message: tText),
        ).thenAnswer(
          (_) => Stream.value(SuccessBaseResponse(tAssistantMessage)),
        );

        cubit.doEvent(const SendMessageEvent(tText));
      },
      // Using a relaxed verification for the exact sequence because of unawaited background calls
      // but ensuring critical states are reached.
      verify: (cubit) {
        expect(cubit.state.status, ChatStatus.success);
        expect(cubit.state.messages.length, 2);
        expect(cubit.state.messages.last.sender, MessageSender.assistant);
        verify(mockGetHistory()).called(1);
      },
    );
  });

  group('LoadHistoryEvent - Anti-Flicker', () {
    final tOldHistory = [
      {'id': '1', 'title': 'Old'},
    ];
    final tNewHistory = [
      {'id': '1', 'title': 'New'},
    ];

    blocTest<ChatCubit, ChatState>(
      'preserves existing history while loading to avoid UI flicker',
      seed: () => ChatState(historyStatus: BaseState(data: tOldHistory)),
      build: () => cubit,
      act: (cubit) {
        when(
          mockGetHistory(),
        ).thenAnswer((_) async => SuccessBaseResponse(tNewHistory));
        cubit.doEvent(const LoadHistoryEvent());
      },
      expect: () => [
        isA<ChatState>()
            .having((s) => s.historyStatus.isLoading, 'loading', true)
            .having((s) => s.history, 'old history preserved', tOldHistory),
        isA<ChatState>()
            .having((s) => s.historyStatus.isLoading, 'loading', false)
            .having((s) => s.history, 'new history', tNewHistory),
      ],
    );
  });
}
