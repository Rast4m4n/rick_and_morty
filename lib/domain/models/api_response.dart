// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:rick_and_morty/domain/models/info_model.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiResponse {
  ApiResponse({required this.info, required this.results});
  final InfoModel info;
  final List<CharacterModel> results;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => _$ApiResponseToJson(this);

  ApiResponse copyWith({InfoModel? info, List<CharacterModel>? results}) {
    return ApiResponse(
      info: info ?? this.info,
      results: results ?? this.results,
    );
  }
}
