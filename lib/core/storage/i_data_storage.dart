import 'package:rick_and_morty/domain/models/character_model.dart';

abstract class ILocalDataStorage {
  Future<void> saveFavoriteCharacter(CharacterModel character);
  Future<void> removeFavoriteCharacter(CharacterModel character);
  Future<List<CharacterModel>> loadFavoriteCharacter();
  Future<void> cacheCharacter(List<CharacterModel> characters);
  Future<List<CharacterModel>> loadCacheCharacter();
}
