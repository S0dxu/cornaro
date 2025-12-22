import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String currentTheme = "light";

class AppColors {
  static Color get primary => const Color(0xFF2157B3); //0xFF459da9

  static Color get bgGrey =>
      currentTheme == "dark"
          ? const Color(0xFF1c1d22)
          : const Color(0xFFF4F4F4);

  static Color get borderGrey =>
      currentTheme == "dark"
          ? const Color(0xFF3a3a3a)
          : const Color(0xFFdadada);

  static Color get text =>
      currentTheme == "dark"
          ? const Color(0xffc4c5ca)
          : Colors.black;

  static Color get contrast =>
      currentTheme == "dark"
          ? Color(0xFF121214)
          : Colors.white;

  static Color get red =>
      currentTheme == "dark"
          ? const Color(0xFFFF6F6A)
          : const Color(0xFFE53935);
}

late void Function() refreshApp;

void applySystemColors() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.bgGrey,
      statusBarIconBrightness:
          currentTheme == "dark" ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.bgGrey,
      systemNavigationBarIconBrightness:
          currentTheme == "dark" ? Brightness.light : Brightness.dark,
    ),
  );
}
