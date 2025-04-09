import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({required this.iApi})
    : apiResponse = iApi.getCharacter(page: 1);

  int currentPage = 1;
  Future<ApiResponse> apiResponse;
  final IApi iApi;
  List<CharacterModel> _favoriteCharacters = [];

  Future<void> loadFavorites(BuildContext context) async {
    _favoriteCharacters =
        await DiScopeProvider.of(context)!.localStorage.loadFavoriteCharacter();
    notifyListeners();
  }

  void loadPage(int page) {
    currentPage = page;
    apiResponse = iApi.getCharacter(page: currentPage).then((response) {
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

    if (updateCharacter.isFavorite) {
      await DiScopeProvider.of(
        context,
      )!.localStorage.saveFavoriteCharacter(updateCharacter);
      _favoriteCharacters.add(updateCharacter);
    } else {
      await DiScopeProvider.of(
        context,
      )!.localStorage.removeFavoriteCharacter(updateCharacter);
      _favoriteCharacters.removeWhere((c) => c.id == updateCharacter.id);
    }

    notifyListeners();
  }
}
