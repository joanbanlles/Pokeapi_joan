import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokeapi/pokemon.dart';
import 'package:pokeapi/screen/PokemonDetailScreen.dart';
import 'package:pokeapi/BBDD/PokemonDatabase.dart';
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

  final PokemonDatabase _pokemonDatabase = PokemonDatabase.instance;

  @override
  void initState() {
    super.initState();
    _loadPokemons();
    searchController.addListener(_filterPokemon);
  }

  Future<void> _loadPokemons() async {
    print('Cargando Pokémon...');

    final List<Map<String, dynamic>> localPokemons =
        await _pokemonDatabase.fetchPokemonsFromDB();

    if (localPokemons.isNotEmpty) {
      print('Pokémon cargados desde la base de datos local.');
      setState(() {
        pokemonList =
            localPokemons
                .map(
                  (pokemon) => Pokemon(
                    name: pokemon['name'],
                    imageUrl: pokemon['imageUrl'],
                    hp: pokemon['hp'],
                    attack: pokemon['attack'],
                    defense: pokemon['defense'],
                    type: pokemon['type'],
                  ),
                )
                .toList();
        filteredPokemonList = List.from(pokemonList);
      });
    } else {
      print(
        'No hay Pokémon en la base de datos local. Cargando desde la API...',
      );
      await fetchPokemon();
    }

    // Cargar favoritos
    await _loadFavorites();
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
      List<Pokemon> loadedPokemon = [];

      for (var item in data['results']) {
        final pokemonResponse = await http.get(Uri.parse(item['url']));
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = json.decode(pokemonResponse.body);
          loadedPokemon.add(Pokemon.fromJson(pokemonData));
          print('Loaded ${pokemonData['name']}');
        }
      }

      setState(() {
        pokemonList = loadedPokemon;
        filteredPokemonList = List.from(pokemonList);
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
    } else {
      await FavoritesManager.removeFavorite(pokemon.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
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
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
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
                        onChanged: (value) {
                          _filterPokemon();
                        },
                      )
                      : SizedBox(),
            ),
            Expanded(
              child:
                  filteredPokemonList.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : (isGridView
                          ? GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                            itemCount: filteredPokemonList.length,
                            itemBuilder: (context, index) {
                              final pokemon = filteredPokemonList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PokemonDetailScreen(
                                            pokemon: pokemon,
                                            index: index + 1,
                                          ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        pokemon.imageUrl,
                                        height: 80,
                                        width: 80,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        pokemon.name.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          pokemon.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          _toggleFavorite(pokemon);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          : ListView.builder(
                            itemCount: filteredPokemonList.length,
                            itemBuilder: (context, index) {
                              final pokemon = filteredPokemonList[index];
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PokemonDetailScreen(
                                            pokemon: pokemon,
                                            index: index + 1,
                                          ),
                                    ),
                                  );
                                },
                                leading: Image.network(
                                  pokemon.imageUrl,
                                  height: 50,
                                  width: 50,
                                ),
                                title: Text(
                                  pokemon.name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    pokemon.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _toggleFavorite(pokemon);
                                  },
                                ),
                              );
                            },
                          )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_filterPokemon);
    searchController.dispose();
    super.dispose();
  }
}
