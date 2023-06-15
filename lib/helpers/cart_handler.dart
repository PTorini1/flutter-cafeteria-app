import 'package:flutter/material.dart';
import '../models/food.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  double amount;
  List<Food> foods;
  Map<String, dynamic> quantity;
  int itemsLength;

  CartProvider({
    required this.amount,
    required this.foods,
    required this.itemsLength,
    required this.quantity,
  });

  void addItem(Food item, int foodQuantity) {
    for (int i = 0; i < foodQuantity; i++) {
      amount += item.price;
      quantity[item.name] == null
          ? quantity[item.name] = 1
          : quantity[item.name] = quantity[item.name]! + 1;
      itemsLength++;
    }
    foods.add(item);
    notifyListeners();
  }

  void addQuantity(Food item, int foodQuantity) {
    for (int i = 0; i < foodQuantity; i++) {
      amount += item.price;
      quantity[item.name] = quantity[item.name]! + 1;
      itemsLength ++;
    }
    foods[foods.indexOf(item)+1].observe = item.observe;
    notifyListeners();
  }

  void removeItem(Food item, {int foodQuantity = 1}) {
    amount -= item.price;
    quantity[item.name] = quantity[item.name]! - 1;
    itemsLength--;
    if (quantity[item.name] == 0) {
      foods.remove(item);
      quantity.remove(item.name);
    }
    notifyListeners();
  }

  static CartProvider fromMap(Map<String, dynamic> data) {
    CartProvider carrinho = CartProvider(
      amount: data['amount'],
      foods: data['foods']
          .map<Food>((mapString) => Food.fromMap(mapString))
          .toList(),
      itemsLength: data['itemsLength'],
      quantity: json.decode(data['quantity']),
    );
    return carrinho;
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'foods': foods.map((e) => e.toJson()).toList(),
        'itemsLength': itemsLength,
        'quantity': json.encode(quantity)
      };
}
