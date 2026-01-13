import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  
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
        final data = jsonDecode(response.body);
        
        //save token securely
        if (data['token'] != null) {
          await _storage.write(key: 'auth_token', value: data['token']);
        }
        
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}