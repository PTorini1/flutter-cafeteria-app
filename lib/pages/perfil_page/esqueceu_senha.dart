import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../services/theme_service.dart';
import 'login_widget.dart';

class EsqueceuSenha extends StatefulWidget {
  const EsqueceuSenha({Key? key}) : super(key: key);
  @override
  _EsqueceuSenhaState createState() => _EsqueceuSenhaState();
}

class _EsqueceuSenhaState extends State<EsqueceuSenha> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  final form = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String confirmaSenha = '';

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future atualizarAuthSenha(String email) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (e) {
        Center(
          child: Text('Error$e'),
        );
      }
    }

    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: AppColor.primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
          padding: const EdgeInsets.only(
            top: 60,
            left: 40,
            right: 40,
          ),
          child: Form(
            key: form,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.asset("assets/images/lanchonet-logo.png"),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: emailController,
                  cursorColor: themeState.getDarktheme
                      ? AppColor.primaryColor
                      : Colors.blue,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "E-mail",
                    labelStyle: Theme.of(context).textTheme.headline3,
                  ),
                  validator: (value) {
                    if ((value == null) || (value.trim().isEmpty == true)) {
                      return 'Informe o email';
                    }
                    if (EmailValidator.validate(emailController.text) ==
                        false) {
                      return 'Coloque um email válido';
                    }
                    if (value.contains('aluno') == false &&
                        value.contains('funcionario') == false &&
                        value.contains('instrutor') == false &&
                        value.contains('admin') == false &&
                        value.contains('senaisp.edu.br') == false &&
                        value.contains('gmail.com') == false) {
                      return 'Coloque um email válido';
                    }
                    return null;
                  },
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 60,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
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
                  child: SizedBox.expand(
                    child: TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text(
                            "Confirmar Email",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20),
                          )
                        ],
                      ),
                      onPressed: () {
                        final isValid = form.currentState!.validate();
                        if (isValid) {
                          form.currentState!.save();
                          final email = emailController.text;

                          atualizarAuthSenha(email);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginWidget()));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
