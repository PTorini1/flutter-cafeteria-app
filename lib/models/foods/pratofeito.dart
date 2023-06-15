import 'package:lanchonet/models/food.dart';
import 'package:lanchonet/models/enums.dart';
import 'ingredient.dart';

class PratoFeito extends Food {
  PratoFeito(
      {required String id,
      required String name,
      required double price,
      required String description,
      required String image,
      required List<Ingredient> ingredients,
      required bool isFavourite,
      required bool isPopular,
      required int quantity,
      required String observe,
      })
      : super(
            id: id,
            name: name,
            price: price,
            description: description,
            image: image,
            foodType: FoodType.pratofeito.toString(),
            ingredients: ingredients,
            isFavourite: isFavourite,
            isPopular: isPopular,
            quantity: quantity,
            observe: observe,
            );
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
  static PratoFeito fromJson(Map<String, dynamic> json) => PratoFeito(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
      ingredients: json['ingredients'],
      isFavourite: json['isFavourite'],
      isPopular: json['isPopular'],
      quantity: json['quantity'],
      observe: json['observe']
      );
}
