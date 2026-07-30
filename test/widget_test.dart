// Basic sanity tests for the Industrial IoT front-end demo data layer.
//
// The UI relies on google_fonts (network) so we keep tests to the pure-Dart
// model / service layer, which is where a real backend will plug in.

import 'package:flutter_test/flutter_test.dart';
import 'package:industrial_iot/models/machine.dart';
import 'package:industrial_iot/services/mock_data_service.dart';

void main() {
  test('mock data exposes machines across lines', () {
    expect(MockDataService.machines, isNotEmpty);
    expect(MockDataService.totalMachines, MockDataService.machines.length);
  });

  test('running machine count matches status', () {
    final running = MockDataService.machines
        .where((m) => m.status == MachineStatus.running)
        .length;
    expect(MockDataService.runningMachines, running);
  });

  test('active alarms exclude acknowledged', () {
    final active =
        MockDataService.alarms.where((a) => !a.acknowledged).length;
    expect(MockDataService.activeAlarms, active);
  });

  test('production order progress is clamped 0..1', () {
    for (final o in MockDataService.orders) {
      expect(o.progress, inInclusiveRange(0.0, 1.0));
    }
  });
}
