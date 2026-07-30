import '../models/machine.dart';
import '../models/production_order.dart';
import '../models/alarm.dart';
import '../models/maintenance_task.dart';
import '../models/shift_report.dart';
import '../models/production_line.dart';

/// Single source of demo data for the front-end.
///
/// Every screen reads from here. To go live, replace these static getters with
/// calls into a repository backed by REST / MQTT / WebSocket — the models and
/// widgets stay unchanged.
class MockDataService {
  static DateTime get _now => DateTime.now();

  // ── Identity ──────────────────────────────────────────────────────────
  static const String plantName = 'Shah Alam Plant 2';
  static const String managerName = 'Ir. Hafiz Rahman';
  static const String operatorName = 'Zul Ariffin';
  static const String operatorLine = 'Line 2 · Injection Molding';

  // ── Plant-level KPIs (Manager dashboard) ─────────────────────────────────
  static double get plantOee => 78.4;
  static double get plantAvailability => 90.2;
  static double get plantPerformance => 88.6;
  static double get plantQuality => 98.1;
  static int get outputToday => 14280;
  static int get targetToday => 18000;
  static int get runningMachines =>
      machines.where((m) => m.status == MachineStatus.running).length;
  static int get totalMachines => machines.length;
  static int get activeAlarms =>
      alarms.where((a) => !a.acknowledged).length;
  static int get criticalAlarms => alarms
      .where((a) => !a.acknowledged && a.severity == AlarmSeverity.critical)
      .length;

  static double get outputAttainment => (outputToday / targetToday) * 100;

  // ── Charts ───────────────────────────────────────────────────────────────
  /// Output units per hour across the current 12h shift window.
  static List<double> get hourlyOutput =>
      [820, 910, 880, 950, 1020, 990, 1040, 1010, 1080, 1120, 1060, 1180];

  /// Plant OEE per hour (%) across the shift.
  static List<double> get hourlyOee =>
      [72, 75, 74, 78, 80, 77, 79, 76, 81, 83, 80, 84];

  /// OEE over the last 7 days (Mon → Sun).
  static List<double> get weeklyOee => [74, 79, 77, 82, 80, 76, 78];

  /// Target line for weekly OEE.
  static const double oeeTarget = 85;

  static List<DowntimeReason> get downtimeReasons => const [
        DowntimeReason('Changeover', 148),
        DowntimeReason('Material shortage', 96),
        DowntimeReason('Mechanical fault', 72),
        DowntimeReason('Quality hold', 54),
        DowntimeReason('No operator', 38),
        DowntimeReason('Cleaning', 22),
      ];

  static List<DefectCategory> get defectCategories => const [
        DefectCategory('Short shot', 62),
        DefectCategory('Flash', 41),
        DefectCategory('Warping', 28),
        DefectCategory('Contamination', 17),
        DefectCategory('Colour mismatch', 9),
      ];

  // ── Production lines ───────────────────────────────────────────────────
  static List<ProductionLine> get lines => const [
        ProductionLine(id: 'l1', name: 'Line 1 · Assembly', machineCount: 4, runningCount: 3, oee: 81.2, output: 5200, target: 6000),
        ProductionLine(id: 'l2', name: 'Line 2 · Injection Molding', machineCount: 3, runningCount: 2, oee: 74.8, output: 4180, target: 6000),
        ProductionLine(id: 'l3', name: 'Line 3 · Packaging', machineCount: 3, runningCount: 3, oee: 79.6, output: 4900, target: 6000),
      ];

  // ── Machines ───────────────────────────────────────────────────────────
  static List<double> _trend(List<int> v) => v.map((e) => e.toDouble()).toList();

  static List<Machine> get machines => [
        Machine(
          id: 'm1', name: 'CNC Mill A1', code: 'CNC-01', line: 'Line 1 · Assembly', type: 'CNC Machining Center',
          status: MachineStatus.running, oee: 84.1, availability: 93, performance: 91, quality: 99.3,
          temperature: 62.4, vibration: 2.1, speed: 1450, power: 18.6, throughput: 142, targetThroughput: 150,
          currentJob: 'WO-4471 · Bracket A', uptimePct: 96.2,
          lastMaintenance: DateTime(2026, 7, 12), nextMaintenance: DateTime(2026, 8, 12),
          oeeTrend: _trend([78, 80, 79, 82, 81, 83, 84, 82, 85, 84, 86, 84]),
        ),
        Machine(
          id: 'm2', name: 'Robotic Arm R2', code: 'ROB-02', line: 'Line 1 · Assembly', type: '6-Axis Robotic Arm',
          status: MachineStatus.running, oee: 88.7, availability: 95, performance: 94, quality: 99.4,
          temperature: 48.1, vibration: 1.2, speed: 0, power: 6.3, throughput: 210, targetThroughput: 220,
          currentJob: 'WO-4471 · Bracket A', uptimePct: 98.0,
          lastMaintenance: DateTime(2026, 7, 20), nextMaintenance: DateTime(2026, 8, 20),
          oeeTrend: _trend([84, 85, 86, 88, 87, 89, 90, 88, 89, 90, 91, 89]),
        ),
        Machine(
          id: 'm3', name: 'Assembly Press P3', code: 'PRS-03', line: 'Line 1 · Assembly', type: 'Hydraulic Press',
          status: MachineStatus.idle, oee: 61.3, availability: 74, performance: 84, quality: 98.6,
          temperature: 41.0, vibration: 0.6, speed: 0, power: 2.1, throughput: 0, targetThroughput: 120,
          currentJob: 'Awaiting material', uptimePct: 71.4,
          lastMaintenance: DateTime(2026, 6, 30), nextMaintenance: DateTime(2026, 7, 31),
          oeeTrend: _trend([70, 68, 66, 64, 60, 58, 55, 60, 62, 61, 63, 61]),
        ),
        Machine(
          id: 'm4', name: 'Vision QC V4', code: 'QC-04', line: 'Line 1 · Assembly', type: 'Vision Inspection',
          status: MachineStatus.running, oee: 90.2, availability: 96, performance: 95, quality: 99.0,
          temperature: 39.7, vibration: 0.3, speed: 0, power: 1.4, throughput: 205, targetThroughput: 210,
          currentJob: 'Inline QC', uptimePct: 99.1,
          lastMaintenance: DateTime(2026, 7, 22), nextMaintenance: DateTime(2026, 8, 22),
          oeeTrend: _trend([88, 89, 90, 91, 90, 92, 91, 90, 91, 92, 90, 90]),
        ),
        Machine(
          id: 'm5', name: 'Injection Molder IM1', code: 'IMM-05', line: 'Line 2 · Injection Molding', type: 'Injection Moulding',
          status: MachineStatus.running, oee: 79.0, availability: 88, performance: 91, quality: 98.7,
          temperature: 214.5, vibration: 3.4, speed: 0, power: 44.2, throughput: 96, targetThroughput: 110,
          currentJob: 'WO-4488 · Housing B', uptimePct: 90.5,
          lastMaintenance: DateTime(2026, 7, 5), nextMaintenance: DateTime(2026, 8, 5),
          oeeTrend: _trend([74, 76, 75, 78, 80, 79, 77, 78, 80, 79, 81, 79]),
        ),
        Machine(
          id: 'm6', name: 'Injection Molder IM2', code: 'IMM-06', line: 'Line 2 · Injection Molding', type: 'Injection Moulding',
          status: MachineStatus.down, oee: 0, availability: 0, performance: 0, quality: 0,
          temperature: 176.2, vibration: 0.0, speed: 0, power: 3.1, throughput: 0, targetThroughput: 110,
          currentJob: 'Fault · Hydraulic pressure low', uptimePct: 42.0,
          lastMaintenance: DateTime(2026, 6, 18), nextMaintenance: DateTime(2026, 7, 30),
          oeeTrend: _trend([70, 68, 60, 55, 40, 20, 0, 0, 0, 0, 0, 0]),
        ),
        Machine(
          id: 'm7', name: 'Dryer / Feeder D7', code: 'DRY-07', line: 'Line 2 · Injection Molding', type: 'Material Dryer',
          status: MachineStatus.maintenance, oee: 0, availability: 0, performance: 0, quality: 0,
          temperature: 55.0, vibration: 0.0, speed: 0, power: 5.0, throughput: 0, targetThroughput: 0,
          currentJob: 'Scheduled PM in progress', uptimePct: 88.0,
          lastMaintenance: DateTime(2026, 7, 30), nextMaintenance: DateTime(2026, 9, 1),
          oeeTrend: _trend([80, 82, 81, 79, 80, 78, 0, 0, 0, 0, 0, 0]),
        ),
        Machine(
          id: 'm8', name: 'Filler F8', code: 'FIL-08', line: 'Line 3 · Packaging', type: 'Rotary Filler',
          status: MachineStatus.running, oee: 82.6, availability: 92, performance: 90, quality: 99.8,
          temperature: 34.2, vibration: 1.0, speed: 1200, power: 9.7, throughput: 380, targetThroughput: 400,
          currentJob: 'WO-4490 · 500ml Bottle', uptimePct: 95.4,
          lastMaintenance: DateTime(2026, 7, 15), nextMaintenance: DateTime(2026, 8, 15),
          oeeTrend: _trend([80, 81, 82, 83, 82, 84, 83, 82, 84, 83, 85, 83]),
        ),
        Machine(
          id: 'm9', name: 'Labeler L9', code: 'LBL-09', line: 'Line 3 · Packaging', type: 'Labelling Machine',
          status: MachineStatus.running, oee: 77.9, availability: 89, performance: 89, quality: 98.3,
          temperature: 36.8, vibration: 0.8, speed: 1180, power: 4.2, throughput: 372, targetThroughput: 400,
          currentJob: 'WO-4490 · 500ml Bottle', uptimePct: 93.0,
          lastMaintenance: DateTime(2026, 7, 10), nextMaintenance: DateTime(2026, 8, 10),
          oeeTrend: _trend([75, 76, 78, 77, 79, 78, 77, 78, 79, 77, 78, 78]),
        ),
        Machine(
          id: 'm10', name: 'Palletizer PZ10', code: 'PAL-10', line: 'Line 3 · Packaging', type: 'Palletizer Robot',
          status: MachineStatus.running, oee: 78.3, availability: 91, performance: 87, quality: 99.0,
          temperature: 44.0, vibration: 1.5, speed: 0, power: 7.8, throughput: 360, targetThroughput: 400,
          currentJob: 'WO-4490 · 500ml Bottle', uptimePct: 94.1,
          lastMaintenance: DateTime(2026, 7, 8), nextMaintenance: DateTime(2026, 8, 8),
          oeeTrend: _trend([76, 77, 78, 79, 78, 80, 79, 78, 79, 80, 78, 78]),
        ),
      ];

  static Machine machineById(String id) =>
      machines.firstWhere((m) => m.id == id, orElse: () => machines.first);

  static List<Machine> machinesForLine(String line) =>
      machines.where((m) => m.line == line).toList();

  /// Machines assigned to the demo operator (Line 2).
  static List<Machine> get operatorMachines =>
      machinesForLine('Line 2 · Injection Molding');

  // ── Production orders ────────────────────────────────────────────────────
  static List<ProductionOrder> get orders => [
        ProductionOrder(id: 'o1', orderNo: 'WO-4471', product: 'Bracket A (Steel)', line: 'Line 1 · Assembly', targetQty: 6000, producedQty: 5200, goodQty: 5164, rejectQty: 36, status: OrderStatus.inProgress, startTime: _now.subtract(const Duration(hours: 5)), dueTime: _now.add(const Duration(hours: 2))),
        ProductionOrder(id: 'o2', orderNo: 'WO-4488', product: 'Housing B (ABS)', line: 'Line 2 · Injection Molding', targetQty: 6000, producedQty: 4180, goodQty: 4126, rejectQty: 54, status: OrderStatus.inProgress, startTime: _now.subtract(const Duration(hours: 6)), dueTime: _now.add(const Duration(hours: 3))),
        ProductionOrder(id: 'o3', orderNo: 'WO-4490', product: '500ml Bottle Fill', line: 'Line 3 · Packaging', targetQty: 6000, producedQty: 4900, goodQty: 4890, rejectQty: 10, status: OrderStatus.inProgress, startTime: _now.subtract(const Duration(hours: 4)), dueTime: _now.add(const Duration(hours: 1))),
        ProductionOrder(id: 'o4', orderNo: 'WO-4492', product: 'Cover C (PP)', line: 'Line 2 · Injection Molding', targetQty: 4500, producedQty: 0, goodQty: 0, rejectQty: 0, status: OrderStatus.queued, startTime: _now.add(const Duration(hours: 3))),
        ProductionOrder(id: 'o5', orderNo: 'WO-4465', product: 'Bracket A (Steel)', line: 'Line 1 · Assembly', targetQty: 5000, producedQty: 5000, goodQty: 4972, rejectQty: 28, status: OrderStatus.completed, startTime: _now.subtract(const Duration(hours: 14)), dueTime: _now.subtract(const Duration(hours: 6))),
        ProductionOrder(id: 'o6', orderNo: 'WO-4480', product: 'Gasket D (Rubber)', line: 'Line 2 · Injection Molding', targetQty: 3000, producedQty: 1200, goodQty: 1180, rejectQty: 20, status: OrderStatus.onHold, startTime: _now.subtract(const Duration(hours: 8))),
      ];

  // ── Alarms ─────────────────────────────────────────────────────────────
  static List<Alarm> get alarms => [
        Alarm(id: 'a1', machineName: 'Injection Molder IM2', line: 'Line 2 · Injection Molding', message: 'Hydraulic pressure below threshold (fault stop)', severity: AlarmSeverity.critical, timestamp: _now.subtract(const Duration(minutes: 12))),
        Alarm(id: 'a2', machineName: 'Assembly Press P3', line: 'Line 1 · Assembly', message: 'Idle > 15 min — awaiting raw material', severity: AlarmSeverity.warning, timestamp: _now.subtract(const Duration(minutes: 28))),
        Alarm(id: 'a3', machineName: 'Injection Molder IM1', line: 'Line 2 · Injection Molding', message: 'Barrel temperature 214°C approaching limit', severity: AlarmSeverity.warning, timestamp: _now.subtract(const Duration(minutes: 41))),
        Alarm(id: 'a4', machineName: 'Labeler L9', line: 'Line 3 · Packaging', message: 'Reject rate 1.7% — above 1.5% target', severity: AlarmSeverity.warning, timestamp: _now.subtract(const Duration(hours: 1, minutes: 3))),
        Alarm(id: 'a5', machineName: 'Dryer / Feeder D7', line: 'Line 2 · Injection Molding', message: 'Preventive maintenance started', severity: AlarmSeverity.info, timestamp: _now.subtract(const Duration(hours: 1, minutes: 30)), acknowledged: true),
        Alarm(id: 'a6', machineName: 'CNC Mill A1', line: 'Line 1 · Assembly', message: 'Tool change completed', severity: AlarmSeverity.info, timestamp: _now.subtract(const Duration(hours: 2, minutes: 10)), acknowledged: true),
        Alarm(id: 'a7', machineName: 'Filler F8', line: 'Line 3 · Packaging', message: 'Vibration spike 1.0 mm/s — within range', severity: AlarmSeverity.info, timestamp: _now.subtract(const Duration(hours: 3)), acknowledged: true),
      ];

  static List<Alarm> alarmsForLine(String line) =>
      alarms.where((a) => a.line == line).toList();

  // ── Maintenance ──────────────────────────────────────────────────────────
  static List<MaintenanceTask> get maintenanceTasks => [
        MaintenanceTask(id: 't1', machineName: 'Dryer / Feeder D7', line: 'Line 2 · Injection Molding', type: MaintenanceType.preventive, status: MaintenanceStatus.overdue, assignee: 'Team Mekanik A', dueDate: _now.subtract(const Duration(days: 1)), notes: 'Desiccant replacement + filter clean'),
        MaintenanceTask(id: 't2', machineName: 'Injection Molder IM2', line: 'Line 2 · Injection Molding', type: MaintenanceType.corrective, status: MaintenanceStatus.dueSoon, assignee: 'Team Hidraulik', dueDate: _now.add(const Duration(hours: 4)), notes: 'Investigate hydraulic pressure drop'),
        MaintenanceTask(id: 't3', machineName: 'Assembly Press P3', line: 'Line 1 · Assembly', type: MaintenanceType.inspection, status: MaintenanceStatus.dueSoon, assignee: 'Fadhil', dueDate: _now.add(const Duration(days: 1)), notes: 'Quarterly safety inspection'),
        MaintenanceTask(id: 't4', machineName: 'CNC Mill A1', line: 'Line 1 · Assembly', type: MaintenanceType.calibration, status: MaintenanceStatus.scheduled, assignee: 'Metrologi', dueDate: _now.add(const Duration(days: 5)), notes: 'Spindle runout calibration'),
        MaintenanceTask(id: 't5', machineName: 'Filler F8', line: 'Line 3 · Packaging', type: MaintenanceType.preventive, status: MaintenanceStatus.scheduled, assignee: 'Team Mekanik B', dueDate: _now.add(const Duration(days: 8)), notes: 'Nozzle seal replacement'),
        MaintenanceTask(id: 't6', machineName: 'Robotic Arm R2', line: 'Line 1 · Assembly', type: MaintenanceType.preventive, status: MaintenanceStatus.done, assignee: 'Team Robotik', dueDate: _now.subtract(const Duration(days: 3)), notes: 'Axis lubrication — completed'),
      ];

  // ── Shift reports ──────────────────────────────────────────────────────
  static List<ShiftReport> get shiftReports => [
        ShiftReport(id: 's1', shift: 'Shift A · 06:00–14:00', date: _now, line: 'All lines', output: 14280, target: 18000, oee: 78.4, availability: 90.2, performance: 88.6, quality: 98.1, downtimeMinutes: 430, rejects: 214, supervisor: 'Hafiz Rahman'),
        ShiftReport(id: 's2', shift: 'Shift C · 22:00–06:00', date: _now.subtract(const Duration(days: 1)), line: 'All lines', output: 16120, target: 18000, oee: 82.1, availability: 92.0, performance: 90.4, quality: 98.7, downtimeMinutes: 288, rejects: 176, supervisor: 'Suresh Kumar'),
        ShiftReport(id: 's3', shift: 'Shift B · 14:00–22:00', date: _now.subtract(const Duration(days: 1)), line: 'All lines', output: 15540, target: 18000, oee: 80.3, availability: 91.1, performance: 89.2, quality: 98.9, downtimeMinutes: 322, rejects: 190, supervisor: 'Wei Ling'),
        ShiftReport(id: 's4', shift: 'Shift A · 06:00–14:00', date: _now.subtract(const Duration(days: 1)), line: 'All lines', output: 15980, target: 18000, oee: 81.4, availability: 91.6, performance: 89.9, quality: 98.8, downtimeMinutes: 300, rejects: 168, supervisor: 'Hafiz Rahman'),
      ];
}
