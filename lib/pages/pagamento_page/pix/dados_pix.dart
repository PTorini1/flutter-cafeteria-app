import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lanchonet/models/pedidos.dart';
import 'package:lanchonet/models/user.dart';
import 'package:lanchonet/pages/cart_page.dart';
import 'package:lanchonet/pages/main_page.dart';
import 'dart:convert';
import '../../../services/theme_service.dart';
import '../../notify_page.dart';

class DadosPix extends StatefulWidget {
  Map<String, dynamic> dadosPix;

  DadosPix(this.dadosPix);

  @override
  _DadosPix createState() => _DadosPix();
}

class _DadosPix extends State<DadosPix> {
  String statusPix = "";
  String chavePix = "";
  String nome = "";
  Map<String, dynamic> resultado = {};
  final List<List> _userData = [];

  _setResultado(Map<String, dynamic> resultado) {
    this.resultado = resultado;
  }

  Future<List<List>?> readUser(uid) async {
      final docUser = FirebaseFirestore.instance.collection('perfil_geral').doc(uid);
      final snapshot = await docUser.get();
      if (snapshot.exists) {
        var user = Usuario.fromJson(snapshot.data()!);
        List<String> dados = [user.getBairro, user.getCelular, user.getCep, user.getCidade, user.getCpf, user.getDDD, user.getEmail, user.getEstado, user.getNome, user.getNumero, user.getRua, user.getSobrenome];
        _userData.add(dados);
        return _userData;
      } else if (snapshot.exists == true) {
        print('Tem algo errado');
      }
      return null;
    }

  Future<dynamic> criaChavePix() async {
    var url = Uri.parse('http://192.168.18.4:8080/transacao_pix/api/gerar_pix');

    var dadosUsuario = await readUser(FirebaseAuth.instance.currentUser!.uid);
    
    var response = await http.post(url, body: {
      "bairro": dadosUsuario![0][0].toString(),
      "celular": dadosUsuario[0][1].toString(),
      "cep": dadosUsuario[0][2].toString(),
      "cidade": dadosUsuario[0][3].toString(),
      "cpf": dadosUsuario[0][4].toString(),
      "ddd": dadosUsuario[0][5].toString(),
      "email": dadosUsuario[0][6].toString(),
      "estado": dadosUsuario[0][7].toString(),
      "nome": dadosUsuario[0][8].toString(),
      "numero": dadosUsuario[0][9].toString(),
      "rua": dadosUsuario[0][10].toString(),
      "sobrenome": dadosUsuario[0][11].toString(),
      'valor': widget.dadosPix["valorPixDouble"].toString()
    });

    if (response.statusCode == 200) {
      _setResultado(json.decode(response.body));
      return resultado['qr_code'];
    } else {
      throw Exception(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pix',
          style: Theme.of(context).textTheme.headline3,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.red,
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const MainPage()));
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          FutureBuilder(
            future: criaChavePix(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset("assets/images/img_pix.png",
                            fit: BoxFit.cover)),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Status do Pagamento Pix:",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold)),
                          Text(resultado["status"],
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.green)),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text("R\$ ${resultado["total_a_pagar"].toString()}",
                              style: TextStyle(
                                  fontSize: 25.0, color: Colors.green))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                              height: 36,
                              width: 36,
                              child: Text(
                                '1.',
                                style: TextStyle(color: AppColor.primaryColor),
                              )),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                              child: Text(
                                  "Abra o app do seu banco ou seu app de pagamentos.",
                                  style: Theme.of(context).textTheme.headline3))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                              height: 36,
                              width: 36,
                              child: Text(
                                '2.',
                                style: TextStyle(color: AppColor.primaryColor),
                              )),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                              child: Text("Busque a opção de pagar com pix.",
                                  style: Theme.of(context).textTheme.headline3))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                              height: 36,
                              width: 36,
                              child: Text(
                                '3.',
                                style: TextStyle(color: AppColor.primaryColor),
                              )),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                              child: Text("Copie e cole o seguinte código.",
                                  style: Theme.of(context).textTheme.headline3))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                resultado["qr_code"],
                                style: TextStyle(fontSize: 14.0),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 44.0,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final data =
                                ClipboardData(text: resultado["qr_code"]);
                            Clipboard.setData(data);
                          },
                          child: Text(
                            "COPIAR CHAVE",
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                  ],
                );
              } else {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
