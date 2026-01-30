import 'package:flutter_test/flutter_test.dart';
import 'package:maintenance_application/data/models/job.dart';

void main() {
  group('Aircraft', () {
    test('creates with correct defaults', () {
      final aircraft = Aircraft(
        registrationNumber: 'N123',
        model: 'Plane',
        manufacturer: 'Maker',
        yearOfManufacture: 2020,
      );

      expect(aircraft.registrationNumber, 'N123');
      expect(aircraft.model, 'Plane');
      expect(aircraft.status, 'active');
    });

    test('creates under maintenance', () {
      final aircraft = Aircraft(
        registrationNumber: 'N456',
        model: 'Plane',
        manufacturer: 'Maker',
        yearOfManufacture: 2020,
        status: 'maintenance',
      );

      expect(aircraft.status, 'maintenance');
    });

    test('creates as retired', () {
      final aircraft = Aircraft(
        registrationNumber: 'N789',
        model: 'Plane',
        manufacturer: 'Maker',
        yearOfManufacture: 2020,
        status: 'retired',
      );

      expect(aircraft.status, 'retired');
      expect(aircraft.registrationNumber, 'N789');
    });

    test('stores model and manufacturer', () {
      final aircraft = Aircraft(
        registrationNumber: 'N123',
        model: 'Boeing 777',
        manufacturer: 'Boeing',
        yearOfManufacture: 2020,
      );

      expect(aircraft.model, 'Boeing 777');
      expect(aircraft.manufacturer, 'Boeing');
    });

    test('stores year of manufacture', () {
      final aircraft = Aircraft(
        registrationNumber: 'N456',
        model: 'Airbus',
        manufacturer: 'Airbus',
        yearOfManufacture: 2015,
      );

      expect(aircraft.yearOfManufacture, 2015);
    });
  });
}
