import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/core/storage/i_data_storage.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

abstract interface class IRepository {
  Future<ApiResponse> getCharacter({
    int page = 1,
    String? species,
    String? status,
    String? gender,
  });
  Future<void> makeFavoriteOrRemoveCharacter(CharacterModel character);
  Future<List<CharacterModel>> getFavoriteCharacters();
}

class CharacterRepository implements IRepository {
  CharacterRepository({
    required IApi iApi,
    required IDataStorage iDbStorage,
    required IDataStorage iLocalStorage,
  }) : _iDbStorage = iDbStorage,
       _iApi = iApi,
       _iLocalStorage = iLocalStorage;

  final IApi _iApi;
  final IDataStorage _iDbStorage;
  final IDataStorage _iLocalStorage;

  /// Получаю api и кешируем данные.
  /// Если нет доступа к сети выводит
  /// данные из кеша
  @override
  Future<ApiResponse> getCharacter({
    int page = 1,
    String? species,
    String? status,
    String? gender,
  }) async {
    try {
      final api = await _iApi.getCharacter(
        page: page,
        species: species,
        status: status,
        gender: gender,
      );
      await _iDbStorage.cacheCharacters(api, page);
      return api;
    } on DioException catch (e) {
      final cached = await _iDbStorage.loadCacheCharacters(page);
      if (cached != null) {
        return cached;
      }
      throw Exception('Ошибка загрузки персонажей из кеша: $e');
    }
  }

  @override
  Future<void> makeFavoriteOrRemoveCharacter(CharacterModel character) async =>
      await _iLocalStorage.makeFavoriteOrRemoveCharacter(character);

  @override
  Future<List<CharacterModel>> getFavoriteCharacters() async =>
      await _iLocalStorage.loadFavoriteCharacter();
}
