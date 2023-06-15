import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lanchonet/models/foods/pratofeito.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/enums.dart';
import '../../models/food.dart';
import '../../models/foods/bebidas.dart';
import '../../models/foods/doces.dart';
import '../../models/foods/ingredient.dart';
import '../../models/foods/lanches.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';

class EditarProdutos extends StatefulWidget {
  final Food food;
  const EditarProdutos({
    required this.food,
    Key? key,
  }) : super(key: key);
  @override
  _EditarProdutos createState() => _EditarProdutos();
}

class _EditarProdutos extends State<EditarProdutos> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  var foodtypecontroller = FoodType.lanches;

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
    if (widget.food.foodType == 'FoodType.bebidas') {
      foodtypecontroller = FoodType.bebidas;
    } else if (widget.food.foodType == 'FoodType.doces') {
      foodtypecontroller = FoodType.doces;
    } else if (widget.food.foodType == 'FoodType.pratofeito') {
      foodtypecontroller = FoodType.pratofeito;
    }
  }

  Future<Usuario?> readUser(uid) async {
    final docUser =
        FirebaseFirestore.instance.collection('perfil_geral').doc(uid);
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return Usuario.fromJson(snapshot.data()!);
    } else if (snapshot.exists == true) {
      print('tem algo errado');
    }
  }

  final form = GlobalKey<FormState>();
  var nomecontroller = TextEditingController();
  var precocontroller = TextEditingController();
  var descricaocontroller = TextEditingController();
  var iconcontroller = TextEditingController();
  var qtdecontroller = TextEditingController();
  List<Ingredient> ingredientcontroller = [];
  final FirebaseStorage storage = FirebaseStorage.instance;
  var file;
  String url = '';
  bool camera = false;

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

  Stream<List<Ingredient>> readIngredientes() => FirebaseFirestore.instance
      .collection('ingrediente')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Ingredient.fromJson(doc.data())).toList());
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

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Produtos',
          style: Theme.of(context).textTheme.headline3,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          padding: EdgeInsets.only(left: 15, top: 20, right: 15),
          child: GestureDetector(
              child: Form(
                  key: form,
                  child: ListView(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                                onTap: () {
                                    showDialog(context: context, builder: (context) {
                                    return AlertDialog(
                                    content: Image.network(widget.food.image),
                                      );
                                     },
                                   );
                                  },
                              child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 4, color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.1))
                                  ],
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(widget.food.image))),
                            ),
                           ),
                           
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 4,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    color: Color.fromARGB(255, 255, 0, 0)),
                                child: GestureDetector(
                                    child: Icon(Icons.edit,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                topLeft: Radius.circular(20)),
                                          ),
                                          builder: ((context) {
                                            return Container(
                                              height: 150,
                                              child: ListView(
                                                children: <Widget>[
                                                  ListTile(
                                                    title: Text('Editar foto'),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons
                                                        .add_photo_alternate),
                                                    title: Text('Alterar foto'),
                                                    onTap: () async {
                                                      XFile? file =
                                                          await getImage();
                                                      this.file = file;
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  // ListTile(
                                                  //   leading: Icon(Icons.delete),
                                                  //   title: Text('Excluir foto'),
                                                  // ),
                                                ],
                                              ),
                                            );
                                          }));
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        child: Text(
                          "Nome",
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 168, 168, 168),
                              fontFamily: 'Montserrat'),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                          controller: nomecontroller,
                          decoration: InputDecoration(
                            hintText: widget.food.name,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              value = widget.food.name;
                              nomecontroller.text = widget.food.name;
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction),
                      SizedBox(height: 10),
                      Container(
                        child: Text(
                          "Preço",
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 168, 168, 168),
                              fontFamily: 'Montserrat'),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                        keyboardType: TextInputType.number,
                        controller: precocontroller,
                        decoration: InputDecoration(
                          hintText: widget.food.price.toString(),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 168, 168, 168),
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            value = widget.food.price.toString();
                            precocontroller.text = widget.food.price.toString();
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Descrição",
                        style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 168, 168, 168),
                            fontFamily: 'Montserrat'),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                        controller: descricaocontroller,
                        decoration: InputDecoration(
                          hintText: widget.food.description,
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 168, 168, 168),
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            value = widget.food.description;
                            descricaocontroller.text = widget.food.description;
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(height: 10),
                      Container(

                        child: Text(
                          "Quantidade do Produto",
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 168, 168, 168),
                              fontFamily: 'Montserrat'),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                        controller: qtdecontroller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: widget.food.quantity.toString(),
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 168, 168, 168),
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            value = widget.food.quantity.toString();
                            qtdecontroller.text = value;
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(
                        height: 15,
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
                        height: 30,
                      ),
                      Center(
                        child: Text('Ingredientes:'),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 50.0,
                        height: 100.0,
                        child: StreamBuilder<List<Ingredient>>(
                          stream: readIngredientes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasData) {
                              List<String> ingredientes = [];
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
                      Container(
                        height: 40,
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
                                    "Alterar Produto",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20),
                                  )
                                ],
                              ),
                              onPressed: () async {
                                final isValid = form.currentState!.validate();

                                String image = '';
                                if (file != null) {
                                  image = await upload(file.path, url);
                                } else {
                                  image = widget.food.image;
                                }


                                if (isValid) {
                                  final name = nomecontroller.text;
                                  final descricao = descricaocontroller.text;
                                  final icon = image;
                                  final quantity = int.parse(
                                      qtdecontroller.text.replaceAll(",", ""));
                                  final preco = double.parse(
                                      precocontroller.text.replaceAll(",", ""));
                                  var comida = null;
                                  final docProduto = FirebaseFirestore.instance
                                      .collection('produtos')
                                      .doc(widget.food.id);
                                  Future updateProduto() async {
                                    if (foodtypecontroller ==
                                        FoodType.bebidas) {
                                      comida = Bebidas(
                                          id: widget.food.id,
                                          name: name,
                                          price: preco,
                                          description: descricao,
                                          image: icon,
                                          ingredients: ingredientcontroller,
                                          isFavourite: false,
                                          isPopular: false,
                                          quantity: quantity);
                                    } else if (foodtypecontroller ==
                                        FoodType.doces) {
                                      comida = Doces(
                                          id: widget.food.id,
                                          name: name,
                                          price: preco,
                                          description: descricao,
                                          image: icon,
                                          ingredients: ingredientcontroller,
                                          isFavourite: false,
                                          isPopular: false,
                                          quantity: quantity);
                                    } else if (foodtypecontroller ==
                                        FoodType.lanches) {
                                      comida = Lanches(
                                          id: widget.food.id,
                                          name: name,
                                          price: preco,
                                          description: descricao,
                                          image: icon,
                                          ingredients: ingredientcontroller,
                                          isFavourite: false,
                                          isPopular: false,
                                          quantity: quantity);
                                    } else if (foodtypecontroller ==
                                        FoodType.pratofeito) {
                                      comida = PratoFeito(
                                          id: widget.food.id,
                                          name: name,
                                          price: preco,
                                          description: descricao,
                                          image: image,
                                          ingredients: ingredientcontroller,
                                          isFavourite: false,
                                          isPopular: false,
                                          quantity: quantity,
                                          observe: '');
                                    }

                                    var json = comida.toJson();
                                    await docProduto.set(json);
                                  }

                                  updateProduto();
                                  // atualizarAuthSenha(senha);
                                  Navigator.pushNamed(context, 'mainuserpage');
                                }
                              }),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  )))),
    );
  }
// Widget buildTextField(String labelText, String placeholderm, bool isPasswordTextField){
// return Padding(padding:
// EdgeInsets.only(bottom: 30),
// child: TextField(
//  keyboardType: TextInputType.text,
//  obscureText: isPasswordTextField == false,
//   decoration: InputDecoration(
//     suffixIcon: isPasswordTextField ?
//     IconButton(icon: Icon(Icons.remove_red_eye, color: Colors.grey),
//     onPressed: () { }
//     ): null,
//     contentPadding: EdgeInsets.only(bottom: 5),
//     labelText: labelText,
//     hintStyle: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//       color: Colors.grey
//     )
//   ),
// ),
// );
}
