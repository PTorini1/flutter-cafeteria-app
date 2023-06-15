import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeData(bool isDarkMode, BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: isDarkMode
          ? Color.fromARGB(255, 29, 29, 29)
          : Color.fromARGB(255, 255, 255, 255),
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDarkMode
            ? Color.fromARGB(255, 0, 0, 0)
            : Color.fromARGB(255, 255, 255, 255),
        secondary: AppColor.primaryColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: isDarkMode ? AppColor.primaryColor : AppColor.primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkMode
                  ? Color.fromARGB(255, 255, 255, 255)
                  : Color.fromARGB(167, 85, 85, 85),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.0,
              style: BorderStyle.solid,
              color: isDarkMode
                  ? AppColor.primaryColor
                  : Color.fromARGB(255, 0, 140, 255),
            ),
          )),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode
            ? Color.fromARGB(255, 29, 29, 29)
            : Color.fromARGB(255, 255, 255, 255),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor:
            isDarkMode ? AppColor.primaryColor : AppColor.primaryColor,
      ),
      iconTheme: IconThemeData(size: 24.0, color: AppColor.primaryColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 255, 0, 0),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDarkMode
            ? Color.fromARGB(255, 255, 255, 255)
            : Color.fromARGB(255, 140, 140, 140),
       
      ),
      textTheme: TextTheme(
        //testo per descrizioni
        bodyText1: TextStyle(
          color: AppColor.descriptionColor,
          fontWeight: FontWeight.normal,
        ),
        //testo per i titoli
        bodyText2: TextStyle(
          color: isDarkMode ? AppColor.textDark : AppColor.titleTextColor,
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
        ),
         headline1: TextStyle(
          color: isDarkMode ? AppColor.textDark : AppColor.titleTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
        headline2: TextStyle(
          color: isDarkMode ? AppColor.textDark : AppColor.titleTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
       
        headline3: TextStyle(
          color: isDarkMode ? AppColor.textDark : AppColor.titleTextColor,
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
        ),
         headline4: TextStyle(
          color: isDarkMode ? AppColor.textDark : AppColor.titleTextColor,
          fontWeight: FontWeight.w400,
          fontSize: 18.0,
        ),
         headline5: TextStyle(
          color: isDarkMode
              ? AppColor.textDark
              : Color.fromARGB(255, 168, 168, 168),
          fontSize: 18.0,
        ),
        headline6: TextStyle(
            color: isDarkMode ? AppColor.textDark : AppColor.titleTextColor,),
      ),
    );
  }
}

extension AppColor on Colors {
  //green
  static const primaryColor = Color.fromARGB(255, 219, 45, 45);
  //light grey for text on description
  static const descriptionColor = Color(0XFF9E9E9E);
  //black for Title text
  static const titleTextColor = Color(0xFF061737);
  // para os textos
  static const textDark = Color(0xFFFFFFFF);
  //icon
  static const iconDark = Color(0xFFFFFFFF);
  //transparent
  static const transparentColor = Color(0xFFC4C4C4);
  //color light for drawing background
  static const figureBckColor = Color(0xFFFAFAFA);
}
