import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:pokeapi/SP/favoritesmanager.dart';
import 'package:pokeapi/main.dart';
import 'package:pokeapi/pokemon.dart';
import 'package:pokeapi/screen/PokemonDetailScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Pokemon> pokemonList = [];
  List<Pokemon> filteredPokemonList = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearchOpen = false;
  bool isDarkMode = false;
  bool isGridView = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    searchController.addListener(_filterPokemon);
  }

  Future<void> _showFavoriteNotification(String pokemonName) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'favorite_pokemon_channel',
          'Pokémon Favoritos',
          channelDescription: 'Notifica cuando marcas un Pokémon como favorito',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '¡Nuevo Favorito!',
      '¡$pokemonName ahora es tu favorito!',
      notificationDetails,
    );
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesManager.getFavorites();
    setState(() {
      for (var pokemon in pokemonList) {
        pokemon.isFavorite = favorites.contains(pokemon.name);
      }
    });
  }

  Future<void> fetchPokemon() async {
    print('Fetching Pokémon...');
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=50'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Future<Pokemon>> futurePokemons =
          data['results'].map<Future<Pokemon>>((item) async {
            final pokemonResponse = await http.get(Uri.parse(item['url']));
            if (pokemonResponse.statusCode == 200) {
              final pokemonData = json.decode(pokemonResponse.body);
              return Pokemon.fromJson(pokemonData, item['url']);
            } else {
              throw Exception('Failed to fetch ${item['name']}');
            }
          }).toList();

      List<Pokemon> loadedPokemon = await Future.wait(futurePokemons);

      setState(() {
        pokemonList = loadedPokemon;
        filteredPokemonList = List.from(pokemonList);
        isLoading = false;
      });

      print('Finished loading Pokémon.');
    } else {
      print('Failed to fetch Pokémon.');
    }
  }

  void _toggleFavorite(Pokemon pokemon) async {
    setState(() {
      pokemon.isFavorite = !pokemon.isFavorite;
    });

    if (pokemon.isFavorite) {
      await FavoritesManager.addFavorite(pokemon.name);
      Future.delayed(Duration(seconds: 3), () {
        _showFavoriteNotification(pokemon.name);
      });
    } else {
      await FavoritesManager.removeFavorite(pokemon.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(isSearchOpen ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearchOpen = !isSearchOpen;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: isSearchOpen ? 60 : 0,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child:
                isSearchOpen
                    ? TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar Pokémon...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged:
                          (value) =>
                              _filterPokemon(), // 🔥 Asegurar que se llama
                    )
                    : SizedBox(),
          ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : isGridView
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredPokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = filteredPokemonList[index];
        return _buildPokemonCard(pokemon);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredPokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = filteredPokemonList[index];
        return _buildPokemonCard(pokemon);
      },
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PokemonDetailScreen(
                  pokemon: pokemon,
                  index: pokemonList.indexOf(pokemon) + 1,
                ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              pokemon.imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            Text(
              pokemon.name.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () => _toggleFavorite(pokemon),
            ),
          ],
        ),
      ),
    );
  }

  void _filterPokemon() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredPokemonList =
          pokemonList.where((pokemon) {
            return pokemon.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterPokemon);
    searchController.dispose();
    super.dispose();
  }
}
