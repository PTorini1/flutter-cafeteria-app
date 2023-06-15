import 'package:lanchonet/helpers/cart_handler.dart';
import 'package:lanchonet/models/user.dart';

class Pedidos {
  final String id;
  final Usuario cliente;
  final CartProvider pedido;
  final bool pronto;
  final bool entregue;
  final String formadepagamento;
  final String token;

  Pedidos({
    required this.id,
    required this.cliente,
    required this.pedido,
    required this.pronto,
    required this.entregue,
    required this.formadepagamento,
    required this.token,
  });

  static Pedidos fromJson(Map<String, dynamic> json) {
    Pedidos pedido = Pedidos(
        id: json['id'],
        cliente: Usuario.fromJson(json['cliente']),
        pedido: CartProvider.fromMap(json['pedido']),
        pronto: json['pronto'],
        entregue: json['entregue'],
        formadepagamento: json['formadepagamento'],
        token: json['token']);
    return pedido;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cliente': cliente.toJson(),
        'pedido': pedido.toJson(),
        'entregue': entregue,
        'pronto': pronto,
        'formadepagamento': formadepagamento,
        'token': token
      };
}
