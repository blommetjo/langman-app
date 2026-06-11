import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiService {

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {

    try {

      final response = await http.post(
        Uri.parse(
          "${AppConfig.baseUrl}/login.php",
        ),
        body: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "status": "error",
        "message":
            "Server fout: ${response.statusCode}",
      };

    } catch (e) {

      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  static Future<List<dynamic>>
      getWerkbonnen() async {

    final response = await http.get(
      Uri.parse(
        "${AppConfig.baseUrl}/get_werkbonnen.php",
      ),
    );

    return jsonDecode(response.body);
  }
}