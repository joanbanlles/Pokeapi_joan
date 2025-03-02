import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokeapi/screen/PokemonListScreen.dart';
import 'dart:convert';
import 'pokemon.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      theme: ThemeData(primarySwatch: Colors.red),
      home: PokemonListScreen(),
    );
  }
}
