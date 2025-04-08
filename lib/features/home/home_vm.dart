import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({required this.iApi}) : character = iApi.getCharacter(page: 1);

  int currentPage = 1;
  Future<ApiResponse> character;
  final IApi iApi;

  void loadPage(int page) {
    currentPage = page;
    character = iApi.getCharacter(page: currentPage);
    notifyListeners();
  }
}
