import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/profile/api/data_sources/profile_local_data_source_impl.dart';

import 'profile_local_data_source_impl_test.mocks.dart';

@GenerateMocks([SecureCacheHelper])
void main() {
  late MockSecureCacheHelper cache;
  late ProfileLocalDataSourceImpl dataSource;

  const storedUser = {
    '_id': 'user_123',
    'firstName': 'Ahmed',
    'lastName': 'Emam',
    'email': 'ahmed@example.com',
    'gender': 'male',
    'age': 25,
  };

  setUp(() {
    cache = MockSecureCacheHelper();
    dataSource = ProfileLocalDataSourceImpl(cache);
  });

  void stubCache(String? value) {
    when(
      cache.readData(key: AppKeys.userDataKey),
    ).thenAnswer((_) async => value);
  }

  test('decodes the stored user', () async {
    stubCache(jsonEncode(storedUser));

    final user = await dataSource.getCachedUser();

    expect(user?.id, 'user_123');
    expect(user?.firstName, 'Ahmed');
    expect(user?.lastName, 'Emam');
    expect(user?.email, 'ahmed@example.com');
    expect(user?.age, 25);
    verify(cache.readData(key: AppKeys.userDataKey)).called(1);
  });

  test('returns null when nothing is stored', () async {
    stubCache(null);

    expect(await dataSource.getCachedUser(), isNull);
  });

  test('returns null on an empty entry', () async {
    stubCache('');

    expect(await dataSource.getCachedUser(), isNull);
  });

  // A payload written by an older build has to read as "no user" rather than
  // throw — the profile tab has no way to recover from a parse error.
  test('returns null instead of throwing on an unreadable entry', () async {
    stubCache('not json at all');

    expect(await dataSource.getCachedUser(), isNull);
  });

  test(
    'returns null when the entry is valid JSON of the wrong shape',
    () async {
      stubCache(jsonEncode(['not', 'an', 'object']));

      expect(await dataSource.getCachedUser(), isNull);
    },
  );
}
