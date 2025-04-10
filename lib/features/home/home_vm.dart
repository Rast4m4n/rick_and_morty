import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/data/repository/character_repository.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({required this.repository})
    : apiResponse = repository.getCharacter(page: 1);

  int currentPage = 1;
  Future<ApiResponse> apiResponse;
  final IRepository repository;
  List<CharacterModel> _favoriteCharacters = [];

  Future<void> loadFavorites(BuildContext context) async {
    _favoriteCharacters =
        await DiScopeProvider.of(context)!.localStorage.loadFavoriteCharacter();
    notifyListeners();
  }

  void loadPage(int page) {
    currentPage = page;
    // Подгружаю данные с api, затем подменяю элементы в списке,
    // которые были сохранены в избранные
    apiResponse = repository.getCharacter(page: currentPage).then((response) {
      final updateResonse =
          response.results.map((character) {
            final isFavorite = _favoriteCharacters.any(
              (favorite) => favorite.id == character.id,
            );
            return character.copyWith(isFavorite: isFavorite);
          }).toList();
      return response.copyWith(results: updateResonse);
    });
    notifyListeners();
  }

  void doIsFavorite(CharacterModel character, context) async {
    final apiResponse = await this.apiResponse;
    final index = apiResponse.results.indexOf(character);
    final updateCharacter = character.copyWith(
      isFavorite: !character.isFavorite,
    );
    apiResponse.results[index] = updateCharacter;

    await DiScopeProvider.of(
      context,
    )!.iRepository.makeFavoriteOrRemoveCharacter(updateCharacter);

    if (updateCharacter.isFavorite) {
      _favoriteCharacters.add(updateCharacter);
    } else {
      _favoriteCharacters.removeWhere((c) => c.id == updateCharacter.id);
    }

    notifyListeners();
  }
}
