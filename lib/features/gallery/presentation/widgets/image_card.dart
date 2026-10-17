import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_image_gallery/core/utils/formatters.dart';
import '../../../detail/presentation/screens/image_detail_screen.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../data/models/pixabay_image.dart';

class ImageCard extends ConsumerWidget {
  final PixabayImage image;
  final VoidCallback? onFavoriteToggled;

  const ImageCard({
    super.key,
    required this.image,
    this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
      favoritesNotifierProvider.select((list) => list.any((img) => img.id == image.id)),
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Hero(
      tag: 'gallery_image_${image.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ImageDetailScreen(image: image),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Network Image with AspectRatio
                AspectRatio(
                  aspectRatio: image.aspectRatio,
                  child: CachedNetworkImage(
                    imageUrl: image.webformatURL,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 250),
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: isDark ? const Color(0xFF1E2838) : const Color(0xFFE2E8F0),
                      highlightColor: isDark ? const Color(0xFF2A374A) : const Color(0xFFF1F5F9),
                      child: Container(
                        color: isDark ? const Color(0xFF1E2838) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark ? const Color(0xFF1E2838) : const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 32),
                      ),
                    ),
                  ),
                ),

                // Gradient Overlay at bottom for readable text
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Photographer Avatar
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          backgroundImage: image.userImageURL.isNotEmpty
                              ? CachedNetworkImageProvider(image.userImageURL)
                              : null,
                          child: image.userImageURL.isEmpty
                              ? Text(
                                  image.user.isNotEmpty ? image.user[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),

                        // Photographer Username
                        Expanded(
                          child: Text(
                            image.user,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(blurRadius: 2, color: Colors.black),
                              ],
                            ),
                          ),
                        ),

                        // Likes count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.thumb_up_rounded,
                              size: 11,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              AppFormatters.formatCompactNumber(image.likes),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Right Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        ref.read(favoritesNotifierProvider.notifier).toggleFavorite(image);
                        onFavoriteToggled?.call();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            key: ValueKey<bool>(isFav),
                            size: 18,
                            color: isFav ? const Color(0xFFEF4444) : Colors.white,
                          ),
                        ),
                      ),
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
