import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/data/food_fake_data.dart';
import 'package:lanchonet/helpers/cart_handler.dart';
import 'package:lanchonet/models/food.dart';
import 'package:lanchonet/pages/notify_page.dart';
import 'package:lanchonet/pages/pagamento_page/cartao_de_credito/pagamento_cartao.dart';
import 'package:lanchonet/pages/pagamento_page/pix/dados_pix.dart';
import 'package:provider/provider.dart';

import '../models/pedidos.dart';
import '../models/user.dart';
import '../services/theme_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String valorPix = "";
  double valor = 0;
  double valorPixDouble = 0;
  Map<String, dynamic> dadosPix = Map();
  String? mtoken = '';

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print('My token is $mtoken');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    //final Set<Food> _cartFoods = CartHandler.foods;
    return Consumer<CartProvider>(builder: (context, cartProv, _) {
      if (cartProv.foods.isEmpty) {
        return Center(child: Text("O Carrinho Está Vazio"));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //list with orders in the cart
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView(
              children: cartProv.foods
                  .map((food) => _buildFoodBox(context, food, cartProv))
                  .toList(),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(36, 0, 36, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "R\$ ${cartProv.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                          ),
                          builder: ((context) {
                            return FutureBuilder(
                              future: readUserLogged(),
                              builder: (context, snapshot) {
                                final user = snapshot.data;
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Container(
                                  height: 300,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('Forma de pagamento'),
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      ListTile(
                                          leading:
                                              Icon(Icons.attach_money_outlined),
                                          title: Text('Pix'),
                                          onTap: () {
                                            valorPix =
                                                cartProv.amount.toString();
                                            valor = cartProv.amount;
                                            valorPixDouble = valor;
                                            dadosPix = {
                                              "valorPixDouble": valorPixDouble,
                                              "valorPix": valorPix
                                            };
                                            String id =
                                                DateTime.now().toString();
                                            Usuario usuario = user!;
                                            CartProvider carrinho = cartProv;
                                            Future createPedido() async {
                                              try {
                                                final docPedido =
                                                    FirebaseFirestore.instance
                                                        .collection('pedidos')
                                                        .doc(id.toString());
                                                Pedidos pedido = Pedidos(
                                                  token: mtoken!,
                                                  id: id.toString(),
                                                  cliente: usuario,
                                                  pedido: carrinho,
                                                  pronto: false,
                                                  entregue: false,
                                                  formadepagamento: 'Pix',
                                                );
                                                var json = pedido.toJson();
                                                await docPedido.set(json);
                                              } on FirebaseException catch (e) {
                                                Center(
                                                  child: Text('Error $e'),
                                                );
                                              }
                                            }

                                            Future updateEstoque(Food x) async {
                                              try {
                                                final docProduto =
                                                    FirebaseFirestore.instance
                                                        .collection('produtos')
                                                        .doc(x.id);
                                                for (var y in carrinho
                                                    .quantity.values) {
                                                  x.quantity =
                                                      x.quantity - y as int;
                                                }
                                                var json = x.toJson();
                                                await docProduto.set(json);
                                              } on FirebaseException catch (e) {
                                                Center(
                                                  child: Text('Error$e'),
                                                );
                                              }
                                            }

                                            for (var x in carrinho.foods) {
                                              updateEstoque(x);
                                            }

                                            createPedido();
                                            carrinho.foods.clear();
                                            carrinho.amount = 0;
                                            carrinho.quantity.clear();
                                            carrinho.itemsLength = 0;
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DadosPix(dadosPix)));
                                          }),
                                      ListTile(
                                        leading: Icon(Icons.credit_card),
                                        title:
                                            Text('Cartão de crédito ou débito'),
                                        onTap: () {
                                          valor = cartProv.amount;
                                          var cartao = PagamentoCartao(valor);
                                          cartao.setValor(valor);
                                          cartao.gerarPreferencia();
                                          String id = DateTime.now().toString();
                                          Usuario usuario = user!;
                                          CartProvider carrinho = cartProv;
                                          Future createPedido() async {
                                            try {
                                              final docPedido =
                                                  FirebaseFirestore.instance
                                                      .collection('pedidos')
                                                      .doc(id.toString());
                                              Pedidos pedido = Pedidos(
                                                token: mtoken!,
                                                id: id.toString(),
                                                cliente: usuario,
                                                pedido: carrinho,
                                                pronto: false,
                                                entregue: false,
                                                formadepagamento:
                                                    'Cartão de Crédito ou Débito',
                                              );
                                              var json = pedido.toJson();
                                              await docPedido.set(json);
                                            } on FirebaseException catch (e) {
                                              Center(
                                                child: Text('Error $e'),
                                              );
                                            }
                                          }

                                          Future updateEstoque(Food x) async {
                                            try {
                                              final docProduto =
                                                  FirebaseFirestore.instance
                                                      .collection('produtos')
                                                      .doc(x.id);
                                              for (var y
                                                  in carrinho.quantity.values) {
                                                x.quantity =
                                                    x.quantity - y as int;
                                              }
                                              var json = x.toJson();
                                              await docProduto.set(json);
                                            } on FirebaseException catch (e) {
                                              Center(
                                                child: Text('Error$e'),
                                              );
                                            }
                                          }

                                          for (var x in carrinho.foods) {
                                            updateEstoque(x);
                                          }

                                          createPedido();
                                          carrinho.foods.clear();
                                          carrinho.amount = 0;
                                          carrinho.quantity.clear();
                                          carrinho.itemsLength = 0;
                                        },
                                      ),
                                      ListTile(
                                          leading:
                                              Icon(Icons.attach_money_outlined),
                                          title: Text('Dinheiro'),
                                          onTap: () {
                                            String id =
                                                DateTime.now().toString();
                                            Usuario usuario = user!;
                                            CartProvider carrinho = cartProv;
                                            Future createPedido() async {
                                              try {
                                                final docPedido =
                                                    FirebaseFirestore.instance
                                                        .collection('pedidos')
                                                        .doc(id.toString());
                                                Pedidos pedido = Pedidos(
                                                  token: mtoken!,
                                                  id: id.toString(),
                                                  cliente: usuario,
                                                  pedido: carrinho,
                                                  pronto: false,
                                                  entregue: false,
                                                  formadepagamento: 'Pix',
                                                );
                                                var json = pedido.toJson();
                                                await docPedido.set(json);
                                              } on FirebaseException catch (e) {
                                                Center(
                                                  child: Text('Error $e'),
                                                );
                                              }
                                            }

                                            Future updateEstoque(Food x) async {
                                              try {
                                                final docProduto =
                                                    FirebaseFirestore.instance
                                                        .collection('produtos')
                                                        .doc(x.id);
                                                for (var y in carrinho
                                                    .quantity.values) {
                                                  x.quantity =
                                                      x.quantity - y as int;
                                                }
                                                var json = x.toJson();
                                                await docProduto.set(json);
                                              } on FirebaseException catch (e) {
                                                Center(
                                                  child: Text('Error$e'),
                                                );
                                              }
                                            }

                                            for (var x in carrinho.foods) {
                                              updateEstoque(x);
                                            }

                                            createPedido();
                                            carrinho.foods.clear();
                                            carrinho.amount = 0;
                                            carrinho.quantity.clear();
                                            carrinho.itemsLength = 0;
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ExpansionPage()));
                                          }),
                                    ],
                                  ),
                                );
                              },
                            );
                          }));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade100,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: const [
                          Text(
                            "Comprar",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  //button for order products

  Widget _buildFoodBox(BuildContext context, Food food, CartProvider cart) {
    final int foodQuantity = cart.quantity[food.name]!;
    final double foodAmount = food.price * foodQuantity;
    Set<Food> foods;
    for (var x = 0; x < cart.foods.length; x++) {
      if (cart.foods.elementAt(x) == food) {
        cart.foods.remove(x);
      }
    }
    return Padding(
        padding: EdgeInsets.all(12),
        child: Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            leading: (food.image.toString() == '')
                ? Text(
                    '',
                    style: TextStyle(fontSize: 16),
                  )
                : Image.network(food.image),
            title: Text(food.name,
                style: Theme.of(context).textTheme.headline3?.copyWith(
                      fontSize: 16,
                    )),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "R\$ ${foodAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: AppColor.transparentColor, fontSize: 22.0),
                ),
                Text(
                  "${cart.quantity[food.name]}x",
                  style: const TextStyle(
                      color: AppColor.transparentColor, fontSize: 22.0),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: AppColor.primaryColor,
              ),
              //remove element from the cart
              onPressed: () {
                //CartHandler.removeItem(food);
                cart.removeItem(food);
              },
            ),
          ),
        ));
  }
}
