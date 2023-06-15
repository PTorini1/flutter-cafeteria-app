class Ingredient {
  final String id;
  final String name;
  final String? icon;
  final int quantity;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    this.icon,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'quantity': quantity,
      };
  static Ingredient fromMap(Map<String, dynamic> data) {
    Ingredient comida = Ingredient(
      id: data['id'],
      name: data['name'],
      icon: data['icon'],
      quantity: data['quantity']
    );
    return comida;
  }

  static Ingredient fromJson(Map<String, dynamic> json) =>
      Ingredient(id: json['id'], name: json['name'], icon: json['icon'], quantity: json['quantity']);

  static dynamic getListMap(List<dynamic> items) {
    if (items == null) {
      return null;
    }
    List<Ingredient> list = [];
    items.forEach((element) {
      list.add(element.toMap());
    });
    return list;
  }
}
