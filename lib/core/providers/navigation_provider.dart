import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentPage = 'dashboard';

  String get currentPage => _currentPage;

  void navigateTo(String page) {
    _currentPage = page;
    notifyListeners();
  }
}
