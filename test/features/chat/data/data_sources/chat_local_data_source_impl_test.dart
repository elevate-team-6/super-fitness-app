import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/features/chat/data/data_sources/local/chat_local_data_source_impl.dart';
import 'package:super_fitness/features/chat/data/models/hive/chat_hive_models.dart';

import 'chat_local_data_source_impl_test.mocks.dart';

@GenerateMocks([Box, SecureCacheHelper])
void main() {
  late ChatLocalDataSourceImpl dataSource;
  late MockBox<Map> mockBox;
  late MockSecureCacheHelper mockCacheHelper;

  setUp(() {
    mockBox = MockBox<Map>();
    mockCacheHelper = MockSecureCacheHelper();
    dataSource = ChatLocalDataSourceImpl(mockCacheHelper)..testBox = mockBox;
  });

  final tSession = ChatSessionHiveModel(
    id: 'session_1',
    title: 'Test Session',
    messages: [],
    lastUpdatedAt: DateTime.parse('2026-07-30T10:00:00Z'),
  );

  group('saveSession', () {
    test('should return SuccessBaseResponse when put is successful', () async {
      when(mockBox.put(any, any)).thenAnswer((_) async => {});

      final result = await dataSource.saveSession(tSession);

      expect(result, isA<SuccessBaseResponse<void>>());
      verify(mockBox.put(tSession.id, any)).called(1);
    });

    test('should return ErrorBaseResponse when put fails', () async {
      when(mockBox.put(any, any)).thenThrow(Exception('Hive Error'));

      final result = await dataSource.saveSession(tSession);

      expect(result, isA<ErrorBaseResponse<void>>());
    });
  });

  group('getSessions', () {
    test('should return sorted sessions by date (descending)', () async {
      final oldSession = ChatSessionHiveModel(
        id: 'old',
        title: 'Old',
        messages: [],
        lastUpdatedAt: DateTime.parse('2026-07-20T10:00:00Z'),
      );
      final newSession = ChatSessionHiveModel(
        id: 'new',
        title: 'New',
        messages: [],
        lastUpdatedAt: DateTime.parse('2026-07-30T10:00:00Z'),
      );

      when(
        mockBox.values,
      ).thenReturn([oldSession.toJson(), newSession.toJson()]);

      final result = await dataSource.getSessions();

      expect(result, isA<SuccessBaseResponse<List<ChatSessionHiveModel>>>());
      final data =
          (result as SuccessBaseResponse<List<ChatSessionHiveModel>>).data;
      expect(data?.first.id, 'new');
      expect(data?.last.id, 'old');
    });
  });

  group('updateSessionMessages', () {
    test('should update messages for existing session', () async {
      when(mockBox.get(any)).thenReturn(tSession.toJson());
      when(mockBox.put(any, any)).thenAnswer((_) async => {});

      final newMessages = [
        ChatMessageHiveModel(
          id: 'msg_1',
          text: 'Hi',
          sender: 'user',
          refs: [],
          isDegraded: false,
          timestamp: DateTime.now(),
        ),
      ];

      final result = await dataSource.updateSessionMessages(
        'session_1',
        newMessages,
      );

      expect(result, isA<SuccessBaseResponse<void>>());
      verify(mockBox.get('session_1')).called(1);
      verify(mockBox.put('session_1', any)).called(1);
    });

    test('should return error if session does not exist', () async {
      when(mockBox.get(any)).thenReturn(null);

      final result = await dataSource.updateSessionMessages('none', []);

      expect(result, isA<ErrorBaseResponse<void>>());
      verifyNever(mockBox.put(any, any));
    });
  });

  group('deleteSession', () {
    test('should call delete on box', () async {
      when(mockBox.delete(any)).thenAnswer((_) async => {});

      final result = await dataSource.deleteSession('id');

      expect(result, isA<SuccessBaseResponse<void>>());
      verify(mockBox.delete('id')).called(1);
    });
  });
}
