import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/food.dart';
import 'package:lanchonet/models/foods/doces.dart';
import 'package:lanchonet/models/foods/ingredient.dart';
import 'package:lanchonet/models/foods/pratofeito.dart';
import 'package:lanchonet/services/theme_service.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/enums.dart';
import '../../models/foods/bebidas.dart';
import '../../models/foods/lanches.dart';
import '../perfil_page/login_page.dart';
import 'package:image_picker/image_picker.dart';

class CadastroProdutos extends StatefulWidget {
  @override
  State<CadastroProdutos> createState() => _CadastroProdutosState();
}

class _CadastroProdutosState extends State<CadastroProdutos> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  Stream<List<Ingredient>> readIngredientes() => FirebaseFirestore.instance
      .collection('ingrediente')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Ingredient.fromJson(doc.data())).toList());
  final form = GlobalKey<FormState>();
  final FirebaseStorage storage = FirebaseStorage.instance;
  var nomecontroller = TextEditingController();
  var precocontroller = TextEditingController();
  var descricaocontroller = TextEditingController();
  List<Ingredient> ingredientcontroller = [];
  var iconcontroller = TextEditingController();
  var foodtypecontroller = FoodType.doces;
  var foodcategorycontroller = FoodCategory.normal;
  var qtdecontroller = TextEditingController();
  var listcontroll = 0;
  var file;
  String url = '';
  bool camera = false;
  Widget buildIngrediente(List<Ingredient> ingredientes) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Container(
        child: MultiSelectDialogField<Ingredient>(
      decoration: BoxDecoration(
        color: themeState.getDarktheme
            ? Color.fromARGB(255, 48, 48, 48)
            : Color.fromARGB(255, 255, 255, 255),
      ),
      buttonText: Text(
        'Escolher',
        style: Theme.of(context).textTheme.headline3?.copyWith(
              fontSize: 25,
            ),
      ),
      title: Text("Escolha os ingredientes"),
      checkColor: AppColor.titleTextColor,
      unselectedColor: Color.fromARGB(83, 255, 255, 255),
      selectedColor: Color.fromARGB(48, 226, 8, 8),
      cancelText: Text(
        'Cancelar',
        style: Theme.of(context).textTheme.headline3?.copyWith(
              fontSize: 15,
            ),
      ),
      confirmText: Text(
        'Aceitar',
        style: Theme.of(context).textTheme.headline3?.copyWith(
              fontSize: 15,
            ),
      ),
      items: ingredientes.map((e) => MultiSelectItem(e, e.name)).toList(),
      listType: MultiSelectListType.CHIP,
      chipDisplay: MultiSelectChipDisplay(
        height: 40,
        scroll: true,
      ),
      onConfirm: (values) {
        ingredientcontroller = values;
      },
    ));
  }

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<String> upload(String path, String url) async {
    File file = File(path);
    try {
      String ref = 'comidas/${nomecontroller.text}.jpg';
      await storage.ref(ref).putFile(file);
      url = await storage.ref(ref).getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao enviar arquivo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de produtos',
            style: Theme.of(context).textTheme.headline3),
        leading: BackButton(
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        key: form,
        children: <Widget>[
          TextFormField(
            controller: nomecontroller,
            decoration: InputDecoration(
              labelText: 'Nome do Produto',
              border: OutlineInputBorder(),
              labelStyle: Theme.of(context).textTheme.headline3?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite o nome do Produto';
              }
            },
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: precocontroller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Preço do Produto',
              labelStyle: Theme.of(context).textTheme.headline3?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite o preço do Produto';
              }
            },
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: descricaocontroller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Descrição do Produto',
              labelStyle: Theme.of(context).textTheme.headline3?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite a descrição do Produto';
              }
            },
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: qtdecontroller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantidade do Produto',
              labelStyle: Theme.of(context).textTheme.headline3?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite a quantidade do Produto';
              }
            },
          ),
          SizedBox(
            height: 15,
          ),
          Container(
              width: MediaQuery.of(context).size.width * .6,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 60),
                  primary: AppColor.primaryColor,
                ),
                onPressed: () async {
                  XFile? file = await getImage();
                  this.file = file;
                },
                child: Text(
                  'Adicionar Imagem',
                  style: Theme.of(context).textTheme.headline3?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                ),
              )),
          SizedBox(
            height: 35,
          ),
          Column(
            children: <Widget>[
              Text(
                "Categoria:",
              ),
              Divider(),
              RadioListTile(
                title: Text("Lanche"),
                value: FoodType.lanches,
                groupValue: foodtypecontroller,
                onChanged: (value) {
                  setState(() {
                    foodtypecontroller = FoodType.lanches;
                  });
                },
              ),
              RadioListTile(
                title: Text("Doce"),
                value: FoodType.doces,
                groupValue: foodtypecontroller,
                onChanged: (value) {
                  setState(() {
                    foodtypecontroller = FoodType.doces;
                  });
                },
              ),
              RadioListTile(
                title: Text("Bebida"),
                value: FoodType.bebidas,
                groupValue: foodtypecontroller,
                onChanged: (value) {
                  setState(() {
                    foodtypecontroller = FoodType.bebidas;
                  });
                },
              ),
              RadioListTile(
                title: Text("Prato Feito"),
                value: FoodType.pratofeito,
                groupValue: foodtypecontroller,
                onChanged: (value) {
                  setState(() {
                    foodtypecontroller = FoodType.pratofeito;
                  });
                },
              ),
            ],
          ),
          SizedBox(
            height: 35,
          ),
          Center(
            child: Text('Ingredientes:'),
          ),
          Divider(),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            width: 30.0,
            height: 101.0,
            child: StreamBuilder<List<Ingredient>>(
              stream: readIngredientes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  List<String> ingredientes = ['A'];
                  final Produtos = snapshot.data!;
                  for (var x = 0; x < Produtos.length; x++) {
                    ingredientes.add(Produtos[x].name);
                  }
                  return buildIngrediente(Produtos);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            width: MediaQuery.of(context).size.width * .4,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.3, 1],
                colors: [
                  Color.fromARGB(255, 219, 29, 29),
                  Color.fromARGB(255, 221, 81, 81),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            child: SizedBox.expand(
              child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Cadastrar",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 20),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                  onPressed: () {
                    final id = nomecontroller.text;
                    final name = nomecontroller.text;
                    final descricao = descricaocontroller.text;
                    int quantity =
                        int.parse(qtdecontroller.text.replaceAll(",", ""));
                    double preco =
                        double.parse(precocontroller.text.replaceAll(",", ""));

                    Food comida;
                    List<Ingredient> list = [];
                    Future createProduto({required String nome}) async {
                      try {
                        String image = '';
                        if (file != null) {
                          image = await upload(file.path, url);
                        }
                        final docProduto = FirebaseFirestore.instance
                            .collection('produtos')
                            .doc(id);
                        for (var x = 0; x < ingredientcontroller.length; x++) {
                          Ingredient ingrediente = Ingredient(
                              id: ingredientcontroller[x].id,
                              name: ingredientcontroller[x].name,
                              icon: ingredientcontroller[x].icon,
                              quantity: ingredientcontroller[x].quantity);
                        }
                        if (foodtypecontroller == FoodType.bebidas) {
                          comida = Bebidas(
                              id: id,
                              name: name,
                              price: preco,
                              description: descricao,
                              image: image,
                              ingredients: ingredientcontroller,
                              isFavourite: false,
                              isPopular: false,
                              quantity: quantity);
                        } else if (foodtypecontroller == FoodType.doces) {
                          comida = Doces(
                              id: id,
                              name: name,
                              price: preco,
                              description: descricao,
                              image: image,
                              ingredients: ingredientcontroller,
                              isFavourite: false,
                              isPopular: false,
                              quantity: quantity);
                        } else if (foodtypecontroller == FoodType.lanches) {
                          comida = Lanches(
                              id: id,
                              name: name,
                              price: preco,
                              description: descricao,
                              image: image,
                              ingredients: ingredientcontroller,
                              isFavourite: false,
                              isPopular: false,
                              quantity: quantity);
                        } else if (foodtypecontroller == FoodType.pratofeito) {
                          comida = PratoFeito(
                            id: id,
                            name: name,
                            price: preco,
                            description: descricao,
                            image: image,
                            ingredients: ingredientcontroller,
                            isFavourite: false,
                            isPopular: false,
                            quantity: quantity,
                            observe: '',
                          );
                        } else {
                          return Text('Por favor, selecione o tipo de comida.');
                        }

                        var json = comida.toJson();

                        await docProduto.set(json);
                      } on FirebaseException catch (e) {
                        Center(
                          child: Text('Error $e'),
                        );
                      } on FirebaseException catch (e) {
                        Center(
                          child: Text('Error $e'),
                        );
                      }
                    }

                    createProduto(nome: name);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
