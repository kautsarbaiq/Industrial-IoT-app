enum MaintenanceType { preventive, corrective, inspection, calibration }

enum MaintenanceStatus { scheduled, dueSoon, overdue, done }

extension MaintenanceTypeX on MaintenanceType {
  String get label {
    switch (this) {
      case MaintenanceType.preventive:
        return 'Preventive';
      case MaintenanceType.corrective:
        return 'Corrective';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.calibration:
        return 'Calibration';
    }
  }
}

extension MaintenanceStatusX on MaintenanceStatus {
  String get label {
    switch (this) {
      case MaintenanceStatus.scheduled:
        return 'Scheduled';
      case MaintenanceStatus.dueSoon:
        return 'Due Soon';
      case MaintenanceStatus.overdue:
        return 'Overdue';
      case MaintenanceStatus.done:
        return 'Completed';
    }
  }
}

/// A maintenance work item against a machine.
class MaintenanceTask {
  final String id;
  final String machineName;
  final String line;
  final MaintenanceType type;
  final MaintenanceStatus status;
  final String assignee;
  final DateTime dueDate;
  final String notes;

  const MaintenanceTask({
    required this.id,
    required this.machineName,
    required this.line,
    required this.type,
    required this.status,
    required this.assignee,
    required this.dueDate,
    this.notes = '',
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) => MaintenanceTask(
        id: json['id'] as String,
        machineName: json['machineName'] as String,
        line: json['line'] as String,
        type: MaintenanceType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => MaintenanceType.preventive,
        ),
        status: MaintenanceStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => MaintenanceStatus.scheduled,
        ),
        assignee: json['assignee'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        notes: json['notes'] as String? ?? '',
      );
}
