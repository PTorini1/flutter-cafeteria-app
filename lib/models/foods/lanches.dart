import 'package:lanchonet/models/food.dart';
import 'package:lanchonet/models/enums.dart';
import 'ingredient.dart';

class Lanches extends Food {
  Lanches(
      {required String id,
      required String name,
      required double price,
      required String description,
      required String image,
      required List<Ingredient> ingredients,
      required bool isFavourite,
      required bool isPopular,
      required int quantity})
      : super(
            id: id,
            name: name,
            price: price,
            description: description,
            image: image,
            foodType: FoodType.lanches.toString(),
            ingredients: ingredients,
            isFavourite: isFavourite,
            isPopular: isPopular,
            quantity: quantity,
            observe: '');
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'image': image,
        'foodType': foodType.toString(),
        'isFavourite': isFavourite,
        'isPopular': isPopular,
        'quantity': quantity,
        'observe': observe,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };
  static Lanches fromJson(Map<String, dynamic> json) => Lanches(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
      ingredients: json['ingredients'],
      isFavourite: json['isFavourite'],
      isPopular: json['isPopular'],
      quantity: json['quantity']);
}
