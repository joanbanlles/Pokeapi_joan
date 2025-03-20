class Pokemon {
  final String name;
  final String imageUrl;
  final int hp;
  final int attack;
  final int defense;
  final int spAttack;
  final int spDefense;
  final int speed;
  final int weight;
  final int height;
  String type;
  bool isFavorite;
  final int id;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
    required this.weight,
    required this.height,
    required this.type,
    required this.id,
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json, int index) {
    return Pokemon(
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ?? '',
      hp: int.parse(json['stats'][0]['base_stat'].toString()), 
      attack: int.parse(json['stats'][1]['base_stat'].toString()), 
      defense: int.parse(json['stats'][2]['base_stat'].toString()), 
      spAttack: int.parse(json['stats'][3]['base_stat'].toString()), 
      spDefense: int.parse(json['stats'][4]['base_stat'].toString()), 
      speed: int.parse(json['stats'][5]['base_stat'].toString()), 
      weight: int.parse(json['weight'].toString()), 
      height: int.parse(json['height'].toString()), 
      type: json['types'][0]['type']['name'],
      id: index,
    );
  }
}