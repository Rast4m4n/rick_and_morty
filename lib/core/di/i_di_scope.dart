import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/core/storage/i_data_storage.dart';
import 'package:rick_and_morty/data/repository/character_repository.dart';

abstract interface class IDiScope {
  Future<void> init();
  IDataStorage get localStorage;
  IDataStorage get dbStorage;
  IApi get api;
  IRepository get repository;
}
