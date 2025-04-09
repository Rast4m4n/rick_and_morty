import 'dart:convert';

import 'package:rick_and_morty/core/storage/i_data_storage.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class _KeyStorage {
  static const favorites = 'favoriteCharacters';
  static const cache = 'cachedCharacters';
}

class SharedPrefStorage implements ILocalDataStorage {
  SharedPrefStorage._internal() {
    _pref = SharedPreferences.getInstance();
  }

  static SharedPrefStorage get _instance => SharedPrefStorage._internal();
  late final Future<SharedPreferences> _pref;

  factory SharedPrefStorage() {
    return _instance;
  }

  @override
  Future<void> cacheCharacter(List<CharacterModel> characters) async {
    throw UnimplementedError();
  }

  @override
  Future<List<CharacterModel>> loadCacheCharacter() async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveFavoriteCharacter(CharacterModel character) async {
    final characters = await loadFavoriteCharacter();
    characters.add(character.copyWith(isFavorite: true));
    final jsonList = characters.map((c) => c.toMap()).toList();
    await (await _pref).setString(_KeyStorage.favorites, jsonEncode(jsonList));
  }

  @override
  Future<void> removeFavoriteCharacter(CharacterModel character) async {
    final characters = await loadFavoriteCharacter();
    characters.removeWhere((favorite) => favorite.id == character.id);
    final jsonList = characters.map((c) => c.toMap()).toList();
    await (await _pref).setString(_KeyStorage.favorites, jsonEncode(jsonList));
  }

  @override
  Future<List<CharacterModel>> loadFavoriteCharacter() async {
    try {
      final data = (await _pref).getString(_KeyStorage.favorites);
      if (data == null || data.isEmpty) return [];

      final json = jsonDecode(data) as List;
      return json
          .map(
            (character) =>
                CharacterModel.fromJson(character as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки избранных персонажей с хранилища: $e');
    }
  }
}
