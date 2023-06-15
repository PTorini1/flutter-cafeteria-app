import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? usuario;

  bool isLoading = true;

  AuthService() {
    authCheck();
  }

  authCheck() {
    auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }
}
