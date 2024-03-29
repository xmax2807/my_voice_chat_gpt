import 'package:flutter/material.dart';
import 'dart:developer' as dev;

final darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSwatch(
      primaryColorDark: const Color(0xFF212121),
      brightness: Brightness.dark,
      accentColor: Colors.yellow[700]),
  primaryIconTheme: const IconThemeData(color: Colors.black),
  dividerColor: Colors.black12,
);

final lightTheme = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    dividerColor: Colors.white54,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey).copyWith(
        secondary: Colors.black, background: const Color(0xFFE5E5E5)));

class ThemeNotifier with ChangeNotifier {
  ThemeData? themeData;
  bool isLightMode;
  ThemeNotifier({this.themeData, this.isLightMode = true}) {
    themeData ?? lightTheme;
  }

  getTheme() => themeData;
  bool getMode() => isLightMode;

  setTheme(ThemeData themeData) {
    this.themeData = themeData;
    notifyListeners();
  }

  switchTheme(bool lightMode) {
    isLightMode = lightMode;
    dev.log(isLightMode.toString());
    themeData = lightMode ? lightTheme : darkTheme;
    notifyListeners();
  }
}
