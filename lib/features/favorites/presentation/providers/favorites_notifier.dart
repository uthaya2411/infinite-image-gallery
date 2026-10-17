import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_image_gallery/core/storage/local_storage_service.dart';
import 'package:infinite_image_gallery/features/gallery/data/models/pixabay_image.dart';

final favoritesNotifierProvider =
    NotifierProvider<FavoritesNotifier, List<PixabayImage>>(FavoritesNotifier.new);

class FavoritesNotifier extends Notifier<List<PixabayImage>> {
  @override
  List<PixabayImage> build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getFavorites();
  }

  bool isFavorite(int id) {
    return state.any((img) => img.id == id);
  }

  Future<void> toggleFavorite(PixabayImage image) async {
    final storage = ref.read(localStorageServiceProvider);
    final exists = isFavorite(image.id);

    if (exists) {
      await storage.removeFavorite(image.id);
      state = state.where((img) => img.id != image.id).toList();
    } else {
      await storage.saveFavorite(image);
      state = [image, ...state];
    }
  }

  Future<void> removeFavorite(int id) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.removeFavorite(id);
    state = state.where((img) => img.id != id).toList();
  }
}
