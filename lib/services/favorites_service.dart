import 'favorites_storage.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  List<String> _favorites = [];

  Future<void> loadFavorites() async {
    _favorites = await FavoritesStorage.loadFavorites();
  }

  Future<void> saveFavorites() async {
    await FavoritesStorage.saveFavorites(_favorites);
  }

  List<String> getFavorites() {
    return _favorites;
  }

  bool isFavorite(String coinId) {
    return _favorites.contains(coinId);
  }

  Future<void> toggleFavorite(String coinId) async {
    if (_favorites.contains(coinId)) {
      _favorites.remove(coinId);
    } else {
      _favorites.add(coinId);
    }
    await saveFavorites();
  }

  Future<void> addFavorite(String coinId) async {
    if (!_favorites.contains(coinId)) {
      _favorites.add(coinId);
      await saveFavorites();
    }
  }

  Future<void> removeFavorite(String coinId) async {
    _favorites.remove(coinId);
    await saveFavorites();
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await saveFavorites();
  }
}
