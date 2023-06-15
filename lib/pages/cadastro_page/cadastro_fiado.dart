import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/fiado.dart';
import 'package:lanchonet/pages/fiados_page/caderneta_page.dart';

import '../../models/user.dart';

class CadastroFiado extends StatefulWidget {
  @override
  State<CadastroFiado> createState() => _CadastroFiadoState();
}

class _CadastroFiadoState extends State<CadastroFiado> {
  final form = GlobalKey<FormState>();
  final dividacontroller = TextEditingController();
  var usuariocontroller;

  @override
  Widget build(BuildContext context) {
    Stream<List<Usuario>> readUsers() => FirebaseFirestore.instance
        .collection('perfil_geral')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Usuario.fromJson(doc.data())).toList());
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Fiado',
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
            children: <Widget>[
              StreamBuilder(
                stream: readUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    if (usuariocontroller == null) {
                      final user = snapshot.data;
                      List<Usuario> usuarios = [];
                      for (var x in user!) {
                        if (x.getPermissoes == 'instrutor') {
                          usuarios.add(x);
                        }
                      }
                      return DropdownButtonFormField(
                        value: usuariocontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Cliente'),
                          labelStyle:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                        ),
                        icon: Icon(Icons.person),
                        items: usuarios
                            .map<DropdownMenuItem<Usuario>>((Usuario value) {
                          return DropdownMenuItem<Usuario>(
                              value: value,
                              child: Text('Nome: ' +
                                  value.getNome +
                                  '   ' +
                                  'CPF: ' +
                                  value.getCpf));
                        }).toList(),
                        onChanged: (value) {
                          usuariocontroller = value;
                        },
                      );
                    } else {
                      final user = snapshot.data;
                      List<Usuario> usuarios = [];
                      for (var x in user!) {
                        if (x.getPermissoes == 'instrutor') {
                          usuarios.add(x);
                        }
                      }
                      return DropdownButtonFormField<Usuario>(
                        value: usuariocontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Cliente'),
                          labelStyle:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                        ),
                        hint: Text('Nome: ' +
                            usuariocontroller.getNome +
                            '   ' +
                            'CPF: ' +
                            usuariocontroller.getCpf),
                        items: usuarios
                            .map<DropdownMenuItem<Usuario>>((Usuario value) {
                          return DropdownMenuItem<Usuario>(
                              value: value,
                              child: Text('Nome: ' +
                                  value.getNome +
                                  '   ' +
                                  'CPF: ' +
                                  value.getCpf));
                        }).toList(),
                        onChanged: (value) {
                          usuariocontroller = value;
                        },
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  controller: dividacontroller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.headline3?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                    labelText: 'Valor da dívida',
                  )),
              SizedBox(
                height: 15,
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
                child: SizedBox(
                  child: TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Cadastrar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15),
                        )
                      ],
                    ),
                    onPressed: () {
                      double valordivida = double.parse(
                          dividacontroller.text.replaceAll(",", ""));
                      ;
                      Fiado usuario = Fiado(
                          caloteiro: usuariocontroller, divida: valordivida);
                      Future createFiado({required String nome}) async {
                        try {
                          final docFiado = FirebaseFirestore.instance
                              .collection('fiados')
                              .doc(usuariocontroller.getId);
                          var json = usuario.toJson();
                          await docFiado.set(json);
                        } on FirebaseException catch (e) {
                          Center(
                            child: Text('Error $e'),
                          );
                        }
                      }

                      createFiado(nome: usuariocontroller.getNome);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CadernetaPage()));
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
