import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/dart_mode.dart';
import 'package:habit_tracker/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // initially light theme
  ThemeData _themeData = lightTheme;

  // get current theme
  ThemeData get themedata => _themeData;

  // is current theme dark theme
  bool get isDarkTheme => _themeData == darkTheme;

  // set theme
  set themeDate(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightTheme) {
      themeDate = darkTheme;
    } else {
      themeDate = lightTheme;
    }
  }
}
