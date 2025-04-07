import 'package:rick_and_morty/domain/models/api_response.dart';

abstract class IApi {
  static const String baseUrl = 'https://rickandmortyapi.com/api';
  Future<ApiResponse> getCharacter({int page = 1});
}
