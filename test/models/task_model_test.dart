import 'package:flutter_test/flutter_test.dart';
import 'package:maintenance_application/data/models/task.dart';

void main() {
  group('Task', () {
    test('creates with correct defaults', () {
      final task = Task(
        title: 'Check engine',
        description: 'Inspect',
        aircraftId: 1,
      );

      expect(task.title, 'Check engine');
      expect(task.aircraftId, 1);
      expect(task.status, 'pending');
    });

    test('creates with custom status', () {
      final task = Task(
        title: 'Check engine',
        description: 'Inspect',
        aircraftId: 1,
        status: 'inProgress',
      );

      expect(task.status, 'inProgress');
    });

    test('creates as completed', () {
      final task = Task(
        title: 'Fix wing',
        description: 'Repair',
        aircraftId: 2,
        status: 'completed',
      );

      expect(task.status, 'completed');
      expect(task.title, 'Fix wing');
    });

    test('stores description', () {
      final task = Task(
        title: 'Check engine',
        description: 'Inspect and test',
        aircraftId: 1,
      );

      expect(task.description, 'Inspect and test');
    });

    test('stores aircraft id', () {
      final task = Task(
        title: 'Check engine',
        description: 'Inspect',
        aircraftId: 5,
      );

      expect(task.aircraftId, 5);
    });
  });
}
