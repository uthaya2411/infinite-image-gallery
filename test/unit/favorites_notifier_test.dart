import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/core/storage/local_storage_service.dart';
import 'package:infinite_image_gallery/features/favorites/presentation/providers/favorites_notifier.dart';
import 'package:infinite_image_gallery/features/gallery/data/models/pixabay_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const testImage = PixabayImage(
    id: 999,
    pageURL: 'https://pixabay.com/test',
    type: 'photo',
    tags: ['test', 'flutter'],
    previewURL: 'https://test.com/preview.jpg',
    previewWidth: 150,
    previewHeight: 100,
    webformatURL: 'https://test.com/web.jpg',
    webformatWidth: 640,
    webformatHeight: 480,
    largeImageURL: 'https://test.com/large.jpg',
    imageWidth: 1920,
    imageHeight: 1080,
    imageSize: 500000,
    views: 1200,
    downloads: 450,
    likes: 85,
    comments: 12,
    userId: 1,
    user: 'FlutterDeveloper',
    userImageURL: '',
  );

  test('FavoritesNotifier adds, queries, and removes favorite images', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    // Initial state: empty
    expect(container.read(favoritesNotifierProvider), isEmpty);
    expect(container.read(favoritesNotifierProvider.notifier).isFavorite(testImage.id), isFalse);

    // Toggle favorite (Add)
    await container.read(favoritesNotifierProvider.notifier).toggleFavorite(testImage);
    expect(container.read(favoritesNotifierProvider).length, equals(1));
    expect(container.read(favoritesNotifierProvider.notifier).isFavorite(testImage.id), isTrue);

    // Toggle favorite again (Remove)
    await container.read(favoritesNotifierProvider.notifier).toggleFavorite(testImage);
    expect(container.read(favoritesNotifierProvider), isEmpty);
    expect(container.read(favoritesNotifierProvider.notifier).isFavorite(testImage.id), isFalse);
  });
}
