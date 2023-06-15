import 'foods/ingredient.dart';

class Food {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final String foodType;
  final List<Ingredient> ingredients;
  int quantity;
  bool isPopular;
  bool isFavourite;
  String observe;

  static Food fromMap(Map<String, dynamic> data) {
    Food comida = Food(
        id: data['id'],
        name: data['name'],
        price: data['price'],
        description: data['description'],
        image: data['image'],
        foodType: data['foodType'],
        ingredients: data['ingredients']
            .map<Ingredient>((mapString) => Ingredient.fromJson(mapString))
            .toList(),
        isFavourite: data['isFavourite'],
        isPopular: data['isPopular'],
        quantity: data['quantity'],
        observe: data['observe']);
    return comida;
  }

  Food(
      {required this.id,
      required this.name,
      required this.price,
      required this.description,
      required this.image,
      required this.foodType,
      required this.ingredients,
      required this.isPopular,
      required this.isFavourite,
      required this.observe,
      required this.quantity});
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'image': image,
        'foodType': foodType.toString(),
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'isFavourite': isFavourite,
        'isPopular': isPopular,
        'quantity': quantity,
        'observe': observe
      };
  static Food fromJson(Map<String, dynamic> json) => Food(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
      foodType: (json['foodType']),
      ingredients: json['ingredients']
          .map<Ingredient>((mapString) => Ingredient.fromJson(mapString))
          .toList(),
      isFavourite: json['isFavourite'],
      isPopular: json['isPopular'],
      quantity: json['quantity'],
      observe: json['observe'],
      );
}
