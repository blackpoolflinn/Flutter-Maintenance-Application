import 'package:flutter/material.dart';
import '../../data/models/job.dart';

class AircraftProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
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
      await _db.insertAircraft(aircraft);
      await loadAircraft();
    } catch (e) {
      print('Error creating aircraft: $e');
      await loadAircraft();
    }
  }

  /// Delete an aircraft
  Future<void> deleteAircraft(int id) async {
    try {
      await _db.deleteAircraft(id);
      await loadAircraft();
    } catch (e) {
      print('Error deleting aircraft: $e');
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
        syncedAt: null,
        createdAt: aircraft.createdAt,
      );
      await _db.updateAircraft(updatedAircraft);
      await loadAircraft();
    } catch (e) {
      print('Error updating aircraft: $e');
      await loadAircraft();
    }
  }
}
