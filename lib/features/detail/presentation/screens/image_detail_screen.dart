import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:infinite_image_gallery/core/utils/formatters.dart';
import 'package:infinite_image_gallery/core/utils/snackbar_utils.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../../gallery/data/models/pixabay_image.dart';
import '../../../gallery/presentation/providers/gallery_notifier.dart';
import '../providers/download_notifier.dart';
import '../widgets/metadata_chip.dart';

class ImageDetailScreen extends ConsumerStatefulWidget {
  final PixabayImage image;

  const ImageDetailScreen({super.key, required this.image});

  @override
  ConsumerState<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends ConsumerState<ImageDetailScreen> {
  final TransformationController _transformController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      _transformController.value = Matrix4.diagonal3Values(2.5, 2.5, 1.0)
        ..setTranslationRaw(-position.dx * 1.5, -position.dy * 1.5, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isFav = ref.watch(
      favoritesNotifierProvider.select((list) => list.any((img) => img.id == image.id)),
    );
    final downloadState = ref.watch(downloadNotifierProvider);

    // Listen to download status changes for notifications
    ref.listen<DownloadState>(downloadNotifierProvider, (previous, next) {
      if (next.status == DownloadStatus.success) {
        SnackbarUtils.showSuccess(context, 'Image saved to your Photo Gallery!');
        ref.read(downloadNotifierProvider.notifier).reset();
      } else if (next.status == DownloadStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Image Area with Zoom
              SliverToBoxAdapter(
                child: GestureDetector(
                  onDoubleTapDown: _handleDoubleTapDown,
                  onDoubleTap: _handleDoubleTap,
                  child: Hero(
                    tag: 'gallery_image_${image.id}',
                    child: Container(
                      color: Colors.black,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.55,
                        minHeight: 300,
                      ),
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: image.largeImageURL.isNotEmpty
                                ? image.largeImageURL
                                : image.webformatURL,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => CachedNetworkImage(
                              imageUrl: image.webformatURL,
                              fit: BoxFit.contain,
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Detailed Metadata Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photographer Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                            backgroundImage: image.userImageURL.isNotEmpty
                                ? CachedNetworkImageProvider(image.userImageURL)
                                : null,
                            child: image.userImageURL.isEmpty
                                ? Text(
                                    image.user.isNotEmpty ? image.user[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        image.user,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 16,
                                      color: Color(0xFF10B981),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Creator & Contributor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quick Favorite Button in Header
                          IconButton.filledTonal(
                            onPressed: () {
                              ref.read(favoritesNotifierProvider.notifier).toggleFavorite(image);
                            },
                            icon: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? const Color(0xFFEF4444) : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Engagement Stats Row
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MetadataChip(
                            icon: Icons.visibility_rounded,
                            label: 'Views',
                            value: AppFormatters.formatCompactNumber(image.views),
                            iconColor: const Color(0xFF06B6D4),
                          ),
                          MetadataChip(
                            icon: Icons.thumb_up_rounded,
                            label: 'Likes',
                            value: AppFormatters.formatCompactNumber(image.likes),
                            iconColor: const Color(0xFFEC4899),
                          ),
                          MetadataChip(
                            icon: Icons.download_rounded,
                            label: 'Downloads',
                            value: AppFormatters.formatCompactNumber(image.downloads),
                            iconColor: const Color(0xFF10B981),
                          ),
                          MetadataChip(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Comments',
                            value: AppFormatters.formatCompactNumber(image.comments),
                            iconColor: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Technical Specs (Dimensions & File Size)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131A26) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSpecItem(
                              context,
                              'Resolution',
                              '${image.imageWidth > 0 ? image.imageWidth : image.webformatWidth} × ${image.imageHeight > 0 ? image.imageHeight : image.webformatHeight}',
                              Icons.aspect_ratio_rounded,
                            ),
                            Container(width: 1, height: 32, color: isDark ? Colors.white12 : Colors.black12),
                            _buildSpecItem(
                              context,
                              'File Size',
                              image.imageSize > 0
                                  ? AppFormatters.formatBytes(image.imageSize)
                                  : 'High Res',
                              Icons.data_usage_rounded,
                            ),
                            Container(width: 1, height: 32, color: isDark ? Colors.white12 : Colors.black12),
                            _buildSpecItem(
                              context,
                              'Format',
                              'JPEG',
                              Icons.photo_size_select_actual_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tags Section
                      if (image.tags.isNotEmpty) ...[
                        const Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: image.tags.map((tag) {
                            return ActionChip(
                              label: Text('#$tag'),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              side: BorderSide(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onPressed: () {
                                ref.read(galleryNotifierProvider.notifier).search(tag);
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Download Button Section
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: downloadState.status == DownloadStatus.downloading
                              ? null
                              : () {
                                  ref
                                      .read(downloadNotifierProvider.notifier)
                                      .downloadAndSaveImage(image);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: downloadState.status == DownloadStatus.downloading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        value: downloadState.progress > 0
                                            ? downloadState.progress
                                            : null,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      'Downloading ${(downloadState.progress * 100).toInt()}%...',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download_rounded, size: 22),
                                    SizedBox(width: 10),
                                    Text(
                                      'Save to Device Gallery',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Top App Bar (Back & Share buttons)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Share Button
                CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      final shareUrl = image.pageURL.isNotEmpty
                          ? image.pageURL
                          : image.largeImageURL;
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Check out this stunning photo by ${image.user} on Lumina Gallery: $shareUrl',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
