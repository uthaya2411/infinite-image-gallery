import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/core/storage/local_storage_service.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/providers/gallery_notifier.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/providers/gallery_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('GalleryNotifier loads initial mock items and paginates successfully', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    // Load initial
    await container.read(galleryNotifierProvider.notifier).loadInitial();
    final state = container.read(galleryNotifierProvider);

    expect(state.status, equals(GalleryStatus.success));
    expect(state.images.isNotEmpty, isTrue);
    expect(state.page, equals(1));

    final initialCount = state.images.length;

    // Load next page (Infinite Scroll Pagination)
    await container.read(galleryNotifierProvider.notifier).loadNextPage();
    final pagedState = container.read(galleryNotifierProvider);

    expect(pagedState.page, equals(2));
    expect(pagedState.images.length, greaterThan(initialCount));
  });

  test('GalleryNotifier filters items by category', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    // Select Animals category
    container.read(galleryNotifierProvider.notifier).selectCategory('animals');
    await Future.delayed(const Duration(milliseconds: 350));

    final state = container.read(galleryNotifierProvider);
    expect(state.selectedCategory, equals('animals'));
    expect(state.images.every((img) => img.tags.contains('animals')), isTrue);
  });
}
