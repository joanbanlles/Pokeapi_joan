import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokeapi/SP/favoritesmanager.dart';
import 'package:pokeapi/pokemon.dart';
import 'package:pokeapi/screen/PokemonDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  String selectedType = "All";
  String sortBy = "number";

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> pokemonTypes = [
    "All",
    "fire",
    "water",
    "grass",
    "electric",
    "rock",
    "ground",
    "psychic",
    "poison",
    "bug",
    "flying",
    "ice",
    "dragon",
    "ghost",
    "dark",
    "steel",
    "fairy"
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
    searchController.addListener(_filterPokemon);
    fetchPokemon();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> fetchPokemon() async {
    try {
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
            Pokemon pokemon =
                Pokemon.fromJson(pokemonData, pokemonList.length + 1);
            pokemon.type = pokemonData['types'][0]['type']['name'];
            pokemon.isFavorite = await FavoritesManager.isFavorite(pokemon.name);
            return pokemon;
          } else {
            throw Exception('Failed to fetch ${item['name']}');
          }
        }).toList();

        List<Pokemon> loadedPokemon = await Future.wait(futurePokemons);

        setState(() {
          pokemonList = loadedPokemon;
          filteredPokemonList = List.from(pokemonList);
          _sortPokemon();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterPokemon() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredPokemonList = pokemonList.where((pokemon) {
        bool matchesName = pokemon.name.toLowerCase().contains(query);
        bool matchesType = selectedType == "All" || pokemon.type == selectedType;
        return matchesName && matchesType;
      }).toList();
      _sortPokemon();
    });
  }

  void _filterByType(String type) {
    setState(() {
      selectedType = type;
      _filterPokemon();
    });
  }

  void _sortPokemon() {
    setState(() {
      if (sortBy == "name") {
        filteredPokemonList.sort((a, b) => a.name.compareTo(b.name));
      } else {
        filteredPokemonList.sort((a, b) => a.id.compareTo(b.id));
      }
    });
  }

  void _changeSortBy(String newSortBy) {
    setState(() {
      sortBy = newSortBy;
      _sortPokemon();
    });
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'favorite_pokemon_channel',
      'Favoritos',
      channelDescription: 'Notificación al agregar un Pokémon a favoritos',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Pokédex',
      message,
      platformDetails,
    );
  }

  void _toggleFavorite(Pokemon pokemon) async {
    bool isFav = await FavoritesManager.isFavorite(pokemon.name);

    setState(() {
      pokemon.isFavorite = !isFav;
    });

    if (pokemon.isFavorite) {
      await FavoritesManager.addFavorite(pokemon.name);
      _showNotification("Has dado Me Gusta a ${pokemon.name}!");
    } else {
      await FavoritesManager.removeFavorite(pokemon.name);
      _showNotification("Has eliminado a ${pokemon.name} de favoritos.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 213, 221, 176).withOpacity(0.7),
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  isDarkMode = !isDarkMode;
                  prefs.setBool('isDarkMode', isDarkMode);
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
            PopupMenuButton<String>(
              onSelected: _changeSortBy,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: "number",
                    child: Text("Ordenar por número"),
                  ),
                  PopupMenuItem(
                    value: "name",
                    child: Text("Ordenar por nombre"),
                  ),
                ];
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
              child: isSearchOpen
                  ? TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar Pokémon...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => _filterPokemon(),
                    )
                  : SizedBox(),
            ),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pokemonTypes.length,
                itemBuilder: (context, index) {
                  String type = pokemonTypes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(
                        type.toUpperCase(),
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: selectedType == type,
                      onSelected: (bool selected) {
                        _filterByType(type);
                      },
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : isGridView
                      ? _buildGridView()
                      : _buildListView(),
            ),
          ],
        ),
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
        return _buildPokemonCard(filteredPokemonList[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredPokemonList.length,
      itemBuilder: (context, index) {
        return _buildPokemonCard(filteredPokemonList[index]);
      },
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailScreen(
              pokemon: pokemon,
              index: filteredPokemonList.indexOf(pokemon) + 1,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Image.network(pokemon.imageUrl, height: 100, width: 100),
            Text(pokemon.name.toUpperCase()),
            IconButton(
              icon: Icon(
                pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: pokemon.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                _toggleFavorite(pokemon);
              },
            ),
          ],
        ),
      ),
    );
  }
}