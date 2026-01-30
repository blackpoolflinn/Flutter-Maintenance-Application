import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/job.dart';

class SyncProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  bool _isSyncing = false;
  String? _lastError;
  DateTime? _lastSyncAt;
  int _lastTasksSynced = 0;
  int _lastAircraftSynced = 0;

  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;
  DateTime? get lastSyncAt => _lastSyncAt;
  int get lastTasksSynced => _lastTasksSynced;
  int get lastAircraftSynced => _lastAircraftSynced;

  String _getBaseUrl() {
    // Android emulator needs 10.0.2.2 to reach host machine's localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Future<void> syncNow({String? baseUrl}) async {
    if (_isSyncing) return; // Prevent concurrent sync operations

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final url = baseUrl ?? _getBaseUrl();
      // Get all local data that hasn't been synced to backend yet
      final unsyncedTasks = await _db.getUnsyncedTasks();
      final unsyncedAircraft = await _db.getUnsyncedAircraft();

      final payload = {
        'tasks': unsyncedTasks
            .map(
              (t) => {
                'id': t.id,
                'title': t.title,
                'description': t.description,
                'status': t.status,
                'aircraftId': t.aircraftId,
                'attachments': t.attachments,
                'createdAt': t.createdAt.toIso8601String(),
              },
            )
            .toList(),
        'aircraft': unsyncedAircraft
            .map(
              (a) => {
                'id': a.id,
                'registrationNumber': a.registrationNumber,
                'model': a.model,
                'manufacturer': a.manufacturer,
                'yearOfManufacture': a.yearOfManufacture,
                'status': a.status,
                'createdAt': a.createdAt.toIso8601String(),
              },
            )
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$url/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('Sync failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final taskIds = (decoded['taskIds'] as List<dynamic>).cast<int>();
      final aircraftIds = (decoded['aircraftIds'] as List<dynamic>).cast<int>();

      // Mark local records as synced so they won't be sent again
      final syncedAt = DateTime.now();
      await _db.markTasksSynced(taskIds, syncedAt);
      await _db.markAircraftSynced(aircraftIds, syncedAt);

      _lastTasksSynced = taskIds.length;
      _lastAircraftSynced = aircraftIds.length;
      _lastSyncAt = syncedAt;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
