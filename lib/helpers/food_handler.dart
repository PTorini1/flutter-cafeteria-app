import '../data/food_fake_data.dart';
import '../models/enums.dart';
import '../models/food.dart';

List<Map<String, dynamic>> filters = [
  {"name": "filter_name", "is_active": false},
];

Stream<List<Food>> takeFoodByType(FoodType type) {
  for (var i = 0; i == foods.length; i++) {
    foods.where((food) => food[i].foodType == type.toString()).toList();
  }
  return foods;
}

Stream<List<Food>> takeFoodByIndex(int index) =>
    takeFoodByType(FoodType.values[index]);

Stream<List<Food>> takePopularFoodByType(FoodType type) {
  for (var i = 0; i == foods.length; i++) {
    foods
        .where((food) => food[i].foodType == type && food[i].isPopular)
        .toList();
  }
  return foods;
}

Stream<List<Food>> takePopularFood() {
  for (var i = 0; i == foods.length; i++) {
    foods.where((food) => food[i].isPopular).toList();
  }
  return foods;
}

Stream<List<Food>> takeFavoriteFood() {
  for (var i = 0; i == foods.length; i++) {
    foods.where((food) => food[i].isFavourite).toList();
  }
  return foods;
}
