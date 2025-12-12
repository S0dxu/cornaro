import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cornaro/pages/home.dart';
import 'package:cornaro/pages/login.dart';
import 'package:cornaro/theme.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final theme = await storage.read(key: "theme") ?? "light";
  currentTheme = theme;
  applySystemColors();

  final token = await storage.read(key: 'session_token');
  final Widget initialPage =
      (token != null && token.isNotEmpty) ? const HomePage() : const LoginPage();

  runApp(MyApp(home: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.bgGrey,
        primaryColor: AppColors.primary,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.3),
          selectionHandleColor: AppColors.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text.withOpacity(0.4),
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: false,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.borderGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.borderGrey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: AppColors.text),
        ),
      ),
      home: home,
    );
  }
}
