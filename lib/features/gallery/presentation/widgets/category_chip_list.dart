import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_image_gallery/core/constants/app_categories.dart';
import '../providers/gallery_notifier.dart';

class CategoryChipList extends ConsumerWidget {
  const CategoryChipList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(
      galleryNotifierProvider.select((state) => state.selectedCategory),
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: AppCategories.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = AppCategories.categories[index];
          final isSelected = selectedCategory.toLowerCase() == category.id.toLowerCase();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: FilterChip(
              avatar: Icon(
                category.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              label: Text(
                category.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[800]),
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: theme.colorScheme.primary,
              backgroundColor: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              onSelected: (_) {
                ref.read(galleryNotifierProvider.notifier).selectCategory(category.id);
              },
            ),
          );
        },
      ),
    );
  }
}
