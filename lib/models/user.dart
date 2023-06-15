//todo: Implement Authentication

import 'dart:isolate';

import '../controllers/encrypt.dart';

class Usuario {
  // final String _token;
  final String _id;
  final String _nome;
  final String _sobrenome;
  final String _email;
  final String _cidade;
  final String _bairro;
  final String _numero;
  final String _rua;
  final String _cep;
  final String _estado;
  final String _ddd;
  final String _celular;
  final String _cpf;
  final String _imageUrl;
  final String _senha;
  final String _permissoes;

  // String get gettoken {
  //   return _token;
  // }

  String get getId {
    return _id;
  }

  String get getNome {
    return _nome;
  }

  String get getSobrenome {
    return _sobrenome;
  }

  String get getEmail {
    return _email;
  }

  String get getCidade {
    return _cidade;
  }

  String get getBairro {
    return _bairro;
  }

  String get getNumero {
    return _numero;
  }

  String get getRua {
    return _rua;
  }

  String get getCep {
    return _cep;
  }

  String get getEstado {
    return _estado;
  }

  String get getDDD {
    return _ddd;
  }

  String get getCelular {
    return _celular;
  }

  String get getCpf {
    return _cpf;
  }

  String get getImageUrl {
    return _imageUrl;
  }

  String get getSenha {
    return _senha;
  }

  String get getPermissoes {
    return _permissoes;
  }

  const Usuario({
    // required String token,
    required String id,
    required String nome,
    required String sobrenome,
    required String email,
    required String cidade,
    required String bairro,
    required String numero,
    required String rua,
    required String cep,
    required String estado,
    required String ddd,
    required String celular,
    required String cpf,
    required String imageUrl,
    required String senha,
    required String permissoes,
  })  : 
  // _token = token,
        _id = id,
        _nome = nome,
        _sobrenome = sobrenome,
        _email = email,
        _cidade = cidade,
        _bairro = bairro,
        _numero = numero,
        _rua = rua,
        _cep = cep,
        _estado = estado,
        _ddd = ddd,
        _celular = celular,
        _cpf = cpf,
        _imageUrl = imageUrl,
        _senha = senha,
        _permissoes = permissoes;

//  Student({int id, String name}) : _id = id, _name = name;
  Map<String, dynamic> toJson() => {
        // 'token': _token,
        'id': _id,
        'nome': _nome,
        'sobrenome': _sobrenome,
        'email': _email,
        'cidade': _cidade,
        'bairro': _bairro,
        'numero': _numero,
        'rua': _rua,
        'cep': _cep,
        'estado': _estado,
        'ddd': _ddd,
        'celular': _celular,
        'cpf': _cpf,
        'senha': _senha,
        'imageUrl': _imageUrl,
        'permissoes': _permissoes
      };
  static Usuario fromJson(Map<String, dynamic> json) => Usuario(
        // token: json['token'],
        id: json['id'],
        nome: json['nome'],
        sobrenome: json['sobrenome'],
        email: json['email'],
        cidade: json['cidade'],
        bairro: json['bairro'],
        numero: json['numero'],
        rua: json['rua'],
        cep: json['cep'],
        estado: json['estado'],
        ddd: json['ddd'],
        celular: json['celular'],
        cpf: json['cpf'],
        senha: json['senha'],
        imageUrl: json['imageUrl'],
        permissoes: json['permissoes'],
      );
}
