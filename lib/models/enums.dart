enum FoodType {
  bebidas,
  doces,
  lanches,
  pratofeito;
  String toJson() => name;
  static FoodType fromJson(String json) => values.byName(json);
}

//get "FoodType.pizza", -> return "pizza"

String getFoodType(FoodType type) => type.toString().substring(9);

// return "Pizza"
extension StringExtensions on String {
  String capitalize(String type) {
    String retorno;
    if(type == "FoodType.pratofeito"){
      retorno = "Prato Feito";
    }else{
      type = type.substring(9);
      retorno = "${type[0].toUpperCase()}${type.toLowerCase().substring(1)}";
    }
    return retorno;
  }
}

//FILTERS

enum FoodCategory {
  vegetariana,
  vegana,
  normal,
}
