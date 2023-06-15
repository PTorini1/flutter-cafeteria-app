import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/data/food_fake_data.dart';
import 'package:lanchonet/helpers/cart_handler.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:lanchonet/models/foods/ingredient.dart';
import 'package:lanchonet/services/theme_service.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/food.dart';
import 'package:lanchonet/pages/food_detail_page/component/quantity_handler.dart';
import 'component/rounded_container.dart';
import 'package:provider/provider.dart';

class FoodDetailPage extends StatefulWidget {
  final Food food;
  const FoodDetailPage({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> with WidgetsBindingObserver {
  int quantity = 1;
  bool click = false;
  late final bool userChangeFavorite;

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  Widget build(
    BuildContext context,
  ){
    var observecontroller = TextEditingController();

    //in questo modo fixo: se andavo indietro con il tasto android non mi ribuildava la page precedente !
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .pop(userChangeFavorite != widget.food.isFavourite);
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context, observecontroller),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: click ? SizedBox() : _buildFab(context, observecontroller)
      ),
    );
  }

  _buildAppBar(BuildContext context) => AppBar(
        leading: InkWell(
          //if user changed favorite item -> rebuild previous page to see modify
          onTap: () => Navigator.of(context)
              .pop(userChangeFavorite != widget.food.isFavourite),
          child: BackButton(
            color: AppColor.primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        centerTitle: true,
        title: //food name
            Text(
          widget.food.name,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: RoundedContainer(
              color: AppColor.primaryColor,
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, 'editarProdutos',
                      arguments: widget.food);
                },
              ),
            ),
          ),
          InkWell(
            onTap: () {
              widget.food.isFavourite = !widget.food.isFavourite;
              setState(() {});
            },
            child: FutureBuilder(
                future: ifComida(widget.food),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final comida = snapshot.data;
                    return RoundedContainer(
                      color: AppColor.primaryColor,
                      child: IconButton(
                        onPressed: () async {
                          final docProduto = FirebaseFirestore.instance
                              .collection('perfil_geral')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('produtos')
                              .doc(widget.food.id);
                          Future updateProduto() async {
                            var json = widget.food.toJson();
                            await docProduto.set(json);
                          }

                          final snapshot = await docProduto.get();

                          Food comida = Food.fromJson(snapshot.data()!);
                          setState(() {
                            if (widget.food.isFavourite == false) {
                              widget.food.isFavourite = true;
                              comida.isFavourite = true;
                            } else {
                              widget.food.isFavourite = false;
                              comida.isFavourite = false;
                            }
                          });
                          updateProduto();
                        },
                        icon: Icon(comida!.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        color: Colors.white,
                      ),
                    );
                  } else if (snapshot.hasData == false) {
                    return RoundedContainer(
                      color: AppColor.primaryColor,
                      child: IconButton(
                        onPressed: () async {
                          setState(() {
                            widget.food.isFavourite = true;
                          });
                          final docProduto = FirebaseFirestore.instance
                              .collection('perfil_geral')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('produtos')
                              .doc(widget.food.id);
                          Future updateProduto() async {
                            var json = widget.food.toJson();
                            await docProduto.set(json);
                          }

                          updateProduto();
                        },
                        icon: Icon(widget.food.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        color: Colors.white,
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ],
      );
  _buildBody(BuildContext context, TextEditingController observecontroller) =>
      Builder(
        builder: (context) {
          final themeState = Provider.of<DarkThemeProvider>(context);
          return GestureDetector(
            onTap:() {
              FocusScope.of(context).unfocus();
              setState(() {
                click = false;
              });
            }, 
            child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 8, child: _buildDetailsImage()),
                    Text(
                      "R\$ ${widget.food.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      flex: click ? 2 : 0,
                      child: Text(
                        "Ingredientes",
                        style: Theme.of(context).textTheme.headline3?.copyWith(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    //lista ingredienti
                    Expanded(
                      flex: click ? 3 : 2,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: widget.food.ingredients
                            .map((data) => _buildIngredient(context, data))
                            .toList(),
                      ),
                    ),
                   click ?  SizedBox() : SizedBox(height: 10),
                    Expanded(
                      flex: click ? 0 : 1,
                      child: click ? SizedBox() : Text(
                        "Detalhes",
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            ?.copyWith(fontSize: 24.0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                        flex: click ? 0 : 3,
                        child: click ? SizedBox() : Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: themeState.getDarktheme
                                  ? Color.fromARGB(255, 66, 66, 66)
                                  : Color.fromARGB(255, 245, 243, 243)),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                widget.food.description,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: themeState.getDarktheme
                                      ? Color.fromARGB(255, 228, 228, 228)
                                      : Color.fromARGB(255, 61, 60, 60),
                                ),
                              ),
                            ),
                          ),
                        ) ),
                    SizedBox(
                      height: 25,
                    ),
                    Builder(
                      builder: (context) {
                        final isKeyboard = WidgetsBinding.instance.window.viewInsets.bottom > 0.0;
                        if (widget.food.foodType == 'FoodType.pratofeito') {
                          return Expanded(
                            flex: click ? 5 : 4,
                            child: TextFormField(
                               onTap: () {
                                setState(() {
                                  click = true;
                                });
                              },
                              onFieldSubmitted: (value) {
                                setState(() {
                                  click = false;
                                });
                              },
                              
                              controller: observecontroller,
                              cursorColor: themeState.getDarktheme ? AppColor.primaryColor : Colors.blue,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Faça uma observação',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    )
                  ]),
            ),
          )
        );
        },
      );

  Row _buildDetailsImage() {
    return Row(
      children: [
        Expanded(
            flex: 6,
            child: (widget.food.image.toString() == '')
                ? const Center(
                    child: Text(
                    'Sem Imagem',
                    style: TextStyle(fontSize: 16),
                  ))
                : Image.network(
                    widget.food.image.toString(),
                    fit: BoxFit.fill,
                  )),
      ],
    );
  }

  Widget _buildIngredient(BuildContext context, Ingredient ingredient) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.40,
      margin: const EdgeInsets.fromLTRB(0, 10, 5, 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              width: 1.0,
              color: themeState.getDarktheme
                  ? Color.fromARGB(255, 255, 255, 255)
                  : Color.fromARGB(255, 17, 19, 22))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(ingredient.icon.toString()),
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              ingredient.name.toString(),
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
        ],
      ),
    );
  }

  _buildFab(BuildContext context, TextEditingController observecontroller) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        QuantityHandler(
          onBtnTapped: (val) => quantity = val,
        ),
        Container(
          width: MediaQuery.of(context).size.width - 160,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(200, 60),
              primary: AppColor.primaryColor,
            ),
            onPressed: () {
              widget.food.observe = observecontroller.text;
              String salvar = '0';
              if (quantity > 0) {
                if (context.read<CartProvider>().foods.isEmpty) {
                  salvar = 'verdadeiro';
                } else {
                  for (var x = 0;
                      x < context.read<CartProvider>().foods.length;
                      x++) {
                    if (context.read<CartProvider>().foods.elementAt(x).name ==
                        widget.food.name) {
                      salvar = 'falso';
                    }
                    else{
                      salvar = 'verdadeiro';
                    }
                  }
                }
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(_buildSnackBar(context, haveError: true));
              }
              if (salvar == 'falso') {
                context.read<CartProvider>().addQuantity(widget.food, quantity);
                //show SnackBar to tell user "added to cart" :P
                ScaffoldMessenger.of(context)
                    .showSnackBar(_buildSnackBar(context));
              } else if (salvar == 'verdadeiro') {
                context.read<CartProvider>().addItem(widget.food, quantity);
                //show SnackBar to tell user "added to cart" :P
                ScaffoldMessenger.of(context)
                    .showSnackBar(_buildSnackBar(context));
              }
              // if (context.read<CartProvider>().foods.isEmpty) {
              //   if (quantity > 0) {
              //     context.read<CartProvider>().addItem(widget.food, quantity);
              //     //show SnackBar to tell user "added to cart" :P
              //     ScaffoldMessenger.of(context)
              //         .showSnackBar(_buildSnackBar(context));
              //   } else {
              //     ScaffoldMessenger.of(context)
              //         .showSnackBar(_buildSnackBar(context, haveError: true));
              //   }
              // } else {
              //   for (var x = 0;
              //       x < context.read<CartProvider>().foods.length;
              //       x++) {
              //     if (quantity > 0) {
              //       if (context.read<CartProvider>().foods.elementAt(x).name ==
              //           widget.food.name) {
              //         context
              //             .read<CartProvider>()
              //             .addQuantity(widget.food, quantity);
              //         ScaffoldMessenger.of(context)
              //             .showSnackBar(_buildSnackBar(context));
              //       } else {
              //         context.read<CartProvider>().addItem(widget.food, quantity);
              //       }
              //     } else {
              //       ScaffoldMessenger.of(context)
              //           .showSnackBar(_buildSnackBar(context, haveError: true));
              //     }
              //   }
              // }
            },
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'Adicionar ao Carrinho',
                style: TextStyle(color: AppColor.textDark, fontSize: 20),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  SnackBar _buildSnackBar(BuildContext context, {bool haveError = false}) =>
      SnackBar(
        //on tap => open cartPage
        backgroundColor:
            haveError ? AppColor.primaryColor : AppColor.primaryColor,
        duration: const Duration(milliseconds: 1500),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              haveError
                  ? "Escolha a quantidade"
                  : "${quantity}x ${widget.food.name} Adicionado ao carrinho!",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (!haveError)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  //pop perchè la pagina precedente deve avere un valore
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    "cart",
                    (route) => false,
                  );
                },
                child: Text(
                  "Continuar",
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(color: AppColor.textDark, fontSize: 15),
                ),
              )
          ],
        ),
      );
}
