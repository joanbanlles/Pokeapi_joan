import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorite_pokemon';


  static Future<void> addFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (!favorites.contains(pokemonName)) {
      favorites.add(pokemonName);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }


  static Future<void> removeFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (favorites.contains(pokemonName)) {
      favorites.remove(pokemonName);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }


  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }


  static Future<bool> isFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.contains(pokemonName);
  }
}
