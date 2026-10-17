import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/models/photo.dart';
import 'package:infinite_image_gallery/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const samplePhoto = Photo(
    id: '10',
    author: 'Paul Jarvis',
    width: 2500,
    height: 1667,
    url: 'https://unsplash.com/10',
    downloadUrl: 'https://picsum.photos/id/10/2500/1667',
  );

  test('FavoritesNotifier adds and removes favorite photos', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(favoritesProvider.notifier);

    // Initial state is empty
    expect(container.read(favoritesProvider), isEmpty);
    expect(notifier.isFavorite('10'), false);

    // Add favorite
    await notifier.toggleFavorite(samplePhoto);
    expect(container.read(favoritesProvider).length, 1);
    expect(notifier.isFavorite('10'), true);

    // Toggle off
    await notifier.toggleFavorite(samplePhoto);
    expect(container.read(favoritesProvider), isEmpty);
    expect(notifier.isFavorite('10'), false);
  });
}
