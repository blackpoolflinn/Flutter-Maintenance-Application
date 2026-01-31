class AuditLog {
  final int? id;
  final String userName;
  final String action;
  final String entityType;
  final String? entityId;
  final String? details;
  final DateTime createdAt;

  AuditLog({
    this.id,
    required this.userName,
    required this.action,
    required this.entityType,
    this.entityId,
    this.details,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'],
      userName: map['userName'],
      action: map['action'],
      entityType: map['entityType'],
      entityId: map['entityId'],
      details: map['details'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
