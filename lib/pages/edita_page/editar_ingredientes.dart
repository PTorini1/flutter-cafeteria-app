import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/foods/ingredient.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';

class EditarIngrediente extends StatefulWidget {
  final Ingredient ingredient;
  const EditarIngrediente({
    required this.ingredient,
    Key? key,
  }) : super(key: key);
  @override
  _EditarIngrediente createState() => _EditarIngrediente();
}

DarkThemeProvider themeChangeProvider = DarkThemeProvider();

void getCurrentAppTheme() async {
  themeChangeProvider.setDarkTheme =
      await themeChangeProvider.darkThemePrefs.getTheme();
}

class _EditarIngrediente extends State<EditarIngrediente> {
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

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  final FirebaseStorage storage = FirebaseStorage.instance;
  final form = GlobalKey<FormState>();
  var nomecontroller = TextEditingController();
  var iconcontroller = TextEditingController();
  var qtdecontroller = TextEditingController();
  var file;
  String url = '';

  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Ingrediente',
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
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Image.network(
                                          widget.ingredient.icon.toString()),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 4, color: Colors.white),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          color: Colors.black.withOpacity(0.1))
                                    ],
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(widget
                                            .ingredient.icon
                                            .toString()))),
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
                                                    leading: Icon(Icons
                                                        .add_photo_alternate),
                                                    title: Text('Alterar foto'),
                                                    onTap: () async{
                                                      XFile? file = await getImage();
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
                          labelText: widget.ingredient.name,
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 168, 168, 168),
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            nomecontroller.text = widget.ingredient.name;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      const Text(
                        "Quantidade",
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
                        controller: qtdecontroller,
                        decoration: InputDecoration(
                          labelText: widget.ingredient.quantity.toString(),
                          border: const OutlineInputBorder(),
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 168, 168, 168),
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            qtdecontroller.text =
                                widget.ingredient.quantity.toString();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 60,
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
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
                                children: const <Widget>[
                                  Text(
                                    "Alterar Ingrediente",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20),
                                  )
                                ],
                              ),
                              onPressed: () async {
                                bool isValid = form.currentState!.validate();

                                String image = '';
                                if (file != null) {
                                  image = await upload(file.path, url);
                                } else {
                                  image = widget.ingredient.icon!;
                                }

                                if (isValid) {
                                  final name = nomecontroller.text;
                                  final icon = image;
                                  int quantity = int.parse(
                                      qtdecontroller.text.replaceAll(",", ""));
                                  final docProduto = FirebaseFirestore.instance
                                      .collection('ingrediente')
                                      .doc(widget.ingredient.name);
                                  Future updateIngredient() async {
                                    Ingredient comida = Ingredient(
                                        id: name,
                                        name: name,
                                        icon: icon,
                                        quantity: quantity);
                                    var json = comida.toJson();
                                    await docProduto.set(json);
                                  }

                                  updateIngredient();
                                  // atualizarAuthSenha(senha);
                                  Navigator.pushNamed(context, 'mainuserpage');
                                }
                              }),
                        ),
                      )
                    ],
                  )))),
    );
  }
}
