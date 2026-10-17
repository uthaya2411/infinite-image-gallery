import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_image_gallery/core/theme/theme_provider.dart';
import 'package:infinite_image_gallery/features/favorites/presentation/providers/favorites_notifier.dart';
import 'package:infinite_image_gallery/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:infinite_image_gallery/features/gallery/data/repositories/gallery_repository.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/providers/gallery_notifier.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/providers/gallery_state.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/widgets/category_chip_list.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/widgets/gallery_empty_view.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/widgets/gallery_error_view.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/widgets/gallery_masonry_grid.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/widgets/gallery_shimmer_grid.dart';
import 'package:infinite_image_gallery/features/settings/screens/api_key_settings_dialog.dart';

class HomeNavigationScreen extends ConsumerStatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  ConsumerState<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends ConsumerState<HomeNavigationScreen> {
  int _currentIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final isDark = theme.brightness == Brightness.dark;
    final favCount = ref.watch(favoritesNotifierProvider.select((list) => list.length));
    final galleryState = ref.watch(galleryNotifierProvider);
    final repo = ref.watch(galleryRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search photos, tags, photographers...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    fontSize: 15,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (val) {
                  ref.read(galleryNotifierProvider.notifier).search(val);
                },
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Lumina Gallery'),
                  if (repo.isDemoMode) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'DEMO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        actions: [
          // Search Toggle Button
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  ref.read(galleryNotifierProvider.notifier).search('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),

          // Theme Toggle Button (Light / Dark)
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                color: isDark ? Colors.amber[300] : Colors.indigo[700],
              ),
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),

          // API Key Settings Dialog Button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'API Configuration',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ApiKeySettingsDialog(),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: Gallery Tab
          Column(
            children: [
              const SizedBox(height: 8),
              // Category Filter Bar
              const CategoryChipList(),
              const SizedBox(height: 8),

              // Gallery Content Area
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (galleryState.status == GalleryStatus.loading) {
                      return const GalleryShimmerGrid();
                    } else if (galleryState.status == GalleryStatus.error) {
                      return GalleryErrorView(
                        errorMessage: galleryState.errorMessage ?? 'Something went wrong',
                      );
                    } else if (galleryState.images.isEmpty) {
                      return GalleryEmptyView(searchQuery: galleryState.searchQuery);
                    }
                    return GalleryMasonryGrid(state: galleryState);
                  },
                ),
              ),
            ],
          ),

          // Tab 1: Favorites Tab
          FavoritesScreen(
            onBrowseTapped: () {
              setState(() => _currentIndex = 0);
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_border_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_rounded),
            ),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
