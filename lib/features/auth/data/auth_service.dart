import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Android Emulator: 'http://10.0.2.2:8000'
  // iOS Simulator / Windows: 'http://127.0.0.1:8000'
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // handle errors 
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}