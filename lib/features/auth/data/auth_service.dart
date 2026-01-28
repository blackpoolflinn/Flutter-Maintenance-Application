import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      // Simple local auth - no backend call needed
      if (email == 'rampcheck' && password == 'password123') {
        await _storage.write(key: 'auth_token', value: 'demo_token_123');
        return true;
      }
      return false;
    } catch (e) {
      return false;
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