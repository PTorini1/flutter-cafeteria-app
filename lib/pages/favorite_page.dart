import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/data/food_fake_data.dart';
import '../common_widgets/food_box.dart';
import '../models/food.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  _buildPage(BuildContext context) {
    return StreamBuilder<List<Food>>(
      stream: readProdutos(),
      builder: (context, snapshot) {
        final comidas = snapshot.data;
        return StreamBuilder<List<Food>>(
          stream: readComidasFavoritas(),
          builder: (context, snapshot) {
            bool deletar = true;
            var comidadeletavel;
            List<Food> comidasFavs = [];
            final produto = snapshot.data;
            if (produto != null && comidas != null) {
              for (var y = 0; y < produto.length; y++) {
                for (var x = 0; x < comidas.length; x++) {
                  if (comidas[x].id == produto[y].id) {
                    deletar = false;
                  } else {
                    comidadeletavel = produto[y];
                  }
                }
              }
              if (deletar == true) {
                final docProdFav = FirebaseFirestore.instance
                    .collection('perfil_geral')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('produtos')
                    .doc(comidadeletavel.id);
                docProdFav.delete();
              }
              for (var x = 0; x < produto.length; x++) {
                if (produto[x].isFavourite == true) {
                  for (var y = 0; y < comidas.length; y++) {
                    if (produto[x].id == comidas[y].id) {
                      comidasFavs.add(comidas[y]);
                    }
                  }
                }
              }
              return SafeArea(
                  child: comidasFavs.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/no_favorite_food.jpg"),
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(child: Text("Sem Favoritos")),
                            const Spacer()
                          ],
                        )
                      : GridView(
                          padding: const EdgeInsets.all(5.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                          ),
                          children: comidasFavs
                              .map((food) => FoodBox(
                                    food: food,
                                    onNavigate: () async {
                                      //rebuild when user navigate.pop

                                      final bool? _rebuildPage =
                                          await Navigator.of(context).pushNamed(
                                              "detail",
                                              arguments: food) as bool?;
                                      //if user changed favorite item, this page will rebuild !
                                      //rebuild only if user change that value ! :P
                                      if (_rebuildPage != null &&
                                          _rebuildPage) {
                                        setState(() {});
                                      }
                                    },
                                  ))
                              .toList(),
                        ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }
}
