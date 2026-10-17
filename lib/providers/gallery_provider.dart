import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class GalleryState {
  final List<Photo> photos;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final bool hasMore;
  final String searchQuery;

  const GalleryState({
    this.photos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.searchQuery = '',
  });

  List<Photo> get filteredPhotos {
    if (searchQuery.trim().isEmpty) return photos;
    final query = searchQuery.trim().toLowerCase();
    return photos.where((p) {
      return p.author.toLowerCase().contains(query) || p.id.contains(query);
    }).toList();
  }

  GalleryState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    bool? hasMore,
    String? searchQuery,
  }) {
    return GalleryState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class GalleryNotifier extends Notifier<GalleryState> {
  @override
  GalleryState build() {
    Future.microtask(() => loadPhotos());
    return const GalleryState(isLoading: true);
  }

  Future<void> loadPhotos() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final api = ref.read(apiServiceProvider);
      final items = await api.getPhotos(page: 1, limit: 20);
      state = state.copyWith(
        photos: items,
        isLoading: false,
        page: 2,
        hasMore: items.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final api = ref.read(apiServiceProvider);
      final nextItems = await api.getPhotos(page: state.page, limit: 20);
      if (nextItems.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      } else {
        state = state.copyWith(
          photos: [...state.photos, ...nextItems],
          isLoadingMore: false,
          page: state.page + 1,
          hasMore: nextItems.length >= 20,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final galleryProvider =
    NotifierProvider<GalleryNotifier, GalleryState>(GalleryNotifier.new);
