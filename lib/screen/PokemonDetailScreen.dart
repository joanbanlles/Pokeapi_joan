import 'package:flutter/material.dart';
import 'package:pokeapi/pokemon.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;
  final int index;

  PokemonDetailScreen({required this.pokemon, required this.index});

  Color getTypeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getTypeColor(pokemon.type),
      appBar: AppBar(
        title: Text(pokemon.name.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(pokemon.imageUrl, height: 150, width: 150),
            SizedBox(height: 20),
            Text(
              '#$index',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              pokemon.name.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              pokemon.type.toUpperCase(),
              style: TextStyle(fontSize: 22, color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'HP: ${pokemon.hp}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              'Attack: ${pokemon.attack}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              'Defense: ${pokemon.defense}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
