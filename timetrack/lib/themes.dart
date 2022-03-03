

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blueGrey,
  primaryColor: Colors.blueGrey[900],
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.cyan[600],
  accentColorBrightness: Brightness.dark,
  fontFamily: 'PublicSans',
  //scaffoldBackgroundColor: Colors.grey[100],
  scaffoldBackgroundColor: Colors.white,
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.blueGrey[50],
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.grey,
  primaryColor: Colors.grey[900],
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.cyan[600],
  accentColorBrightness: Brightness.dark,
  fontFamily: 'PublicSans',
  scaffoldBackgroundColor: Colors.grey[800],
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.grey[850],
  ),
);

final ThemeData blackTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.grey,
  primaryColor: Colors.black,
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.cyan[600],
  accentColorBrightness: Brightness.dark,
  fontFamily: 'PublicSans',
  scaffoldBackgroundColor: Colors.black,
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.black,
  ),
);
