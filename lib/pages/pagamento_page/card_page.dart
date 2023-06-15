import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../services/theme_service.dart';

class CreditCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreditCardState();
  }
}

class CreditCardState extends State<CreditCard>
    with SingleTickerProviderStateMixin {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  late AnimationController controler;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    getCurrentAppTheme();
    super.initState();

    controler = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    controler.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        controler.reset();
      }
    });
  }

  @override
  void dispose() {
    controler.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adicionar cartão',
          style: Theme.of(context).textTheme.headline3,
        ),
        leading: BackButton(
          color: AppColor.primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage('assets/bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              CreditCardWidget(
                glassmorphismConfig:
                    useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                frontCardBorder:
                    !useGlassMorphism ? Border.all(color: Colors.grey) : null,
                backCardBorder:
                    !useGlassMorphism ? Border.all(color: Colors.grey) : null,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
                isHolderNameVisible: true,
                cardBgColor: Colors.black,
                backgroundImage:
                    useBackgroundImage ? 'assets/card_bg.png' : null,
                isSwipeGestureEnabled: true,
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                customCardTypeIcons: <CustomCardTypeIcon>[
                  CustomCardTypeIcon(
                    cardType: CardType.mastercard,
                    cardImage: Image.network(
                      'https://play-lh.googleusercontent.com/czro-ULAemRM1bMldf9gHQ7ajfa9NzKiZXFjI85mxawo60CaKMyHsjWaM38KHiZpsgY',
                      height: 48,
                      width: 48,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      CreditCardForm(
                        formKey: formKey,
                        obscureCvv: true,
                        obscureNumber: true,
                        cvvValidationMessage: 'legal',
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        isHolderNameVisible: true,
                        isCardNumberVisible: true,
                        isExpiryDateVisible: true,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        themeColor: themeState.getDarktheme
                            ? AppColor.primaryColor
                            : Color.fromARGB(255, 0, 140, 255),
                        textColor: themeState.getDarktheme
                            ? AppColor.textDark
                            : AppColor.titleTextColor,
                        cardNumberDecoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.textDark
                                      : Color.fromARGB(167, 85, 85, 85),
                                  style: BorderStyle.solid)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.primaryColor
                                      : Color.fromARGB(255, 0, 140, 255),
                                  style: BorderStyle.solid)),
                          labelText: 'Número do cartão',
                          labelStyle: Theme.of(context).textTheme.headline3,
                        ),
                        expiryDateDecoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.textDark
                                      : Color.fromARGB(167, 85, 85, 85),
                                  style: BorderStyle.solid)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.primaryColor
                                      : Color.fromARGB(255, 0, 140, 255),
                                  style: BorderStyle.solid)),
                          labelText: 'Data de validade',
                          labelStyle: Theme.of(context).textTheme.headline4,
                        ),
                        cvvCodeDecoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.textDark
                                      : Color.fromARGB(167, 85, 85, 85),
                                  style: BorderStyle.solid)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.primaryColor
                                      : Color.fromARGB(255, 0, 140, 255),
                                  style: BorderStyle.solid)),
                          labelText: 'CVC',
                          labelStyle: Theme.of(context).textTheme.headline3,
                        ),
                        cardHolderDecoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.primaryColor)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.textDark
                                      : Color.fromARGB(167, 85, 85, 85),
                                  style: BorderStyle.solid)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: themeState.getDarktheme
                                      ? AppColor.primaryColor
                                      : Color.fromARGB(255, 0, 140, 255),
                                  style: BorderStyle.solid)),
                          labelStyle: Theme.of(context).textTheme.headline3,
                          labelText: 'Nome do titular',
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(158, 68)),
                          onPressed: _onValidate,
                          label: Text(
                            "Confirmar",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: Icon(
                            Icons.check_circle_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 13,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onValidate() {
    if (formKey.currentState!.validate()) {
      return _showConfirm();
    } else {
      print('invalid!');
    }
  }

  void _showConfirm() => showDialog(
      context: context,
      builder: (context) => Center(
              child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animation/card.json',
                  repeat: false,
                  onLoaded: (composition) {
                    controler.forward();
                  },
                ),
                Text('Cartão Cadastrado!',
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(fontSize: 30, color: Colors.white))
              ],
            ),
          )));

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
