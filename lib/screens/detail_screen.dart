import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/photo.dart';
import '../providers/favorites_provider.dart';
import '../widgets/glass_box.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Photo photo;

  const DetailScreen({super.key, required this.photo});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final TransformationController _transformController = TransformationController();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  void _handleDoubleTap() {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
    } else {
      _transformController.value = Matrix4.diagonal3Values(2.0, 2.0, 1.0);
    }
  }

  Future<void> _downloadImage() async {
    setState(() => _isDownloading = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/picsum_${widget.photo.id}.jpg';

      await Dio().download(
        widget.photo.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      await Gal.putImage(savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Image saved to Gallery!'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  void _shareImage() {
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out this photo by ${widget.photo.author}: ${widget.photo.url}',
      ),
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFav = ref.watch(favoritesProvider).any((p) => p.id == widget.photo.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassBox(
            blur: 12,
            opacity: 0.3,
            borderRadius: BorderRadius.circular(30),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GlassBox(
              blur: 12,
              opacity: 0.3,
              borderRadius: BorderRadius.circular(30),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(widget.photo);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12.0),
            child: GlassBox(
              blur: 12,
              opacity: 0.3,
              borderRadius: BorderRadius.circular(30),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 20),
                onPressed: _shareImage,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient blurred background
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.photo.thumbnailUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: (isDark ? Colors.black : Colors.grey.shade900).withValues(alpha: 0.8),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onDoubleTap: _handleDoubleTap,
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Hero(
                          tag: 'photo-${widget.photo.id}',
                          child: CachedNetworkImage(
                            imageUrl: widget.photo.detailUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: CachedNetworkImage(
                                imageUrl: widget.photo.thumbnailUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Glassmorphic Info Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassBox(
                    blur: 20,
                    opacity: 0.35,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.purpleAccent, Colors.blueAccent],
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person, color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.photo.author,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Photo #${widget.photo.id} • Unsplash',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A high-resolution photograph captured by ${widget.photo.author}, featured in the ${widget.photo.category} collection. Optimized for crystal-clear mobile display.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Spec pills
                        Row(
                          children: [
                            Expanded(
                              child: _specGlassPill(
                                Icons.aspect_ratio,
                                'Dimensions',
                                '${widget.photo.width} × ${widget.photo.height}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _specGlassPill(
                                Icons.high_quality,
                                'Resolution',
                                '${(widget.photo.width * widget.photo.height / 1000000).toStringAsFixed(1)} MP',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Glassmorphic Download Button
                        InkWell(
                          onTap: _isDownloading ? null : _downloadImage,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo.shade600,
                                  Colors.purple.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isDownloading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            value: _downloadProgress > 0 ? _downloadProgress : null,
                                            strokeWidth: 2.2,
                                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _downloadProgress > 0
                                              ? 'Saving ${(_downloadProgress * 100).toInt()}%'
                                              : 'Downloading...',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download, color: Colors.white, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Save to Gallery',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
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
        ],
      ),
    );
  }

  Widget _specGlassPill(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
