import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo.dart';

class StorageService {
  static const _favoritesKey = 'favorites_photos';
  static const _themeKey = 'is_dark_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  List<Photo> getFavorites() {
    final list = _prefs.getStringList(_favoritesKey) ?? [];
    return list.map((item) => Photo.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveFavorites(List<Photo> photos) async {
    final list = photos.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, list);
  }

  bool isDarkMode() {
    return _prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_themeKey, isDark);
  }
}
