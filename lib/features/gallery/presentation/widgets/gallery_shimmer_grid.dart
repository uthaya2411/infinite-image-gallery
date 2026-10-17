import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class GalleryShimmerGrid extends StatelessWidget {
  const GalleryShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF1E2838) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF2A374A) : const Color(0xFFF1F5F9);

    // Staggered aspect ratios to simulate realistic masonry placeholders
    final heights = [220.0, 160.0, 260.0, 190.0, 240.0, 170.0, 210.0, 250.0];

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: heights.length,
        itemBuilder: (context, index) {
          final height = heights[index % heights.length];
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
