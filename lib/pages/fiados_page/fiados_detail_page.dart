import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/dark_theme_widget/dark_theme_provider.dart';
import 'package:lanchonet/models/fiado.dart';
import 'package:lanchonet/models/user.dart';
import 'package:lanchonet/pages/fiados_page/caderneta_page.dart';

import '../../services/theme_service.dart';

class FiadosDetailPage extends StatefulWidget {
  final Fiado user;
  const FiadosDetailPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<FiadosDetailPage> createState() => _FiadosDetailPageState();
}

class _FiadosDetailPageState extends State<FiadosDetailPage> {
  //remember Fiados.isFavorite field
  late final bool userChangeFavorite;

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    var dividacontroller = TextEditingController();
    bool click = false;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.user.caloteiro.getNome,
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(
                        widget.user.caloteiro.getImageUrl.toString()),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Text(widget.user.caloteiro.getNome.toString(),
                    style: Theme.of(context).textTheme.headline3),
                SizedBox(
                  height: 5,
                ),
                Text(widget.user.caloteiro.getEmail.toString(),
                    style: Theme.of(context).textTheme.headline3),
                SizedBox(
                  height: 5,
                ),
                Text(widget.user.caloteiro.getCpf.toString(),
                    style: Theme.of(context).textTheme.headline3),
                SizedBox(
                  height: 5,
                ),
                Text(widget.user.divida.toString(),
                    style: Theme.of(context).textTheme.headline3),
                Expanded(
                  child: click ? SizedBox() : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Container(
                                width: MediaQuery.of(context).size.width * .6,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: SizedBox.expand(
                                  child: TextButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Somar o valor da Dívida",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Soma o valor da divida'),
                                              
                                              actions: <Widget>[
                                                TextFormField(
                                                   onTapOutside: (value) {
                                setState(() {
                                  click = false;
                                });
                              },
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: dividacontroller,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Valor pra somar',
                                                    labelStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .headline3
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 20,
                                                            ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: TextButton(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const <Widget>[
                                                        Text(
                                                          "Somar",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      248,
                                                                      0,
                                                                      0),
                                                              fontSize: 15),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      double valordivida =
                                                          double.parse(
                                                                  dividacontroller
                                                                      .text
                                                                      .replaceAll(
                                                                          ",",
                                                                          "")) +
                                                              widget
                                                                  .user.divida;
                                                      ;
                                                      Fiado usuario = Fiado(
                                                          caloteiro: widget
                                                              .user.caloteiro,
                                                          divida: valordivida);
                                                      Future createFiado(
                                                          {required String
                                                              nome}) async {
                                                        try {
                                                          final docFiado =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'fiados')
                                                                  .doc(widget
                                                                      .user
                                                                      .caloteiro
                                                                      .getId);
                                                          var json =
                                                              usuario.toJson();
                                                          await docFiado
                                                              .set(json);
                                                        } on FirebaseException catch (e) {
                                                          Center(
                                                            child: Text(
                                                                'Error $e'),
                                                          );
                                                        }
                                                      }

                                                      createFiado(
                                                          nome: usuario
                                                              .caloteiro
                                                              .getNome);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const CadernetaPage()));
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                            // return TextFormField(
                                            //   keyboardType:
                                            //       TextInputType.number,
                                            //   controller: dividacontroller,
                                            //   decoration: InputDecoration(
                                            //     border: OutlineInputBorder(),
                                            //     labelText:
                                            //         'Edite o valor da dívida',
                                            //     labelStyle: Theme.of(context)
                                            //         .textTheme
                                            //         .headline3
                                            //         ?.copyWith(
                                            //           fontWeight:
                                            //               FontWeight.w400,
                                            //           fontSize: 20,
                                            //         ),
                                            //   ),
                                            // );
                                          },
                                        );
                                      }),
                                ))),
                      ]),
                ),
                Expanded(
                  child: click ? SizedBox() : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 30),
                            child: Container(
                                width: MediaQuery.of(context).size.width * .6,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: SizedBox.expand(
                                  child: TextButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Excluir fiado",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                      onPressed: () async {
                                        final docUser = FirebaseFirestore
                                            .instance
                                            .collection('fiados')
                                            .doc(widget.user.caloteiro.getId);
                                        docUser.delete();
                                        Navigator.pop(context);
                                      }),
                                ))),
                      ]),
                ),
              ]),
        ));
  }
}
