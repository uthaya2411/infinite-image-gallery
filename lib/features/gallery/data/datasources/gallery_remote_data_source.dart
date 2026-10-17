import 'package:dio/dio.dart';
import 'package:infinite_image_gallery/core/constants/api_endpoints.dart';
import 'package:infinite_image_gallery/core/network/api_client.dart';
import 'package:infinite_image_gallery/core/network/network_exceptions.dart';
import '../models/pixabay_response.dart';

class GalleryRemoteDataSource {
  final ApiClient _apiClient;

  GalleryRemoteDataSource(this._apiClient);

  Future<PixabayResponse> fetchImages({
    required String apiKey,
    required int page,
    int perPage = ApiEndpoints.defaultPerPage,
    String? query,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'key': apiKey,
        'page': page,
        'per_page': perPage,
        'image_type': 'photo',
        'safesearch': 'true',
      };

      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = Uri.encodeComponent(query.trim());
      }

      if (category != null && category.trim().isNotEmpty && category.trim().toLowerCase() != 'all') {
        queryParams['category'] = category.trim().toLowerCase();
      }

      final response = await _apiClient.get(
        '',
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return PixabayResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw const NetworkException(message: 'Unexpected server response format.');
      }
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(message: 'Failed to load images: $e');
    }
  }
}
