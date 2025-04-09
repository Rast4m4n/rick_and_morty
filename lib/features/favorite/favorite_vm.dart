import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

class FavoriteViewModel with ChangeNotifier {
  List<CharacterModel> _favoriteCharacters = [];

  Future<List<CharacterModel>> getFavoriteCharacter(
    BuildContext context,
  ) async {
    _favoriteCharacters =
        await DiScopeProvider.of(context)!.localStorage.loadFavoriteCharacter();
    return _favoriteCharacters;
  }

  void doIsFavorite(CharacterModel character, context) async {
    final index = _favoriteCharacters.indexOf(character);
    final updateCharacter = character.copyWith(
      isFavorite: !character.isFavorite,
    );

    _favoriteCharacters[index].copyWith(isFavorite: updateCharacter.isFavorite);

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
