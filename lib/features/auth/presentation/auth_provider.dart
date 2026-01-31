import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../../../core/services/audit_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuditService _auditService = AuditService();
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
    final success = await _authService.login(email, password);
    if (success) {
      _isAuthenticated = true;
      // Set the current user in audit service
      _auditService.setCurrentUser(email);
      // Log the login activity
      await _auditService.logLogin();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auditService.logLogout();
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}