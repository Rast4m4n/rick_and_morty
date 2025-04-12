import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/data/repository/character_repository.dart';
import 'package:rick_and_morty/domain/enums/filter_enum.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({required this.repository})
    : apiResponse = repository.getCharacter(page: 1);

  int currentPage = 1;
  Future<ApiResponse> apiResponse;
  final IRepository repository;
  List<CharacterModel> _favoriteCharacters = [];
  bool isOnline = true;

  CharacterGender? _selectedGender;
  CharacterStatus? _selectedStatus;
  CharacterSpecies? _selectedSpecies;

  CharacterGender? get selectedGender => _selectedGender;
  CharacterStatus? get selectedStatus => _selectedStatus;
  CharacterSpecies? get selectedSpecies => _selectedSpecies;

  Future<void> loadFavorites(BuildContext context) async {
    _favoriteCharacters =
        await DiScopeProvider.of(context)!.localStorage.loadFavoriteCharacter();
    notifyListeners();
  }

  void loadPage(int page) async {
    currentPage = page;
    final connectivity = await Connectivity().checkConnectivity();

    isOnline =
        connectivity.contains(ConnectivityResult.wifi) ||
        connectivity.contains(ConnectivityResult.mobile);

    print(isOnline);
    // Подгружаю данные с api, затем подменяю элементы в списке,
    // которые были сохранены в избранные
    apiResponse = repository
        .getCharacter(
          page: currentPage,
          species: selectedSpecies?.value,
          status: selectedStatus?.value,
          gender: selectedGender?.value,
        )
        .then((response) {
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
    )!.repository.makeFavoriteOrRemoveCharacter(updateCharacter);

    if (updateCharacter.isFavorite) {
      _favoriteCharacters.add(updateCharacter);
    } else {
      _favoriteCharacters.removeWhere((c) => c.id == updateCharacter.id);
    }

    notifyListeners();
  }

  void setStatusFilter(CharacterStatus? status) {
    _selectedStatus = status;
    loadPage(1);
    notifyListeners();
  }

  void setGenderFilter(CharacterGender? gender) {
    _selectedGender = gender;
    loadPage(1);
    notifyListeners();
  }

  void setSpeciesFilter(CharacterSpecies? species) {
    _selectedSpecies = species;
    loadPage(1);
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedGender = null;
    _selectedSpecies = null;
    loadPage(1);
    notifyListeners();
  }
}
