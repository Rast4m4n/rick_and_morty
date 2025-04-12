import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';

class CharacterApi implements IApi {
  final Dio _dio = Dio();

  @override
  Future<ApiResponse> getCharacter({
    int page = 1,
    String? species,
    String? status,
    String? gender,
  }) async {
    final response = await _dio.get(
      '${IApi.baseUrl}/character',
      queryParameters: {
        'page': page,
        'status': status,
        'gender': gender,
        'species': species,
      },
    );
    if (response.statusCode == 200) {
      return ApiResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Ошибка загрузки персонажей: Статус - ${response.statusCode}',
      );
    }
  }
}
