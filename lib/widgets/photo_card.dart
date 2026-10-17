import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo.dart';
import '../providers/favorites_provider.dart';
import '../screens/detail_screen.dart';
import 'glass_box.dart';

class PhotoCard extends ConsumerWidget {
  final Photo photo;

  const PhotoCard({super.key, required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).any((p) => p.id == photo.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(photo: photo),
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'photo-${photo.id}',
                  child: CachedNetworkImage(
                    imageUrl: photo.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isDark ? const Color(0xFF1E2230) : const Color(0xFFE8ECF4),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark ? const Color(0xFF1E2230) : const Color(0xFFE8ECF4),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                // Subtle bottom gradient for readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                        stops: const [0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
                // Photo ID glass badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: GlassBox(
                    blur: 10,
                    opacity: 0.25,
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      '#${photo.id}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Favorite glass button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GlassBox(
                    blur: 10,
                    opacity: 0.25,
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(photo);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.redAccent : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Photographer glass banner at the bottom
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: GlassBox(
                    blur: 14,
                    opacity: 0.35,
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            photo.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
