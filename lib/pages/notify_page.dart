import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lanchonet/data/food_fake_data.dart';
import 'package:lanchonet/pages/main_page.dart';
import 'package:string_extensions/string_extensions.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/pedidos.dart';
import '../../services/theme_service.dart';

class ExpansionPage extends StatefulWidget {
  const ExpansionPage({Key? key}) : super(key: key);

  @override
  State<ExpansionPage> createState() => _ExpansionPageState();
}

class _ExpansionPageState extends State<ExpansionPage>
    with TickerProviderStateMixin {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late TabController _tabController;
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
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

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAnGyKc4w:APA91bGIMXIfeMj7fVi2fgaWqIOxUAmlojdE79Knbmr6zLgjIki2XZ_f0riOHqXjonr6nCUvUAsVLRVQSV6XgHFNBpBIyLxBxs3k3zv_8_IigdeEgIi6Hah9GhkGUyVsSG59GEgSKePa',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_Id': 'dbfood'
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("error push notification");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool active = false;
    return FutureBuilder(
      future: readUserLogged(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data;
          Widget header = ListTile(
              leading: (user!.getImageUrl == '')
                  ? Text(
                      '',
                      style: TextStyle(fontSize: 16),
                    )
                  : CircleAvatar(
                      radius: 35,
                      backgroundImage:
                          NetworkImage(user.getImageUrl.toString())),
              title: Text(user.getNome));
          if (user.getPermissoes == 'admin') {
            return StreamBuilder(
              stream: readPedidos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  final pedidos = snapshot.data;
                  List<Pedidos> pedido = [];
                  List<Pedidos> pedidosatuais = [];
                  List<Pedidos> pedidosprontos = [];
                  List<Pedidos> pedidoshistorico = [];
                  for (var y in pedidos!) {
                    if (y.cliente.getNome == user.getNome) {
                      pedido.add(y);
                    }
                  }
                  for (var x in pedido) {
                    if (x.entregue == true) {
                      pedidoshistorico.add(x);
                    }
                    if (x.pronto == true && x.entregue == false) {
                      pedidosprontos.add(x);
                    } else {
                      pedidosatuais.add(x);
                    }
                  }
                  String pedidoquantde = '';

                  return Scaffold(
                    appBar: _buildAppBar(context),
                    body: TabBarView(controller: _tabController, children: <
                        Widget>[
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ExpansionPanelList.radio(
                            expansionCallback: (index, isExpanded) {
                              if (active == true)
                                header = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                      ),
                                      Text(user.getNome)
                                    ]);
                              else if (active == false)
                                header = ListTile(
                                    // leading: (user.getImageUrl == '')
                                    //     ? Text(
                                    //         '',
                                    //         style: TextStyle(fontSize: 16),
                                    //       )
                                    //     : Image.network(
                                    //         user.getImageUrl,
                                    //       ),
                                    title: Text(user.getNome));
                            },
                            children: pedidosatuais.map<ExpansionPanel>((
                              Pedidos pedido,
                            ) {
                              String pedidoqtde = '';
                              for (var x = 0;
                                  x < pedido.pedido.quantity.length;
                                  x++) {
                                String chave =
                                    pedido.pedido.quantity.keys.elementAt(x);
                                pedidoqtde = pedidoqtde +
                                    ' ' +
                                    chave +
                                    ': ' +
                                    pedido.pedido.quantity[chave].toString();
                                pedidoquantde = pedidoqtde;
                              }
                              return ExpansionPanelRadio(
                                value: pedido.id,
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, isExpanded) {
                                  return Container(
                                      child: Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: header));
                                },
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(pedidoquantde.toString()),
                                            Text(' ' +
                                                pedido.pedido.amount
                                                    .toString()),
                                            Text(' ' + pedido.formadepagamento),
                                          ],
                                        )),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          String token = pedido.token;
                                          print(token);
                                          sendPushMessage(
                                              token,
                                              'Seu pedido está pronto. Venha buscá-lo!',
                                              'Lanchonet');
                                          Future createPedido() async {
                                            try {
                                              final docPedido =
                                                  FirebaseFirestore
                                                      .instance
                                                      .collection('pedidos')
                                                      .doc(
                                                          pedido.id.toString());
                                              Pedidos pedidos = Pedidos(
                                                token: pedido.token,
                                                id: pedido.id.toString(),
                                                cliente: pedido.cliente,
                                                pedido: pedido.pedido,
                                                pronto: true,
                                                entregue: false,
                                                formadepagamento:
                                                    pedido.formadepagamento,
                                              );
                                              var json = pedidos.toJson();
                                              await docPedido.set(json);
                                            } on FirebaseException catch (e) {
                                              Center(
                                                child: Text('Error $e'),
                                              );
                                            }
                                          }

                                          createPedido();
                                        },
                                        child: Text(
                                          'Entregar',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3
                                            ?..copyWith(
                                                color: AppColor.textDark),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ExpansionPanelList.radio(
                            expansionCallback: (index, isExpanded) {
                              if (active == true)
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              else if (active == false)
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                            },
                            children: pedidosprontos.map<ExpansionPanel>((
                              Pedidos pedido,
                            ) {
                              String pedidoqtde = '';
                              for (var x = 0;
                                  x < pedido.pedido.quantity.length;
                                  x++) {
                                String chave =
                                    pedido.pedido.quantity.keys.elementAt(x);
                                pedidoqtde = pedidoqtde +
                                    ' ' +
                                    chave +
                                    ': ' +
                                    pedido.pedido.quantity[chave].toString();
                                pedidoquantde = pedidoqtde;
                              }
                              return ExpansionPanelRadio(
                                value: pedido.id,
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, isExpanded) {
                                  return Container(
                                      child: Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: header));
                                },
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(pedidoquantde.toString()),
                                            Text(pedido.pedido.amount
                                                .toString()),
                                            Text(pedido.formadepagamento),
                                          ],
                                        )),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Future createPedido() async {
                                            try {
                                              final docPedido =
                                                  FirebaseFirestore
                                                      .instance
                                                      .collection('pedidos')
                                                      .doc(
                                                          pedido.id.toString());
                                              Pedidos pedidos = Pedidos(
                                                token: pedido.token,
                                                id: pedido.id.toString(),
                                                cliente: pedido.cliente,
                                                pedido: pedido.pedido,
                                                pronto: true,
                                                entregue: true,
                                                formadepagamento:
                                                    pedido.formadepagamento,
                                              );
                                              var json = pedidos.toJson();
                                              await docPedido.set(json);
                                            } on FirebaseException catch (e) {
                                              Center(
                                                child: Text('Error $e'),
                                              );
                                            }
                                          }

                                          createPedido();
                                        },
                                        child: Text(
                                          'Dar Baixa',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3
                                              ?.copyWith(
                                                  color: AppColor.textDark),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ExpansionPanelList.radio(
                            expansionCallback: (index, isExpanded) {
                              if (active == true)
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              else if (active == false)
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                            },
                            children: pedidoshistorico.map<ExpansionPanel>((
                              Pedidos pedido,
                            ) {
                              String pedidoqtde = '';
                              for (var x = 0;
                                  x < pedido.pedido.quantity.length;
                                  x++) {
                                String chave =
                                    pedido.pedido.quantity.keys.elementAt(x);
                                pedidoqtde = pedidoqtde +
                                    ' ' +
                                    chave +
                                    ': ' +
                                    pedido.pedido.quantity[chave].toString();
                                pedidoquantde = pedidoqtde;
                              }
                              return ExpansionPanelRadio(
                                value: pedido.id,
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, isExpanded) {
                                  return Container(
                                      child: Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: header));
                                },
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(pedidoquantde.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3),
                                            Text(
                                                pedido.pedido.amount.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3),
                                            Text(pedido.formadepagamento,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3),
                                          ],
                                        )),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ]),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else {
            return StreamBuilder(
              stream: readPedidos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  final pedidos = snapshot.data;
                  List<Pedidos> pedido = [];
                  List<Pedidos> pedidosatuais = [];
                  List<Pedidos> pedidosprontos = [];
                  List<Pedidos> pedidoshistorico = [];
                  for (var y in pedidos!) {
                    if (y.cliente.getNome == user.getNome) {
                      pedido.add(y);
                    }
                  }
                  for (var x in pedido) {
                    if (x.entregue == true) {
                      pedidoshistorico.add(x);
                    } else if (x.pronto == true) {
                      pedidosprontos.add(x);
                    } else {
                      pedidosatuais.add(x);
                    }
                  }
                  String pedidoquantde = '';
                  return Scaffold(
                    appBar: _buildAppBar(context),
                    body: TabBarView(controller: _tabController, children: <
                        Widget>[
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ExpansionPanelList.radio(
                            expansionCallback: (index, isExpanded) {
                              if (active == true) {
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              } else if (active == false) {
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              }
                            },
                            children: pedidosatuais.map<ExpansionPanel>((
                              Pedidos pedido,
                            ) {
                              String pedidoqtde = '';
                              for (var x = 0;
                                  x < pedido.pedido.quantity.length;
                                  x++) {
                                String chave =
                                    pedido.pedido.quantity.keys.elementAt(x);
                                pedidoqtde = pedidoqtde +
                                    ' ' +
                                    chave +
                                    ': ' +
                                    pedido.pedido.quantity[chave].toString();
                                pedidoquantde = pedidoqtde;
                              }
                              return ExpansionPanelRadio(
                                value: pedido.id,
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, isExpanded) {
                                  return Container(
                                      child: Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: header));
                                },
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(pedidoquantde.toString()),
                                            Text('' + pedido.pedido.amount
                                                .toString()),
                                            Text('' + pedido.formadepagamento),
                                          ],
                                        )),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          String token = pedido.token;
                                          print(token);
                                          sendPushMessage(
                                              token,
                                              'Seu pedido está pronto. Venha buscá-lo!',
                                              'Lanchonet');
                                          Future createPedido() async {
                                            try {
                                              final docPedido =
                                                  FirebaseFirestore
                                                      .instance
                                                      .collection('pedidos')
                                                      .doc(
                                                          pedido.id.toString());
                                              Pedidos pedidos = Pedidos(
                                                token: pedido.token,
                                                id: pedido.id.toString(),
                                                cliente: pedido.cliente,
                                                pedido: pedido.pedido,
                                                pronto: true,
                                                entregue: false,
                                                formadepagamento:
                                                    pedido.formadepagamento,
                                              );
                                              var json = pedidos.toJson();
                                              await docPedido.set(json);
                                            } on FirebaseException catch (e) {
                                              Center(
                                                child: Text('Error $e'),
                                              );
                                            }
                                          }

                                          createPedido();
                                        },
                                        child: Text(
                                          'Dar baixa',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3
                                              ?.copyWith(
                                                  color: AppColor.textDark),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ExpansionPanelList.radio(
                            expansionCallback: (index, isExpanded) {
                              if (active == true) {
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              } else if (active == false) {
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              }
                            },
                            children: pedidosprontos.map<ExpansionPanel>((
                              Pedidos pedido,
                            ) {
                              String pedidoqtde = '';
                              for (var x = 0;
                                  x < pedido.pedido.quantity.length;
                                  x++) {
                                String chave =
                                    pedido.pedido.quantity.keys.elementAt(x);
                                pedidoqtde = pedidoqtde +
                                    ' ' +
                                    chave +
                                    ': ' +
                                    pedido.pedido.quantity[chave].toString();
                                pedidoquantde = pedidoqtde;
                              }
                              return ExpansionPanelRadio(
                                value: pedido.id,
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, isExpanded) {
                                  return Container(
                                      child: Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: header));
                                },
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(pedidoquantde),
                                            Text('' + pedido.pedido.amount
                                                .toString()),
                                            Text('' + pedido.formadepagamento),
                                          ],
                                        )),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Future createPedido() async {
                                            try {
                                              final docPedido =
                                                  FirebaseFirestore
                                                      .instance
                                                      .collection('pedidos')
                                                      .doc(
                                                          pedido.id.toString());
                                              Pedidos pedidos = Pedidos(
                                                token: pedido.token,
                                                id: pedido.id.toString(),
                                                cliente: pedido.cliente,
                                                pedido: pedido.pedido,
                                                pronto: true,
                                                entregue: true,
                                                formadepagamento:
                                                    pedido.formadepagamento,
                                              );
                                              var json = pedidos.toJson();
                                              await docPedido.set(json);
                                            } on FirebaseException catch (e) {
                                              Center(
                                                child: Text('Error $e'),
                                              );
                                            }
                                          }

                                          createPedido();
                                        },
                                        child: Text(
                                          'Dar Baixa',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3
                                              ?.copyWith(
                                                  color: AppColor.textDark),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ExpansionPanelList.radio(
                            expansionCallback: (index, isExpanded) {
                              if (active == true) {
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              } else if (active == false) {
                                header = ListTile(
                                    leading: (user.getImageUrl == '')
                                        ? Text(
                                            '',
                                            style: TextStyle(fontSize: 16),
                                          )
                                        : CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                user.getImageUrl.toString())),
                                    title: Text(user.getNome));
                              }
                            },
                            children: pedidoshistorico.map<ExpansionPanel>((
                              Pedidos pedido,
                            ) {
                              String pedidoqtde = '';
                              for (var x = 0;
                                  x < pedido.pedido.quantity.length;
                                  x++) {
                                String chave =
                                    pedido.pedido.quantity.keys.elementAt(x);
                                pedidoqtde = pedidoqtde +
                                    ' ' +
                                    chave +
                                    ': ' +
                                    pedido.pedido.quantity[chave].toString();
                                pedidoquantde = pedidoqtde;
                              }
                              return ExpansionPanelRadio(
                                value: pedido.id,
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, isExpanded) {
                                  return Container(
                                      child: Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: header));
                                },
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(pedidoquantde.toString()),
                                            Text('' + pedido.pedido.amount
                                                .toString()),
                                            Text('' + pedido.formadepagamento),
                                          ],
                                        )),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ]),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        title: Text(
          "Gerenciar Pedidos",
          style: Theme.of(context).textTheme.headline3,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: Theme.of(context).textTheme.headline3,
          indicatorColor: AppColor.primaryColor,
          tabs: <Widget>[
            Tab(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  'Em Progresso',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
            Tab(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  'Prontos',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
            Tab(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  'Entregues',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
          ],
        ),
      );
}
