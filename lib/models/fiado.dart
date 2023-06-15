import 'package:lanchonet/models/user.dart';

class Fiado {
  final Usuario caloteiro;
  final double divida;

  Fiado({
    required this.caloteiro,
    required this.divida,
  });

  static Fiado fromMap(Map<String,dynamic> data){
    Fiado fiado = Fiado(
      caloteiro: Usuario.fromJson(data['caloteiro']),
      divida: data['divida']
    );
    return fiado;
  }

  Map<String, dynamic> toJson() =>{
    'caloteiro': caloteiro.toJson(),
    'divida': divida
  };
}
