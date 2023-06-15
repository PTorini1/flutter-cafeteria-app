import 'package:flutter/material.dart';
import 'dark_theme_prefs.dart';

class DarkThemeProvider with ChangeNotifier{
  DarkThemePrefs darkThemePrefs = DarkThemePrefs();
  bool _darkTheme = false;
  bool get getDarktheme => _darkTheme;

  set setDarkTheme (bool value){
    _darkTheme = value;
    darkThemePrefs.setDarkTheme(value);
    notifyListeners();

  }
}