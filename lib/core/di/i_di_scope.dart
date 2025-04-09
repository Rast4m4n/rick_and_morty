import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/core/storage/i_data_storage.dart';

abstract class IDiScope {
  Future<void> init();
  ILocalDataStorage get localStorage;
  IApi get api;
}
