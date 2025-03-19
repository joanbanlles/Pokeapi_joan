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
  final String type;
  bool isFavorite;

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
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json, int index) {
    return Pokemon(
      name: json['name'],
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] ?? '',
      hp: json['stats'][0]['base_stat'],
      attack: json['stats'][1]['base_stat'],
      defense: json['stats'][2]['base_stat'],
      spAttack: json['stats'][3]['base_stat'],
      spDefense: json['stats'][4]['base_stat'],
      speed: json['stats'][5]['base_stat'],
      weight: json['weight'],
      height: json['height'],
      type: json['types'][0]['type']['name'],
    );
  }
}
