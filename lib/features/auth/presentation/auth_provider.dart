import 'package:flutter/material.dart';
import '../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // called when app starts
  Future<void> checkAuthStatus() async {
    _isAuthenticated = await _authService.isLoggedIn();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}