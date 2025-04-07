import 'package:rick_and_morty/core/di/i_di_scope.dart';
import 'package:rick_and_morty/core/storage/i_data_storage.dart';
import 'package:rick_and_morty/core/storage/shared_pref_storage.dart';

class DiScope implements IDiScope {
  @override
  Future<void> init() async {
    _dataStorage = SharedPrefStorage();
  }

  @override
  IDataStorage get storage => _dataStorage;
  late final IDataStorage _dataStorage;

  @override
  // TODO: implement api
  get api => throw UnimplementedError();
}
