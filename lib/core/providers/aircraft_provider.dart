import 'package:flutter/material.dart';
import '../../data/models/job.dart';
import '../services/audit_service.dart';

class AircraftProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final AuditService _auditService = AuditService();
  List<Aircraft> _aircraft = [];
  bool _isLoading = false;

  List<Aircraft> get aircraft => _aircraft;
  bool get isLoading => _isLoading;

  /// Initialize and load aircraft from database
  Future<void> loadAircraft() async {
    _isLoading = true;
    notifyListeners();
    try {
      _aircraft = await _db.getAircraft();
    } catch (e) {
      // Handle error silently
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Create a new aircraft
  Future<void> createAircraft({
    required String registrationNumber,
    required String model,
    required String manufacturer,
    required int yearOfManufacture,
  }) async {
    try {
      final aircraft = Aircraft(
        registrationNumber: registrationNumber,
        model: model,
        manufacturer: manufacturer,
        yearOfManufacture: yearOfManufacture,
        status: 'active',
        syncedAt: null,
      );
      final aircraftId = await _db.insertAircraft(aircraft);
      await _auditService.logAircraftCreated(registrationNumber, aircraftId);
      await loadAircraft();
    } catch (e) {
      await loadAircraft();
    }
  }

  /// Delete an aircraft
  Future<void> deleteAircraft(int id) async {
    try {
      final aircraft = _aircraft.firstWhere((a) => a.id == id);
      await _db.deleteAircraft(id);
      await _auditService.logAircraftDeleted(aircraft.registrationNumber, id);
      await loadAircraft();
    } catch (e) {
      await loadAircraft();
    }
  }

  /// Update aircraft status
  Future<void> updateAircraftStatus(Aircraft aircraft, String newStatus) async {
    try {
      final updatedAircraft = Aircraft(
        id: aircraft.id,
        registrationNumber: aircraft.registrationNumber,
        model: aircraft.model,
        manufacturer: aircraft.manufacturer,
        yearOfManufacture: aircraft.yearOfManufacture,
        status: newStatus,
        syncedAt: null,  // Reset to trigger sync on next sync operation
        createdAt: aircraft.createdAt,
      );
      await _db.updateAircraft(updatedAircraft);
      await _auditService.logAircraftUpdated(aircraft.registrationNumber, aircraft.id, newStatus);
      await loadAircraft();
    } catch (e) {
      await loadAircraft();
    }
  }
}
