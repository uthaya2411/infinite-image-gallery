import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_image_gallery/core/storage/local_storage_service.dart';
import 'package:infinite_image_gallery/features/gallery/data/repositories/gallery_repository.dart';
import 'package:infinite_image_gallery/features/gallery/presentation/providers/gallery_notifier.dart';

class ApiKeySettingsDialog extends ConsumerStatefulWidget {
  const ApiKeySettingsDialog({super.key});

  @override
  ConsumerState<ApiKeySettingsDialog> createState() => _ApiKeySettingsDialogState();
}

class _ApiKeySettingsDialogState extends ConsumerState<ApiKeySettingsDialog> {
  late final TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(localStorageServiceProvider);
    _keyController = TextEditingController(text: storage.getCustomApiKey() ?? '');
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final repo = ref.watch(galleryRepositoryProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF131A26) : Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.key_rounded, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Pixabay API Key', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: repo.isDemoMode
                    ? Colors.amber.withValues(alpha: 0.12)
                    : const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: repo.isDemoMode ? Colors.amber : const Color(0xFF10B981),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    repo.isDemoMode ? Icons.info_outline_rounded : Icons.check_circle_rounded,
                    color: repo.isDemoMode ? Colors.amber[800] : const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      repo.isDemoMode
                          ? 'Demo Mode Active (Curated high-res feed). Enter a key below to query live Pixabay.'
                          : 'Live Pixabay API Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: repo.isDemoMode
                            ? (isDark ? Colors.amber[200] : Colors.amber[900])
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'e.g., 12345678-abcdef...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.vpn_key_rounded),
                suffixIcon: _keyController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _keyController.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            Text(
              'Get your free Pixabay key in seconds at pixabay.com/api/docs.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_keyController.text.isNotEmpty)
          TextButton(
            onPressed: () async {
              final storage = ref.read(localStorageServiceProvider);
              await storage.saveCustomApiKey(null);
              ref.read(galleryNotifierProvider.notifier).loadInitial();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Reset to Demo', style: TextStyle(color: Colors.redAccent)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final storage = ref.read(localStorageServiceProvider);
            await storage.saveCustomApiKey(_keyController.text.trim());
            ref.read(galleryNotifierProvider.notifier).loadInitial();
            if (context.mounted) Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save & Apply'),
        ),
      ],
    );
  }
}
