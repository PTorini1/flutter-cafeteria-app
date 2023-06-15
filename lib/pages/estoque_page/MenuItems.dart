import 'package:flutter/material.dart';

class MenuItem {
  final String text;
  final IconData? icon;

  const MenuItem({
    required this.text,
    this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> primeiro = [
    itemIngredientes,
    itemRelatorio,
    // itemImprimir
  ];

  static const List<MenuItem> segundo = [
    filtro,
    maior,
    menor,
  ];

  static const itemIngredientes =
      MenuItem(text: 'Estoque de Ingredientes', icon: Icons.liquor_sharp);

  static const itemRelatorio = MenuItem(
    text: 'Gerar Relatório do Estoque',
    icon: Icons.print
  );

  static const filtro = MenuItem(
    text: 'Filtrar por Quantidade',
  );

  static const maior = MenuItem(text: 'Mais', icon: Icons.move_up_sharp);

  static const menor = MenuItem(text: 'Menos', icon: Icons.move_down_sharp);
}
