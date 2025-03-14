import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonDatabase {
  static final PokemonDatabase instance = PokemonDatabase._init();
  static Database? _database;

  PokemonDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pokemon.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

Future<void> _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS pokemon (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE,
      url TEXT,
      imageUrl TEXT,
      hp INTEGER,
      attack INTEGER,
      defense INTEGER,
      type TEXT
    )
  ''');
  print("Tabla 'pokemon' creada correctamente.");
}

Future<void> insertPokemon(Map<String, dynamic> pokemon) async {
  final db = await instance.database;
  try {
    await db.insert(
      'pokemon',
      pokemon,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Pokemon guardado: ${pokemon['name']}");
  } catch (e) {
    print("Error al guardar el Pokémon: $e");
    throw e;
  }
}

Future<List<Map<String, dynamic>>> fetchPokemonsFromDB() async {
  final db = await instance.database;
  try {
    final List<Map<String, dynamic>> pokemons = await db.query('pokemon');
    print("Pokémon almacenados en la base de datos: ${pokemons.map((p) => p['name']).toList()}");
    return pokemons;
  } catch (e) {
    print("Error al obtener Pokémon de la base de datos: $e");
    return [];
  }
}

 Future<List<Map<String, dynamic>>> fetchAndStorePokemons({int limit = 20, int offset = 0}) async {
  final db = await instance.database;

  final List<Map<String, dynamic>> existingPokemons = await fetchPokemonsFromDB();
  if (existingPokemons.isNotEmpty) {
    print("Ya hay Pokémon en la base de datos. Cargando desde la base de datos local...");
    return existingPokemons;
  }


  try {
    print("Intentando cargar desde la API...");
    final url = 'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List pokemons = data['results'];

      for (var pokemon in pokemons) {
        await insertPokemon({
          'name': pokemon['name'],
          'url': pokemon['url'],
        });
      }

      print("Pokémon guardados en la base de datos.");
      return await fetchPokemonsFromDB();
    } else {
      print("Error en la API: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Error al cargar Pokémon: $e");
    return [];
  }
}
}