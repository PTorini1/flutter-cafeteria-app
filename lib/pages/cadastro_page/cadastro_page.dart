import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lanchonet/controllers/encrypt.dart';
import 'package:lanchonet/pages/perfil_page/login_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:search_cep/search_cep.dart';

class CadastroPage extends StatefulWidget {
  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  String confirmaSenha = '';
  String permissoesController = 'aluno';
  String uid = 'a';
  String url = '';
  bool camera = false;

  final form = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final senhaController = TextEditingController();
  final telController = TextEditingController();
  final imageController = TextEditingController();
  final cepController = TextEditingController();
  final bairroController = TextEditingController();
  final numeroController = TextEditingController();
  final ruaController = TextEditingController();
  final dddController = TextEditingController();
  final estadoController = TextEditingController();
  final cidadeController = TextEditingController();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final viaCepSearchCep = ViaCepSearchCep();
  var dadosEndereco;
  var file;

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  late FirebaseMessaging messaging;
  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String mtoken = '';
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
        String ref = 'perfil/${nomeController.text}.jpg';
        await storage.ref(ref).putFile(file);
        url = await storage.ref(ref).getDownloadURL();
        return url;
      } on FirebaseException catch (e) {
        throw Exception('Erro ao enviar arquivo');
      }
    }
    bool click = true;
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro', style: Theme.of(context).textTheme.headline3),
        leading: BackButton(
          color: AppColor.primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(
          top: 40,
          left: 40,
          right: 40,
        ),
        child: Form(
          key: form,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: nomeController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  } else if (value.trim().length < 3) {
                    return 'Nome pequeno. Minímo 3 letras';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: sobrenomeController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Sobrenome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o sobrenome';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: emailController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o email';
                  } else if (value.contains('aluno') ||
                      value.contains('senaisp.edu.br') ||
                      value.contains('gmail.com') ||
                      value.contains('outlook.com')) {
                    permissoesController = 'aluno';
                  } else if (value.contains('funcionario') ||
                      value.contains('sp.senai.br')) {
                    permissoesController = 'funcionario';
                  } else if (value.contains('instrutor')) {
                    permissoesController = 'instrutor';
                  } else if (value.contains('admin')) {
                    permissoesController = 'admin';
                  } else if (EmailValidator.validate(emailController.text) ==
                      false) {
                    return "Coloque um email válido";
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
                keyboardType: TextInputType.number,
                controller: cpfController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'CPF'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o CPF';
                  } else if (UtilBrasilFields.isCPFValido(value) == false) {
                    return 'Digite um CPF válido';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: telController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter()
                ],
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Número de Celular'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o telefone';
                  }

                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  dddController.text =
                      telController.text.toString().substring(1, 3);
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: cepController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter()
                ],
                keyboardType: TextInputType.number,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'CEP'),
                onChanged: (value) async {
                  value = value.replaceAll(new RegExp(r'[^0-9]'), '');
                  final infoCepJSON = await viaCepSearchCep.searchInfoByCep(
                      cep: '${value.toString()}');
                  infoCepJSON.toString();
                  ViaCepInfo? endereco;
                  infoCepJSON.map<ViaCepInfo>((r) => endereco = r);

                  if (endereco != null) {
                    bairroController.text = endereco!.bairro!;
                    ruaController.text = endereco!.logradouro!;
                    cidadeController.text = endereco!.localidade!;
                    estadoController.text = endereco!.uf!;
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o CEP';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: estadoController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Estado'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o Estado';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: cidadeController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Cidade'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a Cidade';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: bairroController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Bairro'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o Bairro';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: ruaController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Rua'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a Rua';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: numeroController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Número'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o Número';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                keyboardType: TextInputType.visiblePassword,
                 obscureText: click,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            click = !click;
                          });
                        },
                        icon: Icon(
                          click
                              ? Icons.visibility_off_outlined
                              : Icons.remove_red_eye_outlined,
                          color: themeState.getDarktheme
                              ? AppColor.primaryColor
                              : Colors.blue,
                        )),
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Senha'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a senha';
                  }
                  if (value.trim().length < 8) {
                    confirmaSenha = value;
                    return 'Senha pequena. Minímo 8 caracteres';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  confirmaSenha = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: senhaController,
                cursorColor: themeState.getDarktheme
                    ? AppColor.primaryColor
                    : Colors.blue,
                keyboardType: TextInputType.visiblePassword,
                 obscureText: click,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            click = !click;
                          });
                        },
                        icon: Icon(
                          click
                              ? Icons.visibility_off_outlined
                              : Icons.remove_red_eye_outlined,
                          color: themeState.getDarktheme
                              ? AppColor.primaryColor
                              : Colors.blue,
                        )),
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3,
                    labelText: 'Confirmar senha'),
                validator: (value) {
                  if (value == confirmaSenha) {
                    return null;
                  } else {
                    return 'As senhas tem que ser iguais';
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * .6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      primary: AppColor.primaryColor,
                    ),
                    onPressed: () async {
                      showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                          ),
                          builder: ((context) {
                            return Container(
                              height: 230,
                              child: ListView(
                                children: <Widget>[
                                  ListTile(
                                    title: Text('Editar foto'),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.camera),
                                    title: Text('Tirar foto'),
                                    onTap: () async {
                                      XFile? file =
                                          await getImage(camera = true);
                                      this.file = file;
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.add_photo_alternate),
                                    title: Text('Alterar foto'),
                                    onTap: () async {
                                      XFile? file = await getImage(camera);
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
                height: 20,
              ),
              Container(
                height: 50,
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
                        final sobrenome = sobrenomeController.text;
                        final email = emailController.text;
                        final cpf = cpfController.text;
                        final senha = Encrypt.encryptAES(senhaController.text);
                        final tel = telController.text =
                            telController.text.toString().substring(4);
                        final imageUrl = image;
                        final permissoes = permissoesController;
                        final bairro = bairroController.text;
                        final rua = ruaController.text;
                        final estado = estadoController.text;
                        final ddd = dddController.text;
                        final cidade = cidadeController.text;
                        final cep = cepController.text;
                        final numero = numeroController.text;
                        Future signUp({required String name}) async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: senhaController.text,
                                )
                                .then((data) => {
                                      setState(() {
                                        uid = data.user!.uid.toString();
                                        final docUser = FirebaseFirestore
                                            .instance
                                            .collection('perfil_geral')
                                            .doc(uid);
                                        Usuario user = Usuario(
                                          // token: token,
                                          id: uid,
                                          nome: name,
                                          sobrenome: sobrenome,
                                          email: email,
                                          cidade: cidade,
                                          bairro: bairro,
                                          numero: numero,
                                          rua: rua,
                                          cep: cep,
                                          estado: estado,
                                          ddd: ddd,
                                          celular: tel,
                                          cpf: cpf,
                                          senha: senha,
                                          imageUrl: imageUrl,
                                          permissoes: permissoes,
                                        );
                                        // final user = Usuario();
                                        final json = user.toJson();
                                        // Create document and write data to Firebase
                                        docUser.set(json);
                                      })
                                    });
                          } on FirebaseAuthException catch (e) {
                            Center(
                              child: Text('Error$e'),
                            );
                          }
                        }

                        signUp(name: name);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginWidget()));
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
