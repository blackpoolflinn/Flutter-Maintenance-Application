import '../../data/models/job.dart';

class AuditService {
  static final AuditService _instance = AuditService._internal();
  final DatabaseHelper _db = DatabaseHelper();
  
  factory AuditService() {
    return _instance;
  }

  AuditService._internal();

  // Current user name - using rampcheck as default
  String _currentUser = 'rampcheck';

  String get currentUser => _currentUser;

  void setCurrentUser(String userName) {
    _currentUser = userName;
  }

  Future<void> logAction({
    required String action,
    required String entityType,
    String? entityId,
    String? details,
  }) async {
    try {
      final log = AuditLog(
        userName: _currentUser,
        action: action,
        entityType: entityType,
        entityId: entityId,
        details: details,
      );
      await _db.insertAuditLog(log);
    } catch (e) {
      // Fail silently to not disrupt user actions if audit logging fails
    }
  }

  Future<void> logLogin() async {
    await logAction(
      action: 'login',
      entityType: 'auth',
      details: 'User logged in',
    );
  }

  Future<void> logLogout() async {
    await logAction(
      action: 'logout',
      entityType: 'auth',
      details: 'User logged out',
    );
  }

  Future<void> logTaskCreated(String taskTitle, int? taskId) async {
    await logAction(
      action: 'create',
      entityType: 'task',
      entityId: taskId?.toString(),
      details: 'Created task: $taskTitle',
    );
  }

  Future<void> logTaskUpdated(String taskTitle, int? taskId, String? statusChange) async {
    final detail = statusChange != null
        ? 'Updated task "$taskTitle" status to $statusChange'
        : 'Updated task: $taskTitle';
    await logAction(
      action: 'update',
      entityType: 'task',
      entityId: taskId?.toString(),
      details: detail,
    );
  }

  Future<void> logTaskDeleted(String taskTitle, int? taskId) async {
    await logAction(
      action: 'delete',
      entityType: 'task',
      entityId: taskId?.toString(),
      details: 'Deleted task: $taskTitle',
    );
  }

  Future<void> logAircraftCreated(String registration, int? aircraftId) async {
    await logAction(
      action: 'create',
      entityType: 'aircraft',
      entityId: aircraftId?.toString(),
      details: 'Created aircraft: $registration',
    );
  }

  Future<void> logAircraftUpdated(String registration, int? aircraftId, String? statusChange) async {
    final detail = statusChange != null
        ? 'Updated aircraft "$registration" status to $statusChange'
        : 'Updated aircraft: $registration';
    await logAction(
      action: 'update',
      entityType: 'aircraft',
      entityId: aircraftId?.toString(),
      details: detail,
    );
  }

  Future<void> logAircraftDeleted(String registration, int? aircraftId) async {
    await logAction(
      action: 'delete',
      entityType: 'aircraft',
      entityId: aircraftId?.toString(),
      details: 'Deleted aircraft: $registration',
    );
  }

  Future<void> logSync(int tasksSynced, int aircraftSynced) async {
    await logAction(
      action: 'sync',
      entityType: 'system',
      details: 'Synced $tasksSynced tasks and $aircraftSynced aircraft',
    );
  }

  Future<List<AuditLog>> getRecentActivity({int limit = 10}) async {
    return await _db.getRecentAuditLogs(limit: limit);
  }
}
