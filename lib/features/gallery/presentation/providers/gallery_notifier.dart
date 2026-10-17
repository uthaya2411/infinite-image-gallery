import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/gallery_repository.dart';
import 'gallery_state.dart';

final galleryNotifierProvider =
    NotifierProvider<GalleryNotifier, GalleryState>(GalleryNotifier.new);

class GalleryNotifier extends Notifier<GalleryState> {
  Timer? _debounceTimer;

  @override
  GalleryState build() {
    // Initial fetch on provider build
    Future.microtask(() => loadInitial());
    final repository = ref.watch(galleryRepositoryProvider);
    return GalleryState(isDemoMode: repository.isDemoMode);
  }

  Future<void> loadInitial() async {
    final repository = ref.read(galleryRepositoryProvider);
    state = state.copyWith(
      status: GalleryStatus.loading,
      errorMessage: null,
      page: 1,
      hasReachedMax: false,
      isDemoMode: repository.isDemoMode,
    );

    try {
      final response = await repository.getImages(
        page: 1,
        query: state.searchQuery,
        category: state.selectedCategory,
      );

      final hits = response.hits;
      final hasReachedMax = hits.isEmpty || hits.length < 20;

      state = state.copyWith(
        status: GalleryStatus.success,
        images: hits,
        page: 1,
        hasReachedMax: hasReachedMax,
        isDemoMode: repository.isDemoMode,
      );
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        errorMessage: e.toString(),
        isDemoMode: repository.isDemoMode,
      );
    }
  }

  Future<void> loadNextPage() async {
    // Guard against duplicate concurrent fetches or end of list
    if (state.isLoadingMore || state.hasReachedMax || state.status != GalleryStatus.success) {
      return;
    }

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, paginationError: null);

    final repository = ref.read(galleryRepositoryProvider);

    try {
      final response = await repository.getImages(
        page: nextPage,
        query: state.searchQuery,
        category: state.selectedCategory,
      );

      final newHits = response.hits;
      final hasReachedMax = newHits.isEmpty || newHits.length < 20;

      // Filter duplicates by id to ensure uniqueness
      final existingIds = state.images.map((img) => img.id).toSet();
      final uniqueNewHits = newHits.where((img) => !existingIds.contains(img.id)).toList();

      state = state.copyWith(
        images: [...state.images, ...uniqueNewHits],
        page: nextPage,
        isLoadingMore: false,
        hasReachedMax: hasReachedMax,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        paginationError: 'Failed to load more images. Tap to retry.',
      );
    }
  }

  void search(String query) {
    if (state.searchQuery == query.trim()) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(searchQuery: query.trim());
      loadInitial();
    });
  }

  void selectCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    loadInitial();
  }

  Future<void> refresh() async {
    final repository = ref.read(galleryRepositoryProvider);
    try {
      final response = await repository.getImages(
        page: 1,
        query: state.searchQuery,
        category: state.selectedCategory,
      );

      final hits = response.hits;
      final hasReachedMax = hits.isEmpty || hits.length < 20;

      state = state.copyWith(
        status: GalleryStatus.success,
        images: hits,
        page: 1,
        hasReachedMax: hasReachedMax,
        isDemoMode: repository.isDemoMode,
        errorMessage: null,
      );
    } catch (e) {
      // Keep existing items on refresh error, but show error feedback
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void retry() {
    if (state.status == GalleryStatus.error) {
      loadInitial();
    } else if (state.paginationError != null) {
      loadNextPage();
    }
  }
}
