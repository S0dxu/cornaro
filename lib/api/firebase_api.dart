import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final String backendUrl = "https://cornaro-backend.onrender.com/fcm/register";

  Future<void> initNotifications(String jwtToken) async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken == null) return;

    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken",
      },
      body: jsonEncode({"token": fcmToken}),
    );

    if (response.statusCode == 200) {
      print(response.statusCode);
    } else {
      print("Errore invio token: ${response.statusCode} - ${response.body}");
    }
  }
}