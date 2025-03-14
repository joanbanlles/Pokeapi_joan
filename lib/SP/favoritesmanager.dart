import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorite_pokemon';

  // Guardar un Pokémon como favorito
  static Future<void> addFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (!favorites.contains(pokemonName)) {
      favorites.add(pokemonName);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Eliminar un Pokémon de favoritos
  static Future<void> removeFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (favorites.contains(pokemonName)) {
      favorites.remove(pokemonName);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Obtener la lista de favoritos
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Verificar si un Pokémon es favorito
  static Future<bool> isFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.contains(pokemonName);
  }
}
