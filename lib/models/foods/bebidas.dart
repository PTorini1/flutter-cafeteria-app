import 'package:lanchonet/models/food.dart';
import 'package:lanchonet/models/enums.dart';
import 'ingredient.dart';

class Bebidas extends Food {
  Bebidas(
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
            foodType: FoodType.bebidas.toString(),
            ingredients: ingredients,
            isFavourite: isFavourite,
            isPopular: isPopular,
            observe: '',
            quantity: quantity);
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
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'observe': observe,
      };
  static Bebidas fromJson(Map<String, dynamic> json) => Bebidas(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
      quantity: json['quantity'],
      ingredients: json['ingredients'],
      isPopular: json['isPopular'],
      isFavourite: json['isFavourite']);
}
