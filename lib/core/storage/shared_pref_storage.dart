import 'dart:convert';

import 'package:rick_and_morty/core/storage/i_data_storage.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class _KeyStorage {
  static const favorites = 'favoriteCharacters';
}

class SharedPrefStorage implements IDataStorage {
  SharedPrefStorage._internal();

  @override
  Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  static SharedPrefStorage get _instance => SharedPrefStorage._internal();
  late final SharedPreferences _pref;

  factory SharedPrefStorage() {
    return _instance;
  }

  @override
  Future<void> cacheCharacters(ApiResponse response, int page) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse?> loadCacheCharacters(int page) async {
    throw UnimplementedError();
  }

  @override
  Future<void> makeFavoriteOrRemoveCharacter(CharacterModel character) async {
    if (character.isFavorite) {
      await _saveFavoriteCharacter(character);
    } else {
      await _removeFavoriteCharacter(character);
    }
  }

  Future<void> _saveFavoriteCharacter(CharacterModel character) async {
    final characters = await loadFavoriteCharacter();
    characters.add(character.copyWith(isFavorite: true));
    final jsonList = characters.map((c) => c.toMap()).toList();
    await _pref.setString(_KeyStorage.favorites, jsonEncode(jsonList));
  }

  Future<void> _removeFavoriteCharacter(CharacterModel character) async {
    final characters = await loadFavoriteCharacter();
    characters.removeWhere((favorite) => favorite.id == character.id);
    final jsonList = characters.map((c) => c.toMap()).toList();
    await _pref.setString(_KeyStorage.favorites, jsonEncode(jsonList));
  }

  @override
  Future<List<CharacterModel>> loadFavoriteCharacter() async {
    try {
      final data = _pref.getString(_KeyStorage.favorites);
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
