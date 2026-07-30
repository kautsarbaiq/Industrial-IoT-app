/// A downtime bucket used for Pareto analysis.
class DowntimeReason {
  final String reason;
  final int minutes;
  const DowntimeReason(this.reason, this.minutes);
}

/// A defect category and its count for quality breakdowns.
class DefectCategory {
  final String name;
  final int count;
  const DefectCategory(this.name, this.count);
}

/// A summarised production shift, used on the Reports screen.
class ShiftReport {
  final String id;
  final String shift; // e.g. "Shift A (06:00–14:00)"
  final DateTime date;
  final String line;
  final int output;
  final int target;
  final double oee;
  final double availability;
  final double performance;
  final double quality;
  final int downtimeMinutes;
  final int rejects;
  final String supervisor;

  const ShiftReport({
    required this.id,
    required this.shift,
    required this.date,
    required this.line,
    required this.output,
    required this.target,
    required this.oee,
    required this.availability,
    required this.performance,
    required this.quality,
    required this.downtimeMinutes,
    required this.rejects,
    required this.supervisor,
  });

  double get attainment => target == 0 ? 0 : (output / target) * 100;

  factory ShiftReport.fromJson(Map<String, dynamic> json) => ShiftReport(
        id: json['id'] as String,
        shift: json['shift'] as String,
        date: DateTime.parse(json['date'] as String),
        line: json['line'] as String,
        output: (json['output'] as num).toInt(),
        target: (json['target'] as num).toInt(),
        oee: (json['oee'] as num).toDouble(),
        availability: (json['availability'] as num).toDouble(),
        performance: (json['performance'] as num).toDouble(),
        quality: (json['quality'] as num).toDouble(),
        downtimeMinutes: (json['downtimeMinutes'] as num).toInt(),
        rejects: (json['rejects'] as num).toInt(),
        supervisor: json['supervisor'] as String,
      );
}
