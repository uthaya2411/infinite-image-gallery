import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/gallery_notifier.dart';
import '../providers/gallery_state.dart';
import 'image_card.dart';

class GalleryMasonryGrid extends ConsumerStatefulWidget {
  final GalleryState state;

  const GalleryMasonryGrid({super.key, required this.state});

  @override
  ConsumerState<GalleryMasonryGrid> createState() => _GalleryMasonryGridState();
}

class _GalleryMasonryGridState extends ConsumerState<GalleryMasonryGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // When within 300 pixels from the bottom of the list, trigger loading next page
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(galleryNotifierProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.state.images;
    final isLoadingMore = widget.state.isLoadingMore;
    final paginationError = widget.state.paginationError;
    final hasReachedMax = widget.state.hasReachedMax;

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () => ref.read(galleryNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Staggered Masonry Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (context, index) {
                return ImageCard(image: images[index]);
              },
              childCount: images.length,
            ),
          ),

          // Bottom Pagination Status Indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Builder(
                  builder: (context) {
                    if (isLoadingMore) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Loading more images...',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      );
                    } else if (paginationError != null) {
                      return InkWell(
                        onTap: () => ref.read(galleryNotifierProvider.notifier).retry(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh_rounded, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                paginationError,
                                style: const TextStyle(fontSize: 13, color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (hasReachedMax && images.isNotEmpty) {
                      return const Text(
                        '✨ You\'ve viewed all images',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
