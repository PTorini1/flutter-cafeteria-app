import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/foods/ingredient.dart';
import '../../services/theme_service.dart';

class CadastroIngrediente extends StatefulWidget {
  @override
  State<CadastroIngrediente> createState() => _CadastroIngredienteState();
}

class _CadastroIngredienteState extends State<CadastroIngrediente> {
  final form = GlobalKey<FormState>();
  final Map<String?, String?> _formData = {};
  final nomeController = TextEditingController();
  final qtdecontroller = TextEditingController();
  final iconcontroller = TextEditingController();
  final FirebaseStorage storage = FirebaseStorage.instance;
  var file;
  String url = '';
  bool camera = false;

  Future<XFile?> getImage(bool camera) async {
    final ImagePicker _picker = ImagePicker();
    if (camera == false) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image;
    } else {
      XFile? image = await _picker.pickImage(source: ImageSource.camera);
      return image;
    }
  }

  Future<String> upload(String path, String url) async {
    File file = File(path);
    try {
      String ref = 'ingredientes/${nomeController.text}.jpg';
      await storage.ref(ref).putFile(file);
      url = await storage.ref(ref).getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao enviar arquivo');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de ingredientes',
            style: Theme.of(context).textTheme.headline3),
        leading: BackButton(
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: nomeController,
                initialValue: _formData['name'],
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                    labelText: 'Nome do ingrediente'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do ingrediente';
                  }
                  return null;
                },
                onSaved: (value) => _formData['name'] = value,
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: qtdecontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                    labelText: 'Quantidade do ingrediente'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a quantidade do ingrediente';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * .6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      primary: AppColor.primaryColor,
                    ),
                    onPressed: () async {
                      XFile? file = await getImage(camera);
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
              Expanded(
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                      width: MediaQuery.of(context).size.width * .4,
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
                                "Cadastrar",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15),
                              )
                            ],
                          ),
                          onPressed: () async {
                            String image = '';
                            if (file != null) {
                              image = await upload(file.path, url);
                            }
                            final isValid = form.currentState!.validate();
                            if (isValid) {
                              form.currentState!.save();
                              final name = nomeController.text;
                              final iconUrl = image;
                              int quantity = int.parse(
                                  qtdecontroller.text.replaceAll(",", ""));
                              Future createIngrediente(
                                  {required String name}) async {
                                try {
                                  final id = name;
                                  //Reference to document
                                  final docIngrediente = FirebaseFirestore
                                      .instance
                                      .collection('ingrediente')
                                      .doc(id);
                                  final ingredient = Ingredient(
                                      id: id,
                                      name: name,
                                      icon: iconUrl,
                                      quantity: quantity);
                                  final json = ingredient.toJson();
                                  // Create document and write data to Firebase
                                  await docIngrediente.set(json);
                                } on FirebaseException catch (e) {
                                  Center(
                                    child: Text('Error $e'),
                                  );
                                }
                              }

                              createIngrediente(name: name);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      )),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
