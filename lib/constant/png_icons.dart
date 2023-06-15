import 'package:flutter/material.dart';

class PngIcons {
  //icone di base
  static const cart = "assets/icons/cart.png";
  static const home = "assets/icons/home.png";
  static const search = "assets/icons/search.png";
  //food type
  static const burger = "assets/icons/bebidas.png";
  static const cocktail = "assets/images/bebidas.png";
  static const drink = "assets/images/bebidas.png";
  static const fries = "assets/images/bebidas.png";
  static const pizza = "assets/images/bebidas.png";
  static const salad = "assets/images/bebidas.png";

  static ImageIcon withName(String path, {double size = 24, Color? color}) =>
      ImageIcon(
        AssetImage(path),
        size: size,
        color: color,
      );
}
