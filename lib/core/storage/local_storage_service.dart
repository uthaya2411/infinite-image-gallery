import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infinite_image_gallery/features/gallery/data/models/pixabay_image.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _favoritesKey = 'favorite_images_list';
  static const String _themeModeKey = 'app_theme_mode';
  static const String _apiKeyKey = 'custom_pixabay_api_key';

  // --- Favorites Persistence ---

  List<PixabayImage> getFavorites() {
    final rawList = _prefs.getStringList(_favoritesKey);
    if (rawList == null || rawList.isEmpty) return [];

    try {
      return rawList.map((item) {
        final Map<String, dynamic> jsonMap = jsonDecode(item);
        return PixabayImage.fromJson(jsonMap);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveFavorite(PixabayImage image) async {
    final list = getFavorites();
    if (!list.any((img) => img.id == image.id)) {
      list.insert(0, image);
      final rawList = list.map((img) => jsonEncode(img.toJson())).toList();
      return await _prefs.setStringList(_favoritesKey, rawList);
    }
    return true;
  }

  Future<bool> removeFavorite(int id) async {
    final list = getFavorites();
    list.removeWhere((img) => img.id == id);
    final rawList = list.map((img) => jsonEncode(img.toJson())).toList();
    return await _prefs.setStringList(_favoritesKey, rawList);
  }

  bool isFavorite(int id) {
    final list = getFavorites();
    return list.any((img) => img.id == id);
  }

  // --- Theme Mode Persistence ---

  ThemeMode getThemeMode() {
    final modeStr = _prefs.getString(_themeModeKey);
    switch (modeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<bool> saveThemeMode(ThemeMode mode) async {
    return await _prefs.setString(_themeModeKey, mode.name);
  }

  // --- Custom API Key Persistence ---

  String? getCustomApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  Future<bool> saveCustomApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      return await _prefs.remove(_apiKeyKey);
    }
    return await _prefs.setString(_apiKeyKey, key.trim());
  }
}
