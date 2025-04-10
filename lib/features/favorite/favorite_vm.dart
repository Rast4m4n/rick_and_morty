import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/domain/enums/filter_enum.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

class FavoriteViewModel with ChangeNotifier {
  List<CharacterModel> _favoriteCharacters = [];
  CharacterGender? _selectedGender;
  CharacterStatus? _selectedStatus;
  CharacterSpecies? _selectedSpecies;

  CharacterGender? get selectedGender => _selectedGender;
  CharacterStatus? get selectedStatus => _selectedStatus;
  CharacterSpecies? get selectedSpecies => _selectedSpecies;

  Future<List<CharacterModel>> getFavoriteCharacter(
    BuildContext context,
  ) async {
    _favoriteCharacters =
        await DiScopeProvider.of(context)!.localStorage.loadFavoriteCharacter();
    return _applyFilters();
  }

  List<CharacterModel> _applyFilters() {
    List<CharacterModel> filtered = _favoriteCharacters;
    if (_selectedStatus != null && _selectedStatus != CharacterStatus.all) {
      filtered =
          filtered
              .where((character) => character.status == _selectedStatus!.value)
              .toList();
    }

    if (_selectedGender != null && _selectedGender != CharacterGender.all) {
      filtered =
          filtered
              .where((character) => character.gender == _selectedGender!.value)
              .toList();
    }

    if (_selectedSpecies != null && _selectedSpecies != CharacterSpecies.all) {
      filtered =
          filtered
              .where(
                (character) => character.species == _selectedSpecies!.value,
              )
              .toList();
    }

    return filtered;
  }

  void setStatusFilter(CharacterStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setGenderFilter(CharacterGender? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setSpeciesFilter(CharacterSpecies? species) {
    _selectedSpecies = species;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedGender = null;
    _selectedSpecies = null;
    notifyListeners();
  }

  void doIsFavorite(CharacterModel character, context) async {
    final updateCharacter = character.copyWith(
      isFavorite: !character.isFavorite,
    );

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
