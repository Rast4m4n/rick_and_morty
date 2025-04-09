import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

abstract class IDataStorage {
  Future<void> init();
  Future<void> makeFavoriteOrRemoveCharacter(CharacterModel character);
  Future<List<CharacterModel>> loadFavoriteCharacter();
  Future<void> cacheCharacters(ApiResponse response, int page);
  Future<ApiResponse?> loadCacheCharacters(int page);
}
