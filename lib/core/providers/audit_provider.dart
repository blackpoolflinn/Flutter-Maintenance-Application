import 'package:flutter/material.dart';
import '../../data/models/audit_log.dart';
import '../services/audit_service.dart';

class AuditProvider extends ChangeNotifier {
  final AuditService _auditService = AuditService();
  List<AuditLog> _recentActivity = [];
  bool _isLoading = false;

  List<AuditLog> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading;

  Future<void> loadRecentActivity({int limit = 10}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _recentActivity = await _auditService.getRecentActivity(limit: limit);
    } catch (e) {
      // Silently handle errors, keep existing activity data
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshActivity() async {
    await loadRecentActivity();
  }
}
