import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String _key = 'favorite_coins';

  static Future<void> saveFavorites(List<String> coinIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, coinIds);
    } catch (e) {
      print('Error saving favorites: $e');
      rethrow;
    }
  }

  static Future<List<String>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_key);
      return favorites ?? [];
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  static Future<void> toggleFavorite(String coinId) async {
    final favorites = await loadFavorites();
    if (favorites.contains(coinId)) {
      favorites.remove(coinId);
    } else {
      favorites.add(coinId);
    }
    await saveFavorites(favorites);
  }

  static Future<bool> isFavorite(String coinId) async {
    final favorites = await loadFavorites();
    return favorites.contains(coinId);
  }
}
