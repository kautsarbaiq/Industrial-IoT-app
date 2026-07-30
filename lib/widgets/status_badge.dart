import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/machine.dart';
import '../models/alarm.dart';
import '../models/maintenance_task.dart';
import '../models/production_order.dart';

/// Colour helpers keep status → colour mapping in one place.
Color machineStatusColor(MachineStatus s) {
  switch (s) {
    case MachineStatus.running:
      return AppColors.running;
    case MachineStatus.idle:
      return AppColors.idle;
    case MachineStatus.down:
      return AppColors.down;
    case MachineStatus.maintenance:
      return AppColors.maintenance;
    case MachineStatus.offline:
      return AppColors.offline;
  }
}

Color alarmSeverityColor(AlarmSeverity s) {
  switch (s) {
    case AlarmSeverity.critical:
      return AppColors.red;
    case AlarmSeverity.warning:
      return AppColors.amber;
    case AlarmSeverity.info:
      return AppColors.cyan;
  }
}

Color maintenanceStatusColor(MaintenanceStatus s) {
  switch (s) {
    case MaintenanceStatus.overdue:
      return AppColors.red;
    case MaintenanceStatus.dueSoon:
      return AppColors.amber;
    case MaintenanceStatus.scheduled:
      return AppColors.cyan;
    case MaintenanceStatus.done:
      return AppColors.green;
  }
}

Color orderStatusColor(OrderStatus s) {
  switch (s) {
    case OrderStatus.inProgress:
      return AppColors.cyan;
    case OrderStatus.completed:
      return AppColors.green;
    case OrderStatus.queued:
      return AppColors.slate400;
    case OrderStatus.onHold:
      return AppColors.amber;
  }
}

/// A small coloured pill with an optional leading dot.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;
  final bool pulse;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.dot = true,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot) ...[
          pulse
              ? _PulseDot(color: color)
              : Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final v = _c.value;
        return SizedBox(
          width: 10,
          height: 10,
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 10 * (0.6 + v * 0.8),
              height: 10 * (0.6 + v * 0.8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity((1 - v) * 0.5),
              ),
            ),
            Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: widget.color),
            ),
          ]),
        );
      },
    );
  }
}
