import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'login.dart';
import 'package:flutter/services.dart';
import 'package:cornaro/theme.dart';
import 'package:flutter/foundation.dart';


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
  String currentTheme = "light";
  Uint8List? _selectedImageBytes;
  String? _selectedImageLink;


  File? _selectedImage;

  Future<void> _pickImage() async {
    bool? proceed = await showDialog<bool>(
      barrierColor: AppColors.text.withOpacity(0.05),
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.contrast,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Caricamento Immagine", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                "L'immagine che selezionerai verrà caricata su Imgur e non su un cloud privato.\nVuoi procedere?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.text),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.borderGrey,
                        foregroundColor: AppColors.text,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Procedi"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (proceed != true) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => loading = true);

    try {
      Uint8List imageBytes;

      if (kIsWeb) {
        imageBytes = await pickedFile.readAsBytes();
        _selectedImageBytes = imageBytes;
      } else {
        final file = File(pickedFile.path);
        imageBytes = await file.readAsBytes();
        _selectedImage = file;
      }

      final uploadUrl = Uri.parse("https://cornaro-backend.onrender.com/upload-imgur");
      final request = http.MultipartRequest('POST', uploadUrl);
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'profile.png'));

      final uploadResponse = await request.send();
      final uploadData = await http.Response.fromStream(uploadResponse);
      final uploadJson = jsonDecode(uploadData.body);

      if (uploadJson['link'] != null) {
        setState(() {
          _selectedImageLink = uploadJson['link'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Immagine caricata con successo")),
        );
      } else {
        throw Exception(uploadJson['message'] ?? "Errore upload");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore caricamento immagine: ${e.toString()}")),
      );
      _selectedImage = null;
      _selectedImageBytes = null;
    } finally {
      setState(() => loading = false);
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

    final url = Uri.parse(
      "https://cornaro-backend.onrender.com/register/request",
    );
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"schoolEmail": "${_schoolEmailController.text.trim()}@studenti.liceocornaro.edu.it"}),
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

    try {
      final body = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "instagram": _instagramController.text.trim(),
        "schoolEmail": "${_schoolEmailController.text.trim()}@studenti.liceocornaro.edu.it",
        "password": _passwordController.text.trim(),
        "code": _codeController.text.trim(),
        if (_selectedImageLink != null) "profileImage": _selectedImageLink,
      };

      final url = Uri.parse("https://cornaro-backend.onrender.com/register/verify");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore registrazione')),
      );
    } finally {
      setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    InputDecoration passwordInput(
      String label,
      bool obscure,
      VoidCallback toggle,
    ) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.bgGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      );
    }

    return Scaffold(
      /* resizeToAvoidBottomInset: false, */
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Registrati",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (!codeSent) ...[
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgGrey,
                        border: Border.all(
                          color: AppColors.borderGrey,
                          width: 1,
                        ),
                      ),
                      child: (_selectedImage != null || _selectedImageBytes != null)
                        ? ClipOval(
                            child: kIsWeb
                                ? (_selectedImageBytes != null
                                    ? Image.memory(
                                        _selectedImageBytes!,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      )
                                    : Container())
                                : (_selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      )
                                    : Container()),
                          )
                        : Icon(
                            Icons.camera_alt,
                            size: 36,
                            color: AppColors.text.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Foto profilo",
                      style: TextStyle(
                        color: AppColors.text.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _firstNameController,
                decoration: modernInput("Nome"),
                style: TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _lastNameController,
                decoration: modernInput("Cognome"),
                style: TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _instagramController,
                decoration: modernInput("Instagram (opzionale)"),
                style: TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 14),
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
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: AppColors.text),
                decoration: passwordInput("Password", _obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: TextStyle(color: AppColors.text),
                decoration: passwordInput(
                  "Conferma Password",
                  _obscureConfirmPassword,
                  () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              modernButton("Invia codice", loading, _sendCode),
            ] else ...[
              TextField(
                controller: _codeController,
                decoration: modernInput("Codice ricevuto"),
              ),
              const SizedBox(height: 24),
              modernButton(
                "Completa Registrazione",
                loading,
                _verifyAndRegister,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
