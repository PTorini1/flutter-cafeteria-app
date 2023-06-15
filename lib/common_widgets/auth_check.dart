import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lanchonet/pages/Splash.dart';
import 'package:lanchonet/pages/main_page.dart';
import 'package:lanchonet/pages/perfil_page/login_widget.dart';
import 'package:lanchonet/services/auth_service.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading) {
      return loading();
    } else if (auth.usuario == null) {
      return LoginWidget();
    } else {
      return MainPage();
    }
  }

  loading() {
    return Splash();
  }
}
