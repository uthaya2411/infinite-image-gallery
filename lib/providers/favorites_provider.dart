import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo.dart';
import '../services/storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main()');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

class FavoritesNotifier extends Notifier<List<Photo>> {
  @override
  List<Photo> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getFavorites();
  }

  bool isFavorite(String id) {
    return state.any((p) => p.id == id);
  }

  Future<void> toggleFavorite(Photo photo) async {
    final storage = ref.read(storageServiceProvider);
    if (isFavorite(photo.id)) {
      state = state.where((p) => p.id != photo.id).toList();
    } else {
      state = [...state, photo];
    }
    await storage.saveFavorites(state);
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<Photo>>(FavoritesNotifier.new);
