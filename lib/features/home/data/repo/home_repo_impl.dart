import 'package:injectable/injectable.dart';

import '../../domain/repo/home_repo_contract.dart';
import '../data_sources/home_remote_data_source_contract.dart';

@Injectable(as: HomeRepoContract)
class HomeRepoImpl implements HomeRepoContract {
  // ignore: unused_field
  final HomeRemoteDataSourceContract _homeRemoteDataSourceContract;

  HomeRepoImpl(this._homeRemoteDataSourceContract);
}
