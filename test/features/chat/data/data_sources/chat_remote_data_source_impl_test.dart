import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/services/crashlytics_service.dart';
import 'package:super_fitness/features/chat/api/api_client/chat_api_client.dart';
import 'package:super_fitness/features/chat/api/data_sources/chat_remote_data_source_impl.dart';
import 'package:super_fitness/features/chat/data/models/chat_event_model.dart';

import 'chat_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ChatApiClient, CrashlyticsService])
void main() {
  late ChatRemoteDataSourceImpl dataSource;
  late MockChatApiClient mockApiClient;
  late MockCrashlyticsService mockCrashlyticsService;

  setUp(() {
    mockApiClient = MockChatApiClient();
    mockCrashlyticsService = MockCrashlyticsService();
    dataSource = ChatRemoteDataSourceImpl(
      mockApiClient,
      mockCrashlyticsService,
    );
  });

  const tMessage = "Hello";
  const tToken = "fake_token";
  final tUserContext = {"name": "Test User"};

  group('getChatResponseStream', () {
    test(
      'should yield SuccessBaseResponse<ChatEventModel> when the stream is successful',
      () async {
        // arrange
        final sseData = [
          'data: {"type": "token", "content": "Hello"}\n\n',
          'data: {"type": "done"}\n\n',
        ];
        final byteStream = Stream.fromIterable(
          sseData.map((e) => utf8.encode(e)),
        );
        final response = http.StreamedResponse(byteStream, 200);

        when(
          mockApiClient.getChatResponse(
            message: anyNamed('message'),
            token: anyNamed('token'),
            userContext: anyNamed('userContext'),
          ),
        ).thenAnswer((_) async => response);

        // act
        final result = dataSource.getChatResponseStream(
          message: tMessage,
          token: tToken,
          userContext: tUserContext,
        );

        // assert
        expect(
          result,
          emitsInOrder([
            isA<SuccessBaseResponse<ChatEventModel>>().having(
              (r) => r.data?.type,
              'type',
              'token',
            ),
            isA<SuccessBaseResponse<ChatEventModel>>().having(
              (r) => r.data?.type,
              'type',
              'done',
            ),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'should yield ErrorBaseResponse when status code is not 200',
      () async {
        // arrange
        final response = http.StreamedResponse(const Stream.empty(), 400);

        when(
          mockApiClient.getChatResponse(
            message: anyNamed('message'),
            token: anyNamed('token'),
            userContext: anyNamed('userContext'),
          ),
        ).thenAnswer((_) async => response);

        // act
        final result = dataSource.getChatResponseStream(
          message: tMessage,
          token: tToken,
        );

        // assert
        expect(
          result,
          emitsInOrder([isA<ErrorBaseResponse<ChatEventModel>>(), emitsDone]),
        );
      },
    );

    test(
      'should yield ErrorBaseResponse and continue when JSON is malformed',
      () async {
        // arrange
        final sseData = [
          'data: invalid_json\n\n',
          'data: {"type": "done"}\n\n',
        ];
        final byteStream = Stream.fromIterable(
          sseData.map((e) => utf8.encode(e)),
        );
        final response = http.StreamedResponse(byteStream, 200);

        when(
          mockApiClient.getChatResponse(
            message: anyNamed('message'),
            token: anyNamed('token'),
            userContext: anyNamed('userContext'),
          ),
        ).thenAnswer((_) async => response);

        // act
        final result = dataSource.getChatResponseStream(
          message: tMessage,
          token: tToken,
        );

        // assert
        await expectLater(
          result,
          emitsInOrder([
            isA<ErrorBaseResponse<ChatEventModel>>(),
            isA<SuccessBaseResponse<ChatEventModel>>().having(
              (r) => r.data?.type,
              'type',
              'done',
            ),
            emitsDone,
          ]),
        );
        verify(
          mockCrashlyticsService.recordError(
            any,
            any,
            reason: anyNamed('reason'),
          ),
        ).called(1);
      },
    );

    test(
      'should yield ErrorBaseResponse when the stream is empty (no SSE data)',
      () async {
        // arrange
        final byteStream = Stream.fromIterable([utf8.encode('\n\n')]);
        final response = http.StreamedResponse(byteStream, 200);

        when(
          mockApiClient.getChatResponse(
            message: anyNamed('message'),
            token: anyNamed('token'),
            userContext: anyNamed('userContext'),
          ),
        ).thenAnswer((_) async => response);

        // act
        final result = dataSource.getChatResponseStream(
          message: tMessage,
          token: tToken,
        );

        // assert
        await expectLater(
          result,
          emitsInOrder([
            isA<ErrorBaseResponse<ChatEventModel>>().having(
              (r) => r.errorMessage,
              'message',
              contains('coachIsBusy'), // Key from AppStrings
            ),
            emitsDone,
          ]),
        );
      },
    );

    test('should yield ErrorBaseResponse when an exception occurs', () async {
      // arrange
      when(
        mockApiClient.getChatResponse(
          message: anyNamed('message'),
          token: anyNamed('token'),
          userContext: anyNamed('userContext'),
        ),
      ).thenThrow(Exception('Connection lost'));

      // act
      final result = dataSource.getChatResponseStream(
        message: tMessage,
        token: tToken,
      );

      // assert
      await expectLater(
        result,
        emitsInOrder([isA<ErrorBaseResponse<ChatEventModel>>(), emitsDone]),
      );
      verify(
        mockCrashlyticsService.recordError(
          any,
          any,
          reason: anyNamed('reason'),
        ),
      ).called(1);
    });
  });
}
