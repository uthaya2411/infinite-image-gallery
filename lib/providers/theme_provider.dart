import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'favorites_provider.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.isDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final storage = ref.read(storageServiceProvider);
    final isDark = state == ThemeMode.dark;
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    state = nextMode;
    await storage.setDarkMode(nextMode == ThemeMode.dark);
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
