import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/maintenance_task.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = MockDataService.maintenanceTasks;
    final overdue =
        tasks.where((t) => t.status == MaintenanceStatus.overdue).length;
    final dueSoon =
        tasks.where((t) => t.status == MaintenanceStatus.dueSoon).length;
    final scheduled =
        tasks.where((t) => t.status == MaintenanceStatus.scheduled).length;

    // Sort by urgency then date.
    const order = {
      MaintenanceStatus.overdue: 0,
      MaintenanceStatus.dueSoon: 1,
      MaintenanceStatus.scheduled: 2,
      MaintenanceStatus.done: 3,
    };
    final sorted = [...tasks]
      ..sort((a, b) {
        final c = order[a.status]!.compareTo(order[b.status]!);
        return c != 0 ? c : a.dueDate.compareTo(b.dueDate);
      });

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenTitle(
                title: 'Maintenance',
                subtitle: 'Preventive & corrective work orders'),
            const SizedBox(height: 16),
            Row(children: [
              _summary(context, 'Overdue', overdue, AppColors.red),
              const SizedBox(width: 10),
              _summary(context, 'Due soon', dueSoon, AppColors.amber),
              const SizedBox(width: 10),
              _summary(context, 'Scheduled', scheduled, AppColors.cyan),
            ]),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Work orders'),
            for (final t in sorted) _taskCard(context, t),
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context, String label, int count, Color color) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(children: [
          Text('$count',
              style: GoogleFonts.poppins(
                  color: color, fontSize: 26, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _taskCard(BuildContext context, MaintenanceTask t) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = maintenanceStatusColor(t.status);
    final fmt = DateFormat('d MMM yyyy');
    final done = t.status == MaintenanceStatus.done;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(t.type), color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.machineName,
                      style: GoogleFonts.poppins(
                          color: onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text('${t.type.label} · ${t.line}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
                ],
              ),
            ),
            StatusBadge(label: t.status.label, color: color, dot: false),
          ]),
          if (t.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(t.notes,
                style: GoogleFonts.poppins(color: onSurface, fontSize: 12.5)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.person_outline_rounded, color: onVar, size: 15),
            const SizedBox(width: 4),
            Text(t.assignee,
                style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
            const Spacer(),
            Icon(done ? Icons.check_rounded : Icons.event_outlined,
                color: done ? AppColors.green : color, size: 15),
            const SizedBox(width: 4),
            Text(done ? 'Completed' : fmt.format(t.dueDate),
                style: GoogleFonts.poppins(
                    color: done ? AppColors.green : color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  IconData _iconFor(MaintenanceType t) {
    switch (t) {
      case MaintenanceType.preventive:
        return Icons.build_rounded;
      case MaintenanceType.corrective:
        return Icons.handyman_rounded;
      case MaintenanceType.inspection:
        return Icons.search_rounded;
      case MaintenanceType.calibration:
        return Icons.tune_rounded;
    }
  }
}
