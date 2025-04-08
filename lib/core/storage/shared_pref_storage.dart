import 'package:rick_and_morty/core/storage/i_data_storage.dart';

class SharedPrefStorage implements IDataStorage {
  @override
  Future<void> cacheCharacter() {
    throw UnimplementedError();
  }

  @override
  Future<T?> loadCacheCharacter<T>() {
    throw UnimplementedError();
  }

  @override
  Future<T?> loadFavoriteCharacter<T>() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveFavoriteCharacter() {
    throw UnimplementedError();
  }
}
