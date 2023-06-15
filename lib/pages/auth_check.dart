import 'package:flutter/material.dart';
import 'package:lanchonet/pages/home_page/home_page.dart';
import 'package:lanchonet/pages/perfil_page/login_page.dart';
import 'package:lanchonet/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'Splash.dart';

class AuthCheck extends StatefulWidget {
  AuthCheck({Key? key}) : super(key: key);
  @override
  AuthCheckState createState() => AuthCheckState();
}

@override
class AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading)
      return loading();
    else if (auth.usuario == null)
      return LoginPage();
    else
      return HomePage();
  }

  loading() {
    return Splash();
  }
}
