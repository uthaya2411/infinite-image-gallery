import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../widgets/glass_box.dart';
import '../widgets/photo_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassBox(
                blur: 16,
                opacity: isDark ? 0.35 : 0.6,
                borderRadius: BorderRadius.circular(40),
                padding: const EdgeInsets.all(24),
                child: const Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Favorites Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the heart icon on any photo to save it to your personal collection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        return PhotoCard(photo: favorites[index], isMasonry: true);
      },
    );
  }
}
