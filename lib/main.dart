import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/dark_theme_widget/dark_theme_provider.dart';
import 'package:lanchonet/helpers/cart_handler.dart';
import 'package:lanchonet/router.dart';
import 'package:lanchonet/services/auth_service.dart';
import 'package:lanchonet/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  print('Handling a background message ${message.messageId}');
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(
          create: (context) =>
              CartProvider(amount: 0, foods: [], itemsLength: 0, quantity: {}),
        ),
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (_) {
          return themeChangeProvider;
        }),
      ],
      child:
          Consumer<DarkThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'LanchoNET ',
          theme: AppTheme.themeData(themeProvider.getDarktheme, context),
          debugShowCheckedModeBanner: false,
          onGenerateRoute: FoodDeliveryRouter.onGenerateRoute,
          routes: Routes.list,
          navigatorKey: Routes.navigatorKey,
        );
      }),
    );
  }
  }


//todo: cambiare tutto in italiano
