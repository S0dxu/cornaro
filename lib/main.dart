import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cornaro/pages/home.dart';
import 'package:cornaro/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cornaro/api/firebase_api.dart';
import 'package:cornaro/firebase_options.dart';
import 'package:cornaro/theme.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final token = await storage.read(key: 'session_token');

  if (token != null && token.isNotEmpty) {
    await FirebaseApi().initNotifications(token);
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final Widget initialPage =
      (token != null && token.isNotEmpty) ? const HomePage() : const LoginPage();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatefulWidget {
  final Widget initialPage;
  const MyApp({super.key, required this.initialPage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    refreshApp = () => setState(() {
          applySystemColors();
        });
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final t = await storage.read(key: "theme") ?? "light";
    currentTheme = t;
    applySystemColors();
    setState(() {});
  }

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
      home: widget.initialPage,
    );
  }
}
