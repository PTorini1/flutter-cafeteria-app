import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:lanchonet/models/user.dart';
import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';

const publicKey = "INSIRA SUA PUBLIC KEY";

class PagamentoCartao {
  double valor;
  PagamentoCartao(this.valor);
  String _idPreferencia = "";
  String _platformVersion = 'Unknown';
  final List<List> _userData = [];

  setValor(double valor) {
    this.valor = valor;
  }

  _setIdPreferencia(String idPreferencia) {
    this._idPreferencia = idPreferencia;
  }

  Future<void> gerarPreferencia() async {
    var url = Uri.parse(
        'http://192.168.18.4:8080/transacao_pix/api/gerar_preferencia');

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
      "valor": valor.toString()
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> resultado = json.decode(response.body);
      _idPreferencia = await resultado['id'];
      _setIdPreferencia(_idPreferencia);
      _initPlatformState();
      _telaPagamento();
    } else {
      throw Exception('Failed to payment card');
    }
  }

  Future<void> _initPlatformState() async {
    String? platformVersion;
    try {
      platformVersion = await MercadoPagoMobileCheckout.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    _platformVersion = platformVersion!;
  }

  Future<void> _telaPagamento() async {
    await MercadoPagoMobileCheckout.startCheckout(
      publicKey,
      _idPreferencia,
    );
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
}
