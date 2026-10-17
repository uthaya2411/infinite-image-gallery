import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/models/photo.dart';
import 'package:infinite_image_gallery/providers/gallery_provider.dart';
import 'package:infinite_image_gallery/services/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
  });

  const testPhotos = [
    Photo(
      id: '1',
      author: 'John Doe',
      width: 1000,
      height: 800,
      url: 'https://unsplash.com/1',
      downloadUrl: 'https://picsum.photos/id/1/1000/800',
    ),
    Photo(
      id: '2',
      author: 'Jane Smith',
      width: 1200,
      height: 900,
      url: 'https://unsplash.com/2',
      downloadUrl: 'https://picsum.photos/id/2/1200/900',
    ),
  ];

  test('GalleryNotifier loads photos and filters by search', () async {
    when(() => mockApi.getPhotos(page: 1, limit: 20))
        .thenAnswer((_) async => testPhotos);

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApi),
      ],
    );
    addTearDown(container.dispose);

    // Initial load
    await container.read(galleryProvider.notifier).loadPhotos();

    final state = container.read(galleryProvider);
    expect(state.photos.length, 2);
    expect(state.isLoading, false);

    // Search filter
    container.read(galleryProvider.notifier).search('Jane');
    final filtered = container.read(galleryProvider).filteredPhotos;
    expect(filtered.length, 1);
    expect(filtered.first.author, 'Jane Smith');
  });

  test('GalleryNotifier filters photos by category', () async {
    when(() => mockApi.getPhotos(page: 1, limit: 20))
        .thenAnswer((_) async => testPhotos);

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApi),
      ],
    );
    addTearDown(container.dispose);

    await container.read(galleryProvider.notifier).loadPhotos();

    // Select category of first photo
    final targetCategory = testPhotos.first.category;
    container.read(galleryProvider.notifier).selectCategory(targetCategory);

    final state = container.read(galleryProvider);
    expect(state.selectedCategory, targetCategory);
    expect(state.filteredPhotos.every((p) => p.category == targetCategory), isTrue);
  });

  test('GalleryNotifier toggles layout between masonry and grid', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(galleryProvider).isMasonry, isTrue);

    container.read(galleryProvider.notifier).toggleLayout();
    expect(container.read(galleryProvider).isMasonry, isFalse);

    container.read(galleryProvider.notifier).toggleLayout();
    expect(container.read(galleryProvider).isMasonry, isTrue);
  });
}
