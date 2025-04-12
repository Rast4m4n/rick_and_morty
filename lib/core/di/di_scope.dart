import 'package:rick_and_morty/core/api/character_api.dart';
import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/core/di/i_di_scope.dart';
import 'package:rick_and_morty/core/storage/i_data_storage.dart';
import 'package:rick_and_morty/core/storage/shared_pref_storage.dart';
import 'package:rick_and_morty/core/storage/sql_database.dart';
import 'package:rick_and_morty/data/repository/character_repository.dart';

class DiScope implements IDiScope {
  @override
  Future<void> init() async {
    _localDataStorage = SharedPrefStorage();
    await _localDataStorage.init();
    _dbStorage = SqlDatabase();
    await _dbStorage.init();
    _api = CharacterApi();
    _iRepository = CharacterRepository(
      iApi: _api,
      iDbStorage: _dbStorage,
      iLocalStorage: _localDataStorage,
    );
  }

  @override
  IDataStorage get localStorage => _localDataStorage;
  late final IDataStorage _localDataStorage;

  @override
  IDataStorage get dbStorage => _dbStorage;
  late final IDataStorage _dbStorage;

  @override
  IApi get api => _api;
  late final IApi _api;

  @override
  IRepository get repository => _iRepository;
  late final IRepository _iRepository;
}
