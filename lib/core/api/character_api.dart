import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';

class CharacterApi implements IApi {
  final Dio _dio = Dio();

  @override
  Future<ApiResponse> getCharacter({int page = 1}) async {
    try {
      final response = await _dio.get(
        '${IApi.baseUrl}/character',
        queryParameters: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load characters: ${e.message}');
    }
  }
}
