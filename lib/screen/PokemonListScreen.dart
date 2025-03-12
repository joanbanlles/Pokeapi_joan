import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokeapi/pokemon.dart';
import 'package:pokeapi/screen/PokemonDetailScreen.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Pokemon> pokemonList = [];
  List<Pokemon> filteredPokemonList = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    fetchPokemon();
    searchController.addListener(_filterPokemon);
  }

  Future<void> fetchPokemon() async {
    print('Fetching Pokémon...');
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1024'),
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

  void _filterPokemon() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredPokemonList =
          pokemonList
              .where((pokemon) => pokemon.name.toLowerCase().contains(query))
              .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearchOpen = !isSearchOpen;
      if (!isSearchOpen) {
        searchController.clear();
        _filterPokemon();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex'),
        actions: [
          IconButton(
            icon: Icon(isSearchOpen ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
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
                    )
                    : SizedBox(),
          ),
          Expanded(
            child:
                filteredPokemonList.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: filteredPokemonList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PokemonDetailScreen(
                                      pokemon: filteredPokemonList[index],
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
                                  filteredPokemonList[index].imageUrl,
                                  height: 80,
                                  width: 80,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  filteredPokemonList[index].name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
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
