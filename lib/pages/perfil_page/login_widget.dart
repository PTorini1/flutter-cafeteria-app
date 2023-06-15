import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/pages/Splash.dart';
import 'package:lanchonet/pages/cadastro_page/cadastro_page.dart';
import 'package:lanchonet/pages/perfil_page/esqueceu_senha.dart';
import 'package:lanchonet/pages/perfil_page/login_page.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../services/theme_service.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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
  final passwordcontroller = TextEditingController();
  Future<bool> signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Splash());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordcontroller.text.trim(),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      Center(
        child: Text('Error $e'),
      );
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordcontroller.dispose();

    super.dispose();
  }

  @override
  bool click = true;
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
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
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
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
                  height: 20,
                ),
                TextFormField(
                  cursorColor: themeState.getDarktheme
                      ? AppColor.primaryColor
                      : Colors.blue,
                  controller: passwordcontroller,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: click,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            click = !click;
                          });
                        },
                        icon: Icon(
                          click
                              ? Icons.visibility_off_outlined
                              : Icons.remove_red_eye_outlined,
                          color: themeState.getDarktheme
                              ? AppColor.primaryColor
                              : Colors.blue,
                        )),
                    border: OutlineInputBorder(),
                    labelText: "Senha",
                    labelStyle: Theme.of(context).textTheme.headline3,
                  ),
                  validator: (value) {
                    if ((value == null) || value.trim().isEmpty) {
                      return 'Informe sua senha';
                    }
                    if (passwordcontroller.toString().length <= 7) {
                      return 'Senha com minimo 8 caracteres';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) async {
                    await signIn();
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                ),
                Container(
                  height: 40,
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    child: Text(
                      "Esqueceu sua senha?",
                      style: TextStyle(color: AppColor.primaryColor),
                      textAlign: TextAlign.right,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EsqueceuSenha()));
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
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
                            "Login",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20),
                          )
                        ],
                      ),
                      onPressed: () async {
                        final isValid = form.currentState!.validate();
                        if (isValid) {
                          await signIn();
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
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
                            "Cadastre-se",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20),
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CadastroPage()));
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
