import '../../data/models/pixabay_image.dart';

enum GalleryStatus { initial, loading, success, error }

class GalleryState {
  final GalleryStatus status;
  final List<PixabayImage> images;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? paginationError;
  final String searchQuery;
  final String selectedCategory;
  final String? errorMessage;
  final bool isDemoMode;

  const GalleryState({
    this.status = GalleryStatus.initial,
    this.images = const [],
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.paginationError,
    this.searchQuery = '',
    this.selectedCategory = 'all',
    this.errorMessage,
    this.isDemoMode = false,
  });

  GalleryState copyWith({
    GalleryStatus? status,
    List<PixabayImage>? images,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? paginationError,
    String? searchQuery,
    String? selectedCategory,
    String? errorMessage,
    bool? isDemoMode,
  }) {
    return GalleryState(
      status: status ?? this.status,
      images: images ?? this.images,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: paginationError,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }
}
