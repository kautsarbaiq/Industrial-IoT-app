enum AlarmSeverity { critical, warning, info }

extension AlarmSeverityX on AlarmSeverity {
  String get label {
    switch (this) {
      case AlarmSeverity.critical:
        return 'Critical';
      case AlarmSeverity.warning:
        return 'Warning';
      case AlarmSeverity.info:
        return 'Info';
    }
  }
}

/// An event raised by a machine / line (fault, threshold breach, notice).
class Alarm {
  final String id;
  final String machineName;
  final String line;
  final String message;
  final AlarmSeverity severity;
  final DateTime timestamp;
  final bool acknowledged;

  const Alarm({
    required this.id,
    required this.machineName,
    required this.line,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.acknowledged = false,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
        id: json['id'] as String,
        machineName: json['machineName'] as String,
        line: json['line'] as String,
        message: json['message'] as String,
        severity: AlarmSeverity.values.firstWhere(
          (s) => s.name == json['severity'],
          orElse: () => AlarmSeverity.info,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        acknowledged: json['acknowledged'] as bool? ?? false,
      );
}
