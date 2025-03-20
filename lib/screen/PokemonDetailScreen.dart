import 'package:flutter/material.dart';
import 'package:pokeapi/pokemon.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;
  final int index;

  PokemonDetailScreen({required this.pokemon, required this.index});


  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'rock':
        return Colors.brown;
      case 'ground':
        return Colors.brown[400]!;
      case 'flying':
        return Colors.indigo;
      case 'bug':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("PokeDex"),
        backgroundColor: getTypeColor(pokemon.type),
      ), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: getTypeColor(pokemon.type), 
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Image.network(pokemon.imageUrl, height: 150, width: 150),
                  SizedBox(height: 10),
                  Text(
                    "#$index",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    pokemon.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildTypeChip(pokemon.type)],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "${pokemon.weight} KG   |   ${pokemon.height} M",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            SizedBox(height: 20),
            _buildStats(),
          ],
        ),
      ),
    );
  }


  Widget _buildTypeChip(String type) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Chip(
        label: Text(type.toUpperCase(), style: TextStyle(color: Colors.white)),
        backgroundColor: getTypeColor(type),
      ),
    );
  }


  Widget _buildStats() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.black,
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow("HP", pokemon.hp, Colors.red),
              _buildStatRow("ATK", pokemon.attack, Colors.orange),
              _buildStatRow("DEF", pokemon.defense, Colors.blue),
              _buildStatRow("SP ATK", pokemon.spAttack, Colors.purple),
              _buildStatRow("SP DEF", pokemon.spDefense, Colors.green),
              _buildStatRow("SPD", pokemon.speed, Colors.yellow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    double maxWidth = 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 10,
              width: maxWidth,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 10,
              width: (value / 270.0) * maxWidth, 
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
