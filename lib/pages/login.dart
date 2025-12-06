import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home.dart';
import 'register.dart';
import 'package:cornaro/theme.dart';
import 'package:flutter/services.dart';

/* class AppColors {
  static const primary = Color(0xff0a45ac);
  static const bgGrey = Color(0xfff4f4f4);
  static const borderGrey = Color(0xCCdadada);
} */

InputDecoration modernInput(String label) {
  return InputDecoration(
    labelText: label,
    hintStyle: TextStyle(color: AppColors.primary),
    labelStyle: TextStyle(
      color: AppColors.text.withOpacity(0.6),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: AppColors.bgGrey,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.borderGrey, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.borderGrey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 1.4),
    ),
  );
}

Widget modernButton(String text, bool loading, VoidCallback onTap) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: loading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xfff4f4f6),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    ),
  );
}

final storage = const FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
  
}

class _LoginPageState extends State<LoginPage> {
  final _schoolEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;

  /* @override
  void initState() {
    super.initState();
    
    currentTheme = "light";
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.bgGrey,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgGrey,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  } */


  Future<void> _login() async {
    setState(() => loading = true);
    final url = Uri.parse("https://cornaro-backend.onrender.com/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "schoolEmail": "${_schoolEmailController.text.trim()}@studenti.liceocornaro.edu.it",
        "password": _passwordController.text,
      }),
    );
    setState(() => loading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await storage.write(key: 'session_token', value: data['token']);
      await storage.write(
        key: 'user_name',
        value: (data['firstName'] ?? '') + ' ' + (data['lastName'] ?? '')
      );
      await storage.write(key: 'user_username', value: data['instagram'] ?? '');
      await storage.write(key: 'user_email', value: data['schoolEmail'] ?? '');
      await storage.write(key: 'user_profile_image', value: data['profileImage'] ?? '');

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Errore durante l\'accesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Center(
                child: Text(
                  "Accedi",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _schoolEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: modernInput("Email scolastica").copyWith(
                  suffixText: "@studenti.liceocor...",
                  suffixStyle: TextStyle(color: AppColors.text.withOpacity(0.8)),
                ),
                style: TextStyle(color: AppColors.text),
                onChanged: (value) {
                  final atIndex = value.indexOf('@');
                  if (atIndex != -1) {
                    final cleaned = value.substring(0, atIndex);
                    if (cleaned != value) {
                      _schoolEmailController.text = cleaned;
                      _schoolEmailController.selection = TextSelection.fromPosition(
                        TextPosition(offset: cleaned.length),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 14),
              TextField(
                cursorColor: AppColors.primary,
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: AppColors.text),
                decoration: modernInput("Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              modernButton("Accedi", loading, _login),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(AppColors.primary),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: const Text("Non hai un account? Registrati"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
