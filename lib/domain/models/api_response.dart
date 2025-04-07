import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:rick_and_morty/domain/models/info_model.dart';

class ApiResponse {
  ApiResponse({required this.info, required this.results});
  final Info info;
  final List<CharacterModel> results;

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      info: Info.fromJson(json['info']),
      results:
          (json['results'] as List)
              .map((character) => CharacterModel.fromJson(character))
              .toList(),
    );
  }
}
