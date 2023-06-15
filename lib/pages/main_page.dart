import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lanchonet/dark_theme_widget/change_theme_button.dart';
import 'package:lanchonet/constant/png_icons.dart';
import 'package:lanchonet/helpers/cart_handler.dart';
import 'package:lanchonet/pages/cadastro_page/cadastro_ingredientes.dart';
import 'package:lanchonet/pages/cadastro_page/cadastro_page.dart';
import 'package:lanchonet/pages/cart_page.dart';
import 'package:lanchonet/pages/edita_page/editar_perfil.dart';
import 'package:lanchonet/pages/favorite_page.dart';
import 'package:lanchonet/pages/home_page/home_page.dart';
import 'package:lanchonet/pages/menu_page/menu_page.dart';
import 'package:lanchonet/pages/notify_page.dart';
import 'package:lanchonet/pages/pagamento_page/card_page.dart';
import 'package:lanchonet/pages/perfil_page/login_page.dart';
import 'package:lanchonet/router.dart';
import 'package:provider/provider.dart';
import '../dark_theme_widget/dark_theme_provider.dart';
import '../models/user.dart';
import '../services/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? mtoken = '';
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  bool click = true;
  bool valor = false;
  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  Future<Usuario?> readUser(uid) async {
    try {
      final docUser =
          FirebaseFirestore.instance.collection('perfil_geral').doc(uid);
      final snapshot = await docUser.get();
      if (snapshot.exists) {
        return Usuario.fromJson(snapshot.data()!);
      }
    } on FirebaseException catch (e) {
      Center(
        child: Text('Error $e'),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  late int currentIndex = 0;

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
    requestPermission();
    getToken();
    initInfo();
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const IOSInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
        } else {}
      } catch (e) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('------------------------OnMessage--------------------------');
      print(
          'onMessage: ${message.notification?.title}/${message.notification?.body}}');
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: false,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const IOSNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print('My token is $mtoken');
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('tokens')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'token': token,
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<Usuario?> readUser(uid) async {
      final docUser =
          FirebaseFirestore.instance.collection('perfil_geral').doc(uid);
      final snapshot = await docUser.get();
      if (snapshot.exists) {
        return Usuario.fromJson(snapshot.data()!);
      } else if (snapshot.exists == true) {
        print('tem algo errado');
      }
    }

    bool click = true;
    final width = MediaQuery.of(context).size.width;
    final text = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      drawer: Drawer(
          child: FutureBuilder<Usuario?>(
              future: readUser(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data;
                  Widget result = _buildAdminDrawer(context, user!);
                  if (user.getPermissoes == 'admin' ||
                      user.getPermissoes == 'funcionario') {
                    result = _buildAdminDrawer(context, user);
                  }
                  return result;
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildNavBar(context),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  _buildAdminDrawer(BuildContext context, Usuario user) => Container(
        child: Column(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              color: AppColor.primaryColor,
              child: Column(children: <Widget>[
                const SizedBox(
                  height: 26,
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.getImageUrl.toString()),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  user.getNome.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.copyWith(fontSize: 13, color: AppColor.textDark),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  user.getEmail.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.copyWith(fontSize: 13, color: AppColor.textDark),
                ),
                const SizedBox(
                  height: 13,
                ),
              ])),
          Expanded(
            flex: 3,
            child: ListView(children: <Widget>[
              ListTile(
                title: Text('Editar perfil'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  Navigator.pushNamed(context, 'editarPerfil');
                },
              ),
              ListTile(
                title: Text('Ajuda e feedback'),
                trailing: Icon(Icons.question_answer),
                onTap: () async {
                  const url =
                      'https://lanchonet10.000webhostapp.com/Contato.php';
                  var urllaunchable = await canLaunch(url);
                  if (urllaunchable) {
                    await launch(url);
                  } else {
                  }
                },
              ),
              ListTile(
                title: Text('Estoque de Produtos'),
                trailing: const Icon(Icons.library_books_outlined),
                onTap: () {
                  Navigator.pushNamed(context, 'estoqueProdutos');
                },
              ),
              ListTile(
                  title: Text('Caderneta de fiados'),
                  trailing: const Icon(Icons.menu_book_sharp),
                  onTap: () {
                    Navigator.pushNamed(context, 'cadernetaPage');
                  }),
              ExpansionTile(
                  onExpansionChanged: (value) {
                    setState(() => click = !click);
                  },
                  title: Text(
                    'Cadastros',
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(255, 158, 158, 158)),
                  ),
                  trailing: Icon(click ? Icons.expand_more : Icons.expand_less),
                  children: [
                    ListTile(
                      title: Text('Produtos'),
                      trailing: Icon(Icons.fastfood_outlined),
                      onTap: () {
                        Navigator.pushNamed(context, 'cadastroProdutos');
                      },
                    ),
                    ListTile(
                      title: Text('Ingredientes'),
                      trailing: Icon(Icons.restaurant_menu_rounded),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CadastroIngrediente()));
                      },
                    ),
                    ListTile(
                      title: Text('Fiados'),
                      trailing: Icon(Icons.edit_square),
                      onTap: () {
                        Navigator.pushNamed(context, 'cadastroFiado');
                      },
                    )
                  ]),
            ]),
          ),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              ListTile(
                title: Text('Modo escuro'),
                trailing: ChangeThemeButton(),
              ),
              ListTile(
                title: Text('Deslogar'),
                trailing: Icon(Icons.logout),
                onTap: () {
                  _signOut();
                  Navigator.pushNamed(context, 'login');
                },
              ),
            ]),
          ),
        ]),
      );

  _buildUserDrawer(BuildContext context, Usuario user) => Container(
        child: Column(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              color: AppColor.primaryColor,
              child: Column(children: <Widget>[
                const SizedBox(
                  height: 13,
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.getImageUrl.toString()),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  user.getNome.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.copyWith(fontSize: 13, color: AppColor.textDark),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  user.getEmail.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.copyWith(fontSize: 13, color: AppColor.textDark),
                ),
                const SizedBox(
                  height: 13,
                ),
              ])),
          ListTile(
            title: Text('Editar perfil'),
            trailing: const Icon(Icons.edit),
            onTap: () {
              Navigator.pushNamed(context, 'editarPerfil');
            },
          ),
          ListTile(
            title: Text('Lista de Produtos'),
            trailing: const Icon(Icons.library_books_outlined),
            onTap: () {
              Navigator.pushNamed(context, 'estoqueProdutos');
            },
          ),
          ListTile(
              title: Text('Caderneta de fiados'),
              trailing: const Icon(Icons.menu_book_sharp),
              onTap: () {
                Navigator.pushNamed(context, 'cadernetaPage');
              }),
          ExpansionTile(
              onExpansionChanged: (value) {
                setState(() => click = !click);
              },
              title: Text(
                'Cadastros',
                style: Theme.of(context).textTheme.headline3?.copyWith(
                    fontSize: 16, color: Color.fromARGB(255, 158, 158, 158)),
              ),
              trailing: Icon(click ? Icons.expand_more : Icons.expand_less),
              children: [
                ListTile(
                  title: Text('Produtos'),
                  trailing: Icon(Icons.fastfood_outlined),
                  onTap: () {
                    Navigator.pushNamed(context, 'cadastroProdutos');
                  },
                ),
                ListTile(
                  title: Text('Ingredientes'),
                  trailing: Icon(Icons.restaurant_menu_rounded),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastroIngrediente()));
                  },
                ),
                ListTile(
                  title: Text('Fiados'),
                  trailing: Icon(Icons.edit_square),
                  onTap: () {
                    Navigator.pushNamed(context, 'cadastroFiado');
                  },
                )
              ]),
          Expanded(
            child: ListView(children: [
              ListTile(
                title: Text('Modo escuro'),
                trailing: ChangeThemeButton(),
              ),
              ListTile(
                title: Text('Deslogar'),
                trailing: Icon(Icons.logout),
                onTap: () {
                  _signOut();
                  Navigator.pushNamed(context, 'login');
                },
              ),
            ]),
          ),
        ]),
      );
  _buildAppBar(BuildContext context) => AppBar(
        title: SizedBox(
          width: 128,
          height: 128,
          child: Image.asset("assets/images/lanchonet-name.png"),
        ),
        actions: [],
        iconTheme: const IconThemeData(
          size: 24.0,
          color: AppColor.primaryColor,
        ),
      );

  _buildBody(BuildContext context) {
    switch (currentIndex) {
      case 1:
        return const ExpansionPage();

      case 2:
        return const FavoritePage();

      case 3:
        return const CartPage();

      case 4:
        return const PerfilPage();

      case 5:
        return const LoginPage();

      case 6:
        return CadastroPage();

      case 7:
        return const MenuPage();

      case 8:
        return CreditCard();

      default:
        return const HomePage();
    }
  }

  _buildNavBar(BuildContext context) => BottomAppBar(
        shape: const CircularNotchedRectangle(),
        elevation: 10.0,
        notchMargin: 4.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: currentIndex == 0
                  ? const Icon(Icons.home)
                  : PngIcons.withName(PngIcons.home),
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(
                currentIndex == 1
                    ? Icons.notifications
                    : Icons.notifications_none,
              ),
              onPressed: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            ),
            const SizedBox(width: 32.0),
            IconButton(
              icon: Icon(
                currentIndex == 2 ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),
            Consumer<CartProvider>(builder: (context, cartProv, _) {
              if (cartProv.foods.isEmpty) {
                return IconButton(
                  icon: currentIndex == 3
                      ? const Icon(Icons.shopping_cart)
                      : PngIcons.withName(PngIcons.cart, size: 32.0),
                  onPressed: () {
                    setState(() {
                      currentIndex = 3;
                    });
                  },
                );
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: currentIndex == 3
                        ? const Icon(Icons.shopping_cart)
                        : PngIcons.withName(PngIcons.cart, size: 32.0),
                    onPressed: () {
                      setState(() {
                        currentIndex = 3;
                      });
                    },
                  ),
                  Positioned(
                    top: -5.0,
                    right: -5.0,
                    child: Container(
                      width: 25.0,
                      height: 25.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.0,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      child: FittedBox(
                        child: Text(
                          "${cartProv.itemsLength}",
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      );

  _buildFab(BuildContext context) => FloatingActionButton(
        elevation: 10.0,
        //open menu
        onPressed: () =>
            Navigator.of(context).pushNamed(FoodDeliveryRouter.menu),
        child: const Icon(Icons.restaurant_menu, color: Colors.white),
      );

  _buildEndDrawer(BuildContext context) {
    return Drawer(
      child: Column(children: [
        IconButton(
          icon: currentIndex == 0
              ? const Icon(Icons.home)
              : PngIcons.withName(PngIcons.home),
          onPressed: () {
            setState(() {
              currentIndex = 0;
            });
          },
        ),
        IconButton(
          icon: Icon(currentIndex == 1
              ? Icons.notifications
              : Icons.notifications_none),
          onPressed: () {
            setState(() {
              currentIndex = 1;
            });
          },
        ),
        const SizedBox(width: 32.0),
        IconButton(
          icon: Icon(
            currentIndex == 2 ? Icons.favorite : Icons.favorite_border,
          ),
          onPressed: () {
            setState(() {
              currentIndex = 2;
            });
          },
        ),
        _buildFab(context),
        Consumer<CartProvider>(builder: (context, cartProv, _) {
          if (cartProv.foods.isEmpty) {
            return IconButton(
              icon: currentIndex == 3
                  ? const Icon(Icons.shopping_cart)
                  : PngIcons.withName(PngIcons.cart, size: 32.0),
              onPressed: () {
                setState(() {
                  currentIndex = 3;
                });
              },
            );
          }
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: currentIndex == 3
                    ? const Icon(Icons.shopping_cart)
                    : PngIcons.withName(PngIcons.cart, size: 32.0),
                onPressed: () {
                  setState(() {
                    currentIndex = 3;
                  });
                },
              ),
              Positioned(
                top: -5.0,
                right: -5.0,
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1.0,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  child: FittedBox(
                    child: Text(
                      "${cartProv.itemsLength}",
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ]),
    );
  }
}
