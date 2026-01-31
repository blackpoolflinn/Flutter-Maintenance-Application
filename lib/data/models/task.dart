import 'dart:convert';

class Task {
  final int? id;
  final String title;
  final String description;
  final String status;
  final int? aircraftId;
  final List<String> attachments;
  final DateTime? syncedAt;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.aircraftId,
    this.attachments = const [],
    this.syncedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'aircraftId': aircraftId,
      'attachments': jsonEncode(attachments),
      'syncedAt': syncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      aircraftId: map['aircraftId'],
      attachments: map['attachments'] != null
          ? List<String>.from(jsonDecode(map['attachments']))
          : const [],
      syncedAt: map['syncedAt'] != null ? DateTime.parse(map['syncedAt']) : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
