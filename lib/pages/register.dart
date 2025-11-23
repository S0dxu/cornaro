import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'login.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _instagramController = TextEditingController();
  final _schoolEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  bool loading = false;
  bool codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  File? _selectedImage;

  Future<void> _pickImage() async {
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Caricamento Immagine",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "L'immagine che selezionerai verrà caricata su Imgur e non su un cloud privato.\nVuoi procedere?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Annulla"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff0a45ac),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Procedi"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (proceed != true) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }


  Future<void> _sendCode() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _schoolEmailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compila tutti i campi obbligatori")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le password non coincidono")),
      );
      return;
    }

    setState(() => loading = true);

    final url = Uri.parse("https://cornaro-backend.vercel.app/register/request");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"schoolEmail": _schoolEmailController.text.trim()}),
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      setState(() => codeSent = true);
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Errore invio codice')),
      );
    }
  }

  Future<void> _verifyAndRegister() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci il codice ricevuto")),
      );
      return;
    }

    setState(() => loading = true);

    String? imageLink;

    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      final uploadUrl = Uri.parse("https://cornaro-backend.vercel.app/upload-imgur");
      final request = http.MultipartRequest('POST', uploadUrl);
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: 'profile.png'),
      );

      final uploadResponse = await request.send();
      final uploadData = await http.Response.fromStream(uploadResponse);
      final uploadJson = jsonDecode(uploadData.body);

      if (uploadResponse.statusCode == 200 && uploadJson['link'] != null) {
        imageLink = uploadJson['link'];
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore caricamento immagine")),
        );
        return;
      }

    }

    final body = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "instagram": _instagramController.text.trim(),
      "schoolEmail": _schoolEmailController.text.trim(),
      "password": _passwordController.text.trim(),
      "code": _codeController.text.trim(),
      if (imageLink != null) "profileImage": imageLink,
    };

    final url = Uri.parse("https://cornaro-backend.vercel.app/register/verify");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    setState(() => loading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrazione completata")),
      );
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Errore registrazione')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration passwordInput(String label, bool obscure, VoidCallback toggle) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xfff4f4f4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xCCdadada), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xCCdadada), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff0a45ac), width: 1.4),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "Registrati",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (!codeSent) ...[
              TextField(controller: _firstNameController, decoration: modernInput("Nome")),
              const SizedBox(height: 14),
              TextField(controller: _lastNameController, decoration: modernInput("Cognome")),
              const SizedBox(height: 14),
              TextField(controller: _instagramController, decoration: modernInput("Instagram (opzionale)")),
              const SizedBox(height: 14),
              TextField(controller: _schoolEmailController, decoration: modernInput("Email scolastica")),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xfff4f4f4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xCCdadada), width: 1),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.image, color: Colors.grey[700]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedImage != null
                                    ? "Immagine selezionata"
                                    : "Seleziona immagine (opzionale)",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: FileImage(_selectedImage!),
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: passwordInput("Password", _obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: passwordInput("Conferma Password", _obscureConfirmPassword, () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                }),
              ),
              const SizedBox(height: 20),
              modernButton("Invia codice", loading, _sendCode),
            ] else ...[
              TextField(controller: _codeController, decoration: modernInput("Codice ricevuto")),
              const SizedBox(height: 24),
              modernButton("Completa Registrazione", loading, _verifyAndRegister),
            ],
          ],
        ),
      ),
    );
  }
}
