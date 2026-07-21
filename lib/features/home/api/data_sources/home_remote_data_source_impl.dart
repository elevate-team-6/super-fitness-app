import 'package:injectable/injectable.dart';

import '../../data/data_sources/home_remote_data_source_contract.dart';
import '../api_client/home_api_client.dart';

@Injectable(as: HomeRemoteDataSourceContract)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSourceContract {
  // ignore: unused_field
  final HomeApiClient _apiClient;

  const HomeRemoteDataSourceImpl(this._apiClient);
}
