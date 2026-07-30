/// Operational state of a machine on the shop floor.
enum MachineStatus { running, idle, down, maintenance, offline }

extension MachineStatusX on MachineStatus {
  String get label {
    switch (this) {
      case MachineStatus.running:
        return 'Running';
      case MachineStatus.idle:
        return 'Idle';
      case MachineStatus.down:
        return 'Down';
      case MachineStatus.maintenance:
        return 'Maintenance';
      case MachineStatus.offline:
        return 'Offline';
    }
  }

  static MachineStatus fromString(String value) {
    return MachineStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => MachineStatus.offline,
    );
  }
}

/// A single asset on a production line, with its live telemetry snapshot.
class Machine {
  final String id;
  final String name;
  final String code;
  final String line;
  final String type;
  final MachineStatus status;

  // OEE factors (0..100)
  final double oee;
  final double availability;
  final double performance;
  final double quality;

  // Live telemetry
  final double temperature; // °C
  final double vibration; // mm/s
  final double speed; // rpm
  final double power; // kW
  final int throughput; // units / hour (actual)
  final int targetThroughput; // units / hour (target)

  final String currentJob; // product / order in progress
  final double uptimePct; // rolling uptime for the shift
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;

  /// 24-point rolling OEE history (oldest → newest) for sparklines.
  final List<double> oeeTrend;

  const Machine({
    required this.id,
    required this.name,
    required this.code,
    required this.line,
    required this.type,
    required this.status,
    required this.oee,
    required this.availability,
    required this.performance,
    required this.quality,
    required this.temperature,
    required this.vibration,
    required this.speed,
    required this.power,
    required this.throughput,
    required this.targetThroughput,
    required this.currentJob,
    required this.uptimePct,
    required this.lastMaintenance,
    required this.nextMaintenance,
    this.oeeTrend = const [],
  });

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        line: json['line'] as String,
        type: json['type'] as String,
        status: MachineStatusX.fromString(json['status'] as String? ?? 'offline'),
        oee: (json['oee'] as num).toDouble(),
        availability: (json['availability'] as num).toDouble(),
        performance: (json['performance'] as num).toDouble(),
        quality: (json['quality'] as num).toDouble(),
        temperature: (json['temperature'] as num).toDouble(),
        vibration: (json['vibration'] as num).toDouble(),
        speed: (json['speed'] as num).toDouble(),
        power: (json['power'] as num).toDouble(),
        throughput: (json['throughput'] as num).toInt(),
        targetThroughput: (json['targetThroughput'] as num).toInt(),
        currentJob: json['currentJob'] as String? ?? '—',
        uptimePct: (json['uptimePct'] as num).toDouble(),
        lastMaintenance: DateTime.parse(json['lastMaintenance'] as String),
        nextMaintenance: DateTime.parse(json['nextMaintenance'] as String),
        oeeTrend: (json['oeeTrend'] as List?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            const [],
      );
}
