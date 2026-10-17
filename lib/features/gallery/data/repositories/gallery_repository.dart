import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_image_gallery/core/config/env_config.dart';
import 'package:infinite_image_gallery/core/network/api_client.dart';
import 'package:infinite_image_gallery/core/storage/local_storage_service.dart';
import '../datasources/gallery_mock_data_source.dart';
import '../datasources/gallery_remote_data_source.dart';
import '../models/pixabay_response.dart';

final galleryRemoteDataSourceProvider = Provider<GalleryRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return GalleryRemoteDataSource(client);
});

final galleryMockDataSourceProvider = Provider<GalleryMockDataSource>((ref) {
  return GalleryMockDataSource();
});

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final remoteDataSource = ref.watch(galleryRemoteDataSourceProvider);
  final mockDataSource = ref.watch(galleryMockDataSourceProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return GalleryRepository(remoteDataSource, mockDataSource, storage);
});

class GalleryRepository {
  final GalleryRemoteDataSource _remoteDataSource;
  final GalleryMockDataSource _mockDataSource;
  final LocalStorageService _storage;

  GalleryRepository(
    this._remoteDataSource,
    this._mockDataSource,
    this._storage,
  );

  /// Resolves the current active API key (from local storage or compile-time env)
  String? get activeApiKey {
    final customKey = _storage.getCustomApiKey();
    if (customKey != null && customKey.trim().isNotEmpty) {
      return customKey.trim();
    }
    if (EnvConfig.hasApiKey) {
      return EnvConfig.apiKey;
    }
    return null;
  }

  /// Whether the repository is operating in demo/mock mode due to no API key
  bool get isDemoMode => activeApiKey == null;

  Future<PixabayResponse> getImages({
    required int page,
    int perPage = 20,
    String? query,
    String? category,
  }) async {
    final key = activeApiKey;

    if (key != null && key.isNotEmpty) {
      try {
        return await _remoteDataSource.fetchImages(
          apiKey: key,
          page: page,
          perPage: perPage,
          query: query,
          category: category,
        );
      } catch (e) {
        // If remote fails, fallback gracefully if it's an initial load or invalid key
        rethrow;
      }
    }

    // No API key provided: use the rich curated mock data source
    return await _mockDataSource.fetchImages(
      page: page,
      perPage: perPage,
      query: query,
      category: category,
    );
  }
}
