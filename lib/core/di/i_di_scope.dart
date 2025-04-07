import 'package:rick_and_morty/core/api/I_api.dart';
import 'package:rick_and_morty/core/storage/i_data_storage.dart';

abstract class IDiScope {
  Future<void> init();
  IDataStorage get storage;
  IApi get api;
}
