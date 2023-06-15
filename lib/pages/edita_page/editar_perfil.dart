import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:search_cep/search_cep.dart';
import '../../controllers/encrypt.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({
    Key? key,
  }) : super(key: key);
  @override
  _PerfilPage createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  Future atualizarAuthSenha(String senha, String email) async {
    String? emailk = FirebaseAuth.instance.currentUser!.email;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(senha);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailk.toString(), password: senha);
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      Center(
        child: Text('Error$e'),
      );
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
  final FirebaseStorage storage = FirebaseStorage.instance;
  var file;
  String url = '';
  bool camera = false;
  String confirmaSenha = '';
  int click = 1;
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final telController = TextEditingController();
  final senhaController = TextEditingController();
  final imageController = TextEditingController();
  final ruaController = TextEditingController();
  final bairroController = TextEditingController();
  final numeroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final dddController = TextEditingController();
  final cepController = TextEditingController();
  final viaCepSearchCep = ViaCepSearchCep();
  bool isPressed = false;
  String permissoesController = '';
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

  Future<String> upload(String path, String url, String nome) async {
    File file = File(path);
    try {
      String ref = 'perfil/$nome.jpg';
      await storage.ref(ref).putFile(file);
      url = await storage.ref(ref).getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao enviar arquivo');
    }
  }

  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    bool click = true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar perfil',
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
        actions: [
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                final docUser = FirebaseFirestore.instance
                    .collection('perfil_geral')
                    .doc(FirebaseAuth.instance.currentUser!.uid);
                FirebaseAuth.instance.currentUser!.delete();
                docUser.delete();
                Navigator.pop(context);
              }),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15, top: 20, right: 15),
        child: GestureDetector(
          child: Form(
              key: form,
              child: FutureBuilder(
                  future: readUser(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData) {
                      final user = snapshot.data;
                      return ListView(
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                  
                                GestureDetector( 
                                  onTap: () {
                                    showDialog(context: context, builder: (context) {
                                    return AlertDialog(
                                    content: Image.network(user.getImageUrl),
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
                                            color:
                                                Colors.black.withOpacity(0.1))
                                      ],
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image:
                                              NetworkImage(user!.getImageUrl))),
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
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                        color: Color.fromARGB(255, 255, 0, 0)),
                                    child: GestureDetector(
                                        child: Icon(Icons.edit,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                        onTap: () {
                                          showModalBottomSheet(
                                              context: context,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(20),
                                                    topLeft:
                                                        Radius.circular(20)),
                                              ),
                                              builder: ((context) {
                                                return Container(
                                                  height: 230,
                                                  child: ListView(
                                                    children: <Widget>[
                                                      ListTile(
                                                        title:
                                                            Text('Editar foto'),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      ListTile(
                                                        leading:
                                                            Icon(Icons.camera),
                                                        title:
                                                            Text('Tirar foto'),
                                                        onTap: () async {
                                                          XFile? file =
                                                              await getImage(
                                                                  camera =
                                                                      true);
                                                          this.file = file;
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      ListTile(
                                                        leading: Icon(Icons
                                                            .add_photo_alternate),
                                                        title: Text(
                                                            'Alterar foto'),
                                                        onTap: () async {
                                                          XFile? file =
                                                              await getImage(
                                                                  camera =
                                                                      false);
                                                          this.file = file;
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      // ListTile(
                                                      //   leading:
                                                      //       Icon(Icons.delete),
                                                      //   title: Text(
                                                      //       'Excluir foto'),
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
                            controller: nomeController,
                            decoration: InputDecoration(
                              hintText: user.getNome,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                value = user.getNome;
                              } else if (value.trim().length < 3) {
                                return 'Nome pequeno. Minímo 3 letras';
                              }
                              imageController.text = user.getImageUrl;
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Text(
                              "Sobrenome",
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
                            controller: sobrenomeController,
                            decoration: InputDecoration(
                              hintText: user.getSobrenome,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                sobrenomeController.text = user.getSobrenome;
                                value = user.getSobrenome;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Text(
                              "Email",
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
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: user.getEmail,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                value = user.getEmail;
                              }
                              if (value.contains('aluno')) {
                                permissoesController = 'aluno';
                              } else if (value.contains('funcionario')) {
                                permissoesController = 'funcionario';
                              } else if (value.contains('instrutor')) {
                                permissoesController = 'instrutor';
                              } else if (value.contains('admin')) {
                                permissoesController = 'admin';
                              } else if (EmailValidator.validate(
                                      emailController.text) ==
                                  false) {
                                return "Coloque um email válido";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Text(
                              "CPF",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CpfInputFormatter(),
                            ],
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            controller: cpfController,
                            decoration: InputDecoration(
                              hintText: user.getCpf.toString(),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                value = user.getCpf;
                                cpfController.text = value;
                              }
                              if (UtilBrasilFields.isCPFValido(value) ==
                                  false) {
                                return 'Digite um CPF válido';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Text(
                              "Celular",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: telController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TelefoneInputFormatter()
                            ],
                            keyboardType: TextInputType.number,
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: user.getCelular),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                value = user.getCelular;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              dddController.text =
                                  telController.text.toString().substring(1, 3);
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Text(
                              "CEP",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: cepController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CepInputFormatter()
                            ],
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: user.getCep),
                            onChanged: (value) async {
                              value =
                                  value.replaceAll(new RegExp(r'[^0-9]'), '');
                              final infoCepJSON = await viaCepSearchCep
                                  .searchInfoByCep(cep: '${value.toString()}');
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
                                value = user.getCep;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Text(
                              "Estado",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: estadoController,
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            decoration: InputDecoration(
                              hintText: user.getEstado,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                value = user.getEstado;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Text(
                              "Cidade",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: cidadeController,
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            decoration: InputDecoration(
                              hintText: user.getCidade,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                value = user.getCidade;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Text(
                              "Bairro",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: bairroController,
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            decoration: InputDecoration(
                              hintText: user.getBairro,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                value = user.getBairro;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Text(
                              "Rua",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: ruaController,
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            decoration: InputDecoration(
                              hintText: user.getRua,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                ruaController.text = user.getRua;
                                value = user.getRua;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Text(
                              "Número",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: numeroController,
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
                            decoration: InputDecoration(
                              hintText: user.getNumero,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                numeroController.text = user.getNumero;
                                value = user.getNumero;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Text(
                              "Confirmar senha",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 168, 168, 168),
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: senhaController,
                            cursorColor: themeState.getDarktheme
                                ? AppColor.primaryColor
                                : Colors.blue,
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
                              hintText: 'Confirmar Senha',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value)  {
                              String senhaCriptografada = Encrypt.encryptAES(value); 
                              if (senhaCriptografada != user.getSenha) {
                                return 'Senha deve ser igual a do cadastro';
                              } else {
                                senhaController.text = value.toString();
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            height: 60,
                            alignment: Alignment.centerLeft,
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
                                      "Alterar conta",
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
                                    image = await upload(file.path, url, user.getNome);
                                  }

                                  if (nomeController.text == null ||
                                      nomeController.text == '') {
                                    nomeController.text = user.getNome;
                                  }
                                  if (sobrenomeController.text == null ||
                                      sobrenomeController.text == '') {
                                    sobrenomeController.text =
                                        user.getSobrenome;
                                  }
                                  if (emailController.text == null ||
                                      emailController.text == '') {
                                    emailController.text = user.getEmail;
                                  }
                                  if (cpfController.text == null ||
                                      cpfController.text == '') {
                                    cpfController.text = user.getCpf;
                                  }
                                  if (telController.text == null ||
                                      telController.text == '') {
                                    telController.text = user.getCelular;
                                  }
                                  if (imageController.text == null ||
                                      imageController.text == '') {
                                    imageController.text = user.getImageUrl;
                                  }
                                  if (cepController.text == null ||
                                      cepController.text == '') {
                                    cepController.text = user.getCep;
                                  }
                                  if (bairroController.text == null ||
                                      bairroController.text == '') {
                                    bairroController.text = user.getBairro;
                                  }
                                  if (numeroController.text == null ||
                                      numeroController.text == '') {
                                    numeroController.text = user.getNumero;
                                  }
                                  if (ruaController.text == null ||
                                      ruaController.text == '') {
                                    ruaController.text = user.getRua;
                                  }
                                  if (dddController.text == null ||
                                      dddController.text == '') {
                                    dddController.text = user.getDDD;
                                  }
                                  if (estadoController.text == null ||
                                      estadoController.text == '') {
                                    estadoController.text = user.getEstado;
                                  }
                                  if (cidadeController.text == null ||
                                      cidadeController.text == '') {
                                    cidadeController.text = user.getCidade;
                                  }
                                  if (permissoesController == null ||
                                      permissoesController == '') {
                                    permissoesController = user.getPermissoes;
                                  }

                                  if (isValid) {
                                    form.currentState!.save();

                                    final name = nomeController.text;
                                    final sobrenome = sobrenomeController.text;
                                    final email = emailController.text;
                                    final cpf = cpfController.text;
                                    final senha = Encrypt.encryptAES(senhaController.text);
                                    final imageUrl = image;
                                    final permissoes = permissoesController;
                                    final cidade = cidadeController.text;
                                    final bairro = bairroController.text;
                                    final numero = numeroController.text;
                                    final rua = ruaController.text;
                                    final cep = cepController.text;
                                    final estado = estadoController.text;
                                    final ddd = dddController.text;
                                    final celular = telController.text;

                                    Usuario user = Usuario(
                                      id: FirebaseAuth
                                          .instance.currentUser!.uid,
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
                                      celular: celular,
                                      cpf: cpf,
                                      senha: senha,
                                      imageUrl: imageUrl,
                                      permissoes: permissoes,
                                    );
                                    final docProduto = FirebaseFirestore
                                        .instance
                                        .collection('perfil_geral')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid);
                                    Future updatePerfil() async {
                                      var json = user.toJson();
                                      await docProduto.set(json);
                                    }

                                    updatePerfil();

                                    atualizarAuthSenha(senhaController.text, email);
                                    Navigator.pushNamed(context, 'login');

                                    // atualizarAuthSenha(senha);
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })),
        ),
      ),
    );
  }
}
