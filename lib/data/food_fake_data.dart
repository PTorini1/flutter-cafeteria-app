import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lanchonet/models/user.dart';
import '../models/food.dart';
import '../models/foods/ingredient.dart';
import '../models/pedidos.dart';

//dati a caso

Stream<List<Food>> foods = readProdutos();
Stream<List<Usuario>> readUsers() => FirebaseFirestore.instance
    .collection('perfil_geral')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Usuario.fromJson(doc.data())).toList());

Future<Usuario?> readUserLogged() async {
  ///Get single document by ID
  final docUser = FirebaseFirestore.instance
      .collection('perfil_geral')
      .doc(FirebaseAuth.instance.currentUser!.uid);
  final snapshot = await docUser.get();
  return Usuario.fromJson(snapshot.data()!);
}

Stream<List<Ingredient>> readIngredientes() => FirebaseFirestore.instance
    .collection('ingrediente')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Ingredient.fromJson(doc.data())).toList());

Stream<List<Food>> readProdutos() => FirebaseFirestore.instance
    .collection('produtos')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList());

Stream<List<Pedidos>> readPedidos() => FirebaseFirestore.instance
    .collection('pedidos')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Pedidos.fromJson(doc.data())).toList());

Stream<List<Food>> readComidasFavoritas() => FirebaseFirestore.instance
    .collection('perfil_geral')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('produtos')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList());

Stream<List<Food>> readComidasFavoritas2(Usuario user) => FirebaseFirestore
    .instance
    .collection('perfil_geral')
    .doc(user.getId)
    .collection('produtos')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList());

Future<Food?> ifComida(Food food) async {
  ///Get single document by ID
  final docUser = FirebaseFirestore.instance
      .collection('perfil_geral')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('produtos')
      .doc(food.id);
  final snapshot = await docUser.get();

  if (snapshot.exists) {
    return Food.fromJson(snapshot.data()!);
  }
}
