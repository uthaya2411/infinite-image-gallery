import 'package:dio/dio.dart';
import '../models/photo.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://picsum.photos/v2',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  Future<List<Photo>> getPhotos({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/list',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => Photo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load photos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Please check your network.');
      }
      throw Exception('Network error: ${e.message ?? 'Unknown error'}');
    }
  }
}
