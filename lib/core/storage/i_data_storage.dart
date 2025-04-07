abstract class IDataStorage {
  Future<void> saveFavoriteCharacter();
  Future<T?> loadFavoriteCharacter<T>();
  Future<void> cacheCharacter();
  Future<T?> loadCacheCharacter<T>();
}
