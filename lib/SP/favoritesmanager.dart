import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorite_pokemons';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  static Future<void> addFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();

    if (!favorites.contains(pokemonName)) {
      favorites.add(pokemonName);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  static Future<void> removeFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();

    favorites.remove(pokemonName);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  static Future<bool> isFavorite(String pokemonName) async {
    List<String> favorites = await getFavorites();
    return favorites.contains(pokemonName);
  }
}
