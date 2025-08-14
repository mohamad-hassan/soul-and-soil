import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

enum AppTheme { Light, Dark }

final appThemeData = {
  AppTheme.Light: ThemeData(
      useMaterial3: false,
      fontFamily: 'Roboto',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      canvasColor: backgroundColor,
      textTheme: const TextTheme().apply(bodyColor: darkSecondaryColor, displayColor: darkSecondaryColor),
      appBarTheme: AppBarTheme(
          elevation: 0.0,
          backgroundColor: backgroundColor, //Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark, statusBarColor: backgroundColor.withOpacity(0.8))),
      iconTheme: const IconThemeData(color: darkSecondaryColor),
      colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          surface: secondaryColor,
          secondary: secondaryColor,
          onPrimary: darkBackgroundColor,
          secondaryContainer: darkSecondaryColor,
          outline: borderColor,
          primaryContainer: darkSecondaryColor),
      dialogBackgroundColor: backgroundColor //for datePicker
      ),
  AppTheme.Dark: ThemeData(
      useMaterial3: false,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      canvasColor: darkSecondaryColor,
      appBarTheme: AppBarTheme(
          elevation: 0.0,
          backgroundColor: darkBackgroundColor, //Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
            statusBarColor: darkSecondaryColor.withOpacity(0.8),
          )),
      textTheme: const TextTheme().apply(bodyColor: secondaryColor, displayColor: secondaryColor),
      iconTheme: const IconThemeData(color: secondaryColor),
      colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          onPrimary: secondaryColor,
          surface: darkBackgroundColor,
          brightness: Brightness.dark,
          secondary: darkSecondaryColor,
          secondaryContainer: primaryColor,
          outline: backgroundColor,
          primaryContainer: secondaryColor //for datePicker
          ),
      dialogBackgroundColor: darkBackgroundColor),
};
